"""Tests for Bunko."""

from pathlib import Path
import random
import re
from unittest.mock import patch

from ..games.bunko.game import (
    BunkoGame,
    BunkoOptions,
    WINNING_MODE_ROUND_WINS,
    WINNING_MODE_TOTAL_SCORE,
    evaluate_roll,
)
from ..games.registry import GameRegistry
from ..messages.localization import Localization
from ..users.bot import Bot
from ..users.test_user import MockUser


_locales_dir = Path(__file__).parent.parent / "locales"
Localization.init(_locales_dir)


def make_game(
    *,
    player_count: int = 2,
    start: bool = False,
    bot_all: bool = False,
    web_first: bool = False,
    **option_overrides,
) -> BunkoGame:
    game = BunkoGame(options=BunkoOptions(**option_overrides))
    game.setup_keybinds()
    for index in range(player_count):
        name = f"Player{index + 1}"
        if bot_all:
            user = Bot(name, uuid=f"p{index + 1}")
        else:
            user = MockUser(name, uuid=f"p{index + 1}")
            if web_first and index == 0:
                user.client_type = "web"
        game.add_player(name, user)
    game.host = "Player1"
    if start:
        game.on_start()
    return game


def advance_until(game: BunkoGame, condition, max_ticks: int = 400) -> bool:
    for _ in range(max_ticks):
        if condition():
            return True
        game.on_tick()
    return condition()


def test_game_registered_and_defaults() -> None:
    assert GameRegistry.get("bunko") is BunkoGame
    game = BunkoGame()
    assert game.get_name() == "Bunko"
    assert game.get_type() == "bunko"
    assert game.get_category() == "dice"
    assert game.get_min_players() == 2
    assert game.get_max_players() == 6
    assert game.get_supported_leaderboards() == ["wins", "rating", "games_played"]
    assert game.options.round_count == 6
    assert game.options.winning_mode == "round_wins"
    assert game.relevant_preferences == ["brief_announcements"]


def test_evaluate_roll_scores_authentically() -> None:
    assert evaluate_roll([3, 3, 3], 3) == ("bunko", 21)
    assert evaluate_roll([4, 4, 4], 3) == ("mini_bunko", 5)
    assert evaluate_roll([3, 3, 5], 3) == ("match", 2)
    assert evaluate_roll([1, 2, 4], 3) == ("no_score", 0)


def test_on_start_initializes_round_and_music() -> None:
    game = make_game(start=True)

    assert game.status == "playing"
    assert game.round == 1
    assert game.current_target_number == 1
    assert game.current_player == game.players[0]

    user = game.get_user(game.players[0])
    assert user is not None
    assert any(
        message.type == "play_music" and message.data["name"] == "game_pig/mus.ogg"
        for message in user.messages
    )


def test_roll_match_scores_and_keeps_turn() -> None:
    game = make_game(start=True)
    player = game.players[0]
    actor_user = game.get_user(player)
    observer_user = game.get_user(game.players[1])
    assert isinstance(actor_user, MockUser)
    assert isinstance(observer_user, MockUser)
    actor_user.clear_messages()
    observer_user.clear_messages()

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 4]):
        game.execute_action(player, "roll")

    assert advance_until(game, lambda: not game.has_active_sequence(sequence_id="bunko_roll"))
    assert player.round_score == 2
    assert player.total_score == 2
    assert game.current_player == player
    assert game.last_roll_outcome == "match"
    assert any(
        "You roll 1, 1, 4 and score 2 points" in message
        for message in actor_user.get_spoken_messages()
    )
    assert any(
        "Player1 rolls 1, 1, 4 and scores 2 points" in message
        for message in observer_user.get_spoken_messages()
    )


def test_brief_roll_announcement_uses_compact_personal_output() -> None:
    game = make_game(start=True)
    player = game.players[0]
    user = game.get_user(player)
    assert isinstance(user, MockUser)
    user.preferences.brief_announcements = True
    user.clear_messages()

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 4]):
        game.execute_action(player, "roll")

    assert advance_until(game, lambda: not game.has_active_sequence(sequence_id="bunko_roll"))
    assert "You: 1, 1, 4, +2. Round 2; total 2." in user.get_spoken_messages()


def test_mini_bunko_scores_five_points() -> None:
    game = make_game(start=True)
    player = game.players[0]

    with patch("server.games.bunko.game.random.randint", side_effect=[4, 4, 4]):
        game.execute_action(player, "roll")

    assert advance_until(game, lambda: not game.has_active_sequence(sequence_id="bunko_roll"))
    assert player.round_score == 5
    assert player.total_score == 5
    assert player.mini_bunkos == 1
    assert game.last_roll_outcome == "mini_bunko"


def test_bunko_ends_round_and_next_round_starts_left_of_winner() -> None:
    game = make_game(player_count=3, start=True)
    winner = game.players[0]

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 1]):
        game.execute_action(winner, "roll")

    assert advance_until(game, lambda: game.round == 2)
    assert winner.rounds_won == 1
    assert winner.total_score == 21
    assert winner.bunkos == 1
    assert winner.round_score == 0
    assert game.current_target_number == 2
    assert game.current_player == game.players[1]


def test_no_score_passes_turn() -> None:
    game = make_game(start=True)
    player = game.players[0]

    with patch("server.games.bunko.game.random.randint", side_effect=[2, 3, 4]):
        game.execute_action(player, "roll")

    assert advance_until(game, lambda: not game.has_active_sequence(sequence_id="bunko_roll"))
    assert player.round_score == 0
    assert game.current_player == game.players[1]
    assert game.last_roll_outcome == "no_score"


def test_roll_while_dice_are_resolving_speaks_contextual_error() -> None:
    game = make_game(start=True)
    player = game.players[0]
    user = game.get_user(player)
    assert isinstance(user, MockUser)

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 4]):
        game.execute_action(player, "roll")

    assert game.has_active_sequence(sequence_id="bunko_roll")
    user.clear_messages()
    game.execute_action(player, "roll")

    assert any(
        "Your dice are still rolling" in message
        for message in user.get_spoken_messages()
    )


def test_stale_roll_callback_is_ignored_after_turn_changes() -> None:
    game = make_game(start=True)
    player1, player2 = game.players
    game.advance_turn(announce=False)

    game.on_sequence_callback(
        "bunko_roll",
        "resolve_roll",
        {"player_id": player1.id, "values": [1, 1, 1]},
    )

    assert game.current_player is player2
    assert player1.total_score == 0
    assert player1.round_score == 0
    assert player1.bunkos == 0
    assert game.last_roll == []


def test_roll_sequence_resumes_after_restore() -> None:
    game = make_game(start=True)
    player1 = game.players[0]
    player2 = game.players[1]
    user1 = game.get_user(player1)
    user2 = game.get_user(player2)

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 4]):
        game.execute_action(player1, "roll")

    assert game.has_active_sequence(sequence_id="bunko_roll") is True

    payload = game.to_json()
    restored = BunkoGame.from_json(payload)
    if user1:
        restored.attach_user(player1.id, user1)
    if user2:
        restored.attach_user(player2.id, user2)
    restored.rebuild_runtime_state()

    assert advance_until(
        restored, lambda: not restored.has_active_sequence(sequence_id="bunko_roll")
    )
    restored_player1 = restored.players[0]
    assert restored_player1.round_score == 2
    assert restored.current_player == restored_player1


def test_web_info_actions_visible_in_waiting_and_playing_states() -> None:
    waiting_game = make_game(web_first=True)
    web_player = waiting_game.players[0]
    waiting_actions = {
        entry.action.id for entry in waiting_game.get_all_visible_actions(web_player)
    }
    assert "whos_at_table" in waiting_actions

    active_game = make_game(web_first=True, start=True)
    web_player = active_game.players[0]
    active_actions = {
        entry.action.id for entry in active_game.get_all_visible_actions(web_player)
    }
    assert "check_status" in active_actions
    assert "check_last_roll" in active_actions
    assert "check_scores" in active_actions


def test_touch_standard_actions_follow_project_order() -> None:
    game = make_game(start=True, web_first=True)
    player = game.players[0]
    order = game.create_standard_action_set(player)._order
    expected = [
        "check_status",
        "check_last_roll",
        "check_scores",
        "whose_turn",
        "whos_at_table",
    ]

    positions = [order.index(action_id) for action_id in expected]
    assert positions == sorted(positions)


def test_touch_roll_button_stays_visible_off_turn() -> None:
    game = make_game(start=True, web_first=True)
    player = game.players[1]
    user = game.get_user(player)
    assert isinstance(user, MockUser)
    user.client_type = "mobile"

    actions = {entry.action.id: entry for entry in game.get_all_visible_actions(player)}

    assert "roll" in actions
    assert actions["roll"].enabled is False


def test_prestart_validate_blocks_invalid_direct_options() -> None:
    low_rounds = BunkoGame(options=BunkoOptions(round_count=0))
    assert (
        "bunko-error-round-count-invalid",
        {"count": 0, "min": 1, "max": 12},
    ) in low_rounds.prestart_validate()

    bad_mode = BunkoGame(options=BunkoOptions(winning_mode="fastest_bunko"))
    assert (
        "bunko-error-winning-mode-invalid",
        {"mode": "fastest_bunko"},
    ) in bad_mode.prestart_validate()

    valid = BunkoGame(
        options=BunkoOptions(round_count=12, winning_mode=WINNING_MODE_ROUND_WINS)
    )
    assert valid.prestart_validate() == []


def test_check_scores_uses_selected_winning_mode_order() -> None:
    game = make_game(start=True, winning_mode=WINNING_MODE_TOTAL_SCORE)
    player1 = game.players[0]
    player2 = game.players[1]
    user = game.get_user(player1)
    assert isinstance(user, MockUser)

    player1.total_score = 20
    player1.rounds_won = 1
    player2.total_score = 35
    player2.rounds_won = 0
    user.clear_messages()
    game.execute_action(player1, "check_scores")

    spoken = " ".join(user.get_spoken_messages())
    assert spoken.index("Player2") < spoken.index("Player1")


def test_check_last_roll_uses_personal_context() -> None:
    game = make_game(start=True)
    player = game.players[0]
    user = game.get_user(player)
    assert isinstance(user, MockUser)

    with patch("server.games.bunko.game.random.randint", side_effect=[1, 1, 4]):
        game.execute_action(player, "roll")

    assert advance_until(game, lambda: not game.has_active_sequence(sequence_id="bunko_roll"))
    user.clear_messages()
    game.execute_action(player, "check_last_roll")

    assert any(
        "You last rolled 1, 1, 4" in message
        for message in user.get_spoken_messages()
    )


def test_bot_game_completes() -> None:
    random.seed(1234)
    game = make_game(
        player_count=3,
        start=True,
        bot_all=True,
        round_count=2,
    )

    assert advance_until(game, lambda: game.status == "finished", max_ticks=12000)
    assert game.status == "finished"


def test_bunko_locale_key_and_variable_parity() -> None:
    en_text = (_locales_dir / "en" / "bunko.ftl").read_text(encoding="utf-8")
    vi_text = (_locales_dir / "vi" / "bunko.ftl").read_text(encoding="utf-8")

    def messages(text: str) -> dict[str, set[str]]:
        result = {}
        current_key = None
        current_lines: list[str] = []
        for line in text.splitlines():
            if line and not line.startswith((" ", "\t")) and "=" in line:
                if current_key is not None:
                    result[current_key] = set(
                        re.findall(r"\{\s*\$([a-zA-Z_][\w-]*)", "\n".join(current_lines))
                    )
                current_key = line.split("=", 1)[0].strip()
                current_lines = [line]
            elif current_key is not None:
                current_lines.append(line)
        if current_key is not None:
            result[current_key] = set(
                re.findall(r"\{\s*\$([a-zA-Z_][\w-]*)", "\n".join(current_lines))
            )
        return result

    assert messages(en_text) == messages(vi_text)
