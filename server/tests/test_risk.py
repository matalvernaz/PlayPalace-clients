"""
Tests for the Risk game.

Following the testing strategy:
- Unit tests for territories, combat, reinforcements, cards
- Play tests that run the game from start to finish with bots
- Persistence tests (save/reload at each tick)
"""

import pytest
import random
import json

from server.games.risk.game import (
    RiskGame,
    RiskOptions,
    RiskPlayer,
    RiskCard,
    CARD_TYPES,
)
from server.games.risk.territories import (
    TERRITORIES,
    CONTINENTS,
    ALL_TERRITORY_IDS,
    get_adjacent,
    get_territory_name,
    player_controls_continent,
)
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


class TestTerritoryMap:
    """Tests for the territory map data."""

    def test_42_territories(self):
        assert len(ALL_TERRITORY_IDS) == 42

    def test_6_continents(self):
        assert len(CONTINENTS) == 6

    def test_all_territories_in_continents(self):
        continent_territories = set()
        for c in CONTINENTS.values():
            continent_territories.update(c.territory_ids)
        assert continent_territories == set(ALL_TERRITORY_IDS)

    def test_adjacency_is_symmetric(self):
        for tid, territory in TERRITORIES.items():
            for adj_id in territory.adjacent:
                adj_territory = TERRITORIES[adj_id]
                assert tid in adj_territory.adjacent, (
                    f"{tid} -> {adj_id} but not reverse"
                )

    def test_no_self_adjacency(self):
        for tid, territory in TERRITORIES.items():
            assert tid not in territory.adjacent

    def test_all_territories_connected(self):
        """Verify the map is one connected component."""
        visited = set()
        queue = [ALL_TERRITORY_IDS[0]]
        while queue:
            current = queue.pop()
            if current in visited:
                continue
            visited.add(current)
            queue.extend(get_adjacent(current))
        assert visited == set(ALL_TERRITORY_IDS)

    def test_continent_bonuses(self):
        expected = {
            "north_america": 5,
            "south_america": 2,
            "europe": 5,
            "africa": 3,
            "asia": 7,
            "australia": 2,
        }
        for cid, bonus in expected.items():
            assert CONTINENTS[cid].bonus == bonus

    def test_cross_continent_connections(self):
        """Verify key cross-continent connections exist."""
        # Alaska <-> Kamchatka (NA <-> Asia)
        assert "kamchatka" in TERRITORIES["alaska"].adjacent
        # Brazil <-> North Africa (SA <-> Africa)
        assert "north_africa" in TERRITORIES["brazil"].adjacent
        # Greenland <-> Iceland (NA <-> Europe)
        assert "iceland" in TERRITORIES["greenland"].adjacent
        # Siam <-> Indonesia (Asia <-> Australia)
        assert "indonesia" in TERRITORIES["siam"].adjacent


class TestRiskUnit:
    """Unit tests for Risk game functions."""

    def test_game_creation(self):
        game = RiskGame()
        assert game.get_name() == "Risk"
        assert game.get_type() == "risk"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 6

    def test_reinforcement_calculation(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        # Pick 9 territories across continents to avoid continent bonus
        mixed = ["alaska", "venezuela", "iceland", "north_africa", "ural",
                 "indonesia", "brazil", "scandinavia", "egypt"]
        game.owners = {tid: player.id for tid in mixed}
        game.troops = {tid: 1 for tid in mixed}
        # 9 territories / 3 = 3 (minimum 3), no continent bonus
        assert game._calculate_reinforcements(player) == 3

    def test_reinforcement_with_continent_bonus(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        # Give player all of Australia (4 territories, bonus 2)
        aus_ids = CONTINENTS["australia"].territory_ids
        game.owners = {tid: player.id for tid in aus_ids}
        game.troops = {tid: 1 for tid in aus_ids}
        # 4 / 3 = 1, but minimum 3, + 2 continent bonus = 5
        assert game._calculate_reinforcements(player) == 5

    def test_combat_resolution(self):
        random.seed(42)
        game = RiskGame()
        game.troops = {"a": 5, "b": 3}
        att_losses, def_losses, att_rolls, def_rolls = game._resolve_combat("a", "b", 3)
        assert att_losses >= 0
        assert def_losses >= 0
        assert att_losses + def_losses <= 2  # Max 2 comparisons
        assert len(att_rolls) == 3
        assert len(def_rolls) == 2

    def test_combat_single_die(self):
        random.seed(42)
        game = RiskGame()
        game.troops = {"a": 2, "b": 1}
        att_losses, def_losses, att_rolls, def_rolls = game._resolve_combat("a", "b", 1)
        assert len(att_rolls) == 1
        assert len(def_rolls) == 1
        assert att_losses + def_losses == 1

    def test_card_trade_detection(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        game.hands[player.id] = [
            RiskCard("", "infantry"),
            RiskCard("", "infantry"),
            RiskCard("", "infantry"),
        ]
        trade = game._find_valid_trade(player)
        assert trade is not None
        assert len(trade) == 3

    def test_card_trade_one_of_each(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        game.hands[player.id] = [
            RiskCard("", "infantry"),
            RiskCard("", "cavalry"),
            RiskCard("", "artillery"),
        ]
        trade = game._find_valid_trade(player)
        assert trade is not None

    def test_card_trade_with_wild(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        game.hands[player.id] = [
            RiskCard("", "infantry"),
            RiskCard("", "cavalry"),
            RiskCard("", "wild"),
        ]
        trade = game._find_valid_trade(player)
        assert trade is not None

    def test_no_valid_trade(self):
        game = RiskGame()
        user1 = MockUser("Alice")
        player = game.add_player("Alice", user1)
        game.hands[player.id] = [
            RiskCard("", "infantry"),
            RiskCard("", "cavalry"),
        ]
        trade = game._find_valid_trade(player)
        assert trade is None

    def test_continent_control(self):
        territories = set(CONTINENTS["australia"].territory_ids)
        assert player_controls_continent("australia", territories)
        territories.discard("indonesia")
        assert not player_controls_continent("australia", territories)


class TestRiskGameFlow:
    """Test game flow and phase transitions."""

    def setup_method(self):
        random.seed(100)
        self.game = RiskGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.player1 = self.game.add_player("Alice", self.user1)
        self.player2 = self.game.add_player("Bob", self.user2)
        self.game.on_start()

    def test_game_starts_in_reinforce_phase(self):
        assert self.game.phase == "reinforce"
        assert self.game.armies_to_place > 0

    def test_territories_distributed(self):
        assert len(self.game.owners) == 42
        p1_count = sum(1 for v in self.game.owners.values() if v == self.player1.id)
        p2_count = sum(1 for v in self.game.owners.values() if v == self.player2.id)
        assert p1_count == 21
        assert p2_count == 21

    def test_all_territories_have_troops(self):
        for tid in ALL_TERRITORY_IDS:
            assert self.game.troops.get(tid, 0) >= 1

    def test_reinforce_places_army(self):
        current = self.game.current_player
        owned = self.game._player_territories(current)
        tid = owned[0]
        old_troops = self.game.troops[tid]
        old_remaining = self.game.armies_to_place
        self.game.execute_action(current, f"t_{tid}")
        assert self.game.troops[tid] == old_troops + 1
        assert self.game.armies_to_place == old_remaining - 1

    def test_reinforce_transitions_to_attack(self):
        current = self.game.current_player
        owned = self.game._player_territories(current)
        # Place all armies
        for _ in range(self.game.armies_to_place):
            self.game.execute_action(current, f"t_{owned[0]}")
        assert self.game.phase == "attack"

    def test_skip_attack(self):
        current = self.game.current_player
        owned = self.game._player_territories(current)
        # Place all armies to get to attack phase
        for _ in range(self.game.armies_to_place):
            self.game.execute_action(current, f"t_{owned[0]}")
        assert self.game.phase == "attack"
        self.game.execute_action(current, "skip_attack")
        assert self.game.phase == "fortify"

    def test_skip_fortify_ends_turn(self):
        current = self.game.current_player
        owned = self.game._player_territories(current)
        # Place all armies
        for _ in range(self.game.armies_to_place):
            self.game.execute_action(current, f"t_{owned[0]}")
        # Skip attack
        self.game.execute_action(current, "skip_attack")
        assert self.game.phase == "fortify"
        # Skip fortify
        self.game.execute_action(current, "skip_fortify")
        # Turn should have advanced
        assert self.game.current_player != current


class TestRiskPlayTest:
    """Play tests: full games with bots."""

    def test_two_player_game_completes(self):
        random.seed(42)
        game = RiskGame()
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)
        game.on_start()

        max_ticks = 20000
        for tick in range(max_ticks):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active, "Game should have ended"
        alive = game._alive_players()
        assert len(alive) == 1, "Should have exactly one winner"

    def test_three_player_game_completes(self):
        random.seed(77)
        game = RiskGame()
        bots = [Bot(f"Bot{i}") for i in range(3)]
        for b in bots:
            game.add_player(b.username, b)
        game.on_start()

        for tick in range(30000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active, "3-player game should have ended"

    def test_game_with_different_seeds(self):
        """Run multiple 2-player games to find edge cases."""
        for seed in range(5):
            random.seed(seed)
            game = RiskGame()
            bot1 = Bot("Bot1")
            bot2 = Bot("Bot2")
            game.add_player("Bot1", bot1)
            game.add_player("Bot2", bot2)
            game.on_start()

            for tick in range(20000):
                if not game.game_active:
                    break
                game.on_tick()

            assert not game.game_active, f"Seed {seed}: game didn't end"


class TestRiskPersistence:
    """Test save/reload during gameplay."""

    def test_serialization_roundtrip(self):
        random.seed(55)
        game = RiskGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        json_str = game.to_json()
        loaded = RiskGame.from_json(json_str)

        assert loaded.owners == game.owners
        assert loaded.troops == game.troops
        assert loaded.phase == game.phase
        assert len(loaded.players) == 2

    def test_save_reload_during_play(self):
        random.seed(33)
        game = RiskGame()
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)
        game.on_start()

        for tick in range(20000):
            if not game.game_active:
                break
            # Save and reload every 200 ticks
            if tick % 200 == 0 and tick > 0:
                json_str = game.to_json()
                game = RiskGame.from_json(json_str)
                game.attach_user("Bot1", bot1)
                game.attach_user("Bot2", bot2)
                game.rebuild_runtime_state()
                for player in game.players:
                    user = game.get_user(player)
                    if user:
                        game.setup_player_actions(player)
            game.on_tick()

        assert not game.game_active, "Game should complete with save/reload"
