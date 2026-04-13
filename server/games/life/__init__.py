"""The Game of Life — classic Milton Bradley board game adaptation."""

from .game import GameOfLifeGame
from .options import LifeOptions
from .player import LifePlayer
from .state import (
    Space,
    SpaceType,
    CareerCard,
    EventDef,
    build_track,
    CANONICAL_CAREERS,
    EVENT_DECK,
    LIFE_TILE_VALUES,
)

__all__ = [
    "GameOfLifeGame",
    "LifeOptions",
    "LifePlayer",
    "Space",
    "SpaceType",
    "CareerCard",
    "EventDef",
    "build_track",
    "CANONICAL_CAREERS",
    "EVENT_DECK",
    "LIFE_TILE_VALUES",
]
