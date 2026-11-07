"""GameStatus must read as its plain value wherever the engine turns it into text."""

import json

from server.game_utils.game_status import GameStatus


def test_status_compares_equal_to_its_string_value():
    assert GameStatus.PLAYING == "playing"
    assert GameStatus.WAITING == "waiting"
    assert GameStatus.FINISHED == "finished"


def test_status_formats_as_its_value():
    # The engine's game info screen looks up f"game-info-status-{status}".
    assert f"game-info-status-{GameStatus.PLAYING}" == "game-info-status-playing"
    assert str(GameStatus.FINISHED) == "finished"


def test_status_serializes_as_its_value():
    assert json.dumps({"status": GameStatus.PLAYING}) == '{"status": "playing"}'
