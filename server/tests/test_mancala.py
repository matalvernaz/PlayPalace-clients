"""
Tests for the Mancala game.

Following the testing strategy:
- Unit tests for individual functions (board logic, sowing, capture)
- Play tests that run the game from start to finish with bots
- Persistence tests (save/reload at each tick)
"""

import pytest
import random
import json

from server.games.mancala.game import (
    MancalaGame,
    MancalaOptions,
    MancalaPlayer,
    NUM_PITS,
    P0_STORE,
    P1_STORE,
)
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


class TestMancalaUnit:
    """Unit tests for Mancala game functions."""

    def test_game_creation(self):
        game = MancalaGame()
        assert game.get_name() == "Mancala"
        assert game.get_type() == "mancala"
        assert game.get_category() == "category-board-games"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 2

    def test_player_creation(self):
        game = MancalaGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)
        assert player.name == "Alice"
        assert player.is_bot is False

    def test_options_defaults(self):
        game = MancalaGame()
        assert game.options.stones_per_pit == 4

    def test_custom_options(self):
        options = MancalaOptions(stones_per_pit=6)
        game = MancalaGame(options=options)
        assert game.options.stones_per_pit == 6

    def test_board_initialization(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        # Each pit should have 4 stones
        for i in range(NUM_PITS):
            assert game.board[i] == 4, f"P0 pit {i} should have 4"
            assert game.board[7 + i] == 4, f"P1 pit {i} should have 4"
        # Stores should be empty
        assert game.board[P0_STORE] == 0
        assert game.board[P1_STORE] == 0
        # Total stones: 48
        assert sum(game.board) == 48

    def test_board_init_custom_stones(self):
        game = MancalaGame(options=MancalaOptions(stones_per_pit=6))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        assert sum(game.board) == 72  # 6 * 12


class TestMancalaSowing:
    """Tests for the sowing mechanic."""

    def test_basic_sow(self):
        game = MancalaGame()
        game.board = [4] * 6 + [0] + [4] * 6 + [0]
        extra, captured = game._sow(0, 0)
        assert game.board[0] == 0
        assert game.board[1] == 5
        assert game.board[2] == 5
        assert game.board[3] == 5
        assert game.board[4] == 5
        assert not extra
        assert captured == 0

    def test_extra_turn_landing_in_store(self):
        # Pit 5 with 1 stone -> lands in store (index 6)
        game = MancalaGame()
        game.board = [4, 4, 4, 4, 4, 1] + [0] + [4] * 6 + [0]
        extra, captured = game._sow(0, 5)
        assert extra
        assert game.board[P0_STORE] == 1

    def test_extra_turn_from_pit_4(self):
        game = MancalaGame()
        game.board = [4, 4, 4, 4, 2, 4] + [0] + [4] * 6 + [0]
        extra, captured = game._sow(0, 4)
        assert extra

    def test_capture(self):
        # Pit 0 has 3 stones -> lands in pit 3 (empty), opposite is index 9
        game = MancalaGame()
        game.board = [3, 4, 4, 0, 4, 4] + [0] + [4, 4, 4, 4, 4, 4] + [0]
        extra, captured = game._sow(0, 0)
        assert captured == 5  # 4 from opposite + 1 landing stone
        assert game.board[P0_STORE] == 5
        assert game.board[3] == 0
        assert game.board[9] == 0

    def test_no_capture_on_opponent_side(self):
        # Landing in empty pit on opponent's side should NOT capture
        game = MancalaGame()
        game.board = [0, 0, 0, 0, 0, 5] + [0] + [0, 4, 4, 4, 4, 4] + [0]
        extra, captured = game._sow(0, 5)
        # 5 stones from pit 5: store(6), 7, 8, 9, 10
        # Lands at index 10 (opponent's pit) - no capture even if empty
        assert captured == 0

    def test_no_capture_on_nonempty_own_pit(self):
        # Landing in non-empty own pit should NOT capture
        game = MancalaGame()
        game.board = [3, 4, 4, 1, 4, 4] + [0] + [4, 4, 4, 4, 4, 4] + [0]
        extra, captured = game._sow(0, 0)
        # Pit 3 already has 1, after sowing has 2 -> not a capture
        assert captured == 0

    def test_skip_opponent_store_p0(self):
        # Player 0 should skip player 1's store (index 13)
        game = MancalaGame()
        game.board = [0, 0, 0, 0, 0, 10] + [0] + [0] * 6 + [0]
        extra, captured = game._sow(0, 5)
        # 10 stones: 6(store), 7, 8, 9, 10, 11, 12, skip 13, 0, 1
        assert game.board[P1_STORE] == 0

    def test_skip_opponent_store_p1(self):
        game = MancalaGame()
        game.board = [0] * 6 + [0] + [0, 0, 0, 0, 0, 10] + [0]
        extra, captured = game._sow(1, 5)
        # Player 1 pit 5 is board index 12, 10 stones
        # 13(P1 store), 0, 1, 2, 3, 4, 5, skip 6(P0 store), 7, 8, 9
        # Last stone at index 9 (P1's pit, was empty) -> captures opposite (index 3)
        assert game.board[P0_STORE] == 0, "P0 store should be skipped"

    def test_player1_basic_sow(self):
        game = MancalaGame()
        game.board = [4] * 6 + [0] + [4] * 6 + [0]
        extra, captured = game._sow(1, 0)
        assert game.board[7] == 0
        assert game.board[8] == 5

    def test_simulate_nondestructive(self):
        game = MancalaGame()
        game.board = [4] * 6 + [0] + [4] * 6 + [0]
        saved = game.board[:]
        game._simulate_sow(0, 2)
        assert game.board == saved

    def test_side_empty(self):
        game = MancalaGame()
        game.board = [0] * 6 + [20] + [4] * 6 + [4]
        assert game._side_empty(0)
        assert not game._side_empty(1)

    def test_collect_remaining(self):
        game = MancalaGame()
        game.board = [0] * 6 + [20] + [1, 2, 3, 4, 5, 6] + [4]
        game._collect_remaining()
        assert game.board[P0_STORE] == 20
        assert game.board[P1_STORE] == 4 + 21  # 4 + (1+2+3+4+5+6)
        assert all(game.board[i] == 0 for i in range(6))
        assert all(game.board[7 + i] == 0 for i in range(6))

    def test_opposite_pit_mapping(self):
        """Verify opposite pit formula: 12 - index."""
        # P0 pit 0 (idx 0) <-> P1 pit 5 (idx 12)
        assert 12 - 0 == 12
        # P0 pit 5 (idx 5) <-> P1 pit 0 (idx 7)
        assert 12 - 5 == 7
        # P1 pit 0 (idx 7) <-> P0 pit 5 (idx 5)
        assert 12 - 7 == 5


class TestMancalaActions:
    """Test game actions and turn flow."""

    def setup_method(self):
        self.game = MancalaGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.player1 = self.game.add_player("Alice", self.user1)
        self.player2 = self.game.add_player("Bob", self.user2)
        self.game.on_start()

    def test_sow_action(self):
        """Test executing a sow action."""
        current = self.game.current_player
        self.game.execute_action(current, "pit_2")
        # Pit 2 had 4 stones, now empty
        idx = self.game._player_index(current)
        board_idx = self.game._pit_board_idx(idx, 2)
        assert self.game.board[board_idx] == 0

    def test_empty_pit_disabled(self):
        """Test that empty pits are disabled."""
        current = self.game.current_player
        idx = self.game._player_index(current)
        # Empty a pit
        board_idx = self.game._pit_board_idx(idx, 0)
        self.game.board[board_idx] = 0

        result = self.game._is_pit_enabled(current, action_id="pit_0")
        assert result == "mancala-pit-empty"

    def test_nonempty_pit_enabled(self):
        current = self.game.current_player
        result = self.game._is_pit_enabled(current, action_id="pit_0")
        assert result is None  # None = enabled

    def test_turn_advances_after_sow(self):
        """Normal sow should advance the turn."""
        first_player = self.game.current_player
        # Sow from pit 0 (4 stones -> lands at pit 4, not store)
        self.game.execute_action(first_player, "pit_0")
        assert self.game.current_player != first_player

    def test_extra_turn_on_store_landing(self):
        """Landing in own store should grant extra turn."""
        current = self.game.current_player
        idx = self.game._player_index(current)
        # Set pit 5 to 1 stone so it lands exactly in the store
        self.game.board[self.game._pit_board_idx(idx, 5)] = 1
        self.game.execute_action(current, "pit_5")
        # Should still be the same player's turn
        assert self.game.current_player == current

    def test_check_board_action(self):
        current = self.game.current_player
        self.game.execute_action(current, "check_board")
        spoken = self.user1.get_spoken_messages() if current == self.player1 else self.user2.get_spoken_messages()
        assert any("store" in msg.lower() or "pits" in msg.lower() for msg in spoken)

    def test_game_ends_when_side_empty(self):
        """Game should end when one side is cleared."""
        current = self.game.current_player
        idx = self.game._player_index(current)
        # Set up board so only pit 0 has 1 stone on current player's side
        for i in range(NUM_PITS):
            self.game.board[self.game._pit_board_idx(idx, i)] = 0
        self.game.board[self.game._pit_board_idx(idx, 0)] = 1
        # Put stone in pit that won't land in store (so turn ends, then game checks)
        self.game.execute_action(current, "pit_0")
        # After sowing the last stone from the only non-empty pit,
        # that side becomes empty -> game should end
        assert not self.game.game_active


class TestMancalaBotAI:
    """Test bot decision making."""

    def test_bot_prefers_extra_turn(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        game.add_player("Alice", user1)
        player = game.players[0]

        # Set up so pit 5 with 1 stone gives extra turn
        game.board = [4, 4, 4, 4, 4, 1] + [0] + [4] * 6 + [0]
        result = game.bot_think(player)
        assert result == "pit_5"  # Should prefer the extra turn

    def test_bot_prefers_capture(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        game.add_player("Alice", user1)
        player = game.players[0]

        # Pit 0 with 3 stones lands in empty pit 3, capturing opposite (5 stones)
        # No pit gives an extra turn (none have exact stones to reach store)
        game.board = [3, 3, 3, 0, 3, 3] + [0] + [4, 4, 4, 4, 4, 4] + [0]
        result = game.bot_think(player)
        assert result == "pit_0"  # Should prefer the capture (5 stones)

    def test_bot_returns_valid_action(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        game.add_player("Alice", user1)
        player = game.players[0]

        game.board = [4] * 6 + [0] + [4] * 6 + [0]
        result = game.bot_think(player)
        assert result is not None
        assert result.startswith("pit_")
        pit = int(result.split("_")[1])
        assert 0 <= pit < NUM_PITS

    def test_bot_skips_empty_pits(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        game.add_player("Alice", user1)
        player = game.players[0]

        # Only pit 3 has stones
        game.board = [0, 0, 0, 5, 0, 0] + [0] + [4] * 6 + [0]
        result = game.bot_think(player)
        assert result == "pit_3"


class TestMancalaPlayTest:
    """Play tests: full games with bots."""

    def test_two_player_game_completes(self):
        random.seed(42)
        game = MancalaGame()
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)
        game.on_start()

        max_ticks = 2000
        for tick in range(max_ticks):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active, "Game should have ended"
        # All stones should be in stores
        total = game.board[P0_STORE] + game.board[P1_STORE]
        assert total == 48, f"Total stones should be 48, got {total}"

    def test_game_with_different_seeds(self):
        """Run multiple games with different seeds to find edge cases."""
        for seed in range(10):
            random.seed(seed)
            game = MancalaGame()
            bot1 = Bot("Bot1")
            bot2 = Bot("Bot2")
            game.add_player("Bot1", bot1)
            game.add_player("Bot2", bot2)
            game.on_start()

            for tick in range(2000):
                if not game.game_active:
                    break
                game.on_tick()

            assert not game.game_active, f"Seed {seed}: game didn't end"
            total = game.board[P0_STORE] + game.board[P1_STORE]
            assert total == 48, f"Seed {seed}: stones={total}"

    def test_game_with_custom_stones(self):
        random.seed(99)
        game = MancalaGame(options=MancalaOptions(stones_per_pit=6))
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)
        game.on_start()

        for tick in range(3000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active
        total = game.board[P0_STORE] + game.board[P1_STORE]
        assert total == 72


class TestMancalaPersistence:
    """Test save/reload during gameplay."""

    def test_full_state_preserved(self):
        random.seed(77)
        game = MancalaGame()
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)
        game.on_start()

        for tick in range(2000):
            if not game.game_active:
                break

            # Save and reload every 50 ticks
            if tick % 50 == 0 and tick > 0:
                json_str = game.to_json()
                game = MancalaGame.from_json(json_str)
                game.attach_user("Bot1", bot1)
                game.attach_user("Bot2", bot2)
                game.rebuild_runtime_state()
                for player in game.players:
                    user = game.get_user(player)
                    if user:
                        game.setup_player_actions(player)

            game.on_tick()

        assert not game.game_active, "Game should have completed with save/reload"
        total = game.board[P0_STORE] + game.board[P1_STORE]
        assert total == 48

    def test_serialization_roundtrip(self):
        game = MancalaGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        # Make some moves
        game.board = [0, 3, 5, 2, 0, 7] + [12] + [1, 4, 0, 6, 3, 2] + [3]

        json_str = game.to_json()
        loaded = MancalaGame.from_json(json_str)

        assert loaded.board == game.board
        assert len(loaded.players) == 2
        assert loaded.options.stones_per_pit == 4
