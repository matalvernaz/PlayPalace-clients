"""Tests for The Game of Life."""

import random

from server.games.life.game import GameOfLifeGame
from server.games.life.player import LifePlayer
from server.games.life.options import LifeOptions
from server.games.life.state import (
    ACRES_BONUS,
    CANONICAL_CAREERS,
    EVENT_DECK,
    RISK_IT_STAKE,
    STOCK_COST,
    STOCK_PAYOUT,
    SpaceType,
    TRACK_LENGTHS,
    build_track,
    filter_events_for_options,
)
from server.games.life import bot as life_bot
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


# ---------------------------------------------------------------------------
# Unit tests — state module
# ---------------------------------------------------------------------------

class TestTrackBuilder:
    def test_short_track_length(self):
        track = build_track("short")
        assert len(track) == TRACK_LENGTHS["short"]
        assert track[0].type == SpaceType.START
        assert track[-1].type == SpaceType.FINISH

    def test_standard_track_length(self):
        track = build_track("standard")
        assert len(track) == TRACK_LENGTHS["standard"]

    def test_long_track_length(self):
        track = build_track("long")
        assert len(track) == TRACK_LENGTHS["long"]

    def test_track_has_retire_junction(self):
        for length_key in ("short", "standard", "long"):
            track = build_track(length_key)
            assert any(s.type == SpaceType.RETIRE_JUNCTION for s in track), length_key

    def test_track_has_paydays(self):
        track = build_track("standard")
        assert sum(1 for s in track if s.type == SpaceType.PAYDAY) >= 3

    def test_track_has_events(self):
        track = build_track("standard")
        assert sum(1 for s in track if s.type == SpaceType.EVENT) >= 3

    def test_unknown_length_defaults_to_standard(self):
        track = build_track("bogus")
        assert len(track) == TRACK_LENGTHS["standard"]


class TestEventFilter:
    def test_stock_market_off_drops_lawsuits(self):
        filtered = filter_events_for_options(EVENT_DECK, False, "full", "hidden")
        assert not any(e.effect == "lawsuit" for e in filtered)

    def test_stock_market_on_keeps_lawsuits(self):
        filtered = filter_events_for_options(EVENT_DECK, True, "full", "hidden")
        assert any(e.effect == "lawsuit" for e in filtered)

    def test_life_tiles_off_converts_tile_events_to_cash(self):
        filtered = filter_events_for_options(EVENT_DECK, True, "full", "off")
        tile_converted = [e for e in filtered if e.effect == "cash_gain" and e.amount == 30_000]
        # At least one of the original four life-tile events became a cash event.
        assert len(tile_converted) >= 4


class TestCareerCards:
    def test_canonical_has_degree_and_nondegree(self):
        degree = [c for c in CANONICAL_CAREERS if c.degree_required]
        nondegree = [c for c in CANONICAL_CAREERS if not c.degree_required]
        assert len(degree) >= 3
        assert len(nondegree) >= 3


# ---------------------------------------------------------------------------
# Bot heuristic tests
# ---------------------------------------------------------------------------

class TestBotHeuristics:
    def _player(self, **kwargs) -> LifePlayer:
        p = LifePlayer(id="test", name="Test", is_bot=True)
        for k, v in kwargs.items():
            setattr(p, k, v)
        return p

    def test_pick_career_chooses_highest_salary(self):
        assert life_bot.pick_career([(0, 50_000), (1, 100_000), (2, 75_000)]) == 1

    def test_choose_risk_it_positive_ev_with_cash(self):
        p = self._player(cash=1_000_000)
        assert life_bot.choose_risk_it(p) == "risk"

    def test_choose_risk_it_skips_when_broke(self):
        p = self._player(cash=5_000)
        assert life_bot.choose_risk_it(p) == "skip"

    def test_choose_stock_skips_when_already_held(self):
        p = self._player(cash=100_000, stock_number=3)
        assert life_bot.choose_stock(p) == "skip"

    def test_should_pay_loan_false_when_no_loan(self):
        p = self._player(cash=1_000_000, college_loan=0)
        assert not life_bot.should_pay_loan(p)

    def test_should_pay_loan_true_when_flush(self):
        p = self._player(cash=500_000, college_loan=100_000)
        assert life_bot.should_pay_loan(p)

    def test_should_pay_loan_false_when_cash_tight(self):
        p = self._player(cash=120_000, college_loan=100_000)
        assert not life_bot.should_pay_loan(p)

    def test_choose_retirement_acres_when_leading(self):
        p = self._player(cash=800_000)
        assert life_bot.choose_retirement(p, [800_000, 500_000, 400_000]) == "acres"

    def test_choose_retirement_estates_when_substantially_behind(self):
        p = self._player(cash=200_000)
        assert life_bot.choose_retirement(p, [200_000, 900_000]) == "estates"


# ---------------------------------------------------------------------------
# Player insurance helper tests
# ---------------------------------------------------------------------------

class TestLifePlayer:
    def test_set_coverage_fire(self):
        p = LifePlayer(id="x", name="x")
        assert p.set_coverage("fire") is True
        assert p.has_fire_insurance
        assert p.covers("fire")
        assert not p.covers("auto")

    def test_set_coverage_full(self):
        p = LifePlayer(id="x", name="x")
        assert p.set_coverage("full") is True
        assert p.covers("fire")
        assert p.covers("auto")
        assert p.covers("life")

    def test_set_coverage_already_held_returns_false(self):
        p = LifePlayer(id="x", name="x", has_auto_insurance=True)
        assert p.set_coverage("auto") is False

    def test_insurance_list_ordering(self):
        p = LifePlayer(
            id="x", name="x",
            has_fire_insurance=True, has_life_insurance=True,
        )
        assert p.insurance_list() == ["fire", "life"]


# ---------------------------------------------------------------------------
# Game setup & serialization
# ---------------------------------------------------------------------------

class TestGameSetup:
    def test_metadata(self):
        game = GameOfLifeGame()
        assert game.get_type() == "life"
        assert game.get_name() == "The Game of Life"
        assert game.get_min_players() == 1
        assert game.get_max_players() == 6
        assert game.get_category() == "category-board-games"

    def test_player_creation(self):
        game = GameOfLifeGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)
        assert isinstance(player, LifePlayer)
        assert player.position == 0
        assert player.retired is False

    def test_on_start_builds_track(self):
        game = GameOfLifeGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        assert len(game.track) == TRACK_LENGTHS["standard"]
        assert len(game.event_layout) > 0

    def test_on_start_applies_starting_cash(self):
        game = GameOfLifeGame()
        game.options.starting_cash = 50_000
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        for p in game.players:
            assert p.cash == 50_000

    def test_college_path_off_skips_path_prompt(self):
        game = GameOfLifeGame()
        game.options.college_path = False
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        for p in game.players:
            assert p.pending == "career_pick"

    def test_college_path_on_starts_with_path_prompt(self):
        game = GameOfLifeGame()
        game.options.college_path = True
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        for p in game.players:
            assert p.pending == "path"


class TestSerialization:
    def test_round_trip_preserves_state(self):
        game = GameOfLifeGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()

        # Mutate state.
        game.players[0].position = 15
        game.players[0].cash = 123_456
        game.players[0].career_key = "doctor"
        game.players[0].career_label_key = "life-career-doctor"
        game.players[0].salary = 100_000
        game.players[0].married = True
        game.players[0].children = 2
        game.players[0].has_fire_insurance = True
        game.players[0].stock_number = 7
        game.players[0].life_tile_values = [50_000, 80_000]

        loaded = GameOfLifeGame.from_json(game.to_json())
        p = loaded.players[0]
        assert p.position == 15
        assert p.cash == 123_456
        assert p.career_key == "doctor"
        assert p.salary == 100_000
        assert p.married is True
        assert p.children == 2
        assert p.has_fire_insurance is True
        assert p.stock_number == 7
        assert p.life_tile_values == [50_000, 80_000]
        assert len(loaded.track) == len(game.track)


# ---------------------------------------------------------------------------
# Insurance / stock / loan / retirement handlers
# ---------------------------------------------------------------------------

class TestActions:
    def setup_method(self):
        self.game = GameOfLifeGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.game.add_player("Alice", self.user1)
        self.game.add_player("Bob", self.user2)
        self.game.options.college_path = False  # simpler setup
        self.game.on_start()
        # Past the initial career pick — assign a career manually.
        for p in self.game.players:
            p.career_key = "teacher"
            p.career_label_key = "life-career-teacher"
            p.salary = 40_000
            p.pending = ""
        self.game.career_offers.clear()

    def test_pay_loan_partial(self):
        p = self.game.players[0]
        p.college_loan = 50_000
        p.cash = 20_000
        self.game._action_pay_loan(p, "pay_loan")
        assert p.college_loan == 30_000
        assert p.cash == 0

    def test_pay_loan_full(self):
        p = self.game.players[0]
        p.college_loan = 50_000
        p.cash = 200_000
        self.game._action_pay_loan(p, "pay_loan")
        assert p.college_loan == 0
        assert p.cash == 150_000

    def test_pay_loan_no_op_when_zero(self):
        p = self.game.players[0]
        p.college_loan = 0
        p.cash = 100_000
        self.game._action_pay_loan(p, "pay_loan")
        assert p.cash == 100_000

    def test_sell_stock_refunds(self):
        p = self.game.players[0]
        p.stock_number = 5
        p.cash = 10_000
        self.game._action_sell_stock(p, "sell_stock")
        assert p.stock_number == 0
        assert p.cash == 10_000 + STOCK_COST

    def test_stock_payout_on_opponent_spin(self):
        """When an opponent spins my stock number, I collect STOCK_PAYOUT."""
        alice = self.game.players[0]
        bob = self.game.players[1]
        alice.stock_number = 5
        alice.cash = 0
        # Simulate a spin_result event for Bob with value=5.
        self.game._handle_spin_result({"player_id": bob.id, "value": 5})
        assert alice.cash == STOCK_PAYOUT


class TestEndScreen:
    def test_format_end_screen_sorts_by_total(self):
        game = GameOfLifeGame()
        game.add_player("Alice", MockUser("Alice"))
        game.add_player("Bob", MockUser("Bob"))
        game.on_start()
        game.players[0].cash = 500_000
        game.players[1].cash = 200_000
        result = game.build_game_result()
        # Highest cash first.
        assert result.player_results[0].player_name == "Alice"
        assert result.player_results[1].player_name == "Bob"


# ---------------------------------------------------------------------------
# Full play test — bots run a game to completion, save/load mid-game.
# ---------------------------------------------------------------------------

class TestPlayToCompletion:
    def test_bots_complete_standard_game(self):
        random.seed(42)
        game = GameOfLifeGame()
        b1 = Bot("Bot1")
        b2 = Bot("Bot2")
        game.add_player("Bot1", b1)
        game.add_player("Bot2", b2)
        game.on_start()

        max_ticks = 100_000
        for tick in range(max_ticks):
            if not game.game_active:
                break
            if tick and tick % 2000 == 0:
                # Serialize/deserialize to catch persistence bugs.
                data = game.to_json()
                game = GameOfLifeGame.from_json(data)
                game.attach_user("Bot1", b1)
                game.attach_user("Bot2", b2)
                game.rebuild_runtime_state()
                for p in game.players:
                    game.setup_player_actions(p)
            game.on_tick()

        assert not game.game_active, "game should have finished"
        # All players retired.
        for p in game.players:
            assert p.retired, f"{p.name} should be retired"

    def test_bots_complete_short_no_options_game(self):
        random.seed(7)
        game = GameOfLifeGame()
        game.options.track_length = "short"
        game.options.college_path = False
        game.options.family_enabled = False
        game.options.life_tiles = "off"
        game.options.insurance = "off"
        game.options.stock_market = False
        game.options.retirement = "none"
        b1 = Bot("Bot1")
        b2 = Bot("Bot2")
        game.add_player("Bot1", b1)
        game.add_player("Bot2", b2)
        game.on_start()

        for _ in range(50_000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_solo_game_completes(self):
        random.seed(99)
        game = GameOfLifeGame()
        b = Bot("Bot1")
        game.add_player("Bot1", b)
        game.on_start()
        for _ in range(50_000):
            if not game.game_active:
                break
            game.on_tick()
        assert not game.game_active
