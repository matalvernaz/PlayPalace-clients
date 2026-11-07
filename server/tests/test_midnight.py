"""
Tests for the 1-4-24 (Midnight) game.

Following the testing strategy:
- Unit tests for individual functions
- Play tests that run the game from start to finish with bots
- Persistence tests (save/reload at each tick)
"""

import pytest
from pathlib import Path
import re
import random
import json

from ..game_utils import dice as dice_utils
from ..games.midnight.game import MidnightGame, MidnightOptions
from ..users.test_user import MockUser
from ..users.bot import Bot


def latest_turn_selection(user: MockUser) -> str | None:
    """Return the last explicit turn-menu focus directive sent to a mock user."""
    for message in reversed(user.messages):
        if (
            message.type in {"show_menu", "update_menu"}
            and message.data.get("menu_id") == "turn_menu"
        ):
            return message.data.get("selection_id")
    return None


class TestMidnightGameUnit:
    """Unit tests for Midnight game functions."""

    def test_game_creation(self):
        """Test creating a new Midnight game."""
        game = MidnightGame()
        assert game.get_name() == "1-4-24"
        assert game.get_type() == "midnight"
        assert game.get_category() == "dice"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 6

    def test_player_creation(self):
        """Test creating a player with correct initial state."""
        game = MidnightGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)

        assert player.name == "Alice"
        assert player.round_score == 0
        assert player.round_wins == 0
        assert player.qualified is False
        assert player.dice.num_dice == 6
        assert player.dice.sides == 6
        assert player.is_bot is False

    def test_options_defaults(self):
        """Test default game options."""
        game = MidnightGame()
        assert game.options.rounds == 5

    def test_custom_options(self):
        """Test custom game options."""
        options = MidnightOptions(rounds=10)
        game = MidnightGame(options=options)
        assert game.options.rounds == 10

    def test_serialization(self):
        """Test that game state can be serialized and deserialized."""
        game = MidnightGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)

        game.on_start()
        game.flush_menus()

        # Modify some state
        game.players[0].round_score = 20
        game.players[0].round_wins = 2
        game.players[0].qualified = True
        game.players[0].dice.values = [1, 2, 3, 4, 5, 6]
        game.players[0].dice.locked = [0, 3]
        game.round = 3

        # Serialize
        json_str = game.to_json()
        data = json.loads(json_str)

        # Verify structure
        assert data["round"] == 3
        assert len(data["players"]) == 2
        assert data["players"][0]["round_score"] == 20
        assert data["players"][0]["round_wins"] == 2
        assert data["players"][0]["qualified"] is True
        assert data["players"][0]["dice"]["values"] == [1, 2, 3, 4, 5, 6]
        assert data["players"][0]["dice"]["locked"] == [0, 3]

        # Deserialize
        loaded_game = MidnightGame.from_json(json_str)
        assert loaded_game.round == 3
        assert loaded_game.players[0].round_score == 20
        assert loaded_game.players[0].round_wins == 2
        assert loaded_game.players[0].qualified is True
        assert loaded_game.players[0].dice.values == [1, 2, 3, 4, 5, 6]
        assert loaded_game.players[0].dice.locked == [0, 3]


class TestMidnightGameActions:
    """Test individual game actions."""

    def setup_method(self):
        """Set up a game with two players for each test."""
        self.game = MidnightGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.player1 = self.game.add_player("Alice", self.user1)
        self.player2 = self.game.add_player("Bob", self.user2)
        self.game.on_start()
        self.game.flush_menus()
        self.game.reset_turn_order()

    def test_roll_initial(self):
        """Test rolling all 6 dice initially."""
        random.seed(42)

        assert not self.player1.dice.has_rolled
        self.game.execute_action(self.player1, "roll")

        assert self.player1.dice.has_rolled
        assert len(self.player1.dice.values) == 6
        assert all(1 <= v <= 6 for v in self.player1.dice.values)

    def test_roll_broadcast_formats_dice_list_in_listener_locale(self, monkeypatch):
        """Dice roll lists should use each listener's localized conjunction."""
        self.user1._locale = "vi"
        rolls = iter([1, 3, 3, 3, 1, 4])
        monkeypatch.setattr(
            dice_utils.random,
            "randint",
            lambda _low, _high: next(rolls),
        )

        self.game.execute_action(self.player1, "roll")

        spoken = self.user1.get_last_spoken()
        assert spoken == "Bạn gieo được: 1, 3, 3, 3, 1 và 4."
        assert " and " not in spoken

    def test_score_broadcast_formats_scoring_dice_in_listener_locale(self):
        """Scoring dice lists should also use the listener's localized conjunction."""
        self.user1._locale = "vi"
        self.player1.dice.values = [1, 4, 6, 5, 3, 2]
        self.player1.dice.locked = [0, 1, 2, 3, 4, 5]

        self.game._score_turn(self.player1)

        spoken = self.user1.get_spoken_messages()
        assert any("6, 5, 3 và 2" in message for message in spoken)
        assert not any("6, 5, 3, and 2" in message for message in spoken)

    def test_keep_die(self):
        """Test keeping a die."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")

        # Keep first die
        initial_value = self.player1.dice.values[0]
        self.game.execute_action(self.player1, "toggle_die_0")

        assert 0 in self.player1.dice.kept
        assert self.player1.dice.values[0] == initial_value

    def test_unkeep_die(self):
        """Test unkeeping a kept die."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")

        # Keep first die
        self.game.execute_action(self.player1, "toggle_die_0")
        assert 0 in self.player1.dice.kept

        # Unkeep it
        self.game.execute_action(self.player1, "toggle_die_0")
        assert 0 not in self.player1.dice.kept

    def test_lock_kept_dice_on_roll(self):
        """Test that kept dice become locked on next roll."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")

        # Keep first die
        self.game.execute_action(self.player1, "toggle_die_0")
        assert 0 in self.player1.dice.kept
        assert 0 not in self.player1.dice.locked

        # Roll again - kept die should lock
        self.game.execute_action(self.player1, "roll")
        assert 0 in self.player1.dice.locked
        # After clear_kept=True, kept list contains locked indices
        assert 0 in self.player1.dice.kept

    def test_stop_action_ends_turn(self):
        """Test that bank action evaluates and ends turn."""
        random.seed(100)
        self.game.execute_action(self.player1, "roll")

        # Keep all dice by toggling them
        for i in range(6):
            self.game.execute_action(self.player1, f"toggle_die_{i}")

        # Roll to lock them all (autobank should trigger)
        old_player = self.game.current_player
        self.game.execute_action(self.player1, "roll")

        # Turn should have ended due to autobank
        assert self.game.current_player != old_player

    def test_qualification_with_1_and_4(self):
        """Test that having 1 and 4 qualifies the player."""
        # Manually set dice values to ensure we have 1 and 4
        self.player1.dice.values = [1, 4, 6, 6, 5, 3]
        self.player1.dice.locked = [0, 1, 2, 3, 4, 5]  # All locked

        self.game._score_turn(self.player1)

        assert self.player1.qualified is True
        # Score should be sum of other 4 dice: 6+6+5+3 = 20
        assert self.player1.round_score == 20

    def test_disqualification_without_1(self):
        """Test that not having 1 disqualifies."""
        self.player1.dice.values = [2, 4, 6, 6, 5, 3]
        self.player1.dice.locked = [0, 1, 2, 3, 4, 5]

        self.game._score_turn(self.player1)

        assert self.player1.qualified is False
        assert self.player1.round_score == 0

    def test_disqualification_without_4(self):
        """Test that not having 4 disqualifies."""
        self.player1.dice.values = [1, 2, 6, 6, 5, 3]
        self.player1.dice.locked = [0, 1, 2, 3, 4, 5]

        self.game._score_turn(self.player1)

        assert self.player1.qualified is False
        assert self.player1.round_score == 0

    def test_stop_hidden_before_roll(self):
        """Test that bank action is hidden before first roll."""
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "roll" in visible_ids
        assert "bank" not in visible_ids

    def test_stop_visible_after_roll(self):
        """Test that autobank triggers when rolling with 1 die left."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")

        # Keep and roll 5 times, locking 5 dice one at a time
        for i in range(5):
            # Find the first unlocked die
            for j in range(6):
                if not self.player1.dice.is_locked(j):
                    self.game.execute_action(self.player1, f"toggle_die_{j}")
                    break
            # After 5th keep, we have 1 die unlocked - rolling triggers autobank
            old_player = self.game.current_player
            self.game.execute_action(self.player1, "roll")
            if i == 4:  # After the 5th roll (6th total including first roll)
                # Turn should have ended due to autobank
                assert self.game.current_player != old_player
                return

        # Should not reach here
        assert False, "Autobank should have triggered"

    def test_auto_score_after_roll_focuses_roll_anchor_for_touch(self, monkeypatch):
        """Touch focus should return to Roll when rolling triggers auto-score."""
        self.user1.client_type = "mobile"
        self.player1.dice.values = [1, 4, 6, 5, 3, 2]
        self.player1.dice.locked = [0, 1, 2, 3]
        self.player1.dice.kept = [0, 1, 2, 3, 4]
        monkeypatch.setattr(dice_utils.random, "randint", lambda _low, _high: 6)

        self.game.execute_action(self.player1, "roll")
        self.game.flush_menus()

        assert self.game.current_player == self.player2
        assert latest_turn_selection(self.user1) == "roll"

    def test_dice_toggle_hidden_before_roll(self):
        """Test that dice toggle actions are hidden before first roll."""
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "toggle_die_0" not in visible_ids
        assert "toggle_die_1" not in visible_ids

    def test_dice_toggle_visible_after_roll(self):
        """Test that dice toggle actions are visible after roll."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")

        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        # At least some toggle actions should be visible (unlocked dice)
        toggle_actions = [id for id in visible_ids if id.startswith("toggle_die_")]
        assert len(toggle_actions) > 0

    def test_roll_focuses_first_selectable_die(self):
        """Test that rolling focuses the first dice keep option."""
        random.seed(42)

        self.game.execute_action(self.player1, "roll")
        self.game.flush_menus()

        assert self.user1.menus["turn_menu"]["selection_id"] == "toggle_die_0"

    def test_later_roll_focuses_first_unlocked_die(self):
        """Test that focus skips locked dice after later rolls."""
        random.seed(42)
        self.game.execute_action(self.player1, "roll")
        self.game.execute_action(self.player1, "toggle_die_0")

        self.game.execute_action(self.player1, "roll")
        self.game.flush_menus()

        menu = self.user1.menus["turn_menu"]
        visible_ids = [item.id for item in menu["items"] if getattr(item, "id", None)]
        assert "toggle_die_0" not in visible_ids
        assert "toggle_die_1" in visible_ids
        assert menu["selection_id"] == "toggle_die_1"

    def test_requires_turn(self):
        """Test that turn-required actions are only available on your turn."""
        p1_actions = self.game.get_all_visible_actions(self.player1)
        p2_actions = self.game.get_all_visible_actions(self.player2)

        p1_ids = [a.action.id for a in p1_actions]
        p2_ids = [a.action.id for a in p2_actions]

        p2_by_id = {a.action.id: a for a in p2_actions}

        assert "roll" in p1_ids
        assert "roll" in p2_ids
        assert p2_by_id["roll"].enabled is False
        assert p2_by_id["roll"].disabled_reason == "action-not-your-turn"

    def test_touch_status_actions_are_visible_and_ordered(self):
        """Touch clients get useful state checks before standard table actions."""
        self.user1.client_type = "web"
        standard_set = self.game.create_standard_action_set(self.player1)
        visible_ids = [
            a.action.id for a in standard_set.get_visible_actions(self.game, self.player1)
        ]

        ordered_subset = [
            action_id
            for action_id in visible_ids
            if action_id in {
                "check_dice",
                "check_round_status",
                "check_scores",
                "whose_turn",
                "whos_at_table",
            }
        ]
        assert ordered_subset == [
            "check_dice",
            "check_round_status",
            "check_scores",
            "whose_turn",
            "whos_at_table",
        ]

    def test_check_dice_reports_current_player_context(self):
        """Read current dice explains the active player's dice state."""
        self.player1.dice.values = [1, 4, 6, 5, 2, 3]
        self.player1.dice.kept = [0, 1, 2]
        self.player1.dice.locked = [0, 1]

        self.game.execute_action(self.player2, "check_dice")

        spoken = self.user2.get_last_spoken()
        assert spoken is not None
        assert "Alice's dice" in spoken
        assert "Current qualifying score would be 16" in spoken

    def test_round_tie_does_not_award_round_wins(self):
        """A tied high score is announced but no player receives a round win."""
        self.game.options.rounds = 1
        self.player1.qualified = True
        self.player2.qualified = True
        self.player1.round_score = 20
        self.player2.round_score = 20

        self.game._on_round_end()

        assert self.player1.round_wins == 0
        assert self.player2.round_wins == 0
        assert any("No round win is awarded" in msg for msg in self.user1.get_spoken_messages())

    def test_tied_game_result_has_no_single_winner(self):
        """Stored results should not invent a winner when round wins are tied."""
        self.player1.round_wins = 1
        self.player2.round_wins = 1

        result = self.game.build_game_result()

        assert result.custom_data["winner_name"] is None
        assert result.custom_data["winner_rounds"] == 1

    def test_score_actions_are_backed_by_round_wins(self):
        """Shared score actions report synchronized round-win totals."""
        self.player1.round_wins = 2
        self.player2.round_wins = 1
        self.game._sync_team_scores()

        self.game.execute_action(self.player1, "check_scores")

        spoken = self.user1.get_spoken_messages()
        assert any("Alice: 2 round wins" in msg for msg in spoken)
        assert any("Bob: 1 round win" in msg for msg in spoken)

    def test_invalid_round_count_is_contextual_start_error(self):
        """Directly invalid option state is blocked before start."""
        game = MidnightGame(options=MidnightOptions(rounds=0))
        errors = game.prestart_validate()

        assert (
            "midnight-error-rounds-out-of-range",
            {"rounds": 0, "min": 1, "max": 20},
        ) in errors

    def test_bot_keeps_multiple_useful_dice_before_rerolling(self):
        """Bot should not reroll immediately after keeping only one useful die."""
        self.player1.dice.values = [1, 4, 6, 2, 3, 5]
        self.player1.dice.kept = []
        self.player1.dice.locked = []

        assert self.game.bot_think(self.player1) == "toggle_die_0"
        self.game.execute_action(self.player1, "toggle_die_0")
        assert self.game.bot_think(self.player1) == "toggle_die_1"


class TestMidnightPlayTest:
    """
    Play tests that run complete games with bots.

    Following the testing strategy: games are ticked, saved and reloaded
    at each tick to verify persistence.
    """

    def test_two_player_game_completes(self):
        """Test that a 2-player game runs to completion."""
        random.seed(123)

        game = MidnightGame(options=MidnightOptions(rounds=2))
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()
        game.flush_menus()

        # Run game with periodic save/reload to test persistence
        max_ticks = 2000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            # Save and reload every 50 ticks to verify persistence
            if tick % 50 == 0 and tick > 0:
                json_str = game.to_json()
                game = MidnightGame.from_json(json_str)
                game.attach_user("Bot1", bot1)
                game.attach_user("Bot2", bot2)
                game.rebuild_runtime_state()
                for player in game.players:
                    game.setup_player_actions(player)

            game.on_tick()
            game.flush_menus()

        assert not game.game_active, "Game should have ended"
        # At least one player should have won a round
        max_wins = max(p.round_wins for p in game.players)
        assert max_wins >= 1

    def test_four_player_game_completes(self):
        """Test that a 4-player game runs to completion."""
        random.seed(456)

        game = MidnightGame(options=MidnightOptions(rounds=2))
        bots = [Bot(f"Bot{i}") for i in range(1, 5)]
        for bot in bots:
            game.add_player(bot.username, bot)

        game.on_start()
        game.flush_menus()

        max_ticks = 3000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            # Save and reload every 100 ticks
            if tick % 100 == 0 and tick > 0:
                json_str = game.to_json()
                game = MidnightGame.from_json(json_str)
                for bot in bots:
                    game.attach_user(bot.username, bot)
                game.rebuild_runtime_state()
                for player in game.players:
                    game.setup_player_actions(player)

            game.on_tick()
            game.flush_menus()

        assert not game.game_active

    def test_human_and_bot_game(self):
        """Test a game with one human and one bot."""
        random.seed(789)

        game = MidnightGame(options=MidnightOptions(rounds=1))
        human = MockUser("Human")
        bot = Bot("Bot")
        game.add_player("Human", human)
        game.add_player("Bot", bot)

        game.on_start()
        game.flush_menus()

        max_ticks = 2000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            current = game.current_player
            if current and current.name == "Human":
                # Simple human strategy: roll, keep 1 and 4, keep highest dice, roll or stop
                if not current.dice.has_rolled:
                    game.execute_action(current, "roll")
                elif current.dice.kept_unlocked_count > 0:
                    # Have kept dice, roll to lock them
                    game.execute_action(current, "roll")
                else:
                    # Check if we should keep something
                    found_action = False

                    # Keep 1 if we don't have it
                    locked_values = [current.dice.values[i] for i in current.dice.locked]
                    if 1 not in locked_values:
                        for i in range(6):
                            if not current.dice.is_locked(i) and current.dice.values[i] == 1:
                                game.execute_action(current, f"toggle_die_{i}")
                                found_action = True
                                break

                    # Keep 4 if we don't have it
                    if not found_action and 4 not in locked_values:
                        for i in range(6):
                            if not current.dice.is_locked(i) and current.dice.values[i] == 4:
                                game.execute_action(current, f"toggle_die_{i}")
                                found_action = True
                                break

                    # Keep highest
                    if not found_action:
                        best_i = -1
                        best_v = 0
                        for i in range(6):
                            if not current.dice.is_locked(i) and not current.dice.is_kept(i):
                                if current.dice.values[i] > best_v:
                                    best_v = current.dice.values[i]
                                    best_i = i
                        if best_i >= 0:
                            game.execute_action(current, f"toggle_die_{best_i}")
                            found_action = True

                    # Bank if nothing to do
                    if not found_action:
                        game.execute_action(current, "bank")
            else:
                game.on_tick()
                game.flush_menus()

        assert not game.game_active

        # Check that we got game messages
        messages = human.get_spoken_messages()
        assert len(messages) > 0
        assert any("Round" in m for m in messages)

    def test_different_round_counts(self):
        """Test game with different round counts."""
        for rounds in [1, 3, 10]:
            random.seed(100 + rounds)

            game = MidnightGame(options=MidnightOptions(rounds=rounds))
            bot1 = Bot("Bot1")
            bot2 = Bot("Bot2")
            game.add_player("Bot1", bot1)
            game.add_player("Bot2", bot2)

            game.on_start()
            game.flush_menus()

            for _ in range(rounds * 1000 + 1000):
                if not game.game_active:
                    break
                game.on_tick()
                game.flush_menus()

            assert not game.game_active, f"Game with {rounds} rounds should complete"


class TestMidnightPersistence:
    """Specific tests for game persistence."""

    def test_full_state_preserved(self):
        """Test that all game state is preserved through save/load."""
        game = MidnightGame(options=MidnightOptions(rounds=10))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)

        game.on_start()
        game.flush_menus()

        # Set various state
        game.round = 5
        game.turn_index = 1
        game.players[0].round_score = 18
        game.players[0].round_wins = 2
        game.players[0].qualified = True
        game.players[0].dice.values = [1, 4, 6, 5, 3, 2]
        game.players[0].dice.locked = [0, 1, 2]
        game.players[1].round_score = 0
        game.players[1].round_wins = 3
        game.players[1].qualified = False

        # Save
        json_str = game.to_json()

        # Load
        loaded = MidnightGame.from_json(json_str)

        # Verify all state
        assert loaded.game_active is True
        assert loaded.round == 5
        assert loaded.options.rounds == 10
        assert loaded.players[0].round_score == 18
        assert loaded.players[0].round_wins == 2
        assert loaded.players[0].qualified is True
        assert loaded.players[0].dice.values == [1, 4, 6, 5, 3, 2]
        assert loaded.players[0].dice.locked == [0, 1, 2]
        assert loaded.players[1].round_score == 0
        assert loaded.players[1].round_wins == 3
        assert loaded.players[1].qualified is False

    def test_actions_work_after_reload(self):
        """Test that actions work correctly after reloading."""
        game = MidnightGame()
        user = MockUser("Alice")
        bot = Bot("Bot")
        game.add_player("Alice", user)
        game.add_player("Bot", bot)
        game.on_start()
        game.flush_menus()

        # Do some actions
        game.execute_action(game.players[0], "roll")

        # Save and reload
        json_str = game.to_json()
        game = MidnightGame.from_json(json_str)
        game.attach_user("Alice", user)
        game.attach_user("Bot", bot)
        for player in game.players:
            game.setup_player_actions(player)

        # Actions should still work
        actions = game.get_all_enabled_actions(game.players[0])
        assert len(actions) > 0


def test_midnight_locale_key_and_variable_parity():
    """English and Vietnamese Midnight locale files must stay structurally synced."""
    root = Path(__file__).resolve().parents[1]
    en_text = (root / "locales" / "en" / "midnight.ftl").read_text(encoding="utf-8")
    vi_text = (root / "locales" / "vi" / "midnight.ftl").read_text(encoding="utf-8")

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
                    r"\{\s*\$([a-zA-Z_][\w-]*)",
                    "\n".join(current_lines),
                )
            )
        return result

    assert messages(en_text) == messages(vi_text)


if __name__ == "__main__":
    pytest.main([__file__, "-v"])

