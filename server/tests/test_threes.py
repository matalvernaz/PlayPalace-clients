"""
Tests for the Threes game.
"""

import json
from pathlib import Path
import random
import re

from ..game_utils import dice as dice_utils
from ..games.threes.game import ThreesGame, ThreesPlayer, ThreesOptions
from ..users.test_user import MockUser
from ..users.bot import Bot
from ..users.preferences import DiceKeepingStyle


def latest_turn_selection(user: MockUser) -> str | None:
    """Return the last explicit turn-menu focus directive sent to a mock user."""
    for message in reversed(user.messages):
        if (
            message.type in {"show_menu", "update_menu"}
            and message.data.get("menu_id") == "turn_menu"
        ):
            return message.data.get("selection_id")
    return None


class TestThreesGameUnit:
    """Unit tests for Threes game functions."""

    def test_game_creation(self):
        """Test creating a new Threes game."""
        game = ThreesGame()
        assert game.get_name() == "Threes"
        assert game.get_type() == "threes"
        assert game.get_category() == "dice"
        assert game.get_min_players() == 2
        assert game.get_max_players() == 8
        assert game.relevant_preferences == ["brief_announcements", "dice_keeping_style"]

    def test_player_creation(self):
        """Test creating a player with correct initial state."""
        game = ThreesGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)

        assert player.name == "Alice"
        assert player.is_bot is False
        assert isinstance(player, ThreesPlayer)

    def test_options_defaults(self):
        """Test default game options."""
        game = ThreesGame()
        assert game.options.total_rounds == 10

    def test_custom_options(self):
        """Test custom game options."""
        options = ThreesOptions(total_rounds=10)
        game = ThreesGame(options=options)
        assert game.options.total_rounds == 10

    def test_prestart_validate_blocks_invalid_round_count(self):
        """Direct invalid option state should be caught before starting."""
        game = ThreesGame(options=ThreesOptions(total_rounds=0))
        assert (
            "threes-error-rounds-out-of-range",
            {"rounds": 0, "min": 1, "max": 20},
        ) in game.prestart_validate()

    def test_round_scores_are_spoken_as_separate_lines(self):
        """Round score summaries should be replayable one player at a time."""
        game = ThreesGame(options=ThreesOptions(total_rounds=1))
        alice_user = MockUser("Alice")
        bob_user = MockUser("Bob")
        alice = game.add_player("Alice", alice_user)
        bob = game.add_player("Bob", bob_user)
        assert isinstance(alice, ThreesPlayer)
        assert isinstance(bob, ThreesPlayer)
        alice.total_score = 3
        bob.total_score = 5
        game.current_round = 1
        alice_user.clear_messages()
        bob_user.clear_messages()

        game._end_round()

        assert alice_user.get_spoken_messages()[:3] == [
            "Round 1 scores:",
            "Alice: 3",
            "Bob: 5",
        ]
        assert not any(
            "Round 1 scores: Alice: 3" in message
            for message in alice_user.get_spoken_messages()
        )

    def test_serialization(self):
        """Test that game state can be serialized and deserialized."""
        game = ThreesGame()
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)

        game.on_start()

        # Modify some state
        game.current_round = 3

        # Serialize
        json_str = game.to_json()
        data = json.loads(json_str)

        # Verify structure
        assert data["current_round"] == 3
        assert len(data["players"]) == 2

        # Deserialize
        loaded_game = ThreesGame.from_json(json_str)
        assert loaded_game.current_round == 3


class TestThreesGameActions:
    """Test individual Threes actions and touch focus behavior."""

    def setup_method(self):
        self.game = ThreesGame(options=ThreesOptions(total_rounds=2))
        self.user1 = MockUser("Alice")
        self.user2 = MockUser("Bob")
        self.player1 = self.game.add_player("Alice", self.user1)
        self.player2 = self.game.add_player("Bob", self.user2)
        self.game.on_start()
        self.game.flush_menus()
        self.user1.clear_messages()
        self.user2.clear_messages()

    def test_roll_broadcasts_actor_perspective_and_listener_brief(
        self, monkeypatch
    ):
        """Roll announcements should be personal, public, and brief per listener."""
        self.user1.preferences.brief_announcements = True
        rolls = iter([3, 1, 4, 5, 6])
        monkeypatch.setattr(
            dice_utils.random,
            "randint",
            lambda _low, _high: next(rolls),
        )

        self.game.execute_action(self.player1, "roll")

        assert self.user1.get_last_spoken() == "Rolled 3, 1, 4, 5, and 6."
        assert (
            self.user2.get_last_spoken()
            == "Alice rolled: 3, 1, 4, 5, and 6."
        )

    def test_keep_broadcasts_actor_and_observer_context(self):
        """Keeping dice should not send the actor the third-person wording."""
        self.player1.dice.values = [3, 1, 4, 5, 6]
        self.player1.dice.kept = []
        self.player1.dice.locked = []

        self.game.execute_action(self.player1, "toggle_die_0")

        assert self.user1.get_last_spoken() == "You keep die 1, showing 3."
        assert self.user2.get_last_spoken() == "Alice keeps die 1, showing 3."

    def test_roll_focuses_first_enabled_option_for_touch(self):
        """After rolling, touch focus lands on the first selectable die."""
        self.user1.client_type = "mobile"
        random.seed(42)

        self.game.execute_action(self.player1, "roll")
        self.game.flush_menus()

        assert latest_turn_selection(self.user1) == "toggle_die_0"

    def test_value_style_roll_focuses_first_die_when_all_dice_default_kept(self):
        """Value-based dice controls still focus the first result row."""
        game = ThreesGame(options=ThreesOptions(total_rounds=2))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        user1.client_type = "web"
        user1.preferences.dice_keeping_style = DiceKeepingStyle.VALUE_BASED
        player1 = game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        game.flush_menus()
        user1.clear_messages()
        random.seed(42)

        game.execute_action(player1, "roll")
        game.flush_menus()

        assert player1.dice.kept == [0, 1, 2, 3, 4]
        assert latest_turn_selection(user1) == "toggle_die_0"

    def test_touch_turn_menu_orders_dice_before_roll_and_bank(self):
        """Touch menus should match Midnight: dice results first, actions after."""
        game = ThreesGame(options=ThreesOptions(total_rounds=2))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        user1.client_type = "mobile"
        player1 = game.add_player("Alice", user1)
        game.add_player("Bob", user2)
        game.on_start()
        game.flush_menus()
        user1.clear_messages()
        random.seed(42)

        game.execute_action(player1, "roll")
        game.flush_menus()

        item_ids = [item.id for item in user1.menus["turn_menu"]["items"]]
        dice_indices = [
            item_ids.index(action_id)
            for action_id in item_ids
            if action_id.startswith("toggle_die_")
        ]
        assert dice_indices
        assert max(dice_indices) < item_ids.index("roll")
        assert item_ids.index("roll") < item_ids.index("bank")

    def test_value_style_controls_work_when_first_die_is_locked(self):
        """Value-based keys should not be disabled just because die one is locked."""
        self.user1.preferences.dice_keeping_style = DiceKeepingStyle.VALUE_BASED
        self.player1.dice.values = [3, 6, 2, 4, 5]
        self.player1.dice.locked = [0]
        self.player1.dice.kept = [0, 1, 2, 3, 4]

        self.game.execute_action(self.player1, "dice_key_2")

        assert 2 not in self.player1.dice.kept

    def test_auto_score_after_roll_focuses_roll_anchor_for_touch(self, monkeypatch):
        """Rolling into the automatic score path still returns touch focus to Roll."""
        self.user1.client_type = "mobile"
        self.player1.dice.values = [3, 1, 2, 4, 5]
        self.player1.dice.locked = [0, 1, 2]
        self.player1.dice.kept = [0, 1, 2, 3]
        monkeypatch.setattr(dice_utils.random, "randint", lambda _low, _high: 6)

        self.game.execute_action(self.player1, "roll")
        self.game.flush_menus()

        assert self.game.current_player == self.player2
        assert latest_turn_selection(self.user1) == "roll"

    def test_bank_focuses_roll_anchor_for_touch(self):
        """Banking a completed turn should keep the touch cursor on Roll."""
        self.user1.client_type = "mobile"
        self.player1.dice.values = [3, 1, 2, 4, 5]
        self.player1.dice.locked = []
        self.player1.dice.kept = [0, 1, 2, 3, 4]

        self.game.execute_action(self.player1, "bank")
        self.game.flush_menus()

        assert self.game.current_player == self.player2
        assert latest_turn_selection(self.user1) == "roll"

    def test_check_hand_reports_current_player_context_to_observer(self):
        """Check dice reads the active turn, not merely the caller's own dice."""
        self.player1.dice.values = [3, 4, 5, 1, 2]
        self.player1.dice.kept = [0, 3]
        self.player1.dice.locked = [0]

        self.game.execute_action(self.player2, "check_hand")

        spoken = self.user2.get_last_spoken()
        assert spoken is not None
        assert "Alice's dice are" in spoken
        assert "12 points" in spoken
        assert "4 dice still unlocked" in spoken

    def test_check_dice_button_stays_visible_for_touch_through_turn_states(self):
        """Check dice should remain a stable touch utility during gameplay."""
        game = ThreesGame(options=ThreesOptions(total_rounds=2))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        user1.client_type = "mobile"
        player1 = game.add_player("Alice", user1)
        player2 = game.add_player("Bob", user2)
        game.on_start()
        game.flush_menus()

        def visible_ids() -> list[str]:
            return [item.id for item in user1.menus["turn_menu"]["items"]]

        assert "check_hand" in visible_ids()

        player1.dice.values = [3, 1, 2, 4, 5]
        player1.dice.kept = [0, 1, 2, 3, 4]
        game.refresh_menus(player1)
        game.flush_menus()
        assert "check_hand" in visible_ids()

        game.execute_action(player1, "bank")
        game.flush_menus()
        assert game.current_player == player2
        assert "check_hand" in visible_ids()

    def test_shared_score_actions_show_lowest_threes_scores_first(self):
        """View scores should use the shared score component with Threes totals."""
        self.player1.total_score = 12
        self.player2.total_score = 4
        self.game._sync_team_scores()

        self.game.execute_action(self.player1, "check_scores")

        spoken = self.user1.get_spoken_messages()
        bob_index = spoken.index("Bob: 4 points")
        alice_index = spoken.index("Alice: 12 points")
        assert bob_index < alice_index

        self.game.execute_action(self.player1, "check_scores_detailed")
        status_items = self.user1.menus["status_box"]["items"]
        assert [item.text for item in status_items[:2]] == [
            "Bob: 4 points",
            "Alice: 12 points",
        ]

    def test_score_actions_self_heal_legacy_missing_team_scores(self):
        """Older restored Threes games should rebuild score rows on demand."""
        self.player1.total_score = 8
        self.player2.total_score = 2
        self.game.team_manager.teams = []
        self.game.team_manager._player_to_team = {}

        self.game.execute_action(self.player1, "check_scores")

        spoken = self.user1.get_spoken_messages()
        assert "Bob: 2 points" in spoken
        assert "Alice: 8 points" in spoken

    def test_touch_waiting_player_has_contextual_disabled_reason(self):
        """Visible touch anchors should explain why they cannot be used."""
        self.user2.client_type = "web"

        actions = {
            resolved.action.id: resolved
            for resolved in self.game.get_all_visible_actions(self.player2)
        }

        assert actions["roll"].enabled is False
        assert actions["roll"].disabled_reason == (
            "threes-error-roll-not-your-turn",
            {"player": "Alice"},
        )

    def test_bot_keeps_zeroes_before_unfinished_moon_chase(self):
        """Bot should prefer safe zeroes unless the moon shot is complete."""
        self.player1.dice.values = [6, 6, 6, 3, 6]
        self.player1.dice.locked = [0, 1, 2]
        self.player1.dice.kept = [0, 1, 2]

        self.game._bot_decide_keepers(self.player1)

        assert 3 in self.player1.dice.kept
        assert 4 not in self.player1.dice.kept

    def test_bot_finishes_complete_moon_shot(self):
        """Five sixes should still be kept for the -30 moon-shot score."""
        self.player1.dice.values = [6, 6, 6, 6, 6]
        self.player1.dice.locked = [0, 1, 2]
        self.player1.dice.kept = [0, 1, 2]

        self.game._bot_decide_keepers(self.player1)

        assert self.player1.dice.kept == [0, 1, 2, 3, 4]


class TestThreesPlayTest:
    """Integration tests for complete game play."""

    def test_two_player_game_completes(self):
        """Test that a 2-player bot game completes."""
        game = ThreesGame()
        game.options.total_rounds = 3  # Fewer rounds for faster test

        bot1 = Bot("Bot1")
        bot2 = Bot("Bot2")
        game.add_player("Bot1", bot1)
        game.add_player("Bot2", bot2)

        game.on_start()

        # Run game for many ticks
        max_ticks = 5000
        for _ in range(max_ticks):
            if game.status == "finished":
                break
            game.on_tick()

        assert game.status == "finished"

    def test_four_player_game_completes(self):
        """Test that a 4-player bot game completes."""
        game = ThreesGame()
        game.options.total_rounds = 3

        for i in range(4):
            bot = Bot(f"Bot{i}")
            game.add_player(f"Bot{i}", bot)

        game.on_start()

        max_ticks = 10000
        for _ in range(max_ticks):
            if game.status == "finished":
                break
            game.on_tick()

        assert game.status == "finished"


class TestThreesPersistence:
    """Tests for game persistence."""

    def test_full_state_preserved(self):
        """Test that full game state is preserved through save/load."""
        game = ThreesGame(options=ThreesOptions(total_rounds=5))
        user1 = MockUser("Alice")
        user2 = MockUser("Bob")
        game.add_player("Alice", user1)
        game.add_player("Bob", user2)

        game.on_start()

        # Set various state
        game.current_round = 3

        # Save
        json_str = game.to_json()

        # Load
        loaded = ThreesGame.from_json(json_str)

        # Verify state
        assert loaded.game_active is True
        assert loaded.current_round == 3
        assert loaded.options.total_rounds == 5


def test_threes_locale_key_and_variable_parity():
    """English and Vietnamese Threes locale files must stay structurally synced."""
    root = Path(__file__).resolve().parents[1]
    en_text = (root / "locales" / "en" / "threes.ftl").read_text(encoding="utf-8")
    vi_text = (root / "locales" / "vi" / "threes.ftl").read_text(encoding="utf-8")

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


def test_threes_manuals_use_synchronized_beginner_terms():
    """Docs should stay manual-like and aligned across EN/VI terminology."""
    root = Path(__file__).resolve().parents[1]
    en_doc = (
        root / "documentation" / "content" / "en" / "games" / "threes.md"
    ).read_text(encoding="utf-8")
    vi_doc = (
        root / "documentation" / "content" / "vi" / "games" / "threes.md"
    ).read_text(encoding="utf-8")

    assert "\\*\\*Personal Options\\*\\*" in en_doc
    assert "\\*\\*Tùy chọn cá nhân\\*\\*" in vi_doc
    assert "Brief announcements" in en_doc
    assert "Thông báo ngắn gọn" in vi_doc
    assert "shoot the moon" in en_doc
    assert "chạm trăng" in vi_doc

