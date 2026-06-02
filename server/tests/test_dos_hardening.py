"""Tests for the Batch B DoS / input-hardening changes.

Covers chat length caps, the ignore-list cap, locale allowlisting, and the
per-IP connection cap. Auth-idle timeout and the packet-flood backstop are
time/IO dependent and verified behaviorally rather than here.
"""

import pytest
from pydantic import ValidationError

from server.core.server import Server
from server.core.users.preferences import MAX_IGNORED_USERS, UserPreferences
from server.network.packet_models import CLIENT_TO_SERVER_PACKET_ADAPTER
from server.network.websocket_server import ClientConnection, WebSocketServer


def _validate(packet):
    return CLIENT_TO_SERVER_PACKET_ADAPTER.validate_python(packet)


def test_chat_message_length_capped():
    _validate({"type": "chat", "message": "hello", "convo": "global"})
    with pytest.raises(ValidationError):
        _validate({"type": "chat", "message": "x" * 2001, "convo": "global"})


def test_chat_language_length_capped():
    with pytest.raises(ValidationError):
        _validate({"type": "chat", "message": "hi", "language": "y" * 41})


def test_add_ignored_caps_list():
    prefs = UserPreferences()
    for i in range(MAX_IGNORED_USERS):
        assert prefs.add_ignored(f"user{i}") is True
    assert len(prefs.ignored_users) == MAX_IGNORED_USERS
    assert prefs.add_ignored("one-too-many") is False
    assert len(prefs.ignored_users) == MAX_IGNORED_USERS


def test_sanitize_locale(tmp_path):
    srv = Server(host="127.0.0.1", port=0, db_path=tmp_path / "db.sqlite", preload_locales=False)
    assert srv._sanitize_locale("en") == "en"
    # Unknown codes and path-traversal attempts fall back to the default.
    assert srv._sanitize_locale("../etc") == srv._default_locale
    assert srv._sanitize_locale("zz") == srv._default_locale
    assert srv._sanitize_locale(None) == srv._default_locale


class _FakeWS:
    """Minimal stand-in for a websocket connection in _handle_client."""

    def __init__(self, ip, port=12345):
        self.remote_address = (ip, port)
        self.request = None
        self.closed_with = None

    async def close(self, code=1000, reason=""):
        self.closed_with = (code, reason)

    def __aiter__(self):
        return self

    async def __anext__(self):
        raise StopAsyncIteration


@pytest.mark.asyncio
async def test_per_ip_connection_cap_refuses():
    ws_server = WebSocketServer(max_connections_per_ip=2)
    for i in range(2):
        existing = ClientConnection(
            websocket=_FakeWS("10.0.0.1"), address=f"10.0.0.1:{1000 + i}", ip_address="10.0.0.1"
        )
        ws_server._clients[existing.address] = existing

    third = _FakeWS("10.0.0.1", port=2000)
    await ws_server._handle_client(third)

    assert third.closed_with is not None  # refused with a close frame
    assert "10.0.0.1:2000" not in ws_server._clients  # never registered
