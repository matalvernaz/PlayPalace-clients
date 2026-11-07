"""Tests for the polished Snakes and Ladders game."""

from pathlib import Path
import json
import random
import re
from unittest.mock import patch

import pytest

from ..games.snakesandladders.game import (
    FINISH_BOUNCE_BACK,
    FINISH_EXACT_STAY,
    SnakesAndLaddersGame,
    SnakesAndLaddersOptions,
    SnakesPlayer,
)
from ..messages.localization import Localization
from ..game_utils.sequence_runner_mixin import SequenceBeat, SequenceOperation
from ..users.bot import Bot
from ..users.test_user import MockUser


LOCALES_DIR = Path(__file__).parent.parent / "locales"
DOCS_DIR = Path(__file__).parent.parent / "documentation" / "content"


def ftl_messages(text: str) -> dict[str, set[str]]:
    """Return every Fluent message key and the variables it references."""
    messages: dict[str, set[str]] = {}
    current_key: str | None = None
    current_lines: list[str] = []
    for line in text.splitlines():
        if line and not line.startswith((" ", "\t")) and "=" in line:
            if current_key is not None:
                messages[current_key] = set(
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
        messages[current_key] = set(
            re.findall(
                r"\{\s*\$([a-zA-Z_][\w-]*)", "\n".join(current_lines)
            )
        )
    return messages


def make_game(
    *,
    options: SnakesAndLaddersOptions | None = None,
    start: bool = True,
    touch: bool = False,
) -> tuple[
    SnakesAndLaddersGame,
    SnakesPlayer,
    SnakesPlayer,
    MockUser,
    MockUser,
]:
    game = SnakesAndLaddersGame(options=options or SnakesAndLaddersOptions())
    alice = MockUser("Alice", uuid="snakes-alice")
    bob = MockUser("Bob", uuid="snakes-bob")
    if touch:
        alice.client_type = "mobile"
        bob.client_type = "web"
    player1 = game.add_player("Alice", alice)
    player2 = game.add_player("Bob", bob)
    game.host = "Alice"
    game.setup_keybinds()
    if start:
        game.on_start()
    return game, player1, player2, alice, bob


def roll(game: SnakesAndLaddersGame, player: SnakesPlayer, value: int) -> None:
    def controlled_randint(low: int, high: int) -> int:
        return value if (low, high) == (1, 6) else 1

    with patch(
        "server.games.snakesandladders.game.random.randint",
        side_effect=controlled_randint,
    ):
        game.execute_action(player, "roll")


def resolve_roll(game: SnakesAndLaddersGame, max_ticks: int = 500) -> None:
    for _ in range(max_ticks):
        if not game.has_active_sequence(tag="turn_flow"):
            return
        game.on_tick()
    pytest.fail("Snakes and Ladders roll sequence did not finish")


def spoken(user: MockUser) -> list[str]:
    return user.get_spoken_messages()


class TestSnakesMetadataAndSetup:
    def test_game_metadata_and_defaults(self) -> None:
        game = SnakesAndLaddersGame()

        assert game.get_name() == "Snakes and Ladders"
        assert game.get_type() == "snakesandladders"
        assert game.get_category() == "board"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 4
        assert game.get_supported_leaderboards() == [
            "wins",
            "rating",
            "games_played",
        ]
        assert game.WINNING_SQUARE == 100
        assert game.options.finish_rule == FINISH_BOUNCE_BACK
        assert game.options.extra_turn_on_six is True
        assert game.relevant_preferences == ["brief_announcements"]

    def test_player_starts_before_square_one(self) -> None:
        game = SnakesAndLaddersGame()
        player = game.add_player("Alice", MockUser("Alice"))

        assert isinstance(player, SnakesPlayer)
        assert player.position == 0
        assert player.finished is False

    def test_on_start_initializes_active_players_only(self) -> None:
        game, player1, player2, _, _ = make_game(start=False)
        spectator = game.add_spectator(
            "Watcher", MockUser("Watcher", uuid="snakes-watcher")
        )
        player1.position = 50
        player2.finished = True
        spectator.position = 77

        game.on_start()

        assert player1.position == 0
        assert player2.position == 0
        assert player2.finished is False
        assert spectator.position == 77
        assert game.turn_player_ids == [player1.id, player2.id]
        assert game.current_player is player1

    def test_invalid_finish_rule_is_rejected_with_context(self) -> None:
        game = SnakesAndLaddersGame(
            options=SnakesAndLaddersOptions(finish_rule="teleport")
        )

        assert (
            "snakes-error-invalid-finish-rule",
            {"rule": "teleport"},
        ) in game.prestart_validate()

    @pytest.mark.parametrize("finish_rule", [FINISH_BOUNCE_BACK, FINISH_EXACT_STAY])
    @pytest.mark.parametrize("extra_turn", [False, True])
    def test_supported_options_have_no_setup_conflict(
        self, finish_rule: str, extra_turn: bool
    ) -> None:
        game = SnakesAndLaddersGame(
            options=SnakesAndLaddersOptions(
                finish_rule=finish_rule,
                extra_turn_on_six=extra_turn,
            )
        )

        assert game.prestart_validate() == []

    def test_options_survive_serialization(self) -> None:
        game = SnakesAndLaddersGame(
            options=SnakesAndLaddersOptions(
                finish_rule=FINISH_EXACT_STAY,
                extra_turn_on_six=False,
            )
        )

        restored = SnakesAndLaddersGame.from_json(game.to_json())

        assert restored.options.finish_rule == FINISH_EXACT_STAY
        assert restored.options.extra_turn_on_six is False

    def test_option_summaries_localize_rule_values(self) -> None:
        options = SnakesAndLaddersOptions(
            finish_rule=FINISH_EXACT_STAY,
            extra_turn_on_six=False,
        )

        english = options.format_options_summary("en")
        vietnamese = options.format_options_summary("vi")

        assert any("Exact roll; stay put after an overshoot" in line for line in english)
        assert any("Phải gieo đúng; đi quá thì đứng yên" in line for line in vietnamese)
        assert not any(FINISH_EXACT_STAY in line for line in english + vietnamese)

    def test_locale_keys_variables_and_vietnamese_manual_terms_are_synchronized(
        self,
    ) -> None:
        en_text = (LOCALES_DIR / "en" / "snakesandladders.ftl").read_text(
            encoding="utf-8"
        )
        vi_text = (LOCALES_DIR / "vi" / "snakesandladders.ftl").read_text(
            encoding="utf-8"
        )
        vi_doc = (
            DOCS_DIR / "vi" / "games" / "snakesandladders.md"
        ).read_text(encoding="utf-8")

        assert ftl_messages(en_text) == ftl_messages(vi_text)
        for term in (
            "khu vực xuất phát",
            "chân thang",
            "đầu rắn",
            "bật ngược",
            "Phải gieo đúng; đi quá thì đứng yên",
        ):
            assert term in vi_text
            assert term in vi_doc


class TestSnakesMovement:
    def setup_method(self) -> None:
        (
            self.game,
            self.player1,
            self.player2,
            self.user1,
            self.user2,
        ) = make_game()
        self.user1.clear_messages()
        self.user2.clear_messages()

    def test_first_roll_can_reach_ladder_on_square_one(self) -> None:
        roll(self.game, self.player1, 1)
        resolve_roll(self.game)

        assert self.player1.position == 38
        assert self.game.current_player is self.player2
        assert Localization.get(
            "en", "snakes-enter-you", position=1
        ) in spoken(self.user1)
        assert Localization.get(
            "en", "snakes-ladder-you", start=1, end=38, distance=37
        ) in spoken(self.user1)

    def test_normal_move_changes_position_after_audio_steps(self) -> None:
        self.player1.position = 1

        roll(self.game, self.player1, 4)

        assert self.player1.position == 1
        assert self.game.is_rolling is True
        resolve_roll(self.game)

        assert self.player1.position == 5
        assert self.game.is_rolling is False
        assert self.game.current_player is self.player2

    def test_ladder_climb(self) -> None:
        self.player1.position = 3

        roll(self.game, self.player1, 1)
        resolve_roll(self.game)

        assert self.player1.position == 14
        assert Localization.get(
            "en", "snakes-ladder-you", start=4, end=14, distance=10
        ) in spoken(self.user1)

    def test_snake_slide(self) -> None:
        self.player1.position = 15

        roll(self.game, self.player1, 1)
        resolve_roll(self.game)

        assert self.player1.position == 6
        assert Localization.get(
            "en", "snakes-snake-you", start=16, end=6, distance=10
        ) in spoken(self.user1)

    def test_bounce_back_resolves_interaction_without_impossible_square(self) -> None:
        self.player1.position = 98

        roll(self.game, self.player1, 4)
        resolve_roll(self.game)

        assert self.player1.position == 78
        assert Localization.get(
            "en",
            "snakes-bounce-you",
            start=98,
            position=98,
            roll=4,
            target=100,
        ) in spoken(self.user1)
        assert Localization.get(
            "en", "snakes-snake-you", start=98, end=78, distance=20
        ) in spoken(self.user1)
        assert all("102" not in message for message in spoken(self.user1))
        assert all("102" not in message for message in spoken(self.user2))

    def test_exact_stay_rule_leaves_piece_in_place_after_overshoot(self) -> None:
        self.game.options.finish_rule = FINISH_EXACT_STAY
        self.player1.position = 97

        roll(self.game, self.player1, 4)
        resolve_roll(self.game)

        assert self.player1.position == 97
        assert self.game.current_player is self.player2
        assert Localization.get(
            "en",
            "snakes-exact-miss-you",
            needed=3,
            position=97,
            roll=4,
            target=100,
        ) in spoken(self.user1)
        step_sounds = [
            sound
            for sound in self.user1.get_sounds_played()
            if sound.startswith("game_squares/step")
        ]
        assert step_sounds == []

    def test_exact_stay_roll_of_six_still_grants_extra_turn(self) -> None:
        self.game.options.finish_rule = FINISH_EXACT_STAY
        self.player1.position = 96

        roll(self.game, self.player1, 6)
        resolve_roll(self.game)

        assert self.player1.position == 96
        assert self.game.current_player is self.player1
        assert Localization.get(
            "en", "snakes-extra-turn-you", position=96
        ) in spoken(self.user1)

    def test_rolling_six_grants_extra_turn_after_movement(self) -> None:
        self.player1.position = 2

        roll(self.game, self.player1, 6)
        resolve_roll(self.game)

        assert self.player1.position == 8
        assert self.game.current_player is self.player1
        assert self.game.is_rolling is False

    def test_extra_turn_option_can_be_disabled(self) -> None:
        self.game.options.extra_turn_on_six = False
        self.player1.position = 2

        roll(self.game, self.player1, 6)
        resolve_roll(self.game)

        assert self.player1.position == 8
        assert self.game.current_player is self.player2
        assert Localization.get(
            "en", "snakes-extra-turn-you", position=8
        ) not in spoken(self.user1)

    def test_exact_roll_wins(self) -> None:
        self.player1.position = 98

        roll(self.game, self.player1, 2)
        resolve_roll(self.game)

        assert self.player1.position == 100
        assert self.player1.finished is True
        assert self.game.winner is self.player1
        assert self.game.winner_id == self.player1.id
        assert self.game.status == "finished"

    def test_ladder_to_square_one_hundred_wins(self) -> None:
        self.player1.position = 79

        roll(self.game, self.player1, 1)
        resolve_roll(self.game)

        assert self.player1.position == 100
        assert self.game.winner is self.player1
        assert self.game.status == "finished"


class TestSnakesAnnouncementsAndActions:
    def setup_method(self) -> None:
        (
            self.game,
            self.player1,
            self.player2,
            self.user1,
            self.user2,
        ) = make_game()
        self.user1.clear_messages()
        self.user2.clear_messages()

    def test_roll_and_move_use_first_and_third_person(self) -> None:
        self.player1.position = 1

        roll(self.game, self.player1, 4)
        resolve_roll(self.game)

        assert Localization.get("en", "snakes-roll-you", roll=4) in spoken(
            self.user1
        )
        assert Localization.get(
            "en", "snakes-roll-other", player="Alice", roll=4
        ) in spoken(self.user2)
        assert Localization.get(
            "en", "snakes-move-you", start=1, position=5, roll=4
        ) in spoken(self.user1)
        assert Localization.get(
            "en",
            "snakes-move-other",
            player="Alice",
            start=1,
            position=5,
            roll=4,
        ) in spoken(self.user2)

    def test_turn_and_winner_use_first_and_third_person(self) -> None:
        game, player1, _, user1, user2 = make_game()

        assert Localization.get("en", "snakes-turn-start-you") in spoken(user1)
        assert Localization.get(
            "en", "snakes-turn-start-other", player="Alice"
        ) in spoken(user2)
        user1.clear_messages()
        user2.clear_messages()
        player1.position = 98

        roll(game, player1, 2)
        resolve_roll(game)

        assert Localization.get(
            "en", "snakes-win-you", position=100
        ) in spoken(user1)
        assert Localization.get(
            "en", "snakes-win-other", player="Alice", position=100
        ) in spoken(user2)

    def test_brief_announcements_are_selected_per_listener(self) -> None:
        self.user1.preferences.brief_announcements = True
        self.player1.position = 1

        roll(self.game, self.player1, 4)
        resolve_roll(self.game)

        assert Localization.get(
            "en", "snakes-move-you-brief", position=5
        ) in spoken(self.user1)
        assert Localization.get(
            "en", "snakes-move-other", player="Alice", start=1, position=5, roll=4
        ) in spoken(self.user2)
        assert Localization.get(
            "en", "snakes-move-you", start=1, position=5, roll=4
        ) not in spoken(self.user1)

    def test_out_of_turn_roll_has_contextual_error(self) -> None:
        self.game.execute_action(self.player2, "roll")

        assert self.user2.get_last_spoken() == Localization.get(
            "en", "snakes-error-roll-not-your-turn"
        )

    def test_second_roll_during_sequence_has_contextual_error(self) -> None:
        roll(self.game, self.player1, 2)

        self.game.execute_action(self.player1, "roll")

        assert self.user1.get_last_spoken() == Localization.get(
            "en", "snakes-error-roll-resolving"
        )

    def test_roll_button_remains_visible_and_disabled_out_of_turn(self) -> None:
        visible = {
            resolved.action.id: resolved
            for resolved in self.game.get_all_visible_actions(self.player2)
        }

        assert "roll" in visible
        assert visible["roll"].enabled is False
        assert visible["roll"].disabled_reason == "snakes-error-roll-not-your-turn"

    def test_touch_standard_action_order(self) -> None:
        game, player1, _, _, _ = make_game(touch=True)
        action_set = game.create_standard_action_set(player1)
        order = action_set._order

        assert order.index("check_positions") < order.index("whose_turn")
        assert order.index("whose_turn") < order.index("whos_at_table")

    def test_check_positions_opens_live_panel_focused_on_current_player(self) -> None:
        self.player1.position = 5
        self.player2.position = 10

        self.game.execute_action(self.player1, "check_positions")

        menu = self.user1.menus["status_box"]
        assert menu["selection_id"] == f"player:{self.player1.id}"
        assert [item.id for item in menu["items"]] == [
            "goal",
            f"player:{self.player2.id}",
            f"player:{self.player1.id}",
        ]
        lines = [item.text for item in menu["items"]]
        assert Localization.get(
            "en", "snakes-status-current-position", player="Alice", position=5, remaining=95
        ) in lines
        assert Localization.get(
            "en", "snakes-status-player-position", player="Bob", position=10, remaining=90
        ) in lines

    def test_live_positions_refresh_without_new_focus_jump(self) -> None:
        self.player1.position = 5
        self.player2.position = 10
        self.game.execute_action(self.player1, "check_positions")
        self.user1.clear_messages()

        self.player1.position = 20
        self.game.refresh_menus()
        self.game.flush_menus()

        updates = [
            message
            for message in self.user1.messages
            if message.type == "show_menu"
            and message.data.get("menu_id") == "status_box"
        ]
        assert updates
        assert updates[-1].data["selection_id"] is None
        assert [item.id for item in self.user1.menus["status_box"]["items"]] == [
            "goal",
            f"player:{self.player1.id}",
            f"player:{self.player2.id}",
        ]

    def test_positions_remain_available_during_roll_sequence(self) -> None:
        roll(self.game, self.player1, 2)

        self.game.execute_action(self.player1, "check_positions")

        assert "status_box" in self.user1.menus


class TestSnakesPersistenceAndResults:
    def test_legacy_save_without_new_fields_loads_defaults(self) -> None:
        game, _, _, _, _ = make_game()
        payload = json.loads(game.to_json())
        payload.pop("options", None)
        payload.pop("last_roll", None)
        payload.pop("winner_id", None)

        restored = SnakesAndLaddersGame.from_json(json.dumps(payload))

        assert restored.options.finish_rule == FINISH_BOUNCE_BACK
        assert restored.options.extra_turn_on_six is True
        assert restored.last_roll == 0
        assert restored.winner_id == ""

    def test_roll_sequence_resumes_after_restore(self) -> None:
        game, player1, player2, user1, user2 = make_game()
        player1.position = 1
        roll(game, player1, 4)

        restored = SnakesAndLaddersGame.from_json(game.to_json())
        restored.attach_user(player1.id, user1)
        restored.attach_user(player2.id, user2)
        resolve_roll(restored)

        restored_player1 = restored.get_player_by_id(player1.id)
        restored_player2 = restored.get_player_by_id(player2.id)
        assert isinstance(restored_player1, SnakesPlayer)
        assert isinstance(restored_player2, SnakesPlayer)
        assert restored_player1.position == 5
        assert restored.current_player is restored_player2
        assert restored.is_rolling is False

    def test_bounce_and_snake_sequence_resumes_after_restore(self) -> None:
        game, player1, player2, user1, user2 = make_game()
        player1.position = 98
        roll(game, player1, 4)
        for _ in range(20):
            game.on_tick()

        restored = SnakesAndLaddersGame.from_json(game.to_json())
        restored.attach_user(player1.id, user1)
        restored.attach_user(player2.id, user2)
        resolve_roll(restored)

        restored_player = restored.get_player_by_id(player1.id)
        assert isinstance(restored_player, SnakesPlayer)
        assert restored_player.position == 78

    def test_legacy_bounce_sequence_resumes_without_invalid_position(self) -> None:
        game, player1, player2, user1, user2 = make_game()
        player1.position = 98
        game.is_rolling = True
        game.start_sequence(
            "turn_flow",
            [
                SequenceBeat(
                    ops=[
                        SequenceOperation.callback_op(
                            "move", {"player_id": player1.id, "pos": 102}
                        )
                    ],
                    delay_after_ticks=1,
                ),
                SequenceBeat(
                    ops=[
                        SequenceOperation.callback_op(
                            "bounce", {"player_id": player1.id, "pos": 98}
                        )
                    ],
                    delay_after_ticks=1,
                ),
                SequenceBeat(
                    ops=[
                        SequenceOperation.callback_op(
                            "snake",
                            {"player_id": player1.id, "start": 98, "end": 78},
                        )
                    ],
                    delay_after_ticks=1,
                ),
                SequenceBeat(
                    ops=[SequenceOperation.callback_op("end_turn")]
                ),
            ],
            tag="turn_flow",
            lock_scope=game.SEQUENCE_LOCK_GAMEPLAY,
            pause_bots=True,
            start_immediately=False,
        )

        restored = SnakesAndLaddersGame.from_json(game.to_json())
        restored.attach_user(player1.id, user1)
        restored.attach_user(player2.id, user2)
        resolve_roll(restored)

        restored_player = restored.get_player_by_id(player1.id)
        restored_next_player = restored.get_player_by_id(player2.id)
        assert isinstance(restored_player, SnakesPlayer)
        assert restored_player.position == 78
        assert restored.current_player is restored_next_player
        assert restored.is_rolling is False
        assert all("102" not in message for message in spoken(user1))

    def test_result_uses_active_player_ids_and_winner_id(self) -> None:
        game, player1, player2, _, _ = make_game()
        player1.position = 100
        player1.finished = True
        player2.position = 73
        game.winner_id = player1.id

        result = game.build_game_result()

        assert result.custom_data["winner_name"] == "Alice"
        assert result.custom_data["winner_ids"] == [player1.id]
        assert result.custom_data["final_positions"] == {
            player1.id: 100,
            player2.id: 73,
        }
        assert [entry.player_id for entry in result.player_results] == [
            player1.id,
            player2.id,
        ]

    def test_end_screen_supports_legacy_name_keyed_positions(self) -> None:
        game, player1, player2, _, _ = make_game()
        result = game.build_game_result()
        result.custom_data["final_positions"] = {"Alice": 100, "Bob": 0}

        lines = game.format_end_screen(result, "en")

        assert Localization.get(
            "en", "snakes-end-score", rank=1, player="Alice", position=100
        ) in lines
        assert Localization.get(
            "en", "snakes-end-score-start", rank=2, player="Bob"
        ) in lines


class TestSnakesBotPlay:
    def test_bot_game_completes(self) -> None:
        random_state = random.getstate()
        try:
            random.seed(42)
            game = SnakesAndLaddersGame()
            game.add_player("Bot1", Bot("Bot1"))
            game.add_player("Bot2", Bot("Bot2"))
            game.on_start()

            max_ticks = 100_000
            ticks = 0
            while game.game_active and ticks < max_ticks:
                game.on_tick()
                ticks += 1

            assert game.game_active is False
            assert game.winner is not None
            assert ticks < max_ticks
        finally:
            random.setstate(random_state)
