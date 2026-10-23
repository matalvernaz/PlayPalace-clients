"""Cards Against Humanity driven by the events real clients send.

Clients send a menu pick as its 1-based position plus the row's id, and
shortcuts as keybind events. These tests play a real table that way, so they
cover the dispatch paths that calling execute_action directly skips.
"""

import logging
from pathlib import Path

import pytest

from ..core.users.test_user import MockUser
from ..games.humanitycards.game import HumanityCardsGame
from ..messages.localization import Localization

Localization.init(Path(__file__).parent.parent / "locales")

MAX_TICKS = 2_000


def _start_table() -> HumanityCardsGame:
    game = HumanityCardsGame()
    # The server sets up shortcuts when it creates or restores a table.
    game.setup_keybinds()
    for index, name in enumerate(("Alice", "Bob", "Carol")):
        game.add_player(name, MockUser(name, uuid=f"hc-events-{index}"))
    game.host = "Alice"
    game.on_start()
    _tick_until(game, "submitting")
    return game


def _tick_until(game: HumanityCardsGame, phase: str) -> None:
    for _ in range(MAX_TICKS):
        if game.phase == phase:
            return
        game.on_tick()
    raise AssertionError(f"table never reached {phase!r}; it is in {game.phase!r}")


def _judge(game: HumanityCardsGame):
    return next(player for player in game.players if game._is_judge(player))


def _answerers(game: HumanityCardsGame):
    return [player for player in game.players if not game._is_judge(player)]


def _press(game: HumanityCardsGame, player, key: str) -> None:
    game.handle_event(player, {"type": "keybind", "key": key})


def _required(game: HumanityCardsGame) -> int:
    return game.current_black_card["pick"]


def _submit_by_keys(game: HumanityCardsGame, player) -> None:
    for number in range(1, _required(game) + 1):
        _press(game, player, str(number))
    _press(game, player, "space")
    assert game.get_player_by_id(player.id).submitted_cards is not None


def _judging_table() -> HumanityCardsGame:
    game = _start_table()
    for player in _answerers(game):
        _submit_by_keys(game, player)
    _tick_until(game, "judging")
    return game


def _pick_event(position: int, selection_id: str | None) -> dict:
    event = {"type": "menu", "menu_id": "turn_menu", "selection": position}
    if selection_id is not None:
        event["selection_id"] = selection_id
    return event


def _shown_rows(game: HumanityCardsGame, player) -> list:
    return game.get_user(player).menus["turn_menu"]["items"]


def _scores(game: HumanityCardsGame) -> list[int]:
    return [player.score for player in game.players]


@pytest.mark.parametrize("paint", ["rebuild", "update"])
@pytest.mark.parametrize("send_id", [True, False], ids=["position-and-id", "position-only"])
def test_picking_the_czar_prompt_row_picks_no_answer(paint, send_id):
    game = _judging_table()
    judge = _judge(game)
    if paint == "rebuild":
        game.rebuild_player_menu(judge)
    else:
        game.update_player_menu(judge)
    row_ids = [row.id for row in _shown_rows(game, judge)]
    header_position = row_ids.index("judge_prompt_header") + 1
    assert row_ids[header_position] == "judge_pick_0"

    game.handle_event(judge, _pick_event(header_position, "judge_prompt_header" if send_id else None))

    assert game.phase == "judging"
    assert _scores(game) == [0, 0, 0]


def test_picking_the_row_after_the_prompt_by_position_picks_the_first_answer():
    game = _judging_table()
    judge = _judge(game)
    game.rebuild_player_menu(judge)
    row_ids = [row.id for row in _shown_rows(game, judge)]
    first_answer_position = row_ids.index("judge_pick_0") + 1
    first_answer = game.submissions[game.submission_order[0]]

    game.handle_event(judge, _pick_event(first_answer_position, None))

    assert game.phase != "judging"
    assert game.get_player_by_id(first_answer["player_id"]).score == 1


def test_space_before_choosing_enough_cards_says_how_many(caplog):
    game = _start_table()
    player = _answerers(game)[0]
    user = game.get_user(player)

    with caplog.at_level(logging.WARNING, logger="playpalace.localization"):
        _press(game, player, "space")

    assert user.get_last_spoken() == Localization.get("en", "hc-wrong-card-count", count=_required(game))
    assert game.get_player_by_id(player.id).submitted_cards is None
    assert not caplog.records


def test_choosing_one_card_too_many_says_the_selection_is_full(caplog):
    game = _start_table()
    player = _answerers(game)[0]
    user = game.get_user(player)
    required = _required(game)
    for number in range(1, required + 1):
        _press(game, player, str(number))

    with caplog.at_level(logging.WARNING, logger="playpalace.localization"):
        _press(game, player, str(required + 1))

    assert user.get_last_spoken() == Localization.get("en", "hc-selection-full", count=required)
    assert len(game.get_player_by_id(player.id).selected_indices) == required
    assert not caplog.records
