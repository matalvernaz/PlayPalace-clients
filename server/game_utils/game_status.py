"""Game lifecycle status enum."""

from enum import StrEnum


class GameStatus(StrEnum):
    """Game lifecycle status.

    A StrEnum, so ``GameStatus.PLAYING == "playing"`` is True and the status
    also turns into its plain value in ``str()`` and f-strings. The engine
    stores ``Game.status`` as a string and builds text from it (the game
    info screen looks up ``game-info-status-{status}``), so a plain
    ``(str, Enum)`` here would show up as "GameStatus.PLAYING".
    """

    WAITING = "waiting"
    PLAYING = "playing"
    FINISHED = "finished"
