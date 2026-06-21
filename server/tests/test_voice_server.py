"""Server-integration tests for voice chat (join / presence / leave / table hooks).

Drives the VoiceMixin methods on a bare Server with a fake DB + recording
connections. The standalone token/service tests live in test_voice_service.py;
the mute primitive in test_mutes.py.
"""

import asyncio

import pytest

from server.auth.voice_rate_limit import VoiceRateLimiter
from server.core.server import Server
from server.core.tables.manager import TableManager
from server.core.users.test_user import MockUser
from server.persistence.database import MuteRecord
from server.voice import VoiceService


class RecordingConnection:
    def __init__(self):
        self.sent: list[dict] = []
        self.username: str | None = None

    async def send(self, packet: dict) -> None:
        self.sent.append(packet)


class DummyDb:
    """Minimal DB exposing only what the voice handlers touch."""

    def __init__(self):
        self._mute: MuteRecord | None = None

    def set_mute(self, record: MuteRecord) -> None:
        self._mute = record

    def get_active_mute(self, username: str, now: int) -> MuteRecord | None:
        m = self._mute
        if m and m.username.lower() == username.lower() and (m.expires_at is None or m.expires_at > now):
            return m
        return None


def _make_server() -> Server:
    server = Server.__new__(Server)
    server._tables = TableManager()
    server._tables._server = server
    server._db = DummyDb()
    server._users = {}
    server._user_states = {}
    server._voice = VoiceService(
        enabled=True,
        public_url="wss://voice.example.com",
        api_key="k",
        api_secret="s",
        room_prefix="pp",
        token_ttl_seconds=300,
    )
    server._voice_context_resolvers = {"table": server._resolve_table_voice_context}
    server._voice_presence_by_user = {}
    server._voice_join_authorizations_by_user = {}
    server._voice_rate_limiter = VoiceRateLimiter()
    return server


def _add_user(server: Server, name: str) -> MockUser:
    user = MockUser(name, uuid=f"uuid-{name.lower()}")
    user.connection = RecordingConnection()
    server._users[name] = user
    return user


# --------------------------------------------------------------------- join


@pytest.mark.asyncio
async def test_authorizes_voice_for_current_table_member():
    server = _make_server()
    alice = _add_user(server, "Alice")
    table = server._tables.create_table("pig", "Alice", alice)
    client = RecordingConnection()
    client.username = "Alice"

    await server._handle_voice_join(client, {"type": "voice_join", "scope": "table"})

    info = client.sent[0]
    assert info["type"] == "voice_join_info"
    assert info["room"] == f"pp:table:{table.table_id}"
    assert info["context_id"] == table.table_id
    assert info["participant"]["identity"] == "uuid-alice"


@pytest.mark.asyncio
async def test_rejects_voice_for_non_member():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    table = server._tables.create_table("pig", "Alice", alice)
    client = RecordingConnection()
    client.username = "Bob"

    await server._handle_voice_join(
        client, {"type": "voice_join", "scope": "table", "context_id": table.table_id}
    )

    assert bob.connection.sent[0]["type"] == "voice_join_error"
    assert bob.connection.sent[0]["key"] == "voice-not-in-context"


@pytest.mark.asyncio
async def test_rejects_voice_when_user_has_no_table():
    server = _make_server()
    alice = _add_user(server, "Alice")
    client = RecordingConnection()
    client.username = "Alice"

    await server._handle_voice_join(client, {"type": "voice_join", "scope": "table"})

    assert alice.connection.sent[0]["key"] == "voice-not-at-table"


@pytest.mark.asyncio
async def test_clear_error_when_voice_disabled():
    server = _make_server()
    server._voice = VoiceService(enabled=False)
    alice = _add_user(server, "Alice")
    server._tables.create_table("pig", "Alice", alice)
    client = RecordingConnection()
    client.username = "Alice"

    await server._handle_voice_join(client, {"type": "voice_join", "scope": "table"})

    assert alice.connection.sent[0]["key"] == "voice-unavailable"


@pytest.mark.asyncio
async def test_rejects_muted_user():
    server = _make_server()
    alice = _add_user(server, "Alice")
    server._db.set_mute(
        MuteRecord(id=1, username="Alice", admin_username="Admin", reason="spam", issued_at=0, expires_at=None)
    )
    server._tables.create_table("pig", "Alice", alice)
    client = RecordingConnection()
    client.username = "Alice"

    await server._handle_voice_join(client, {"type": "voice_join", "scope": "table"})

    assert alice.connection.sent[0]["key"] == "voice-muted-permanent"


@pytest.mark.asyncio
async def test_voice_join_is_rate_limited():
    server = _make_server()
    alice = _add_user(server, "Alice")
    client = RecordingConnection()
    client.username = "Alice"
    alice.connection = client
    server._tables.create_table("pig", "Alice", alice)

    saw_rate_limit = False
    for _ in range(8):
        await server._handle_voice_join(client, {"type": "voice_join", "scope": "table"})
        if client.sent[-1]["type"] == "voice_join_error":
            saw_rate_limit = True
            break

    assert saw_rate_limit
    assert client.sent[-1]["key"] == "voice-rate-limited"


# ----------------------------------------------------------------- presence


@pytest.mark.asyncio
async def test_presence_requires_recent_join_authorization():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    table = server._tables.create_table("pig", "Alice", alice)
    table.add_member("Bob", bob)
    alice_client = RecordingConnection()
    alice_client.username = "Alice"

    # No prior _handle_voice_join, so no authorization is on record.
    await server._handle_voice_presence(
        alice_client,
        {"type": "voice_presence", "state": "connected", "scope": "table", "context_id": table.table_id},
    )

    assert "Alice" not in server._voice_presence_by_user
    assert bob.get_spoken_messages() == []


@pytest.mark.asyncio
async def test_presence_announces_connect_and_explicit_leave():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    table = server._tables.create_table("pig", "Alice", alice)
    table.add_member("Bob", bob)
    alice_client = RecordingConnection()
    alice_client.username = "Alice"
    server._record_voice_join_authorization("Alice", scope="table", context_id=table.table_id)

    await server._handle_voice_presence(
        alice_client,
        {"type": "voice_presence", "state": "connected", "scope": "table", "context_id": table.table_id},
    )
    assert "Alice connected" in bob.get_last_spoken()
    assert bob.get_sounds_played()[-1] == "voice_join.ogg"
    assert alice.get_sounds_played()[-1] == "voice_join.ogg"

    await server._handle_voice_leave(
        alice_client, {"type": "voice_leave", "scope": "table", "context_id": table.table_id}
    )
    assert alice_client.sent[-1]["type"] == "voice_leave_ack"
    assert "Alice disconnected" in bob.get_last_spoken()
    assert bob.get_sounds_played()[-1] == "voice_leave.ogg"


@pytest.mark.asyncio
async def test_connect_announcement_respects_ignore():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    bob.preferences.add_ignored("Alice")  # Bob ignores Alice
    table = server._tables.create_table("pig", "Alice", alice)
    table.add_member("Bob", bob)
    alice_client = RecordingConnection()
    alice_client.username = "Alice"
    server._record_voice_join_authorization("Alice", scope="table", context_id=table.table_id)

    await server._handle_voice_presence(
        alice_client,
        {"type": "voice_presence", "state": "connected", "scope": "table", "context_id": table.table_id},
    )

    # Bob hears nothing about Alice; Alice still gets her own confirmation.
    assert bob.get_spoken_messages() == []
    assert bob.get_sounds_played() == []
    assert alice.get_sounds_played()[-1] == "voice_join.ogg"


@pytest.mark.asyncio
async def test_stale_voice_leave_does_not_clear_newer_presence():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    table = server._tables.create_table("pig", "Alice", alice)
    table.add_member("Bob", bob)
    alice_client = RecordingConnection()
    alice_client.username = "Alice"
    server._record_voice_join_authorization("Alice", scope="table", context_id=table.table_id)
    await server._handle_voice_presence(
        alice_client,
        {"type": "voice_presence", "state": "connected", "scope": "table", "context_id": table.table_id},
    )
    bob.clear_messages()

    await server._handle_voice_leave(
        alice_client, {"type": "voice_leave", "scope": "table", "context_id": "stale-id"}
    )

    assert server._voice_presence_by_user["Alice"]["context_id"] == table.table_id
    assert bob.get_spoken_messages() == []
    assert alice_client.sent[-1]["type"] == "voice_leave_ack"


# --------------------------------------------------------- table lifecycle


@pytest.mark.asyncio
async def test_presence_clears_when_member_leaves_table():
    server = _make_server()
    alice = _add_user(server, "Alice")
    bob = _add_user(server, "Bob")
    table = server._tables.create_table("pig", "Alice", alice)
    table.add_member("Bob", bob)
    alice_client = RecordingConnection()
    alice_client.username = "Alice"
    server._record_voice_join_authorization("Alice", scope="table", context_id=table.table_id)
    await server._handle_voice_presence(
        alice_client,
        {"type": "voice_presence", "state": "connected", "scope": "table", "context_id": table.table_id},
    )
    bob.clear_messages()
    alice.connection.sent.clear()

    table.remove_member("Alice")
    await asyncio.sleep(0)

    assert "Alice left the table" in bob.get_last_spoken()
    assert alice.connection.sent[-1]["type"] == "voice_context_closed"
    assert "Alice" not in server._voice_presence_by_user


@pytest.mark.asyncio
async def test_table_removal_sends_context_closed_without_presence():
    server = _make_server()
    alice = _add_user(server, "Alice")
    table = server._tables.create_table("pig", "Alice", alice)

    table.remove_member("Alice")
    await asyncio.sleep(0)

    assert alice.connection.sent[-1]["type"] == "voice_context_closed"
    assert alice.connection.sent[-1]["context_id"] == table.table_id
