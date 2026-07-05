"""Tests for the NetworkUser implementation."""

from server.core.users.base import EscapeBehavior, MenuItem, TrustLevel
from server.core.users.network_user import NetworkUser
from server.core.users.preferences import UserPreferences


class DummyConnection:
    """Minimal stand-in for a websocket connection."""


def drain_messages(user: NetworkUser) -> list[dict]:
    return user.get_queued_messages()


def test_network_user_show_and_update_menu_tracks_state():
    user = NetworkUser(
        username="alice",
        locale="en",
        connection=DummyConnection(),
        uuid="test-uuid",
        trust_level=TrustLevel.ADMIN,
        preferences=UserPreferences(),
        approved=True,
    )

    items = [
        "Start",
        MenuItem(text="Settings", id="settings", sound="click"),
    ]
    user.show_menu(
        "lobby",
        items,
        multiletter=False,
        escape_behavior=EscapeBehavior.SELECT_LAST,
        position=2,
        grid_enabled=True,
        grid_width=3,
    )
    packet = drain_messages(user)[0]
    assert packet["menu_id"] == "lobby"
    assert packet["items"][1]["id"] == "settings"
    assert packet["position"] == 1  # converted to zero-based
    state = user._current_menus["lobby"]
    assert state["escape_behavior"] == EscapeBehavior.SELECT_LAST.value
    assert state["grid_enabled"] and state["grid_width"] == 3

    user.update_menu("lobby", ["Resume"], position=3, selection_id="resume")
    packet = drain_messages(user)[0]
    assert packet["selection_id"] == "resume"
    assert packet["position"] == 2
    assert user._current_menus["lobby"]["position"] == 3

    user.remove_menu("lobby")
    packet = drain_messages(user)[0]
    assert packet["items"] == []
    assert "lobby" not in user._current_menus


def test_network_user_show_menu_reuses_previous_position_when_not_specified():
    user = NetworkUser(
        username="alice",
        locale="en",
        connection=DummyConnection(),
        uuid="test-uuid",
        trust_level=TrustLevel.USER,
        preferences=UserPreferences(),
        approved=True,
    )

    user.show_menu("options_menu", [MenuItem(text="One", id="one")], position=1)
    drain_messages(user)

    user.show_menu(
        "options_menu",
        [
            MenuItem(text="One", id="one"),
            MenuItem(text="Two", id="two"),
        ],
    )
    packet = drain_messages(user)[0]
    assert packet["position"] == 0  # 1-based stored -> 0-based packet


def test_network_user_audio_and_clear_ui_packets():
    user = NetworkUser("bob", "en", DummyConnection())
    user.show_menu("main", ["Play"])
    user.show_editbox("chat", "Say something", default_value="Hi")
    drain_messages(user)  # discard menu + editbox packets

    user.play_sound("shuffle", volume=80, pan=-10, pitch=120)
    user.play_music("theme", looping=False)
    user.stop_music()
    user.play_ambience("rain", intro="wind", outro="fade")
    user.stop_ambience()
    user.clear_ui()

    packets = drain_messages(user)
    types = [p["type"] for p in packets]
    assert types == [
        "play_sound",
        "play_music",
        "stop_music",
        "play_ambience",
        "stop_ambience",
        "clear_ui",
    ]
    assert user._current_music is None
    assert user._current_menus == {}
    assert user._current_editboxes == {}


def test_network_user_editboxes_and_speak_queue():
    user = NetworkUser("carol", "en", DummyConnection())

    user.speak("hello")
    user.speak("warning", buffer="activity")
    user.show_editbox("input", "Prompt", multiline=True, read_only=True)

    packets = drain_messages(user)
    assert packets[0] == {"type": "speak", "text": "hello"}
    assert packets[1] == {"type": "speak", "text": "warning", "buffer": "activity"}
    edit_packet = packets[2]
    assert edit_packet["type"] == "request_input"
    assert edit_packet["multiline"] and edit_packet["read_only"]
    assert "input" in user._current_editboxes

    user.remove_editbox("input")
    assert "input" not in user._current_editboxes


def test_get_queued_messages_clears_queue_and_locale_change():
    user = NetworkUser("dave", "en", DummyConnection())

    user.speak("queued")
    user.play_sound("tick")

    packets = user.get_queued_messages()
    assert [p["type"] for p in packets] == ["speak", "play_sound"]
    assert user.get_queued_messages() == []

    user.set_locale("pl")
    assert user.locale == "pl"


def test_setters_for_trust_preferences_and_approval():
    user = NetworkUser("eve", "en", DummyConnection(), approved=False)

    user.set_trust_level(TrustLevel.USER)
    user.set_trust_level(TrustLevel.ADMIN)
    assert user.trust_level == TrustLevel.ADMIN

    prefs = UserPreferences(play_turn_sound=False)
    user.set_preferences(prefs)
    assert user.preferences is prefs

    user.set_approved(True)
    assert user.approved is True


def _coalescing_user() -> NetworkUser:
    return NetworkUser("frank", "en", DummyConnection())


def test_flush_coalesces_repaints_of_same_menu_keeping_order():
    user = _coalescing_user()
    user.show_menu("turn_menu", ["Draw"])
    user.speak("between")
    user.show_menu("turn_menu", ["Draw", "Pass"])

    packets = drain_messages(user)
    assert [p["type"] for p in packets] == ["speak", "menu"]
    assert packets[1]["items"] == ["Draw", "Pass"]


def test_flush_carries_explicit_selection_onto_surviving_repaint():
    user = _coalescing_user()
    items = [
        MenuItem(text="Card 1", id="card_1"),
        MenuItem(text="Card 2", id="card_2"),
    ]
    user.update_menu("hand", items, selection_id="card_2")
    user.show_menu("hand", items)

    packets = drain_messages(user)
    assert len(packets) == 1
    menu = packets[0]
    assert menu["selection_id"] == "card_2"
    assert "_sticky_position" not in menu
    # The surviving packet is the show form, so full config is present.
    assert "escape_behavior" in menu


def test_flush_carries_explicit_position_onto_surviving_repaint():
    user = _coalescing_user()
    user.update_menu("board", ["a", "b", "c"], position=2)
    user.update_menu("board", ["a", "b", "c"])

    packets = drain_messages(user)
    assert len(packets) == 1
    assert packets[0]["position"] == 1  # zero-based on the wire


def test_flush_does_not_treat_sticky_restored_position_as_explicit():
    user = _coalescing_user()
    user.show_menu("m", ["a", "b"], position=2)
    drain_messages(user)

    # The repaint restores the stored position (sticky); the follow-up update
    # has no focus of its own and must not inherit the restored position as
    # if it were an explicit directive.
    user.show_menu("m", ["a", "b", "c"])
    user.update_menu("m", ["a", "b", "c", "d"])

    packets = drain_messages(user)
    assert len(packets) == 1
    assert "position" not in packets[0]
    assert packets[0].get("selection_id") is None
    assert "_sticky_position" not in packets[0]


def test_flush_strips_sticky_marker_from_wire_packets():
    user = _coalescing_user()
    user.show_menu("m", ["a", "b"], position=2)
    drain_messages(user)

    user.show_menu("m", ["a", "b", "c"])
    packets = drain_messages(user)
    assert packets[0]["position"] == 1
    assert "_sticky_position" not in packets[0]


def test_identical_repaint_of_current_menu_is_skipped():
    user = _coalescing_user()
    user.show_menu("m", ["a", "b"])
    drain_messages(user)

    user.show_menu("m", ["a", "b"])
    assert drain_messages(user) == []

    user.update_menu("m", ["a", "b"])
    assert drain_messages(user) == []

    # Explicit focus bypasses the skip.
    user.update_menu("m", ["a", "b"], selection_id="x")
    packets = drain_messages(user)
    assert len(packets) == 1 and packets[0]["selection_id"] == "x"


def test_repaint_after_another_menu_sends_even_if_unchanged():
    user = _coalescing_user()
    user.show_menu("m", ["a"])
    user.show_menu("other", ["y"])
    drain_messages(user)

    user.show_menu("m", ["a"])
    packets = drain_messages(user)
    assert len(packets) == 1 and packets[0]["menu_id"] == "m"


def test_repaint_after_editbox_sends_even_if_unchanged():
    user = _coalescing_user()
    user.show_menu("m", ["a"])
    drain_messages(user)

    user.show_editbox("e", "Prompt")
    drain_messages(user)

    user.show_menu("m", ["a"])
    packets = drain_messages(user)
    assert len(packets) == 1 and packets[0]["menu_id"] == "m"


def test_repaint_after_reconnect_sends_even_if_unchanged():
    user = _coalescing_user()
    user.show_menu("m", ["a"])
    drain_messages(user)

    user.set_connection(DummyConnection())
    user.show_menu("m", ["a"])
    packets = drain_messages(user)
    assert len(packets) == 1 and packets[0]["menu_id"] == "m"


def test_help_text_change_is_content_and_sends():
    user = _coalescing_user()
    user.show_menu("m", ["a"], help_text="one")
    drain_messages(user)

    user.show_menu("m", ["a"], help_text="two")
    packets = drain_messages(user)
    assert len(packets) == 1 and packets[0]["help_text"] == "two"

    user.show_menu("m", ["a"], help_text="two")
    assert drain_messages(user) == []


def test_skipped_repaint_preserves_remembered_position():
    user = _coalescing_user()
    user.show_menu("m", ["a", "b"], position=2)
    drain_messages(user)

    user.show_menu("m", ["a", "b"])  # skipped
    assert drain_messages(user) == []

    # Content change later still restores the remembered position.
    user.show_menu("m", ["a", "b", "c"])
    packets = drain_messages(user)
    assert packets[0]["position"] == 1


def test_flush_keeps_distinct_menus_and_remove_wins_when_last():
    user = _coalescing_user()
    user.show_menu("a_menu", ["x"])
    user.show_menu("b_menu", ["y"])
    packets = drain_messages(user)
    assert [p["menu_id"] for p in packets] == ["a_menu", "b_menu"]

    user.show_menu("a_menu", ["x"])
    user.remove_menu("a_menu")
    packets = drain_messages(user)
    assert len(packets) == 1
    assert packets[0]["items"] == []
