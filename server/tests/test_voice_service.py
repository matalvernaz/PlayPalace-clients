"""Unit tests for the voice authorization core (VoiceService / token mint).

Server-integration tests (join/presence/leave handlers, mute and ignore
gating) live alongside the server wiring; these cover the standalone service.
"""

import base64
import hashlib
import hmac
import json

import pytest

from ..voice import VoiceAuthorizationError, VoiceContext, VoiceService


def _decode_jwt(token: str, secret: str) -> dict:
    header, payload, signature = token.split(".")
    expected = hmac.new(secret.encode("utf-8"), f"{header}.{payload}".encode("ascii"), hashlib.sha256).digest()
    actual = base64.urlsafe_b64decode(signature + "=" * (-len(signature) % 4))
    assert hmac.compare_digest(expected, actual)
    return json.loads(base64.urlsafe_b64decode(payload + "=" * (-len(payload) % 4)))


def _ready_service(**overrides) -> VoiceService:
    defaults = dict(
        enabled=True,
        public_url="wss://voice.example.com",
        api_key="test-key",
        api_secret="test-secret",
        room_prefix="pa",
        token_ttl_seconds=300,
    )
    defaults.update(overrides)
    return VoiceService(**defaults)


def test_livekit_join_packet_contains_room_limited_grant() -> None:
    service = _ready_service()
    context = VoiceContext(scope="table", context_id="abc123", room_label="Test room")

    packet = service.create_join_packet(context=context, identity="uuid-alice", display_name="Alice")
    claims = _decode_jwt(packet["token"], "test-secret")

    assert packet["type"] == "voice_join_info"
    assert packet["provider"] == "livekit"
    assert packet["scope"] == "table"
    assert packet["context_id"] == "abc123"
    assert packet["url"] == "wss://voice.example.com"
    assert packet["room"] == "pa:table:abc123"
    assert packet["participant"] == {"identity": "uuid-alice", "name": "Alice"}
    assert claims["iss"] == "test-key"
    assert claims["sub"] == "uuid-alice"
    assert claims["name"] == "Alice"
    assert claims["video"]["roomJoin"] is True
    assert claims["video"]["room"] == "pa:table:abc123"
    assert claims["video"]["canPublish"] is True
    assert claims["video"]["canPublishSources"] == ["microphone"]
    assert claims["video"]["canSubscribe"] is True


def test_token_expiry_matches_configured_ttl() -> None:
    service = _ready_service(token_ttl_seconds=300)
    packet = service.create_join_packet(
        context=VoiceContext(scope="table", context_id="t1"),
        identity="id",
        display_name="Name",
    )
    claims = _decode_jwt(packet["token"], "test-secret")
    assert claims["exp"] - claims["nbf"] == 300 + 5  # nbf is issued_at - 5


def test_disabled_or_unconfigured_service_is_not_ready() -> None:
    assert VoiceService(enabled=False).is_ready() is False
    assert _ready_service(api_secret="").is_ready() is False
    assert _ready_service(public_url="").is_ready() is False
    assert _ready_service().is_ready() is True


def test_create_join_packet_raises_when_unavailable() -> None:
    with pytest.raises(VoiceAuthorizationError, match="voice-unavailable"):
        VoiceService(enabled=False).create_join_packet(
            context=VoiceContext(scope="table", context_id="t1"),
            identity="id",
            display_name="Name",
        )


def test_build_room_name_sanitizes_and_rejects_empty_components() -> None:
    service = _ready_service(room_prefix="pa")
    assert service.build_room_name(VoiceContext(scope="table", context_id="a b/c")) == "pa:table:a_b_c"
    with pytest.raises(VoiceAuthorizationError, match="voice-invalid-context"):
        service.build_room_name(VoiceContext(scope="", context_id="x"))


def test_capability_packet_hides_url_until_ready() -> None:
    assert VoiceService(enabled=False).capability_packet() == {
        "type": "voice_capability",
        "enabled": False,
        "provider": "livekit",
        "url": "",
        "token_ttl_seconds": 900,
    }
    ready = _ready_service().capability_packet()
    assert ready["enabled"] is True
    assert ready["url"] == "wss://voice.example.com"


def test_from_config_reads_voice_section_and_clamps_ttl() -> None:
    assert VoiceService.from_config(None).is_ready() is False
    assert VoiceService.from_config({}).enabled is False

    svc = VoiceService.from_config(
        {
            "enabled": True,
            "url": "wss://v.example.com",
            "api_key": "k",
            "api_secret": "s",
            "room_prefix": "pp",
            "token_ttl_seconds": 5,  # below floor
        }
    )
    assert svc.is_ready() is True
    assert svc.room_prefix == "pp"
    assert svc.token_ttl_seconds == 60  # clamped to minimum
