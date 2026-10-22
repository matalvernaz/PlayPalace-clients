"""Start-check and wait messages must render as real English sentences.

Game.validate_start broadcasts its (key, params) errors when someone presses
Start, and several games speak wait reasons as disabled-action messages. A key
with no English message comes out as "[key]" and logs an error, so these tests
render every one of them and fail on any formatting warning.
"""

import logging

import pytest

import server.games  # noqa: F401  (importing the package registers every game)
from server.core.users.test_user import MockUser
from server.games.registry import get_game_class
from server.messages.localization import Localization

LOGGER_NAME = "playpalace.localization"


def _game_with_players(game_type: str, count: int):
    game = get_game_class(game_type)()
    for index in range(count):
        name = f"Player{index + 1}"
        game.add_player(name, MockUser(name, uuid=f"p{index + 1}"))
    return game


def _render_without_warnings(caplog, key: str, **params) -> str:
    caplog.clear()
    with caplog.at_level(logging.WARNING, logger=LOGGER_NAME):
        text = Localization.get("en", key, **params)
    problems = [
        record.getMessage()
        for record in caplog.records
        if record.name == LOGGER_NAME
        and (
            "Failed to format message" in record.getMessage()
            or "Fluent formatting errors" in record.getMessage()
        )
    ]
    assert problems == [], problems
    assert not text.startswith("["), text
    return text


@pytest.mark.parametrize(
    ("game_type", "player_count", "expected_key"),
    [
        ("pig", 1, "action-start-needs-more-players"),
        ("chess", 1, "action-start-requires-exact-players"),
        ("chess", 3, "action-start-requires-exact-players"),
        ("pig", 5, "action-start-has-too-many-players"),
    ],
)
def test_validate_start_errors_render_in_english(caplog, game_type, player_count, expected_key):
    game = _game_with_players(game_type, player_count)

    errors = game.validate_start()

    keys = [error[0] if isinstance(error, tuple) else error for error in errors]
    assert keys[0] == expected_key
    key, params = errors[0]
    text = _render_without_warnings(caplog, key, **params)
    assert str(player_count) in text


@pytest.mark.parametrize("current", [0, 1, 2])
def test_needs_more_players_plural_forms(caplog, current):
    text = _render_without_warnings(caplog, "action-start-needs-more-players", current=current, minimum=2)
    assert "at least 2 players" in text
    if current == 1:
        assert "There is 1 player now." in text
    else:
        assert f"There are {current} players now." in text


@pytest.mark.parametrize("required", [1, 2])
def test_requires_exact_players_plural_forms(caplog, required):
    text = _render_without_warnings(caplog, "action-start-requires-exact-players", current=0, required=required)
    if required == 1:
        assert "exactly 1 player to start" in text
    else:
        assert f"exactly {required} players to start" in text
    assert "There are 0 players now." in text


@pytest.mark.parametrize("current", [1, 5])
def test_too_many_players_plural_forms(caplog, current):
    text = _render_without_warnings(caplog, "action-start-has-too-many-players", current=current, maximum=4)
    assert "at most 4 players" in text
    if current == 1:
        assert "There is 1 player now." in text
    else:
        assert f"There are {current} players now." in text


@pytest.mark.parametrize("key", ["action-wait", "action-wait-for-hand", "action-wait-for-intro", "unknown-player"])
def test_wait_and_fallback_messages_exist(caplog, key):
    _render_without_warnings(caplog, key)
