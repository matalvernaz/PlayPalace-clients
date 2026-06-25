"""Voice room authorization service."""

from __future__ import annotations

from dataclasses import dataclass, field
import re
from typing import Any

from .tokens import generate_livekit_token


SUPPORTED_PROVIDER = "livekit"
DEFAULT_TOKEN_TTL_SECONDS = 900
# Room/identity components must be URL-safe for the provider; collapse anything else.
ROOM_COMPONENT_PATTERN = re.compile(r"[^A-Za-z0-9_.:-]+")


class VoiceAuthorizationError(Exception):
    """Raised when a voice room request cannot be authorized."""


@dataclass(frozen=True)
class VoiceContext:
    """A joinable voice scope, e.g. one game table."""

    scope: str
    context_id: str
    room_label: str = ""
    metadata: dict[str, Any] = field(default_factory=dict)


@dataclass(frozen=True)
class VoiceService:
    """Mints provider tokens authorizing a user into a per-context voice room.

    Disabled and inert unless fully configured (see :meth:`is_ready`); the
    server advertises readiness to clients via :meth:`capability_packet`.
    """

    enabled: bool = False
    provider: str = SUPPORTED_PROVIDER
    public_url: str = ""
    api_key: str = ""
    api_secret: str = ""
    room_prefix: str = "playpalace"
    token_ttl_seconds: int = DEFAULT_TOKEN_TTL_SECONDS

    @classmethod
    def from_config(cls, cfg: dict[str, Any] | None) -> "VoiceService":
        """Build from the ``[voice]`` table of config.toml (absent -> disabled)."""
        cfg = cfg or {}
        provider = str(cfg.get("provider", SUPPORTED_PROVIDER)).strip().lower() or SUPPORTED_PROVIDER
        try:
            token_ttl_seconds = max(60, min(86400, int(cfg.get("token_ttl_seconds", DEFAULT_TOKEN_TTL_SECONDS))))
        except (TypeError, ValueError):
            token_ttl_seconds = DEFAULT_TOKEN_TTL_SECONDS
        return cls(
            enabled=bool(cfg.get("enabled", False)),
            provider=provider,
            public_url=str(cfg.get("url", "")).strip(),
            api_key=str(cfg.get("api_key", "")).strip(),
            api_secret=str(cfg.get("api_secret", "")).strip(),
            room_prefix=str(cfg.get("room_prefix", "playpalace")).strip() or "playpalace",
            token_ttl_seconds=token_ttl_seconds,
        )

    def is_ready(self) -> bool:
        return (
            self.enabled
            and self.provider == SUPPORTED_PROVIDER
            and bool(self.public_url)
            and bool(self.api_key)
            and bool(self.api_secret)
        )

    def capability_packet(self) -> dict[str, Any]:
        """Advertise voice readiness to clients (sent on login)."""
        return {
            "type": "voice_capability",
            "enabled": self.is_ready(),
            "provider": self.provider,
            "url": self.public_url if self.is_ready() else "",
            "token_ttl_seconds": self.token_ttl_seconds,
        }

    def build_room_name(self, context: VoiceContext) -> str:
        scope = self._safe_component(context.scope)
        context_id = self._safe_component(context.context_id)
        prefix = self._safe_component(self.room_prefix)
        if not scope or not context_id:
            raise VoiceAuthorizationError("voice-invalid-context")
        return f"{prefix}:{scope}:{context_id}"

    def create_join_packet(
        self,
        *,
        context: VoiceContext,
        identity: str,
        display_name: str,
        metadata: dict[str, Any] | None = None,
    ) -> dict[str, Any]:
        if not self.is_ready():
            raise VoiceAuthorizationError("voice-unavailable")
        room = self.build_room_name(context)
        token_metadata = dict(context.metadata)
        if metadata:
            token_metadata.update(metadata)
        token, expires_at = generate_livekit_token(
            api_key=self.api_key,
            api_secret=self.api_secret,
            identity=identity,
            name=display_name,
            room=room,
            ttl_seconds=self.token_ttl_seconds,
            metadata=token_metadata,
        )
        return {
            "type": "voice_join_info",
            "provider": self.provider,
            "scope": context.scope,
            "context_id": context.context_id,
            "url": self.public_url,
            "room": room,
            "room_label": context.room_label,
            "participant": {
                "identity": identity,
                "name": display_name,
            },
            "token": token,
            "expires_at": expires_at,
            "ice_servers": [],
        }

    def _safe_component(self, value: str) -> str:
        normalized = ROOM_COMPONENT_PATTERN.sub("_", value.strip())
        return normalized.strip("_")[:96]
