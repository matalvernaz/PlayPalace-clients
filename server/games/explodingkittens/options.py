"""Lobby options for Exploding Kittens."""

from dataclasses import dataclass

from ..base import GameOptions
from ...game_utils.options import (
    BoolOption,
    IntOption,
    MenuOption,
    option_field,
)


@dataclass
class ExplodingKittensOptions(GameOptions):
    edition: str = option_field(
        MenuOption(
            default="standard",
            value_key="edition",
            choices=["standard", "nsfw"],
            choice_labels={
                "standard": "ek-edition-standard",
                "nsfw": "ek-edition-nsfw",
            },
            label="ek-set-edition",
            prompt="ek-prompt-edition",
            change_msg="ek-option-changed-edition",
            description="ek-desc-edition",
        )
    )
    streaking_kittens: bool = option_field(
        BoolOption(
            default=False,
            value_key="enabled",
            label="ek-toggle-streaking",
            change_msg="ek-option-changed-streaking",
            description="ek-desc-streaking",
        )
    )
    hand_size: int = option_field(
        IntOption(
            default=7,
            min_val=4,
            max_val=10,
            value_key="cards",
            label="ek-set-hand-size",
            prompt="ek-prompt-hand-size",
            change_msg="ek-option-changed-hand-size",
            description="ek-desc-hand-size",
        )
    )
    peek_count: int = option_field(
        IntOption(
            default=3,
            min_val=1,
            max_val=5,
            value_key="cards",
            label="ek-set-peek-count",
            prompt="ek-prompt-peek-count",
            change_msg="ek-option-changed-peek-count",
            description="ek-desc-peek-count",
        )
    )
    nope_window_seconds: int = option_field(
        IntOption(
            default=5,
            min_val=2,
            max_val=15,
            value_key="seconds",
            label="ek-set-nope-window",
            prompt="ek-prompt-nope-window",
            change_msg="ek-option-changed-nope-window",
            description="ek-desc-nope-window",
        )
    )
