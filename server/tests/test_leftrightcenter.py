"""
Tests for the Left Center Right game.
"""

import json
from pathlib import Path
import random
import re

from ..games.leftrightcenter.game import (
    LeftRightCenterGame,
    LeftRightCenterOptions,
)
from ..messages.localization import Localization
from ..users.test_user import MockUser
from ..users.bot import Bot


_locales_dir = Path(__file__).resolve().parents[1] / "locales"


def make_game(*, locale: str = "en") -> tuple[LeftRightCenterGame, list[MockUser]]:
    game = LeftRightCenterGame()
    users = [
        MockUser("Alice", locale=locale),
        MockUser("Bob", locale=locale),
        MockUser("Cara", locale=locale),
    ]
    for user in users:
        game.add_player(user.username, user)
    game.on_start()
    return game, users


def advance_until(game: LeftRightCenterGame, predicate, max_ticks: int = 200) -> bool:
    for _ in range(max_ticks):
        if predicate():
            return True
        game.on_tick()
    return predicate()


def test_game_creation():
    game = LeftRightCenterGame()
    assert game.get_name() == "Left Center Right"
    assert game.get_type() == "leftrightcenter"
    assert game.get_category() == "dice"
    assert game.get_min_players() == 3
    assert game.get_max_players() == 20


def test_options_defaults():
    game = LeftRightCenterGame()
    assert game.options.starting_chips == 3


def test_player_creation():
    game = LeftRightCenterGame()
    user = MockUser("Alice")
    player = game.add_player("Alice", user)
    assert player.name == "Alice"
    assert player.chips == 0
    assert player.is_bot is False


def test_serialization_round_trip():
    game = LeftRightCenterGame(options=LeftRightCenterOptions(starting_chips=5))
    for name in ("Alice", "Bob", "Cara"):
        game.add_player(name, MockUser(name))
    game.on_start()

    game.center_pot = 2
    game.players[0].chips = 4
    game.players[1].chips = 1
    game.players[2].chips = 3
    game.turn_index = 1

    json_str = game.to_json()
    data = json.loads(json_str)
    assert data["center_pot"] == 2
    assert data["players"][0]["chips"] == 4

    loaded = LeftRightCenterGame.from_json(json_str)
    assert loaded.center_pot == 2
    assert loaded.players[0].chips == 4
    assert loaded.options.starting_chips == 5


def test_roll_transfers(monkeypatch):
    game, _ = make_game()

    sequence = iter(["left", "right", "center"])

    def fake_choice(_):
        return next(sequence)

    monkeypatch.setattr("server.games.leftrightcenter.game.random.choice", fake_choice)

    current = game.current_player
    assert current is not None
    current.chips = 3

    game.execute_action(current, "roll")

    assert advance_until(
        game, lambda: not game.has_active_sequence(sequence_id="lrc_roll")
    )

    assert game.center_pot == 1
    chips = {p.name: p.chips for p in game.players}
    assert chips["Bob"] == 4
    assert chips["Cara"] == 4
    assert chips["Alice"] == 0


def test_winner_detection():
    game, _ = make_game()

    game.players[0].chips = 0
    game.players[1].chips = 2
    game.players[2].chips = 0

    assert game.game_active is True
    assert game._check_for_winner() is True
    assert game.game_active is False


def test_pre_turn_winner_ends_before_roll():
    game, _ = make_game()

    # Only Alice has chips before the next turn starts
    game.players[0].chips = 2
    game.players[1].chips = 0
    game.players[2].chips = 0

    assert game.game_active is True
    game._start_turn()
    assert game.game_active is False


def test_bot_game_completes():
    random.seed(2468)
    game = LeftRightCenterGame()
    bots = [Bot("Bot1"), Bot("Bot2"), Bot("Bot3")]
    for bot in bots:
        game.add_player(bot.username, bot)
    game.on_start()

    max_ticks = 10000
    for _ in range(max_ticks):
        if not game.game_active:
            break
        game.on_tick()

    assert not game.game_active


def test_team_scores_sync(monkeypatch):
    game, _ = make_game()

    sequence = iter(["left", "right", "center"])

    def fake_choice(_):
        return next(sequence)

    monkeypatch.setattr("server.games.leftrightcenter.game.random.choice", fake_choice)

    current = game.current_player
    assert current is not None
    current.chips = 3

    game.execute_action(current, "roll")

    assert advance_until(
        game, lambda: not game.has_active_sequence(sequence_id="lrc_roll")
    )

    for p in game.players:
        team = game._team_manager.get_team(p.name)
        assert team is not None
        assert team.total_score == p.chips


def test_repeated_roll_is_locked_before_resolution(monkeypatch):
    game, users = make_game()
    player = game.current_player
    assert player is not None
    users[0].clear_messages()

    choices = iter(["dot", "dot", "dot"])
    monkeypatch.setattr(
        "server.games.leftrightcenter.game.random.choice", lambda _: next(choices)
    )

    game.execute_action(player, "roll")
    game.execute_action(player, "roll")

    assert len(game.active_sequences) == 1
    assert users[0].get_spoken_messages() == [
        "You roll Dot, Dot, and Dot.",
        "Your roll is already being resolved. Wait for the chip transfers to finish.",
    ]


def test_roll_sequence_survives_serialization(monkeypatch):
    game, _ = make_game()
    player = game.current_player
    assert player is not None

    choices = iter(["left", "right", "center"])
    monkeypatch.setattr(
        "server.games.leftrightcenter.game.random.choice", lambda _: next(choices)
    )
    game.execute_action(player, "roll")

    loaded = LeftRightCenterGame.from_json(game.to_json())
    assert loaded.has_active_sequence(sequence_id="lrc_roll")
    assert advance_until(
        loaded, lambda: not loaded.has_active_sequence(sequence_id="lrc_roll")
    )

    chips = {p.name: p.chips for p in loaded.players}
    assert chips == {"Alice": 0, "Bob": 4, "Cara": 4}
    assert loaded.center_pot == 1
    assert loaded.current_player is loaded.players[1]


def test_roll_broadcast_uses_personal_and_public_perspectives(monkeypatch):
    game, users = make_game()
    player = game.current_player
    assert player is not None
    for user in users:
        user.clear_messages()

    choices = iter(["left", "center", "dot"])
    monkeypatch.setattr(
        "server.games.leftrightcenter.game.random.choice", lambda _: next(choices)
    )
    game.execute_action(player, "roll")

    assert users[0].get_last_spoken() == "You roll Left, Center, and Dot."
    assert users[1].get_last_spoken() == "Alice rolls Left, Center, and Dot."


def test_brief_announcements_are_per_listener(monkeypatch):
    game, users = make_game()
    player = game.current_player
    assert player is not None
    users[0].preferences.brief_announcements = True
    for user in users:
        user.clear_messages()

    choices = iter(["left", "center", "dot"])
    monkeypatch.setattr(
        "server.games.leftrightcenter.game.random.choice", lambda _: next(choices)
    )
    game.execute_action(player, "roll")

    assert users[0].get_last_spoken() == "You: Left, Center, and Dot."
    assert users[1].get_last_spoken() == "Alice rolls Left, Center, and Dot."


def test_no_chip_turn_skips_without_generic_turn_announcement():
    game, users = make_game()
    game.players[0].chips = 0
    game.players[1].chips = 2
    game.players[2].chips = 1
    game.current_player = game.players[0]
    for user in users:
        user.clear_messages()

    game._start_turn()

    assert game.current_player is game.players[1]
    assert users[0].get_spoken_messages()[0].startswith(
        "You have no chips, so your turn is skipped."
    )
    assert "Alice's turn." not in users[0].get_spoken_messages()


def test_last_roll_action_uses_listener_perspective(monkeypatch):
    game, users = make_game()
    player = game.current_player
    assert player is not None

    choices = iter(["left", "center", "dot"])
    monkeypatch.setattr(
        "server.games.leftrightcenter.game.random.choice", lambda _: next(choices)
    )
    game.execute_action(player, "roll")

    users[0].clear_messages()
    users[1].clear_messages()
    game.execute_action(game.players[0], "check_last_roll")
    game.execute_action(game.players[1], "check_last_roll")

    assert users[0].get_last_spoken() == "Your last roll was Left, Center, and Dot."
    assert users[1].get_last_spoken() == "Alice last rolled Left, Center, and Dot."


def test_touch_actions_follow_standard_order():
    game, users = make_game()
    users[0].client_type = "mobile"

    action_set = game.create_standard_action_set(game.players[0])
    order = action_set._order

    expected = [
        "check_center",
        "check_last_roll",
        "check_scores",
        "whose_turn",
        "whos_at_table",
    ]
    assert [order.index(action_id) for action_id in expected] == sorted(
        order.index(action_id) for action_id in expected
    )


def test_invalid_starting_chips_are_rejected():
    game = LeftRightCenterGame(options=LeftRightCenterOptions(starting_chips=0))

    assert game.prestart_validate() == [
        (
            "lrc-error-starting-chips-invalid",
            {"count": 0, "min": 1, "max": 10},
        )
    ]


def test_game_result_contains_winner_and_rating_rankings():
    game, _ = make_game()
    game.players[0].chips = 0
    game.players[1].chips = 2
    game.players[2].chips = 0

    result = game.build_game_result()

    assert result.custom_data["winner_name"] == "Bob"
    assert result.custom_data["winner_ids"] == [game.players[1].id]
    assert result.custom_data["team_rankings"][0] == {
        "members": ["Bob"],
        "score": 2,
    }


def test_lrc_locale_key_and_variable_parity():
    en_text = (_locales_dir / "en" / "leftrightcenter.ftl").read_text(
        encoding="utf-8"
    )
    vi_text = (_locales_dir / "vi" / "leftrightcenter.ftl").read_text(
        encoding="utf-8"
    )

    def messages(text: str) -> dict[str, set[str]]:
        result = {}
        current_key = None
        current_lines: list[str] = []
        for line in text.splitlines():
            if line and not line.startswith((" ", "\t")) and "=" in line:
                if current_key is not None:
                    result[current_key] = set(
                        re.findall(
                            r"\{\s*\$([a-zA-Z_][\w-]*)",
                            "\n".join(current_lines),
                        )
                    )
                current_key = line.split("=", 1)[0].strip()
                current_lines = [line]
            elif current_key is not None:
                current_lines.append(line)
        if current_key is not None:
            result[current_key] = set(
                re.findall(
                    r"\{\s*\$([a-zA-Z_][\w-]*)", "\n".join(current_lines)
                )
            )
        return result

    assert messages(en_text) == messages(vi_text)


def test_vietnamese_game_name_matches_documentation():
    document = (
        Path(__file__).resolve().parents[1]
        / "documentation"
        / "content"
        / "vi"
        / "games"
        / "leftrightcenter.md"
    ).read_text(encoding="utf-8")

    assert Localization.get("vi", "game-name-leftrightcenter") == "Trái, Giữa, Phải"
    assert document.startswith(r"\*\*Trái, Giữa, Phải\*\*")

