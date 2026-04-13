"""Player state for Exploding Kittens."""

from dataclasses import dataclass, field

from ..base import Player


@dataclass
class EKPlayer(Player):
    """Per-player state.

    Attributes:
        hand: Card identifiers held by this player.
        eliminated: True once they've drawn an Exploding Kitten with no Defuse.
        has_streaking_kitten: True if they currently hold the Streaking Kitten
            (variant). Tracked separately from hand because the rules treat it
            as "passively held"; if they later draw a real Exploding Kitten,
            both go off at once.
        last_peek: The cards they most recently saw via See the Future, top
            first. Cleared when they end their turn.
        pending: What menu prompt is currently being asked of this player.
    """

    hand: list[str] = field(default_factory=list)
    eliminated: bool = False
    has_streaking_kitten: bool = False
    last_peek: list[str] = field(default_factory=list)

    # Pending state — drives turn-menu visibility.
    # "" / "target_for_favor" / "target_for_cat_pair" / "target_for_cat_trio"
    # / "cat_trio_name" / "defuse_position" / "nope_choice"
    pending: str = ""
    pending_card: str = ""  # the card being played (for cat pair/trio target prompts)
