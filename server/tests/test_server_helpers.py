"""Targeted tests for helper methods inside core.server.Server."""

import asyncio
from contextlib import contextmanager

import pytest


from types import SimpleNamespace

import server.core.server as server_module
from server.core.server import Server
from server.core.users.preferences import UserPreferences


@contextmanager
def fast_disconnect_grace():
    """Short-circuit the 2-second mobile-reconnect grace period inside
    ``_delayed_disconnect_cleanup`` so disconnect tests complete promptly.
    Only patches the ``asyncio.sleep`` reference inside core.server."""
    original = server_module.asyncio.sleep

    async def _no_sleep(_seconds):
        return None

    server_module.asyncio.sleep = _no_sleep
    try:
        yield
    finally:
        server_module.asyncio.sleep = original


async def _run_disconnect_with_cleanup(server, client, username):
    """Call _on_client_disconnect and await the deferred cleanup task."""
    await server._on_client_disconnect(client)
    task = server._pending_disconnects.get(username)
    if task:
        await task


class DummyNetworkUser:
    def __init__(self, approved=True, locale="en", username=""):
        self.approved = approved
        self.locale = locale
        self.username = username
        self.spoken = []
        self.sounds = []
        self._queue = []
        # Mirrors the real NetworkUser.preferences attribute. Tests that
        # exercise filtering paths (chat, table_create, menus) can mutate
        # this directly via ``user.preferences.add_ignored("…")``.
        self.preferences = UserPreferences()
        # Server._on_client_disconnect now guards against stale-disconnect
        # races by checking ``user.connection is not client``. Tests set this
        # after constructing the client (see test_on_client_disconnect_*).
        self.connection = None

    def speak_l(self, message_id, **kwargs):
        self.spoken.append((message_id, kwargs))

    def play_sound(self, sound):
        self.sounds.append(sound)

    def play_music(self, name, looping=True):
        # Recorded for completeness; new menu tests don't assert on it.
        self.sounds.append(("music", name))

    def queue(self, message):
        self._queue.append(message)

    def get_queued_messages(self):
        messages = list(self._queue)
        self._queue.clear()
        return messages


class DummyClient:
    def __init__(self):
        self.sent = []

    async def send(self, payload):
        self.sent.append(payload)


class DummyWebSocketServer:
    def __init__(self, mapping):
        self.mapping = mapping

    def get_client_by_username(self, username):
        return self.mapping.get(username)


@pytest.fixture
def server(tmp_path):
    db_path = tmp_path / "test.db"
    srv = Server(db_path=str(db_path), locales_dir="locales", config_path=tmp_path / "missing.toml")
    return srv


@pytest.mark.asyncio
async def test_flush_user_messages_sends_only_to_connected_clients(server):
    alice = DummyNetworkUser()
    bob = DummyNetworkUser()
    alice.queue({"type": "ping"})
    bob.queue({"type": "pong"})
    server._users = {"alice": alice, "bob": bob}

    alice_client = DummyClient()
    ws = DummyWebSocketServer({"alice": alice_client})
    server._ws_server = ws

    server._flush_user_messages()
    await asyncio.sleep(0)  # allow scheduled tasks to run

    assert alice_client.sent == [{"type": "ping"}]
    assert bob.get_queued_messages() == []  # queue already drained


def test_broadcast_helpers_respect_approval(server):
    approved = DummyNetworkUser(approved=True)
    unapproved = DummyNetworkUser(approved=False)
    server._users = {"ok": approved, "pending": unapproved}

    server._broadcast_presence_l("user-online", "Bot", "online.ogg")
    server._broadcast_admin_announcement("Admin")
    server._broadcast_server_owner_announcement("Owner")
    server._user_states = {"ok": {}, "pending": {}}
    server._broadcast_table_created("Host", "farkle")

    # Only approved user should receive notifications
    assert len(approved.spoken) == 4
    assert approved.sounds == ["online.ogg", "table_created.ogg"]
    assert unapproved.spoken == []
    assert unapproved.sounds == []


def test_on_client_disconnect_broadcasts_only_for_approved(server):
    approved = DummyNetworkUser(approved=True)
    banned = DummyNetworkUser(approved=True)
    banned.trust_level = type("T", (), {"value": 0})()
    approved.trust_level = type("T", (), {"value": 2})()
    server._users = {"alice": approved, "bob": banned}
    server._user_states = {"alice": {}, "bob": {}}

    client = SimpleNamespace(username="alice", address="addr")
    approved.connection = client

    server._on_client_disconnect = Server._on_client_disconnect.__get__(server, Server)

    with fast_disconnect_grace():
        asyncio.run(_run_disconnect_with_cleanup(server, client, "alice"))
    assert server._users == {"bob": banned}
    assert server._user_states == {"bob": {}}
    assert approved.sounds[-1] == "offlineadmin.ogg"


def test_on_client_disconnect_keeps_members_when_not_last(server):
    user = DummyNetworkUser(approved=True)
    user.uuid = "user-1"
    user.trust_level = type("T", (), {"value": 1})()
    server._users = {"alice": user}
    server._user_states = {"alice": {}}

    class DummyGame:
        def __init__(self, player_id):
            self.player_id = player_id
            self.called = False

        def get_player_by_id(self, player_id):
            return SimpleNamespace(id=player_id) if player_id == self.player_id else None

        def _perform_leave_game(self, player):
            self.called = True

    members = [SimpleNamespace(username="alice"), SimpleNamespace(username="bob")]
    table = SimpleNamespace(
        members=members,
        game=DummyGame(user.uuid),
        remove_member=lambda username: members.__setitem__(
            slice(None), [m for m in members if m.username != username]
        ),
    )
    server._tables = SimpleNamespace(find_user_table=lambda username: table)

    client = SimpleNamespace(username="alice", address="addr")
    user.connection = client
    server._on_client_disconnect = Server._on_client_disconnect.__get__(server, Server)
    with fast_disconnect_grace():
        asyncio.run(_run_disconnect_with_cleanup(server, client, "alice"))

    assert table.game.called
    assert [m.username for m in members] == ["alice", "bob"]


def test_on_client_disconnect_removes_last_member(server):
    user = DummyNetworkUser(approved=True)
    user.uuid = "user-1"
    user.trust_level = type("T", (), {"value": 1})()
    server._users = {"alice": user}
    server._user_states = {"alice": {}}

    class DummyGame:
        def __init__(self, player_id):
            self.player_id = player_id
            self.called = False

        def get_player_by_id(self, player_id):
            return SimpleNamespace(id=player_id) if player_id == self.player_id else None

        def _perform_leave_game(self, player):
            self.called = True

    members = [SimpleNamespace(username="alice")]
    table = SimpleNamespace(
        members=members,
        game=DummyGame(user.uuid),
        remove_member=lambda username: members.__setitem__(
            slice(None), [m for m in members if m.username != username]
        ),
    )
    server._tables = SimpleNamespace(find_user_table=lambda username: table)

    client = SimpleNamespace(username="alice", address="addr")
    user.connection = client
    server._on_client_disconnect = Server._on_client_disconnect.__get__(server, Server)
    with fast_disconnect_grace():
        asyncio.run(_run_disconnect_with_cleanup(server, client, "alice"))

    assert table.game.called
    assert members == []


def test_send_game_list_includes_all_games(server):
    async def capture_send(payload):
        capture_send.sent.append(payload)

    capture_send.sent = []
    client = SimpleNamespace(send=capture_send)

    asyncio.run(server._send_game_list(client))
    assert capture_send.sent
    games_payload = capture_send.sent[-1]
    assert games_payload["type"] == "update_options_lists"
    assert "games" in games_payload and games_payload["games"]


# ---------------------------------------------------------------------------
# Ignore-list filtering
# ---------------------------------------------------------------------------


def _make_user_with_connection(username, approved=True):
    user = DummyNetworkUser(approved=approved, username=username)
    captured: list = []

    async def _send(payload):
        captured.append(payload)

    user.connection = SimpleNamespace(send=_send)
    user.connection.sent = captured  # alias for inspection in tests
    return user


def test_broadcast_table_created_skips_ignored_recipients(server):
    host = _make_user_with_connection("Bob")
    ignorer = _make_user_with_connection("Alice")
    ignorer.preferences.add_ignored("Bob")
    bystander = _make_user_with_connection("Carol")
    server._users = {"Bob": host, "Alice": ignorer, "Carol": bystander}
    server._user_states = {"Bob": {}, "Alice": {}, "Carol": {}}

    server._broadcast_table_created("Bob", "farkle")

    # Ignorer should hear nothing about the table; others should.
    assert ignorer.spoken == []
    assert any(msg_id == "table-created" for msg_id, _ in bystander.spoken)


def test_handle_chat_local_filters_ignored_sender_at_table(server):
    sender = _make_user_with_connection("Bob")
    receiver = _make_user_with_connection("Alice")
    receiver.preferences.add_ignored("Bob")
    server._users = {"Bob": sender, "Alice": receiver}
    table = SimpleNamespace(
        members=[SimpleNamespace(username="Bob"), SimpleNamespace(username="Alice")]
    )
    server._tables = SimpleNamespace(find_user_table=lambda u: table)

    client = SimpleNamespace(username="Bob", address="addr")
    asyncio.run(server._handle_chat(client, {"convo": "local", "message": "hi"}))

    # The receiver had Bob ignored — should not receive Bob's chat.
    assert receiver.connection.sent == []
    # Sender's own connection still echoes (server sends to every member,
    # including the sender, who never ignores themselves).
    assert sender.connection.sent
    assert sender.connection.sent[0]["sender"] == "Bob"


def test_handle_chat_global_filters_ignored_sender(server):
    sender = _make_user_with_connection("Bob")
    receiver = _make_user_with_connection("Alice")
    receiver.preferences.add_ignored("bob")  # case-insensitive
    server._users = {"Bob": sender, "Alice": receiver}
    server._tables = SimpleNamespace(find_user_table=lambda u: None)

    client = SimpleNamespace(username="Bob", address="addr")
    asyncio.run(server._handle_chat(client, {"convo": "global", "message": "hello"}))

    assert receiver.connection.sent == []
    assert sender.connection.sent  # the sender still sees their own message


def test_ignore_handler_persists_and_pushes_list(server, tmp_path):
    user = _make_user_with_connection("Alice")
    user.preferences = UserPreferences()
    server._users = {"Alice": user}

    # Stub out the DB write so we don't need a real schema for this test.
    saved = {}

    def fake_update(username, prefs_json):
        saved[username] = prefs_json

    server._db = SimpleNamespace(update_user_preferences=fake_update)
    server._send_preferences = lambda *_args, **_kwargs: asyncio.sleep(0)

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": "Bob"}))

    assert "bob" in user.preferences.ignored_users
    assert "Alice" in saved
    # The server should have pushed an ignored_list snapshot back.
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed
    assert pushed[-1]["usernames"] == ["bob"]

    # Unignore round-trips identically.
    asyncio.run(server._handle_unignore_user(client, {"username": "BOB"}))
    assert user.preferences.ignored_users == []
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed[-1]["usernames"] == []


def test_self_ignore_is_rejected(server):
    user = _make_user_with_connection("Alice")
    server._users = {"Alice": user}
    server._db = SimpleNamespace(update_user_preferences=lambda *a, **k: None)
    server._send_preferences = lambda *_args, **_kwargs: asyncio.sleep(0)

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": "alice"}))

    # Self-ignore is a no-op: the list stays empty even though the server
    # still echoes the (empty) snapshot back to the client so the UI
    # doesn't get stuck.
    assert user.preferences.ignored_users == []


# ---------------------------------------------------------------------------
# Ignore-list filtering — additional edge cases
# ---------------------------------------------------------------------------


def test_handle_chat_local_lobby_filters_ignored_sender(server):
    """Local chat *outside* a table (lobby fan-out) also drops ignored senders."""
    sender = _make_user_with_connection("Bob")
    receiver = _make_user_with_connection("Alice")
    receiver.preferences.add_ignored("Bob")
    server._users = {"Bob": sender, "Alice": receiver}
    server._tables = SimpleNamespace(find_user_table=lambda u: None)

    client = SimpleNamespace(username="Bob", address="addr")
    asyncio.run(server._handle_chat(client, {"convo": "local", "message": "hi"}))

    assert receiver.connection.sent == []
    assert sender.connection.sent  # sender still hears their own echo


def test_handle_chat_global_does_not_filter_unrelated_users(server):
    """Sanity: a recipient who hasn't ignored the sender still receives the message."""
    sender = _make_user_with_connection("Bob")
    listener = _make_user_with_connection("Alice")  # no ignore
    server._users = {"Bob": sender, "Alice": listener}
    server._tables = SimpleNamespace(find_user_table=lambda u: None)

    client = SimpleNamespace(username="Bob", address="addr")
    asyncio.run(server._handle_chat(client, {"convo": "global", "message": "hi"}))

    assert listener.connection.sent
    assert listener.connection.sent[0]["sender"] == "Bob"


def test_tables_menu_filters_ignored_host_and_adds_meta(server):
    """_show_tables_menu hides tables hosted by ignored users and stamps
    meta={'host': …} on the rest so clients can offer per-row actions."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    captured: list = []
    user.show_menu = lambda menu_id, items, **kw: captured.append((menu_id, items))

    ignored_table = SimpleNamespace(
        host="Bob", table_id="t1", game_type="farkle",
        members=[SimpleNamespace(username="Bob")],
    )
    visible_table = SimpleNamespace(
        host="Carol", table_id="t2", game_type="farkle",
        members=[SimpleNamespace(username="Carol")],
    )
    server._tables = SimpleNamespace(
        get_waiting_tables=lambda game_type: [ignored_table, visible_table]
    )

    server._show_tables_menu(user, "farkle")
    assert captured
    items = captured[0][1]
    table_items = [i for i in items if i.id and i.id.startswith("table_")]
    assert [i.id for i in table_items] == ["table_t2"]
    assert table_items[0].meta == {"host": "Carol"}


def test_active_tables_menu_falls_back_when_all_hosts_ignored(server):
    """When every active table is hosted by an ignored user, the menu
    speaks the no-tables fallback instead of rendering an empty list."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    bob_table = SimpleNamespace(
        host="Bob", table_id="t1", game_type="farkle",
        members=[SimpleNamespace(username="Bob")],
    )
    server._tables = SimpleNamespace(get_waiting_tables=lambda: [bob_table])

    menu_calls: list = []
    user.show_menu = lambda *a, **kw: menu_calls.append((a, kw))

    result = server._show_active_tables_menu(user)
    assert result is False
    assert any(msg_id == "no-active-tables" for msg_id, _ in user.spoken)
    assert menu_calls == []  # no empty menu emitted


def test_active_tables_menu_shows_unignored_tables(server):
    """Mixed case: at least one un-ignored table → menu renders normally."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    bob_table = SimpleNamespace(
        host="Bob", table_id="t1", game_type="farkle",
        members=[SimpleNamespace(username="Bob")],
    )
    carol_table = SimpleNamespace(
        host="Carol", table_id="t2", game_type="farkle",
        members=[SimpleNamespace(username="Carol")],
    )
    server._tables = SimpleNamespace(get_waiting_tables=lambda: [bob_table, carol_table])

    captured: list = []
    user.show_menu = lambda menu_id, items, **kw: captured.append(items)

    result = server._show_active_tables_menu(user)
    assert result is True
    items = captured[0]
    table_items = [i for i in items if i.id and i.id.startswith("table_")]
    assert [i.id for i in table_items] == ["table_t2"]
    assert table_items[0].meta == {"host": "Carol"}


def test_collect_online_users_entries_skips_ignored(server):
    """_collect_online_users_entries hides ignored users from the requester."""
    alice = _make_user_with_connection("Alice")
    alice.preferences.add_ignored("Bob")
    bob = _make_user_with_connection("Bob")
    carol = _make_user_with_connection("Carol")
    server._users = {"Alice": alice, "Bob": bob, "Carol": carol}
    server._tables = SimpleNamespace(find_user_table=lambda u: None)

    usernames = [u for u, _ in server._collect_online_users_entries(alice)]
    assert "Bob" not in usernames
    assert {"Alice", "Carol"} <= set(usernames)


def test_online_users_menu_tags_items_with_username_meta(server):
    """The online-users menu carries meta={'username': …} on each row so
    clients can pin per-user actions (ignore/unignore) without parsing text."""
    alice = _make_user_with_connection("Alice")
    bob = _make_user_with_connection("Bob")
    server._users = {"Alice": alice, "Bob": bob}
    server._tables = SimpleNamespace(find_user_table=lambda u: None)

    captured: list = []
    alice.show_menu = lambda menu_id, items, **kw: captured.append(items)

    server._show_online_users_menu(alice)
    assert captured
    items = captured[0]
    user_metas = [i.meta for i in items if i.meta and "username" in i.meta]
    assert {m["username"] for m in user_metas} == {"Alice", "Bob"}


def test_handle_ignore_user_rejects_whitespace_target(server):
    """Whitespace-only target is an early-return: no save, no push."""
    user = _make_user_with_connection("Alice")
    server._users = {"Alice": user}

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": "   "}))

    assert user.preferences.ignored_users == []
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed == []


def test_handle_ignore_user_rejects_non_string_target(server):
    """Non-string username is dropped silently — defensive against bad clients."""
    user = _make_user_with_connection("Alice")
    server._users = {"Alice": user}

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": 42}))

    assert user.preferences.ignored_users == []


def test_handle_ignore_user_unknown_requester_is_noop(server):
    """A packet whose client.username is no longer in _users (race / disconnect)
    returns silently; nothing crashes."""
    server._users = {}
    client = SimpleNamespace(username="ghost", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": "Bob"}))
    # Reaching this line without an exception is the assertion.


def test_handle_ignore_user_duplicate_is_idempotent_but_still_syncs(server):
    """Re-ignoring an already-ignored user does NOT touch the DB but still
    pushes the current snapshot — keeps a slow/duplicate client in sync."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    saves: list = []
    server._db = SimpleNamespace(
        update_user_preferences=lambda u, j: saves.append((u, j))
    )
    server._send_preferences = lambda *_a, **_kw: asyncio.sleep(0)

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_ignore_user(client, {"username": "Bob"}))

    assert saves == []  # no redundant DB write
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed and pushed[-1]["usernames"] == ["bob"]


def test_handle_unignore_user_missing_target_still_syncs(server):
    """Un-ignoring a user who isn't on the list: no DB write, but still
    push so the client's cached copy can converge if it had drifted."""
    user = _make_user_with_connection("Alice")
    server._users = {"Alice": user}

    saves: list = []
    server._db = SimpleNamespace(
        update_user_preferences=lambda u, j: saves.append((u, j))
    )
    server._send_preferences = lambda *_a, **_kw: asyncio.sleep(0)

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_unignore_user(client, {"username": "Bob"}))

    assert saves == []
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed and pushed[-1]["usernames"] == []


def test_handle_unignore_user_rejects_whitespace(server):
    """Whitespace-only username on unignore is a no-op (no push either)."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_unignore_user(client, {"username": "   "}))

    # Existing entry untouched.
    assert user.preferences.ignored_users == ["bob"]
    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed == []


def test_handle_list_ignored_pushes_current_snapshot(server):
    """list_ignored re-sends the canonical sorted lowercase snapshot."""
    user = _make_user_with_connection("Alice")
    user.preferences.add_ignored("Charlie")
    user.preferences.add_ignored("Bob")
    server._users = {"Alice": user}

    client = SimpleNamespace(username="Alice", address="addr")
    asyncio.run(server._handle_list_ignored(client))

    pushed = [p for p in user.connection.sent if p.get("type") == "ignored_list"]
    assert pushed
    assert pushed[-1]["usernames"] == ["bob", "charlie"]


def test_handle_list_ignored_for_unknown_requester_is_noop(server):
    server._users = {}
    client = SimpleNamespace(username="ghost", address="addr")
    asyncio.run(server._handle_list_ignored(client))
    # No exception = pass.


# ---------------------------------------------------------------------------
# MenuItem.meta serialization (added to support ignore-from-menu actions)
# ---------------------------------------------------------------------------


def test_menu_item_to_dict_includes_meta_when_set():
    from server.core.users.base import MenuItem
    item = MenuItem(text="Bob (online)", id="online_user", meta={"username": "Bob"})
    assert item.to_dict() == {
        "text": "Bob (online)",
        "id": "online_user",
        "meta": {"username": "Bob"},
    }


def test_menu_item_to_dict_omits_empty_meta():
    """An empty meta dict shouldn't bloat the wire payload."""
    from server.core.users.base import MenuItem
    item = MenuItem(text="x", id="x", meta={})
    out = item.to_dict()
    assert out == {"text": "x", "id": "x"}
    assert "meta" not in out


def test_menu_item_to_dict_returns_plain_string_with_no_attrs():
    from server.core.users.base import MenuItem
    assert MenuItem(text="plain").to_dict() == "plain"
