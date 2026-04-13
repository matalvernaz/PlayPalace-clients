"""Tests for Exploding Kittens."""

import random

from server.games.explodingkittens.game import ExplodingKittensGame
from server.games.explodingkittens.player import EKPlayer
from server.games.explodingkittens.state import (
    CARD_DEFUSE,
    CARD_EXPLODING_KITTEN,
    CARD_NOPE,
    CARD_SKIP,
    CARD_TACOCAT,
    build_starting_deck,
    hand_count,
    hand_summary,
    is_action_card,
    is_cat_card,
    remove_one,
)
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


# ---------------------------------------------------------------------------
# State / deck construction
# ---------------------------------------------------------------------------

class TestDeckConstruction:
    def test_each_player_gets_one_defuse(self):
        rng = random.Random(0)
        hands, _deck = build_starting_deck(player_count=4, rng=rng)
        for hand in hands:
            assert hand.count(CARD_DEFUSE) == 1

    def test_hand_size_default(self):
        rng = random.Random(0)
        hands, _deck = build_starting_deck(player_count=4, rng=rng)
        # 1 defuse + 7 cards
        for hand in hands:
            assert len(hand) == 8

    def test_hand_size_custom(self):
        rng = random.Random(0)
        hands, _deck = build_starting_deck(player_count=3, rng=rng, hand_size=4)
        for hand in hands:
            assert len(hand) == 5  # 1 defuse + 4

    def test_no_exploding_kittens_in_starting_hands(self):
        rng = random.Random(0)
        hands, _deck = build_starting_deck(player_count=5, rng=rng)
        for hand in hands:
            assert CARD_EXPLODING_KITTEN not in hand

    def test_correct_number_of_kittens_in_deck(self):
        rng = random.Random(0)
        for n in (2, 3, 4, 5):
            _hands, deck = build_starting_deck(player_count=n, rng=rng)
            assert deck.count(CARD_EXPLODING_KITTEN) == n - 1

    def test_streaking_kitten_added(self):
        rng = random.Random(0)
        _hands, deck = build_starting_deck(player_count=3, rng=rng, streaking_kittens=True)
        assert deck.count("streaking-kitten") == 1


class TestHandHelpers:
    def test_hand_count(self):
        hand = [CARD_SKIP, CARD_SKIP, CARD_NOPE, CARD_DEFUSE]
        assert hand_count(hand, CARD_SKIP) == 2
        assert hand_count(hand, CARD_NOPE) == 1
        assert hand_count(hand, CARD_TACOCAT) == 0

    def test_remove_one(self):
        hand = [CARD_SKIP, CARD_SKIP, CARD_NOPE]
        assert remove_one(hand, CARD_SKIP)
        assert hand == [CARD_SKIP, CARD_NOPE]
        assert not remove_one(hand, CARD_TACOCAT)

    def test_summary(self):
        s = hand_summary([CARD_SKIP, CARD_SKIP, CARD_NOPE])
        assert s == {CARD_SKIP: 2, CARD_NOPE: 1}

    def test_is_action_card(self):
        assert is_action_card(CARD_SKIP)
        assert not is_action_card(CARD_TACOCAT)
        assert not is_action_card(CARD_DEFUSE)

    def test_is_cat_card(self):
        assert is_cat_card(CARD_TACOCAT)
        assert not is_cat_card(CARD_SKIP)


# ---------------------------------------------------------------------------
# Game setup + serialization
# ---------------------------------------------------------------------------

class TestGameSetup:
    def test_metadata(self):
        game = ExplodingKittensGame()
        assert game.get_type() == "explodingkittens"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 5

    def test_player_creation(self):
        game = ExplodingKittensGame()
        user = MockUser("Alice")
        p = game.add_player("Alice", user)
        assert isinstance(p, EKPlayer)

    def test_on_start_deals_hands(self):
        game = ExplodingKittensGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        for p in game.players:
            assert hand_count(p.hand, CARD_DEFUSE) == 1
            assert len(p.hand) == 1 + game.options.hand_size


class TestSerialization:
    def test_round_trip(self):
        game = ExplodingKittensGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        game.players[0].hand = [CARD_SKIP, CARD_NOPE, CARD_DEFUSE]
        game.players[0].eliminated = False
        game.players[0].has_streaking_kitten = True
        game.players[0].last_peek = [CARD_TACOCAT, CARD_SKIP]
        game.draws_owed = 3
        game.pending_action = {
            "actor_id": "x", "card": CARD_SKIP, "params": {}, "cancelled": True,
        }
        game.nope_window_ticks = 50
        loaded = ExplodingKittensGame.from_json(game.to_json())
        assert loaded.players[0].hand == [CARD_SKIP, CARD_NOPE, CARD_DEFUSE]
        assert loaded.players[0].has_streaking_kitten
        assert loaded.players[0].last_peek == [CARD_TACOCAT, CARD_SKIP]
        assert loaded.draws_owed == 3
        assert loaded.pending_action["cancelled"] is True
        assert loaded.nope_window_ticks == 50


# ---------------------------------------------------------------------------
# Action effects
# ---------------------------------------------------------------------------

class TestActions:
    def setup_method(self):
        self.game = ExplodingKittensGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.alice = self.game.add_player("Alice", self.user1)
        self.bob = self.game.add_player("Bob", self.user2)
        self.game.on_start()
        # Clean state for predictable tests.
        for p in self.game.players:
            p.hand = [CARD_DEFUSE]
        self.game.deck = []
        self.game.discard = []
        self.game.draws_owed = 1
        self.game.pending_action = None
        self.game.nope_window_ticks = 0

    def test_skip_resolves_immediately_with_no_nope(self):
        self.alice.hand = [CARD_SKIP, CARD_DEFUSE]
        self.game.options.nope_window_seconds = 0  # fire immediately
        self.game._action_play_simple(self.alice, "play_skip")
        # Manually close the (already 0-tick) window.
        self.game.nope_window_ticks = 0
        self.game._close_nope_window()
        # Skip ends the turn.
        assert self.game.current_player is self.bob

    def test_attack_transfers_draws(self):
        self.alice.hand = [CARD_ATTACK := "attack", CARD_DEFUSE]
        self.game.options.nope_window_seconds = 0
        self.game._action_play_simple(self.alice, f"play_{CARD_ATTACK}")
        self.game._close_nope_window()
        assert self.game.current_player is self.bob
        # Bob should owe 2 draws now (1 + 2 - 1 normalization? actually current+2).
        assert self.game.draws_owed == 3

    def test_nope_cancels_action(self):
        self.alice.hand = [CARD_SKIP, CARD_DEFUSE]
        self.bob.hand = [CARD_NOPE, CARD_DEFUSE]
        self.game.options.nope_window_seconds = 1
        self.game._action_play_simple(self.alice, "play_skip")
        # Bob plays Nope mid-window.
        self.game._action_play_nope(self.bob, "play_nope")
        assert self.game.pending_action is not None
        assert self.game.pending_action["cancelled"]
        # Close the window — cancelled actions don't fire.
        self.game.nope_window_ticks = 0
        self.game._close_nope_window()
        # Skip was cancelled, so it's still Alice's turn.
        assert self.game.current_player is self.alice

    def test_nope_chain_un_cancels(self):
        self.alice.hand = [CARD_SKIP, CARD_NOPE, CARD_DEFUSE]
        self.bob.hand = [CARD_NOPE, CARD_NOPE, CARD_DEFUSE]
        self.game.options.nope_window_seconds = 1
        self.game._action_play_simple(self.alice, "play_skip")
        self.game._action_play_nope(self.bob, "play_nope")  # cancelled
        # Alice un-Nopes.
        self.game._action_play_nope(self.alice, "play_nope")
        assert self.game.pending_action["cancelled"] is False
        self.game.nope_window_ticks = 0
        self.game._close_nope_window()
        assert self.game.current_player is self.bob

    def test_draw_safe_card_ends_turn(self):
        self.alice.hand = [CARD_DEFUSE]
        self.game.deck = [CARD_SKIP]
        self.game._action_draw(self.alice, "draw")
        assert CARD_SKIP in self.alice.hand
        assert self.game.current_player is self.bob

    def test_draw_exploding_kitten_with_defuse_prompts_position(self):
        self.alice.hand = [CARD_DEFUSE]
        self.game.deck = [CARD_EXPLODING_KITTEN]
        self.game._action_draw(self.alice, "draw")
        assert CARD_DEFUSE not in self.alice.hand
        assert CARD_EXPLODING_KITTEN not in self.alice.hand
        assert self.alice.pending == "defuse_position"

    def test_draw_exploding_kitten_no_defuse_eliminates(self):
        self.alice.hand = []  # no defuse
        self.game.deck = [CARD_EXPLODING_KITTEN]
        self.game._action_draw(self.alice, "draw")
        assert self.alice.eliminated

    def test_streaking_kitten_passive_ek_immunity(self):
        self.alice.hand = []
        self.alice.has_streaking_kitten = True
        self.game.deck = [CARD_EXPLODING_KITTEN]
        self.game._action_draw(self.alice, "draw")
        assert not self.alice.eliminated


# ---------------------------------------------------------------------------
# Full-game play test
# ---------------------------------------------------------------------------

class TestPlayToCompletion:
    def test_three_bot_game_completes(self):
        random.seed(11)
        game = ExplodingKittensGame()
        for name in ("Bot1", "Bot2", "Bot3"):
            game.add_player(name, Bot(name))
        # Shorten Nope window so the game progresses faster.
        game.options.nope_window_seconds = 2
        game.on_start()
        for tick in range(50_000):
            if not game.game_active:
                break
            if tick and tick % 1500 == 0:
                data = game.to_json()
                game = ExplodingKittensGame.from_json(data)
                for p in game.players:
                    game.attach_user(p.name, Bot(p.name))
                game.rebuild_runtime_state()
                for p in game.players:
                    game.setup_player_actions(p)
                game.options.nope_window_seconds = 2
            game.on_tick()
        assert not game.game_active
        survivors = [p for p in game.players if not p.eliminated]
        assert len(survivors) == 1
