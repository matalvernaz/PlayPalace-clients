"""Lobby options for Liar's Dice."""

from dataclasses import dataclass

from ..base import GameOptions
from ...game_utils.options import (
    BoolOption,
    IntOption,
    option_field,
)


@dataclass
class LiarsDiceOptions(GameOptions):
    starting_dice: int = option_field(
        IntOption(
            default=5,
            min_val=3,
            max_val=8,
            value_key="dice",
            label="ld-set-starting-dice",
            prompt="ld-prompt-starting-dice",
            change_msg="ld-option-changed-starting-dice",
            description="ld-desc-starting-dice",
        )
    )
    wild_ones: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="ld-toggle-wild-ones",
            change_msg="ld-option-changed-wild-ones",
            description="ld-desc-wild-ones",
        )
    )
    spot_on: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="ld-toggle-spot-on",
            change_msg="ld-option-changed-spot-on",
            description="ld-desc-spot-on",
        )
    )
