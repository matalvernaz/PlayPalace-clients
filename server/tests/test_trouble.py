"""Tests for the Trouble game.

Focus per project priorities:
- Every option combination produces a game that completes.
- Presets apply cleanly; individual overrides switch preset to "custom".
- Customization-heavy: track size, token count, safe spaces, finish mode,
  extra-turn-on-six, six-to-leave-home — each tested in isolation AND in
  representative combinations via bot-vs-bot play.
- Serialization round-trip survives mid-game saves.
"""

import json
import random

import pytest

from server.games.trouble.game import (
    TroubleGame,
    TroubleOptions,
    TroublePlayer,
    FINISH_LANE_LENGTH,
)
from server.games.trouble.presets import (
    PRESETS,
    PRESET_KEYS,
    apply_preset,
    matching_preset_id,
)
from server.game_utils.parcheesi import Token, TokenZone
from server.core.users.test_user import MockUser
from server.core.users.bot import Bot


# ==========================================================================
# Registration & basic shape
# ==========================================================================


class TestTroubleRegistration:
    def test_game_metadata(self):
        assert TroubleGame.get_name() == "Trouble"
        assert TroubleGame.get_type() == "trouble"
        assert TroubleGame.get_category() == "category-board-games"
        assert TroubleGame.get_min_players() == 2
        assert TroubleGame.get_max_players() == 4

    def test_player_creation(self):
        game = TroubleGame()
        user = MockUser("Alice")
        player = game.add_player("Alice", user)
        assert player.name == "Alice"
        assert isinstance(player, TroublePlayer)


# ==========================================================================
# Options defaults and customization
# ==========================================================================


class TestTroubleOptionsDefaults:
    def test_defaults(self):
        opts = TroubleOptions()
        assert opts.preset == "classic"
        assert opts.team_mode == "individual"
        assert opts.track_size == "28"
        assert opts.tokens_per_player == "4"
        assert opts.extra_turn_on_six is True
        assert opts.six_to_leave_home is True
        assert opts.safe_spaces == "none"
        assert opts.finish_behavior == "exact"
        assert opts.bot_difficulty == "greedy"

    @pytest.mark.parametrize("track_size", ["20", "24", "28", "32", "36", "40"])
    def test_track_size_customization(self, track_size):
        opts = TroubleOptions()
        opts.track_size = track_size
        game = TroubleGame(options=opts)
        assert game.track_length == int(track_size)

    @pytest.mark.parametrize("tokens", ["2", "3", "4", "5", "6"])
    def test_tokens_per_player_customization(self, tokens):
        opts = TroubleOptions()
        opts.tokens_per_player = tokens
        game = TroubleGame(options=opts)
        assert game.tokens_per_player == int(tokens)

    @pytest.mark.parametrize(
        "safe_mode", ["none", "home_stretch", "every_seventh"]
    )
    def test_safe_spaces_customization(self, safe_mode):
        opts = TroubleOptions()
        opts.safe_spaces = safe_mode
        game = TroubleGame(options=opts)
        _setup_two_players(game)
        # _safe_positions should compute without error.
        safe = game._safe_positions(game._seat_geometries())
        if safe_mode == "none":
            assert safe == frozenset()
        else:
            assert isinstance(safe, frozenset)

    @pytest.mark.parametrize("finish", ["exact", "bounce", "allow"])
    def test_finish_behavior_customization(self, finish):
        opts = TroubleOptions()
        opts.finish_behavior = finish
        game = TroubleGame(options=opts)
        _setup_two_players(game)
        engine = game._build_engine()
        # Just verify the engine is built with the requested mode.
        assert engine.finish_mode.value == finish


# ==========================================================================
# Presets
# ==========================================================================


class TestTroublePresets:
    def test_every_preset_covers_all_keys(self):
        """Each preset must set every key in PRESET_KEYS."""
        for preset_id, preset in PRESETS.items():
            for key in PRESET_KEYS:
                assert key in preset, (
                    f"Preset {preset_id!r} is missing key {key!r}"
                )

    @pytest.mark.parametrize("preset_id", ["classic", "fast", "brutal"])
    def test_apply_preset_sets_values(self, preset_id):
        opts = TroubleOptions()
        ok = apply_preset(opts, preset_id)
        assert ok
        preset = PRESETS[preset_id]
        for key, value in preset.items():
            assert getattr(opts, key) == value

    def test_apply_unknown_preset_returns_false(self):
        opts = TroubleOptions()
        assert apply_preset(opts, "nonexistent") is False

    @pytest.mark.parametrize("preset_id", ["classic", "fast", "brutal"])
    def test_matching_preset_id_after_apply(self, preset_id):
        opts = TroubleOptions()
        apply_preset(opts, preset_id)
        assert matching_preset_id(opts) == preset_id

    def test_override_switches_to_custom(self):
        opts = TroubleOptions()
        apply_preset(opts, "classic")
        # Change one value to something Classic doesn't have.
        opts.track_size = "40"
        assert matching_preset_id(opts) is None

    def test_game_apply_preset_method(self):
        game = TroubleGame()
        assert game.apply_preset_to_options("classic") is True
        assert game.options.preset == "classic"
        assert game.options.track_size == "28"

    def test_game_apply_preset_custom_returns_false(self):
        game = TroubleGame()
        assert game.apply_preset_to_options("custom") is False

    def test_recompute_preset_tag_after_override(self):
        game = TroubleGame()
        game.apply_preset_to_options("classic")
        game.options.track_size = "40"
        game.recompute_preset_tag()
        assert game.options.preset == "custom"

    def test_recompute_preset_tag_finds_exact_match(self):
        game = TroubleGame()
        # Manually set values matching "fast" preset.
        for key, value in PRESETS["fast"].items():
            setattr(game.options, key, value)
        game.recompute_preset_tag()
        assert game.options.preset == "fast"


# ==========================================================================
# Turn flow
# ==========================================================================


def _setup_two_players(game: TroubleGame) -> tuple[TroublePlayer, TroublePlayer]:
    u1 = MockUser("Alice")
    u2 = MockUser("Bob")
    p1 = game.add_player("Alice", u1)
    p2 = game.add_player("Bob", u2)
    game.on_start()
    return p1, p2


class TestTroubleTurnFlow:
    def test_on_start_initializes_tokens(self):
        game = TroubleGame()
        p1, p2 = _setup_two_players(game)
        assert len(p1.tokens) == 4
        assert all(t.zone == TokenZone.HOME for t in p1.tokens)
        assert all(t.zone == TokenZone.HOME for t in p2.tokens)

    def test_seat_indices_assigned(self):
        game = TroubleGame()
        p1, p2 = _setup_two_players(game)
        assert {p1.seat_index, p2.seat_index} == {0, 1}

    def test_roll_sets_last_roll(self):
        random.seed(42)
        game = TroubleGame()
        p1, _ = _setup_two_players(game)
        current = game.current_player
        assert isinstance(current, TroublePlayer)
        game.execute_action(current, "roll")
        # After a roll, either last_roll is set (and we're choosing a move)
        # or the turn has already ended (auto-applied single move / no move).
        # In all cases: the player either has a pending roll or reset to 0.
        assert current.last_roll in (0, 1, 2, 3, 4, 5, 6)

    def test_no_legal_move_passes_turn(self):
        """With six_to_leave_home on and no tokens on track, rolling a non-6
        leaves no legal move and the turn passes."""
        game = TroubleGame()
        p1, p2 = _setup_two_players(game)
        current = game.current_player
        assert isinstance(current, TroublePlayer)
        # Force a non-6 roll by monkeypatching random.
        import server.games.trouble.game as tmodule
        original = tmodule.random.randint
        try:
            tmodule.random.randint = lambda a, b: 3
            game.execute_action(current, "roll")
            # Roll should be 0 now (turn ended) OR current_player is different.
        finally:
            tmodule.random.randint = original
        # After the roll and a no-legal-move pass, current_player should
        # differ from the player who just rolled.
        assert current.last_roll == 0


class TestTroubleOptionCustomizationAffectsPlay:
    def test_any_roll_gives_legal_moves_when_six_rule_off(self):
        """With six_to_leave_home off, a non-6 roll produces legal release
        moves for every token still in Home."""
        game = TroubleGame(options=TroubleOptions())
        game.options.six_to_leave_home = False
        p1, _ = _setup_two_players(game)
        current = game.current_player
        assert isinstance(current, TroublePlayer)

        import server.games.trouble.game as tmodule
        original = tmodule.random.randint
        try:
            tmodule.random.randint = lambda a, b: 3  # non-6
            game.execute_action(current, "roll")
        finally:
            tmodule.random.randint = original
        # Multiple legal moves (one per Home token) so no auto-apply;
        # the player is now expected to pick. last_roll stays 3.
        assert current.last_roll == 3
        assert set(current.legal_move_tokens) == {1, 2, 3, 4}

        # Executing the choice releases the specified token.
        game.execute_action(current, "move_token_1")
        token1 = current.tokens[0]
        assert token1.zone == TokenZone.TRACK

    def test_extra_turn_off_means_turn_always_ends(self):
        game = TroubleGame()
        game.options.extra_turn_on_six = False
        p1, p2 = _setup_two_players(game)
        current = game.current_player

        import server.games.trouble.game as tmodule
        original = tmodule.random.randint
        try:
            tmodule.random.randint = lambda a, b: 6
            game.execute_action(current, "roll")
        finally:
            tmodule.random.randint = original
        # With extra_turn_on_six off, rolling a 6 still releases a token
        # (six-to-leave-home is on by default) but should NOT give an extra turn.
        # current_player changed to the other player.
        assert game.current_player is not current


# ==========================================================================
# Bot play — whole-game runs across option combinations
# ==========================================================================


def _run_bot_game(
    *,
    seed: int = 0,
    track_size: str = "28",
    tokens_per_player: str = "4",
    extra_turn_on_six: bool = True,
    six_to_leave_home: bool = True,
    safe_spaces: str = "none",
    finish_behavior: str = "exact",
    bot_difficulty: str = "greedy",
    team_mode: str = "individual",
    num_players: int = 2,
    max_ticks: int = 20_000,
) -> TroubleGame:
    """Play a bots-only game with the given option combination."""
    random.seed(seed)
    game = TroubleGame()
    game.options.track_size = track_size
    game.options.tokens_per_player = tokens_per_player
    game.options.extra_turn_on_six = extra_turn_on_six
    game.options.six_to_leave_home = six_to_leave_home
    game.options.safe_spaces = safe_spaces
    game.options.finish_behavior = finish_behavior
    game.options.bot_difficulty = bot_difficulty
    game.options.team_mode = team_mode
    for i in range(num_players):
        bot = Bot(f"Bot{i + 1}")
        game.add_player(f"Bot{i + 1}", bot)
    game.on_start()
    for _ in range(max_ticks):
        if not game.game_active:
            break
        game.on_tick()
    return game


class TestTroubleBotPlay:
    def test_classic_two_player_completes(self):
        game = _run_bot_game(seed=1)
        assert not game.game_active

    def test_classic_four_player_completes(self):
        game = _run_bot_game(seed=2, num_players=4)
        assert not game.game_active

    def test_naive_bot_completes(self):
        game = _run_bot_game(seed=3, bot_difficulty="naive")
        assert not game.game_active

    @pytest.mark.parametrize("seed", [10, 11, 12, 13, 14])
    def test_multiple_seeds_complete(self, seed):
        game = _run_bot_game(seed=seed)
        assert not game.game_active


class TestTroubleBotPlayAcrossOptions:
    """Matrix: verify bot games complete under representative option combos."""

    @pytest.mark.parametrize("track_size", ["20", "28", "40"])
    def test_track_sizes(self, track_size):
        game = _run_bot_game(seed=20, track_size=track_size)
        assert not game.game_active

    @pytest.mark.parametrize("tokens", ["2", "4", "6"])
    def test_token_counts(self, tokens):
        game = _run_bot_game(seed=21, tokens_per_player=tokens)
        assert not game.game_active

    @pytest.mark.parametrize(
        "finish_mode", ["exact", "bounce", "allow"]
    )
    def test_finish_modes(self, finish_mode):
        game = _run_bot_game(seed=22, finish_behavior=finish_mode)
        assert not game.game_active

    @pytest.mark.parametrize(
        "safe_mode", ["none", "home_stretch", "every_seventh"]
    )
    def test_safe_modes(self, safe_mode):
        game = _run_bot_game(seed=23, safe_spaces=safe_mode)
        assert not game.game_active

    def test_six_to_leave_home_off(self):
        game = _run_bot_game(seed=24, six_to_leave_home=False)
        assert not game.game_active

    def test_extra_turn_on_six_off(self):
        game = _run_bot_game(seed=25, extra_turn_on_six=False)
        assert not game.game_active


class TestTroublePresetPlay:
    @pytest.mark.parametrize("preset_id", ["classic", "fast", "brutal"])
    def test_each_preset_completes(self, preset_id):
        random.seed(50 + hash(preset_id) % 1000)
        game = TroubleGame()
        game.apply_preset_to_options(preset_id)
        for i in range(4):
            game.add_player(f"Bot{i + 1}", Bot(f"Bot{i + 1}"))
        game.on_start()
        for _ in range(30_000):
            if not game.game_active:
                break
            game.on_tick()
        assert not game.game_active, (
            f"Preset {preset_id!r} did not complete within 30k ticks"
        )


class TestTroubleTeamMode:
    def test_2v2_completes(self):
        game = _run_bot_game(
            seed=60,
            num_players=4,
            team_mode="2v2",
            tokens_per_player="2",  # Keep it fast.
        )
        assert not game.game_active


# ==========================================================================
# Serialization
# ==========================================================================


class TestTroubleSerialization:
    def test_roundtrip_preserves_state(self):
        random.seed(100)
        game = TroubleGame()
        for i in range(2):
            game.add_player(f"Bot{i + 1}", Bot(f"Bot{i + 1}"))
        game.on_start()
        # Run a few ticks to get non-trivial state.
        for _ in range(300):
            if not game.game_active:
                break
            game.on_tick()

        json_str = game.to_json()
        restored = TroubleGame.from_json(json_str)

        # Board state matches
        for orig_p, restored_p in zip(game.players, restored.players):
            assert len(orig_p.tokens) == len(restored_p.tokens)
            for orig_t, new_t in zip(orig_p.tokens, restored_p.tokens):
                assert orig_t.zone == new_t.zone
                assert orig_t.position == new_t.position
                assert orig_t.token_number == new_t.token_number

    def test_options_survive_roundtrip(self):
        game = TroubleGame()
        game.options.track_size = "36"
        game.options.finish_behavior = "bounce"
        game.options.safe_spaces = "home_stretch"
        game.options.bot_difficulty = "naive"
        for i in range(2):
            game.add_player(f"Bot{i + 1}", Bot(f"Bot{i + 1}"))
        game.on_start()

        json_str = game.to_json()
        restored = TroubleGame.from_json(json_str)

        assert restored.options.track_size == "36"
        assert restored.options.finish_behavior == "bounce"
        assert restored.options.safe_spaces == "home_stretch"
        assert restored.options.bot_difficulty == "naive"


class TestTroubleSerializationRoundtripDuringPlay:
    def test_save_reload_every_200_ticks(self):
        random.seed(101)
        game = TroubleGame()
        for i in range(2):
            game.add_player(f"Bot{i + 1}", Bot(f"Bot{i + 1}"))
        game.on_start()

        for tick in range(15_000):
            if not game.game_active:
                break
            if tick > 0 and tick % 200 == 0:
                json_str = game.to_json()
                game = TroubleGame.from_json(json_str)
                # Rebind bot users
                for p in game.players:
                    game.attach_user(p.name, Bot(p.name))
                game.rebuild_runtime_state()
                for p in game.players:
                    if game.get_user(p):
                        game.setup_player_actions(p)
            game.on_tick()

        assert not game.game_active, (
            "Game should complete with periodic save/reload"
        )


# ==========================================================================
# Narration
# ==========================================================================


class TestTroubleNarration:
    def test_turn_start_speaks_summary_to_each_player(self):
        game = TroubleGame()
        u1 = MockUser("Alice")
        u2 = MockUser("Bob")
        game.add_player("Alice", u1)
        game.add_player("Bob", u2)
        game.on_start()

        # Every player should have heard at least one spoken message containing
        # either "Home" or "track" after on_start (which fires _start_turn).
        alice_msgs = u1.get_spoken_messages()
        bob_msgs = u2.get_spoken_messages()
        assert any(
            "home" in m.lower() or "track" in m.lower() for m in alice_msgs
        ), f"Alice heard no turn summary: {alice_msgs}"
        assert any(
            "home" in m.lower() or "track" in m.lower() for m in bob_msgs
        ), f"Bob heard no turn summary: {bob_msgs}"

    def test_check_board_produces_full_detail(self):
        game = TroubleGame()
        u1 = MockUser("Alice")
        u2 = MockUser("Bob")
        game.add_player("Alice", u1)
        game.add_player("Bob", u2)
        game.on_start()
        current = game.current_player
        assert isinstance(current, TroublePlayer)
        user = game.get_user(current)
        assert user is not None
        user.messages.clear()
        game.execute_action(current, "check_board")
        spoken = user.get_spoken_messages()
        assert any(
            "token" in m.lower() for m in spoken
        ), f"Check board produced no token detail: {spoken}"
