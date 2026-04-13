"""Player state for Liar's Dice."""

from dataclasses import dataclass, field

from ..base import Player


@dataclass
class LiarsDicePlayer(Player):
    """Per-player state.

    dice: this round's hidden roll, length == dice_count.
    dice_count: how many dice this player still has.
    eliminated: True once dice_count reaches 0.
    """

    dice: list[int] = field(default_factory=list)
    dice_count: int = 0
    eliminated: bool = False
