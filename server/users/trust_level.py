"""Account trust levels and virtual bot ids used by this server's core.

PlayAural's user base models trust as a plain integer, but our core, auth and
database code compare TrustLevel members, so the enum lives here, outside the
files copied from PlayAural.
"""

import uuid as uuid_module
from enum import Enum


class TrustLevel(Enum):
    """User trust level for permission checks."""

    BANNED = 0  # Banned user
    USER = 1  # Normal user
    ADMIN = 2  # Administrator
    SERVER_OWNER = 3  # Server owner (highest privilege)


def generate_virtual_bot_uuid(name: str) -> str:
    """Generate a deterministic UUID for a virtual bot based on its name.

    This ensures virtual bots have consistent UUIDs across server restarts
    so their game stats persist properly.
    """
    # Use UUID5 with a custom namespace for virtual bots
    namespace = uuid_module.UUID("a1b2c3d4-e5f6-7890-abcd-ef1234567890")
    return str(uuid_module.uuid5(namespace, f"virtual_bot:{name}"))


def trust_rank(level: "TrustLevel | int") -> int:
    """Return a trust level as a number, whether it's our enum or the engine's plain integer.

    Our network users carry TrustLevel; PlayAural's test and bot users carry
    an int. Comparisons go through this so either works.
    """
    return int(getattr(level, "value", level))
