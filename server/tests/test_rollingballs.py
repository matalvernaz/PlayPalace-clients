"""
Tests for the Rolling Balls game.

Following the testing strategy:
- Unit tests for individual functions
- Play tests that run the game from start to finish with bots
- Persistence tests (save/reload at each tick)
"""

import json
from collections import Counter
from pathlib import Path
import random
import re

import pytest

from server.games.rollingballs.game import (
    DRAW_SEQUENCE_TAG,
    PIPE_PREVIEW_MAX,
    PIPE_PREVIEW_MIN,
    RollingBallsGame,
    RollingBallsOptions,
    RollingBallsPlayer,
    load_ball_packs,
    get_pack_names,
)
from server.users.test_user import MockUser
from server.users.bot import Bot


LOCALES_DIR = Path(__file__).parent.parent / "locales"
DOCS_DIR = Path(__file__).parent.parent / "documentation" / "content"


def set_web_client(game: RollingBallsGame, *players) -> None:
    targets = players or game.players
    for player in targets:
        user = game.get_user(player)
        if user is not None:
            user.client_type = "web"


def advance_draw(game: RollingBallsGame, max_ticks: int = 300) -> None:
    for _ in range(max_ticks):
        if not game.has_active_sequence(tag=DRAW_SEQUENCE_TAG):
            return
        game.on_tick()
    raise AssertionError("Rolling Balls draw sequence did not finish")


def valid_ball(value: int = 1, key: str = "rb-ball-free-museum-day") -> dict:
    return {"value": value, "description_key": key}


def ftl_messages(text: str) -> dict[str, set[str]]:
    result: dict[str, set[str]] = {}
    current = ""
    for line in text.splitlines():
        match = re.match(r"^([a-z0-9-]+)\s*=", line)
        if match:
            current = match.group(1)
            result[current] = set()
        if current:
            result[current].update(
                re.findall(r"\{\s*\$([a-zA-Z_][\w-]*)", line)
            )
    return result


class TestRollingBallsUnit:
    """Unit tests for Rolling Balls game functions."""

    def test_game_creation(self):
        """Test creating a new Rolling Balls game."""
        game = RollingBallsGame()
        assert game.get_name() == "Rolling Balls"
        assert game.get_type() == "rollingballs"
        assert game.get_category() == "misc"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 4
        assert game.relevant_preferences == ["brief_announcements"]

    def test_player_creation(self):
        """Test creating a player with correct initial state."""
        game = RollingBallsGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)

        assert player.name == "Alice"
        assert player.has_reshuffled is False
        assert player.view_pipe_uses == 0
        assert player.reshuffle_uses == 0
        assert player.is_bot is False

    def test_options_defaults(self):
        """Test default game options."""
        game = RollingBallsGame()
        assert game.options.min_take == 1
        assert game.options.max_take == 3
        assert game.options.view_pipe_limit == 5
        assert game.options.reshuffle_limit == 3
        assert game.options.reshuffle_penalty == 1

    def test_custom_options(self):
        """Test custom game options."""
        options = RollingBallsOptions(
            view_pipe_limit=10,
            reshuffle_limit=0,
            reshuffle_penalty=3,
        )
        game = RollingBallsGame(options=options)
        assert game.options.view_pipe_limit == 10
        assert game.options.reshuffle_limit == 0
        assert game.options.reshuffle_penalty == 3

    def test_ball_packs_load(self):
        """Test that ball packs load correctly from JSON."""
        packs = load_ball_packs()
        assert len(packs) >= 2
        assert "rb-pack-international" in packs
        assert "rb-pack-vietnam" in packs
        for pack_id, pack in packs.items():
            assert len(pack) == 55
            assert Counter(pack.values()) == Counter(
                {value: 5 for value in range(-5, 6)}
            )
            for desc, value in pack.items():
                assert isinstance(desc, str)
                assert isinstance(value, int)

    def test_get_pack_names(self):
        """Test getting available pack names."""
        names = get_pack_names()
        assert "rb-pack-international" in names
        assert "rb-pack-vietnam" in names

    def test_default_ball_pack_option(self):
        """Test default ball pack selection is the first available pack."""
        game = RollingBallsGame()
        assert game.options.ball_packs == [get_pack_names()[0]]

    def test_fill_pipe_2_players(self):
        """Test pipe filling with 2 players."""
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        assert len(game.pipe) == 25

    def test_fill_pipe_3_players(self):
        """Test pipe filling with 3 players."""
        game = RollingBallsGame()
        for name in ["Alice", "Bob", "Charlie"]:
            game.add_player(name, MockUser(name))
        game.on_start()

        assert len(game.pipe) == 35

    def test_fill_pipe_4_players(self):
        """Test pipe filling with 4 players."""
        game = RollingBallsGame()
        for name in ["Alice", "Bob", "Charlie", "Dave"]:
            game.add_player(name, MockUser(name))
        game.on_start()

        assert len(game.pipe) == 50

    def test_filled_pipe_is_unique_and_value_balanced(self):
        random.seed(123)
        game = RollingBallsGame()
        for name in ["Alice", "Bob", "Charlie", "Dave"]:
            game.add_player(name, MockUser(name))

        game.on_start()

        keys = [ball["description_key"] for ball in game.pipe]
        counts = Counter(ball["value"] for ball in game.pipe)
        assert len(keys) == len(set(keys)) == 50
        assert set(counts) == set(range(-5, 6))
        assert max(counts.values()) - min(counts.values()) <= 1

    def test_pipe_balls_from_pack(self):
        """Test that pipe balls come from the selected pack."""
        random.seed(42)
        game = RollingBallsGame(
            options=RollingBallsOptions(ball_packs=["rb-pack-international"])
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        packs = load_ball_packs()
        combined_pack: dict[str, int] = {}
        for pack_name in game.options.ball_packs:
            combined_pack.update(packs[pack_name])
        for ball in game.pipe:
            assert isinstance(ball["description_key"], str)
            assert len(ball["description_key"]) > 0
            assert ball["description_key"] in combined_pack
            assert ball["value"] == combined_pack[ball["description_key"]]

    def test_pipe_balls_from_different_pack(self):
        """Test that pipe balls come from a different pack when selected."""
        random.seed(42)
        game = RollingBallsGame(
            options=RollingBallsOptions(ball_packs=["rb-pack-vietnam"])
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        packs = load_ball_packs()
        pizza_pack = packs.get("rb-pack-vietnam", {})
        for ball in game.pipe:
            assert ball["description_key"] in pizza_pack
            assert ball["value"] == pizza_pack[ball["description_key"]]

    def test_web_standard_menu_orders_pipe_actions_before_scores_turn_and_table(self):
        """Web clients should receive the standard info actions in the shared order."""
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        player1 = game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        set_web_client(game, player1)
        game.on_start()

        action_set = game.create_standard_action_set(player1)
        order = action_set._order

        expected = [
            "check_pipe_status",
            "view_pipe",
            "reshuffle",
            "check_scores",
            "whose_turn",
            "whos_at_table",
        ]
        indices = [order.index(action_id) for action_id in expected]

        assert indices == sorted(indices)
        assert order.index("view_pipe") < order.index("check_scores")
        assert order.index("reshuffle") < order.index("check_scores")

    def test_reshuffle_penalty_option_hidden_when_reshuffling_disabled(self):
        game = RollingBallsGame(
            options=RollingBallsOptions(reshuffle_limit=0)
        )
        player = game.add_player("Alice", MockUser("Alice"))

        option_set = game.options.create_options_action_set(game, player)

        assert "set_reshuffle_penalty" not in option_set._order

    def test_disabled_optional_actions_still_exist_for_keybind_resolution(self):
        game = RollingBallsGame(
            options=RollingBallsOptions(
                view_pipe_limit=0,
                reshuffle_limit=0,
            )
        )
        player = game.add_player("Alice", MockUser("Alice"))

        standard_set = game.create_standard_action_set(player)

        assert "view_pipe" in standard_set._order
        assert "reshuffle" in standard_set._order

    def test_serialization(self):
        """Test that game state can be serialized and deserialized."""
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        # Modify some state
        game._team_manager.add_to_team_score("Alice", 15)
        game.players[0].view_pipe_uses = 2
        game.players[0].reshuffle_uses = 1
        game.round = 3

        # Serialize
        json_str = game.to_json()
        data = json.loads(json_str)

        # Verify structure
        assert data["round"] == 3
        assert len(data["players"]) == 2
        assert data["players"][0]["view_pipe_uses"] == 2
        assert data["players"][0]["reshuffle_uses"] == 1

        # Deserialize
        loaded_game = RollingBallsGame.from_json(json_str)
        assert loaded_game.round == 3
        assert loaded_game._team_manager.get_team("Alice").total_score == 15
        assert loaded_game.players[0].view_pipe_uses == 2
        assert loaded_game.players[0].reshuffle_uses == 1
        assert len(loaded_game.pipe) == len(game.pipe)


class TestRollingBallsActions:
    """Test individual game actions."""

    def setup_method(self):
        """Set up a game with two players for each test."""
        random.seed(42)
        self.game = RollingBallsGame()
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.player1 = self.game.add_player("Alice", self.user1)
        self.player2 = self.game.add_player("Bob", self.user2)
        self.game.on_start()
        self.game.reset_turn_order()

    def test_take_1_ball(self):
        """Test taking 1 ball from the pipe."""
        initial_pipe_len = len(self.game.pipe)
        initial_score = self.game._team_manager.get_team(self.player1.name).total_score
        first_ball_value = self.game.pipe[0]["value"]

        self.game.execute_action(self.player1, "take_1")
        assert len(self.game.pipe) == initial_pipe_len
        advance_draw(self.game)

        assert len(self.game.pipe) == initial_pipe_len - 1
        assert (
            self.game._team_manager.get_team(self.player1.name).total_score
            == initial_score + first_ball_value
        )

    def test_take_2_balls(self):
        """Test taking 2 balls from the pipe."""
        initial_pipe_len = len(self.game.pipe)
        expected_score = self.game.pipe[0]["value"] + self.game.pipe[1]["value"]

        self.game.execute_action(self.player1, "take_2")
        advance_draw(self.game)

        assert len(self.game.pipe) == initial_pipe_len - 2
        assert self.game._team_manager.get_team(self.player1.name).total_score == expected_score

    def test_take_3_balls(self):
        """Test taking 3 balls from the pipe."""
        initial_pipe_len = len(self.game.pipe)
        expected_score = sum(self.game.pipe[i]["value"] for i in range(3))

        self.game.execute_action(self.player1, "take_3")
        advance_draw(self.game)

        assert len(self.game.pipe) == initial_pipe_len - 3
        assert self.game._team_manager.get_team(self.player1.name).total_score == expected_score

    def test_take_controls_stay_visible_but_disable_when_pipe_is_short(self):
        """Persistent take controls should keep their focus anchors near game end."""
        self.game.pipe = [valid_ball()]
        visible_actions = self.game.get_all_visible_actions(self.player1)
        actions = {resolved.action.id: resolved for resolved in visible_actions}

        assert actions["take_1"].enabled is True
        assert actions["take_2"].enabled is False
        assert actions["take_2"].disabled_reason == (
            "rb-not-enough-balls",
            {"count": 2, "remaining": 1},
        )
        assert actions["take_3"].enabled is False

    def test_reshuffle(self):
        """Test reshuffling the pipe."""
        # Save original pipe order
        original_pipe = [b["value"] for b in self.game.pipe[:15]]

        self.game.execute_action(self.player1, "reshuffle")

        # Pipe should still have the same number of balls
        assert len(self.game.pipe) == 25
        assert self.player1.has_reshuffled is True
        assert self.player1.reshuffle_uses == 1

        # Penalty should be applied
        assert (
            self.game._team_manager.get_team(self.player1.name).total_score
            == -self.game.options.reshuffle_penalty
        )

    def test_reshuffle_hidden_when_limit_0(self):
        """Test reshuffle action hidden when limit is 0."""
        self.game.options.reshuffle_limit = 0
        # Need to rebuild action sets for the option change to take effect
        self.game.setup_player_actions(self.player1)
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "reshuffle" not in visible_ids

    def test_reshuffle_touch_control_stays_visible_when_uses_exhausted(self):
        """An exhausted touch control remains as a disabled focus anchor."""
        set_web_client(self.game, self.player1)
        self.player1.reshuffle_uses = self.game.options.reshuffle_limit
        actions = {
            resolved.action.id: resolved
            for resolved in self.game.get_all_visible_actions(self.player1)
        }

        assert actions["reshuffle"].enabled is False
        assert actions["reshuffle"].disabled_reason == (
            "rb-no-reshuffles-left",
            {"limit": self.game.options.reshuffle_limit},
        )

    def test_reshuffle_touch_control_stays_visible_after_use_this_turn(self):
        """The reshuffle anchor remains present after its once-per-turn use."""
        set_web_client(self.game, self.player1)
        self.game.execute_action(self.player1, "reshuffle")

        actions = {
            resolved.action.id: resolved
            for resolved in self.game.get_all_visible_actions(self.player1)
        }

        assert actions["reshuffle"].enabled is False
        assert actions["reshuffle"].disabled_reason == "rb-already-reshuffled"

    def test_reshuffle_touch_control_explains_when_pipe_is_too_small(self):
        set_web_client(self.game, self.player1)
        self.game.pipe = [valid_ball()] * 5
        actions = {
            resolved.action.id: resolved
            for resolved in self.game.get_all_visible_actions(self.player1)
        }

        assert actions["reshuffle"].enabled is False
        assert actions["reshuffle"].disabled_reason == (
            "rb-not-enough-balls-to-reshuffle",
            {"remaining": 5, "required": 6},
        )

    def test_reshuffle_no_penalty_when_0(self):
        """Test that no penalty when reshuffle_penalty is 0."""
        self.game.options.reshuffle_penalty = 0
        self.game.execute_action(self.player1, "reshuffle")

        assert self.game._team_manager.get_team(self.player1.name).total_score == 0

    def test_view_pipe(self):
        """Test viewing the pipe."""
        self.game.execute_action(self.player1, "view_pipe")

        assert self.player1.view_pipe_uses == 1
        # Check that the user received a status box with pipe information
        assert "status_box" in self.user1.menus

    def test_view_pipe_visible_when_uses_remain(self):
        """Test view pipe is visible as a touch-client turn button when uses remain."""
        set_web_client(self.game, self.player1)
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "view_pipe" in visible_ids

    def test_view_pipe_hidden_when_limit_0(self):
        """Test view pipe hidden when limit is 0."""
        self.game.options.view_pipe_limit = 0
        self.game.setup_player_actions(self.player1)
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "view_pipe" not in visible_ids

    def test_view_pipe_hidden_when_uses_exhausted(self):
        """Test view pipe hidden when all uses consumed."""
        self.player1.view_pipe_uses = self.game.options.view_pipe_limit
        visible_actions = self.game.get_all_visible_actions(self.player1)
        visible_ids = [a.action.id for a in visible_actions]

        assert "view_pipe" not in visible_ids

    def test_view_pipe_no_charge_when_unchanged(self):
        """Test that viewing the pipe again without changes doesn't use a charge."""
        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 1

        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 1

    def test_view_pipe_shows_bounded_preview(self):
        self.game.execute_action(self.player1, "view_pipe")

        preview = self.player1.last_viewed_pipe
        assert preview is not None
        assert PIPE_PREVIEW_MIN <= len(preview) <= PIPE_PREVIEW_MAX
        assert len(preview) == self.game.options.max_take * 2

    def test_final_preview_can_be_reopened_until_pipe_changes(self):
        self.game.options.view_pipe_limit = 1
        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 1
        assert self.game._is_view_pipe_enabled(self.player1) is None

        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 1

        self.game.pipe.pop(0)
        assert self.game._is_view_pipe_enabled(self.player1) == (
            "rb-no-views-left",
            {"limit": 1},
        )

    def test_view_pipe_charges_after_change(self):
        """Test that viewing the pipe after a change uses a charge."""
        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 1

        # Take a ball to change the pipe
        self.game.execute_action(self.player1, "take_1")
        advance_draw(self.game)

        # View again - pipe changed, should cost a use
        self.game.execute_action(self.player1, "view_pipe")
        assert self.player1.view_pipe_uses == 2

    def test_take_controls_stay_visible_off_turn_but_are_disabled(self):
        """Turn changes must not remove the primary focus anchors."""
        p1_actions = self.game.get_all_visible_actions(self.player1)
        p2_actions = self.game.get_all_visible_actions(self.player2)

        p1 = {resolved.action.id: resolved for resolved in p1_actions}
        p2 = {resolved.action.id: resolved for resolved in p2_actions}

        assert p1["take_1"].enabled is True
        assert p2["take_1"].enabled is False
        assert p2["take_1"].disabled_reason == (
            "rb-take-not-your-turn",
            {"count": 1, "player": self.player1.name},
        )

    def test_reshuffle_resets_each_turn(self):
        """Test that has_reshuffled resets at the start of each turn."""
        self.player1.has_reshuffled = True
        # Simulate turn end and new turn
        self.game._start_turn()

        current = self.game.current_player
        assert current is not None
        rb_current: RollingBallsPlayer = current  # type: ignore
        assert rb_current.has_reshuffled is False

    def test_option_change_rebuilds_take_actions(self):
        """Test that changing min/max take rebuilds the take actions."""
        # Start with defaults (min=1, max=3)
        visible_actions = self.game.get_all_visible_actions(self.player1)
        take_ids = [a.action.id for a in visible_actions if a.action.id.startswith("take_")]
        assert take_ids == ["take_1", "take_2", "take_3"]

        # Change max_take to 5 via the option system
        self.game._handle_option_change("max_take", "5")

        visible_actions = self.game.get_all_visible_actions(self.player1)
        take_ids = [a.action.id for a in visible_actions if a.action.id.startswith("take_")]
        assert take_ids == ["take_1", "take_2", "take_3", "take_4", "take_5"]

    def test_option_conflict_is_preserved_and_blocks_start(self):
        """Conflicting settings should be explicit instead of silently mutating."""
        self.game._handle_option_change("min_take", "3")
        assert self.game.options.min_take == 3

        self.game._handle_option_change("max_take", "2")
        assert self.game.options.max_take == 2
        assert self.game.options.min_take == 3
        assert (
            "rb-error-take-range-conflict",
            {"min": 3, "max": 2},
        ) in self.game.prestart_validate()

    def test_min_take_hides_lower_actions(self):
        """Test that take actions below min_take are not created."""
        game = RollingBallsGame(
            options=RollingBallsOptions(min_take=2, max_take=4)
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        game.reset_turn_order()

        visible_actions = game.get_all_visible_actions(game.players[0])
        visible_ids = [a.action.id for a in visible_actions]

        assert "take_1" not in visible_ids
        assert "take_2" in visible_ids
        assert "take_3" in visible_ids
        assert "take_4" in visible_ids
        assert "take_5" not in visible_ids

    def test_max_take_limits_actions(self):
        """Test that take actions above max_take are not created."""
        game = RollingBallsGame(
            options=RollingBallsOptions(min_take=1, max_take=5)
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        game.reset_turn_order()

        visible_actions = game.get_all_visible_actions(game.players[0])
        visible_ids = [a.action.id for a in visible_actions]

        assert "take_1" in visible_ids
        assert "take_2" in visible_ids
        assert "take_3" in visible_ids
        assert "take_4" in visible_ids
        assert "take_5" in visible_ids

    def test_single_take_option(self):
        """Test that min_take == max_take creates only one take action."""
        game = RollingBallsGame(
            options=RollingBallsOptions(min_take=2, max_take=2)
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        game.reset_turn_order()

        visible_actions = game.get_all_visible_actions(game.players[0])
        take_ids = [a.action.id for a in visible_actions if a.action.id.startswith("take_")]

        assert take_ids == ["take_2"]

    def test_forced_final_draw_is_contextual_and_completes_game(self):
        self.game.options.min_take = 3
        self.game.pipe = [
            valid_ball(2),
            valid_ball(-1, "rb-ball-amsterdam-bicycle-crash"),
        ]
        self.user1.clear_messages()
        self.user2.clear_messages()

        self.game._start_turn()
        advance_draw(self.game)

        assert self.game.status == "finished"
        assert any(
            "fewer than the minimum take of 3" in message
            for message in self.user1.get_spoken_messages()
        )
        assert any(
            "Alice must take the rest" in message
            for message in self.user2.get_spoken_messages()
        )

    def test_draw_broadcasts_first_and_third_person_context(self):
        self.game.pipe = [valid_ball(2)] + self.game.pipe[1:]
        self.user1.clear_messages()
        self.user2.clear_messages()

        self.game.execute_action(self.player1, "take_1")
        advance_draw(self.game)

        actor_text = "\n".join(self.user1.get_spoken_messages())
        observer_text = "\n".join(self.user2.get_spoken_messages())
        assert "Your ball 1:" in actor_text
        assert "Alice's ball 1:" in observer_text
        assert "Your 1-ball draw has a net value of 2 points" in actor_text
        assert "Alice's 1-ball draw has a net value of 2 points" in observer_text

    def test_brief_announcements_skip_individual_ball_descriptions(self):
        self.user1.preferences.set_game_override(
            "brief_announcements", "rollingballs", True
        )
        self.game.pipe = [valid_ball(2)] + self.game.pipe[1:]
        self.user1.clear_messages()
        self.user2.clear_messages()

        self.game.execute_action(self.player1, "take_1")
        advance_draw(self.game)

        actor_text = "\n".join(self.user1.get_spoken_messages())
        observer_text = "\n".join(self.user2.get_spoken_messages())
        assert "Free museum admission" not in actor_text
        assert "Net 2; your score is 2." in actor_text
        assert "Free museum admission" in observer_text

    def test_reshuffle_always_changes_front_order(self, monkeypatch):
        original = [dict(ball) for ball in self.game.pipe[:15]]
        monkeypatch.setattr(random, "shuffle", lambda values: None)

        self.game.execute_action(self.player1, "reshuffle")

        assert self.game.pipe[:15] == original[1:] + original[:1]

    def test_invalid_direct_options_are_reported_before_start(self):
        game = RollingBallsGame(
            options=RollingBallsOptions(
                min_take=0,
                max_take=6,
                view_pipe_limit=-1,
                reshuffle_limit=101,
                reshuffle_penalty=8,
                ball_packs=["missing-pack"],
            )
        )

        errors = game.prestart_validate()

        assert ("rb-error-min-take-invalid", {"count": 0, "min": 1, "max": 5}) in errors
        assert ("rb-error-max-take-invalid", {"count": 6, "min": 1, "max": 5}) in errors
        assert (
            "rb-error-view-limit-invalid",
            {"count": -1, "min": 0, "max": 100},
        ) in errors
        assert (
            "rb-error-reshuffle-limit-invalid",
            {"count": 101, "min": 0, "max": 100},
        ) in errors
        assert (
            "rb-error-reshuffle-penalty-invalid",
            {"points": 8, "min": 0, "max": 5},
        ) in errors
        assert ("rb-error-invalid-ball-packs", {"count": 1}) in errors

    def test_bot_reshuffles_a_known_bad_prefix(self):
        self.player1.is_bot = True
        self.player1.last_viewed_pipe = None
        self.player1.view_pipe_uses = 0
        self.game.pipe[:6] = [
            valid_ball(-5, "rb-ball-paris-pickpocket"),
            valid_ball(-4, "rb-ball-venice-flood"),
            valid_ball(-3, "rb-ball-spilled-coffee-in-rome"),
            valid_ball(0, "rb-ball-neutral-passport"),
            valid_ball(1, "rb-ball-free-museum-day"),
            valid_ball(2, "rb-ball-eiffel-tower-view"),
        ]

        assert self.game.bot_think(self.player1) == "reshuffle"


class TestRollingBallsPlayTest:
    """Play tests that run complete games with bots."""

    def test_two_player_game_completes(self):
        """Test that a 2-player game runs to completion."""
        random.seed(123)

        game = RollingBallsGame()
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        max_ticks = 5000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            # Save and reload every 50 ticks
            if tick % 50 == 0 and tick > 0:
                json_str = game.to_json()
                game = RollingBallsGame.from_json(json_str)
                game.attach_user("Bot1", bot1)
                game.attach_user("Bot2", bot2)
                game.rebuild_runtime_state()
                for player in game.players:
                    game.setup_player_actions(player)

            game.on_tick()

        assert not game.game_active, "Game should have ended"
        assert len(game.pipe) == 0

    def test_four_player_game_completes(self):
        """Test that a 4-player game runs to completion."""
        random.seed(456)

        game = RollingBallsGame()
        bots = [Bot(f"Bot{i}") for i in range(1, 5)]
        for bot in bots:
            game.add_player(bot.username, bot)

        game.on_start()

        max_ticks = 10000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            if tick % 50 == 0 and tick > 0:
                json_str = game.to_json()
                game = RollingBallsGame.from_json(json_str)
                for bot in bots:
                    game.attach_user(bot.username, bot)
                game.rebuild_runtime_state()
                for player in game.players:
                    game.setup_player_actions(player)

            game.on_tick()

        assert not game.game_active

    def test_game_with_no_reshuffles(self):
        """Test game with reshuffle limit set to 0."""
        random.seed(789)

        game = RollingBallsGame(
            options=RollingBallsOptions(reshuffle_limit=0)
        )
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        for tick in range(5000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_game_with_no_view_pipe(self):
        """Test game with view pipe limit set to 0."""
        random.seed(101)

        game = RollingBallsGame(
            options=RollingBallsOptions(view_pipe_limit=0)
        )
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        for tick in range(5000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_game_with_high_penalty(self):
        """Test game with maximum reshuffle penalty."""
        random.seed(202)

        game = RollingBallsGame(
            options=RollingBallsOptions(reshuffle_penalty=5)
        )
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        for tick in range(5000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_bot_acts_after_reshuffle(self):
        """Test that a bot takes balls after reshuffling (doesn't freeze)."""
        random.seed(42)

        game = RollingBallsGame(
            options=RollingBallsOptions(reshuffle_limit=100, reshuffle_penalty=0)
        )
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        for tick in range(5000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_game_with_custom_take_range(self):
        """Test game with min_take=2 and max_take=5."""
        random.seed(404)

        game = RollingBallsGame(
            options=RollingBallsOptions(min_take=2, max_take=5)
        )
        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        for tick in range(5000):
            if not game.game_active:
                break
            game.on_tick()

        assert not game.game_active

    def test_human_and_bot_game(self):
        """Test a game with one human and one bot."""
        random.seed(303)

        game = RollingBallsGame()
        human = MockUser("Human")
        bot = Bot("Bot")
        game.add_player("Human", human)
        game.add_player("Bot", bot)

        game.on_start()

        max_ticks = 5000
        for tick in range(max_ticks):
            if not game.game_active:
                break

            game.on_tick()

            # Human always takes 1 ball on their turn (when not revealing)
            current = game.current_player
            if (
                current
                and current.name == "Human"
                and not game.has_active_sequence(tag=DRAW_SEQUENCE_TAG)
            ):
                game.execute_action(current, "take_1")

        assert not game.game_active
        messages = human.get_spoken_messages()
        assert len(messages) > 0


class TestRollingBallsPersistence:
    """Specific tests for game persistence."""

    def test_full_state_preserved(self):
        """Test that all game state is preserved through save/load."""
        random.seed(42)
        game = RollingBallsGame(
            options=RollingBallsOptions(
                view_pipe_limit=10,
                reshuffle_limit=5,
                reshuffle_penalty=2,
            )
        )
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        # Modify state
        game.round = 5
        game._team_manager.add_to_team_score("Alice", 15)
        game.players[0].view_pipe_uses = 3
        game.players[0].reshuffle_uses = 2
        game.players[0].has_reshuffled = True
        game._team_manager.add_to_team_score("Bob", -5)

        # Save
        json_str = game.to_json()

        # Load
        loaded = RollingBallsGame.from_json(json_str)

        # Verify all state
        assert loaded.game_active is True
        assert loaded.round == 5
        assert loaded.options.view_pipe_limit == 10
        assert loaded.options.reshuffle_limit == 5
        assert loaded.options.reshuffle_penalty == 2
        assert loaded._team_manager.get_team("Alice").total_score == 15
        assert loaded.players[0].view_pipe_uses == 3
        assert loaded.players[0].reshuffle_uses == 2
        assert loaded.players[0].has_reshuffled is True
        assert loaded._team_manager.get_team("Bob").total_score == -5
        assert len(loaded.pipe) == len(game.pipe)

    def test_pipe_preserved(self):
        """Test that pipe contents are preserved through save/load."""
        random.seed(42)
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()

        original_pipe = [b.copy() for b in game.pipe]

        json_str = game.to_json()
        loaded = RollingBallsGame.from_json(json_str)

        assert len(loaded.pipe) == len(original_pipe)
        for i, ball in enumerate(loaded.pipe):
            assert ball["value"] == original_pipe[i]["value"]
            assert ball["description_key"] == original_pipe[i]["description_key"]

    def test_actions_work_after_reload(self):
        """Test that actions work correctly after reloading."""
        random.seed(42)
        game = RollingBallsGame()
        user = MockUser("Alice")
        bot = Bot("Bot")
        game.add_player("Alice", user)
        game.add_player("Bot", bot)
        game.on_start()

        # Save and reload
        json_str = game.to_json()
        game = RollingBallsGame.from_json(json_str)
        game.attach_user("Alice", user)
        game.attach_user("Bot", bot)
        for player in game.players:
            game.setup_player_actions(player)

        # Actions should still work
        actions = game.get_all_enabled_actions(game.players[0])
        assert len(actions) > 0

    def test_active_draw_sequence_survives_reload_without_double_scoring(self):
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        player1 = game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        initial_length = len(game.pipe)
        expected_delta = sum(ball["value"] for ball in game.pipe[:2])

        game.execute_action(player1, "take_2")
        assert game.has_active_sequence(tag=DRAW_SEQUENCE_TAG)
        loaded = RollingBallsGame.from_json(game.to_json())
        loaded.attach_user("Alice", user1)
        loaded.attach_user("Bob", user2)
        loaded.rebuild_runtime_state()
        for player in loaded.players:
            loaded.setup_player_actions(player)

        advance_draw(loaded)

        assert len(loaded.pipe) == initial_length - 2
        assert loaded._team_manager.get_team("Alice").total_score == expected_delta

    def test_legacy_mid_reveal_state_migrates_to_sequence(self):
        game = RollingBallsGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        player1 = game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        legacy_ball = dict(game.pipe.pop(0))
        legacy_ball["num"] = 1
        game._team_manager.add_to_team_score("Alice", legacy_ball["value"])
        game._ball_reveal_player_id = player1.id
        game._ball_reveal_queue = [legacy_ball]
        game._ball_reveal_tick = game.sound_scheduler_tick + 2

        loaded = RollingBallsGame.from_json(game.to_json())
        loaded.attach_user("Alice", user1)
        loaded.attach_user("Bob", user2)
        loaded.rebuild_runtime_state()

        assert loaded.has_active_sequence(tag=DRAW_SEQUENCE_TAG)
        assert loaded._ball_reveal_queue == []
        assert loaded._ball_reveal_player_id == ""
        advance_draw(loaded)
        assert loaded._team_manager.get_team("Alice").total_score == legacy_ball["value"]


def test_tied_winners_receive_shared_result_ids_and_ranks() -> None:
    game = RollingBallsGame()
    user1 = MockUser("Alice")
    user2 = MockUser("Bob")
    alice = game.add_player("Alice", user1)
    bob = game.add_player("Bob", user2)
    game.on_start()
    game._team_manager.get_team("Alice").total_score = 7
    game._team_manager.get_team("Bob").total_score = 7
    game.pipe = []
    user1.clear_messages()
    user2.clear_messages()

    game._announce_winner()
    result = game.build_game_result()
    lines = game.format_end_screen(result, "en")

    assert result.custom_data["winner_name"] is None
    assert result.custom_data["winner_ids"] == [alice.id, bob.id]
    assert lines[1].startswith("1.")
    assert lines[2].startswith("1.")
    assert "You share the win with Bob" in user1.get_last_spoken()
    assert "You share the win with Alice" in user2.get_last_spoken()


def test_locale_parity_ball_coverage_and_vietnamese_documentation_terms() -> None:
    en_text = (LOCALES_DIR / "en" / "rollingballs.ftl").read_text(
        encoding="utf-8"
    )
    vi_text = (LOCALES_DIR / "vi" / "rollingballs.ftl").read_text(
        encoding="utf-8"
    )
    en_messages = ftl_messages(en_text)
    vi_messages = ftl_messages(vi_text)

    assert en_messages == vi_messages
    for pack in load_ball_packs().values():
        assert set(pack) <= en_messages.keys()

    en_docs = (
        DOCS_DIR / "en" / "games" / "rollingballs.md"
    ).read_text(encoding="utf-8")
    vi_docs = (
        DOCS_DIR / "vi" / "games" / "rollingballs.md"
    ).read_text(encoding="utf-8")
    assert "PlayPalace" in en_docs
    assert "PlayPalace" in vi_docs
    assert "not an original game created by PlayAural" in en_docs
    assert "không phải là trò chơi nguyên bản" in vi_docs
    assert "PlayAural original" not in en_docs
    assert "nguyên bản của PlayAural" not in vi_docs
    assert "Confirm Risky Actions" not in en_docs
    assert "Xác nhận hành động rủi ro" not in vi_docs
    for term in (
        "Quần thể danh thắng Tràng An",
        "Phố cổ Hội An",
        "Quần thể di tích Cố đô Huế",
        "Vịnh Hạ Long - quần đảo Cát Bà",
        "Phong Nha - Kẻ Bàng",
        "Xem trước trong ống",
        "Xáo đoạn đầu ống",
    ):
        assert term in vi_docs


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
