"""Tests for error handling and observability improvements (PR 1)."""

import asyncio
import logging
import threading

import pytest
import websockets.exceptions

from server.core.server import Server
from server.core.tick import TickScheduler
from server.messages.localization import Localization
from server.network.websocket_server import ClientConnection


# ---------------------------------------------------------------------------
# Localization.get() — issue #1
# ---------------------------------------------------------------------------


def test_localization_get_returns_the_id_and_logs_a_missing_key(caplog):
    """When a message ID does not exist, the engine returns the id; the server logs it once."""
    from server.core import localization_logging

    localization_logging.install()
    fake_id = "nonexistent-message-id-xyz-test-only"
    with caplog.at_level(logging.ERROR, logger="playpalace.localization"):
        result = Localization.get("en", fake_id)
        Localization.get("en", fake_id)
    assert result == fake_id
    assert sum(fake_id in record.message for record in caplog.records) == 1


def test_localization_get_logs_fluent_format_errors(caplog):
    """When Fluent reports formatting errors (e.g. missing variables), log them once."""
    from server.core import localization_logging

    localization_logging.install()
    localization_logging._already_logged.clear()
    # game-player-skipped uses $player — omitting it triggers a Fluent format error
    with caplog.at_level(logging.ERROR, logger="playpalace.localization"):
        result = Localization.get("en", "game-player-skipped")
        Localization.get("en", "game-player-skipped")
    # Should still return *something* (Fluent partial result), not crash
    assert isinstance(result, str)
    assert result != "game-player-skipped"
    failures = [r for r in caplog.records if "Failed to format message 'game-player-skipped'" in r.message]
    assert len(failures) == 1


# ---------------------------------------------------------------------------
# Localization cache — issue #5
# ---------------------------------------------------------------------------


# ---------------------------------------------------------------------------
# TickScheduler — issue #2
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_tick_loop_logs_exception(caplog):
    """Tick loop should log full traceback, not just print."""
    raised = {"done": False}

    def on_tick():
        if not raised["done"]:
            raised["done"] = True
            raise RuntimeError("test tick boom")

    scheduler = TickScheduler(on_tick, tick_interval_ms=10)
    with caplog.at_level(logging.ERROR, logger="playpalace.tick"):
        await scheduler.start()
        await asyncio.sleep(0.1)
        await scheduler.stop()

    assert any("Error in tick callback" in r.message for r in caplog.records)
    # Should include traceback info
    assert any(r.exc_info is not None for r in caplog.records if "tick callback" in r.message)


# ---------------------------------------------------------------------------
# WebSocket — issues #3, #4
# ---------------------------------------------------------------------------


class ClosedWebSocket:
    """WebSocket that raises ConnectionClosed on send."""

    async def send(self, data):
        raise websockets.exceptions.ConnectionClosed(None, None)

    async def close(self):
        pass

    @property
    def remote_address(self):
        return ("127.0.0.1", 9999)


@pytest.mark.asyncio
async def test_websocket_send_logs_dropped_packet_on_disconnect(caplog):
    """Dropped packets on disconnect should be logged at DEBUG."""
    conn = ClientConnection(websocket=ClosedWebSocket(), address="127.0.0.1:9999")
    conn.username = "alice"
    with caplog.at_level(logging.DEBUG, logger="playpalace.packets"):
        await conn.send({"type": "speak", "text": "hello"})
    assert any("Dropped packet" in r.message and "alice" in r.message for r in caplog.records)


@pytest.mark.asyncio
async def test_websocket_malformed_json_logs_warning(caplog):
    """Malformed JSON from clients should produce a warning log."""

    class FakeAsyncIter:
        """Simulate an async websocket that yields one bad message then stops."""

        def __init__(self):
            self._messages = [b"not valid json"]
            self._index = 0

        def __aiter__(self):
            return self

        async def __anext__(self):
            if self._index < len(self._messages):
                msg = self._messages[self._index]
                self._index += 1
                return msg
            raise StopAsyncIteration

    class FakeWebSocket:
        def __init__(self):
            self._iter = FakeAsyncIter()

        @property
        def remote_address(self):
            return ("10.0.0.1", 5555)

        def __aiter__(self):
            return self._iter.__aiter__()

        async def send(self, data):
            pass

        async def close(self):
            pass

    from server.network.websocket_server import WebSocketServer

    ws_server = WebSocketServer()
    ws = FakeWebSocket()

    with caplog.at_level(logging.WARNING, logger="playpalace.packets"):
        await ws_server._handle_client(ws)

    assert any("Malformed JSON" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# Server: preferences — issue #6
# ---------------------------------------------------------------------------


@pytest.fixture
def server(tmp_path):
    return Server(
        host="127.0.0.1",
        port=0,
        db_path=tmp_path / "db.sqlite",
        
    )


def test_corrupt_preferences_logs_warning(server, caplog):
    """Corrupt preference JSON should log a warning and return defaults."""
    from server.core.server import UserPreferences

    class FakeUserRecord:
        uuid = "test-uuid-1234"
        preferences_json = '{"invalid_key": [broken'

    with caplog.at_level(logging.WARNING, logger="playpalace.server"):
        result = server._load_user_preferences(FakeUserRecord())

    assert isinstance(result, UserPreferences)
    assert any("Corrupt preferences" in r.message and "test-uuid-1234" in r.message for r in caplog.records)


def test_preferences_type_error_caught(server, caplog):
    """TypeError from bad preference data should also be caught."""
    class FakeUserRecord:
        uuid = "test-uuid-5678"
        preferences_json = '{"unexpected_kwarg_xyz": 42}'

    with caplog.at_level(logging.WARNING, logger="playpalace.server"):
        result = server._load_user_preferences(FakeUserRecord())

    # Should return defaults without crashing — whether it logs depends on
    # whether from_dict raises or silently ignores unknown keys
    from server.core.server import UserPreferences

    assert isinstance(result, UserPreferences)


# ---------------------------------------------------------------------------
# Server: DB startup check — issue #9
# ---------------------------------------------------------------------------


def test_warn_if_no_users_db_error_logs(server, caplog, monkeypatch):
    """Database errors during startup check should be logged."""
    monkeypatch.delenv("PLAYPALACE_BOOTSTRAP_WARNING_SUPPRESSED", raising=False)

    class BrokenDB:
        def get_user_count(self):
            raise RuntimeError("db connection failed")

    server._db = BrokenDB()

    with caplog.at_level(logging.WARNING, logger="playpalace.server"):
        server._warn_if_no_users()

    assert any("Failed to check user count" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# Server: config load — issue #10
# ---------------------------------------------------------------------------


def test_config_load_failure_uses_logging(tmp_path, caplog):
    """Config parse errors should use LOG.error, not print."""
    config_file = tmp_path / "config.toml"
    config_file.write_text("this is not valid toml [[[", encoding="utf-8")

    srv = Server(
        host="127.0.0.1",
        port=0,
        db_path=tmp_path / "db.sqlite",
        config_path=str(config_file),
        
    )

    with caplog.at_level(logging.ERROR, logger="playpalace.server"):
        srv._load_config_settings()

    assert any("Failed to load config" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# Server: invalid config values — issue #11
# ---------------------------------------------------------------------------


def test_invalid_config_value_logs_warning(tmp_path, caplog):
    """Non-integer config values should log a warning."""
    config_file = tmp_path / "config.toml"
    config_file.write_text(
        '[auth]\nusername_min_length = "not_a_number"\n',
        encoding="utf-8",
    )

    srv = Server(
        host="127.0.0.1",
        port=0,
        db_path=tmp_path / "db.sqlite",
        config_path=str(config_file),
        
    )

    with caplog.at_level(logging.WARNING, logger="playpalace.server"):
        srv._load_config_settings()

    assert any("Invalid config value" in r.message for r in caplog.records)


# ---------------------------------------------------------------------------
# Server: contextlib.suppress narrowing — issue #13
# ---------------------------------------------------------------------------


class FakeClientBase:
    """Minimal duck-typed ClientConnection for handoff tests."""

    username = ""
    authenticated = False
    replaced = False

    async def send(self, packet):
        pass

    async def close(self):
        pass


@pytest.mark.asyncio
async def test_handoff_session_catches_expected_close_errors(server):
    """Expected exceptions from close() should be caught gracefully."""
    from server.users.network_user import NetworkUser

    class OldClient(FakeClientBase):
        username = "old_user"
        authenticated = True

        async def close(self):
            raise OSError("connection reset")

    class NewClient(FakeClientBase):
        pass

    old = OldClient()
    new = NewClient()

    user = NetworkUser(username="testuser", locale="en", connection=old)

    # Should not raise — OSError is an expected close exception
    await server._handoff_existing_session(user, new)
    assert new.username == "testuser"


@pytest.mark.asyncio
async def test_handoff_session_propagates_unexpected_errors(server):
    """Unexpected exceptions from close() should propagate."""
    from server.users.network_user import NetworkUser

    class OldClient(FakeClientBase):
        username = "old_user"
        authenticated = True

        async def close(self):
            raise ValueError("unexpected bug in close path")

    class NewClient(FakeClientBase):
        pass

    old = OldClient()
    new = NewClient()

    user = NetworkUser(username="testuser2", locale="en", connection=old)

    with pytest.raises(ValueError, match="unexpected bug"):
        await server._handoff_existing_session(user, new)
