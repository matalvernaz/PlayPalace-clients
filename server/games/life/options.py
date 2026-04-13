"""Lobby options for The Game of Life."""

from dataclasses import dataclass

from ..base import GameOptions
from ...game_utils.options import (
    BoolOption,
    IntOption,
    MenuOption,
    option_field,
)


@dataclass
class LifeOptions(GameOptions):
    """Options for The Game of Life.

    Every option has a `*-desc-*` localization key so the client reads a
    plain-English description when the user focuses the option. The
    `choice_labels` maps keep internal values stable (useful for bots,
    serialization, and tests) while letting the UI show localized text.
    """

    track_length: str = option_field(
        MenuOption(
            default="standard",
            value_key="length",
            choices=["short", "standard", "long"],
            choice_labels={
                "short": "life-length-short",
                "standard": "life-length-standard",
                "long": "life-length-long",
            },
            label="life-set-track-length",
            prompt="life-prompt-track-length",
            change_msg="life-option-changed-track-length",
            description="life-desc-track-length",
        )
    )
    college_path: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="life-toggle-college-path",
            change_msg="life-option-changed-college-path",
            description="life-desc-college-path",
        )
    )
    family_enabled: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="life-toggle-family",
            change_msg="life-option-changed-family",
            description="life-desc-family",
        )
    )
    life_tiles: str = option_field(
        MenuOption(
            default="hidden",
            value_key="mode",
            choices=["hidden", "revealed", "off"],
            choice_labels={
                "hidden": "life-tiles-hidden",
                "revealed": "life-tiles-revealed",
                "off": "life-tiles-off",
            },
            label="life-set-life-tiles",
            prompt="life-prompt-life-tiles",
            change_msg="life-option-changed-life-tiles",
            description="life-desc-life-tiles",
        )
    )
    insurance: str = option_field(
        MenuOption(
            default="full",
            value_key="mode",
            choices=["full", "simplified", "off"],
            choice_labels={
                "full": "life-insurance-full",
                "simplified": "life-insurance-simplified",
                "off": "life-insurance-off",
            },
            label="life-set-insurance",
            prompt="life-prompt-insurance",
            change_msg="life-option-changed-insurance",
            description="life-desc-insurance",
        )
    )
    stock_market: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="life-toggle-stock-market",
            change_msg="life-option-changed-stock-market",
            description="life-desc-stock-market",
        )
    )
    retirement: str = option_field(
        MenuOption(
            default="classic",
            value_key="mode",
            choices=["classic", "safe", "none"],
            choice_labels={
                "classic": "life-retire-classic",
                "safe": "life-retire-safe",
                "none": "life-retire-none",
            },
            label="life-set-retirement",
            prompt="life-prompt-retirement",
            change_msg="life-option-changed-retirement",
            description="life-desc-retirement",
        )
    )
    event_layout: str = option_field(
        MenuOption(
            default="fixed",
            value_key="mode",
            choices=["fixed", "random"],
            choice_labels={
                "fixed": "life-layout-fixed",
                "random": "life-layout-random",
            },
            label="life-set-event-layout",
            prompt="life-prompt-event-layout",
            change_msg="life-option-changed-event-layout",
            description="life-desc-event-layout",
        )
    )
    starting_cash: int = option_field(
        IntOption(
            default=10_000,
            min_val=0,
            max_val=100_000,
            value_key="money",
            label="life-set-starting-cash",
            prompt="life-prompt-starting-cash",
            change_msg="life-option-changed-starting-cash",
            description="life-desc-starting-cash",
        )
    )
