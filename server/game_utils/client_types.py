"""Client type detection helpers for multi-client support."""


def is_mobile_client_type(client_type: str) -> bool:
    """Return True if the client is a native mobile app."""
    return client_type == "mobile"


def is_web_client_type(client_type: str) -> bool:
    """Return True if the client is a browser-based web client."""
    return client_type == "web"


def is_touch_client_type(client_type: str) -> bool:
    """Return True if the client uses touch input (mobile or web on mobile devices)."""
    return client_type in ("mobile", "web")


def uses_self_voicing(client_type: str) -> bool:
    """Return True if the client manages its own TTS/speech output."""
    return client_type in ("mobile", "macos")
