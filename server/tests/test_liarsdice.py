"""Tests for Liar's Dice."""

import random

from server.games.liarsdice.game import LiarsDiceGame
from server.games.liarsdice.player import LiarsDicePlayer
from server.games.liarsdice.state import (
    count_face,
    enumerate_valid_bids,
    is_higher_bid,
)
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


# ---------------------------------------------------------------------------
# State / bid validation
# ---------------------------------------------------------------------------

class TestCountFace:
    def test_count_no_wild(self):
        assert count_face([1, 2, 2, 3, 6], face=2, wild_ones=False) == 2

    def test_count_with_wild_for_non_one(self):
        assert count_face([1, 2, 2, 3, 6], face=2, wild_ones=True) == 3

    def test_count_with_wild_for_ones(self):
        assert count_face([1, 1, 2, 3, 6], face=1, wild_ones=True) == 2


class TestBidValidation:
    def test_first_bid_is_always_valid(self):
        assert is_higher_bid((1, 2), None, wild_ones=True)
        assert is_higher_bid((5, 6), None, wild_ones=False)

    def test_higher_quantity_same_face(self):
        assert is_higher_bid((4, 3), (3, 3), wild_ones=True)
        assert not is_higher_bid((3, 3), (3, 3), wild_ones=True)

    def test_higher_face_same_quantity_with_wild(self):
        assert is_higher_bid((3, 4), (3, 3), wild_ones=True)
        assert not is_higher_bid((3, 2), (3, 3), wild_ones=True)

    def test_switching_to_ones_halves_quantity(self):
        # (5, 6) -> (3, 1) is valid (ceil(5/2) = 3)
        assert is_higher_bid((3, 1), (5, 6), wild_ones=True)
        assert not is_higher_bid((2, 1), (5, 6), wild_ones=True)

    def test_switching_from_ones_doubles_plus_one(self):
        # (3, 1) -> (7, 4) is valid (2*3+1 = 7)
        assert is_higher_bid((7, 4), (3, 1), wild_ones=True)
        assert not is_higher_bid((6, 4), (3, 1), wild_ones=True)

    def test_no_wild_ordering(self):
        assert is_higher_bid((3, 2), (3, 1), wild_ones=False)
        assert is_higher_bid((4, 1), (3, 6), wild_ones=False)
        assert not is_higher_bid((3, 6), (3, 6), wild_ones=False)


class TestEnumerateBids:
    def test_no_current_bid_returns_minimal(self):
        bids = enumerate_valid_bids(current=None, total_dice=10, wild_ones=True)
        assert (1, 1) in bids
        assert (1, 6) in bids

    def test_current_bid_excludes_lower(self):
        bids = enumerate_valid_bids(current=(3, 4), total_dice=10, wild_ones=True)
        for q, f in bids:
            assert is_higher_bid((q, f), (3, 4), wild_ones=True)

    def test_max_options_cap(self):
        bids = enumerate_valid_bids(
            current=None, total_dice=100, wild_ones=True, max_options=20,
        )
        assert len(bids) == 20


# ---------------------------------------------------------------------------
# Game setup + serialization
# ---------------------------------------------------------------------------

class TestGameSetup:
    def test_metadata(self):
        game = LiarsDiceGame()
        assert game.get_type() == "liarsdice"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 6

    def test_on_start_deals_dice(self):
        game = LiarsDiceGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        for p in game.players:
            assert p.dice_count == game.options.starting_dice
            assert len(p.dice) == game.options.starting_dice
            assert all(1 <= d <= 6 for d in p.dice)


class TestSerialization:
    def test_round_trip_preserves_state(self):
        game = LiarsDiceGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        game.players[0].dice = [1, 2, 3, 4, 5]
        game.players[0].dice_count = 5
        game.current_bid = (4, 6)
        game.last_bidder_id = game.players[1].id
        game.round_no = 7
        loaded = LiarsDiceGame.from_json(game.to_json())
        assert loaded.players[0].dice == [1, 2, 3, 4, 5]
        assert loaded.current_bid == (4, 6)
        assert loaded.last_bidder_id == game.players[1].id
        assert loaded.round_no == 7


# ---------------------------------------------------------------------------
# Reveal logic
# ---------------------------------------------------------------------------

class TestReveal:
    def setup_method(self):
        self.game = LiarsDiceGame()
        self.alice = self.game.add_player("Alice", MockUser("Alice"))
        self.bob = self.game.add_player("Bob", MockUser("Bob"))
        self.game.on_start()

    def test_liar_call_punishes_overbid(self):
        # Force known dice.
        self.alice.dice = [2, 3, 4, 5, 6]
        self.bob.dice = [2, 3, 4, 5, 6]
        # Bid: 5 sixes. Actual sixes (with wilds): 2 sixes + 0 ones = 2. Bid > actual → bidder loses.
        self.game.current_bid = (5, 6)
        self.game.last_bidder_id = self.alice.id
        self.game._resolve_reveal(challenger=self.bob, mode="liar")
        assert self.alice.dice_count == self.game.options.starting_dice - 1

    def test_liar_call_punishes_truthful_challenge(self):
        self.alice.dice = [6, 6, 6, 1, 1]
        self.bob.dice = [6, 1, 6, 6, 6]
        # Bid: 4 sixes. Actual sixes (with wilds): 7 (3 sixes + 2 ones from Alice; 4 sixes + 1 one from Bob).
        self.game.current_bid = (4, 6)
        self.game.last_bidder_id = self.alice.id
        self.game._resolve_reveal(challenger=self.bob, mode="liar")
        assert self.bob.dice_count == self.game.options.starting_dice - 1

    def test_spot_on_correct_others_lose(self):
        self.alice.dice = [3, 4, 5, 6, 1]
        self.bob.dice = [3, 4, 5, 6, 1]
        # Sixes with wilds: 1 + 1 (six) + 1 + 1 (ones) = 4.
        self.game.current_bid = (4, 6)
        self.game.last_bidder_id = self.alice.id
        self.game.options.spot_on = True
        starting = self.game.options.starting_dice
        self.game._resolve_reveal(challenger=self.bob, mode="spot_on")
        # bob called correctly → alice (the bidder, "other") loses 1
        # bob keeps all dice
        assert self.alice.dice_count == starting - 1
        assert self.bob.dice_count == starting

    def test_spot_on_wrong_caller_loses_two(self):
        self.alice.dice = [2, 2, 2, 2, 2]
        self.bob.dice = [3, 3, 3, 3, 3]
        self.game.current_bid = (10, 6)
        self.game.last_bidder_id = self.alice.id
        self.game.options.spot_on = True
        starting = self.game.options.starting_dice
        self.game._resolve_reveal(challenger=self.bob, mode="spot_on")
        assert self.bob.dice_count == starting - 2


# ---------------------------------------------------------------------------
# Full-game play test
# ---------------------------------------------------------------------------

class TestPlayToCompletion:
    def test_two_bot_game_completes(self):
        random.seed(3)
        game = LiarsDiceGame()
        for name in ("Bot1", "Bot2"):
            game.add_player(name, Bot(name))
        game.on_start()
        for tick in range(50_000):
            if not game.game_active:
                break
            if tick and tick % 1500 == 0:
                data = game.to_json()
                game = LiarsDiceGame.from_json(data)
                for p in game.players:
                    game.attach_user(p.name, Bot(p.name))
                game.rebuild_runtime_state()
                for p in game.players:
                    game.setup_player_actions(p)
            game.on_tick()
        assert not game.game_active
        survivors = [p for p in game.players if not p.eliminated]
        assert len(survivors) == 1

    def test_no_wild_no_spot_on_completes(self):
        random.seed(8)
        game = LiarsDiceGame()
        game.options.wild_ones = False
        game.options.spot_on = False
        for name in ("Bot1", "Bot2", "Bot3"):
            game.add_player(name, Bot(name))
        game.on_start()
        for _ in range(50_000):
            if not game.game_active:
                break
            game.on_tick()
        assert not game.game_active
