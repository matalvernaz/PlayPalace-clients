"""Tests for the Parcheesi-family shared board primitives.

The engine is stateless so all tests construct a fresh engine per case.
"""

import pytest

from server.game_utils.parcheesi import (
    FinishMode,
    MovementEngine,
    SeatGeometry,
    Token,
    TokenZone,
    clockwise_distance,
    every_nth_safe_positions,
    home_stretch_safe_positions,
    normalize_track_position,
)


# ==========================================================================
# Track math
# ==========================================================================


class TestTrackMath:
    def test_normalize_basic(self):
        assert normalize_track_position(0, 28) == 0
        assert normalize_track_position(27, 28) == 27
        assert normalize_track_position(28, 28) == 0
        assert normalize_track_position(29, 28) == 1

    def test_normalize_negative(self):
        assert normalize_track_position(-1, 28) == 27

    def test_clockwise_distance(self):
        assert clockwise_distance(0, 5, 28) == 5
        assert clockwise_distance(25, 2, 28) == 5  # wraps around
        assert clockwise_distance(5, 5, 28) == 0


# ==========================================================================
# Seat geometry
# ==========================================================================


class TestSeatGeometry:
    def test_two_seats_on_track_28(self):
        geoms = SeatGeometry.all_seats(num_seats=2, track_length=28)
        assert len(geoms) == 2
        assert geoms[0].start_position == 0
        assert geoms[0].finish_entry_position == 27
        assert geoms[1].start_position == 14
        assert geoms[1].finish_entry_position == 13

    def test_four_seats_on_track_28(self):
        geoms = SeatGeometry.all_seats(num_seats=4, track_length=28)
        starts = [g.start_position for g in geoms]
        assert starts == [0, 7, 14, 21]

    def test_invalid_num_seats_raises(self):
        with pytest.raises(ValueError):
            SeatGeometry.for_seat(0, num_seats=0, track_length=28)

    def test_invalid_track_length_raises(self):
        with pytest.raises(ValueError):
            SeatGeometry.for_seat(0, num_seats=4, track_length=0)


# ==========================================================================
# Home release
# ==========================================================================


def _make_engine(
    *,
    track_length: int = 28,
    finish_lane_length: int = 4,
    num_seats: int = 4,
    finish_mode: FinishMode = FinishMode.EXACT,
    safe_positions: frozenset[int] = frozenset(),
) -> MovementEngine:
    geoms = SeatGeometry.all_seats(
        num_seats=num_seats, track_length=track_length
    )
    return MovementEngine(
        track_length=track_length,
        finish_lane_length=finish_lane_length,
        seat_geometries=geoms,
        finish_mode=finish_mode,
        safe_positions=safe_positions,
    )


class TestHomeRelease:
    def test_release_requires_six_by_default(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.HOME)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=3,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert not result.legal
        assert result.reason == "token-home-needs-six"

    def test_release_on_six(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.HOME)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=6,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.TRACK
        assert result.new_position == 0  # Seat 0 starts at track pos 0

    def test_release_any_roll_when_six_rule_off(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.HOME)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=2,
            opponent_tokens=[],
            six_to_leave_home=False,
        )
        assert result.legal
        assert result.new_zone == TokenZone.TRACK

    def test_release_bumps_opponent_at_start(self):
        engine = _make_engine()
        my_token = Token(token_number=1, zone=TokenZone.HOME)
        opp = Token(token_number=3, zone=TokenZone.TRACK, position=0)
        result = engine.simulate_move(
            seat_index=0,
            token=my_token,
            roll=6,
            opponent_tokens=[(2, opp)],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.bumped_owner_seat == 2
        assert result.bumped_token_number == 3


# ==========================================================================
# Track movement
# ==========================================================================


class TestTrackMovement:
    def test_simple_advance_stays_on_track(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.TRACK, position=0)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=3,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.TRACK
        assert result.new_position == 3

    def test_wrap_around(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.TRACK, position=25)
        # Seat 0's finish_entry is at 27; track moves remaining = 27 - 25 = 2.
        # Roll 2 → land on 27 (still on track).
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=2,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.TRACK
        assert result.new_position == 27

    def test_crossing_into_finish_lane(self):
        engine = _make_engine()
        # Seat 0: finish_entry=27. Token at 27; roll of 1 moves one step into
        # the lane (lane position 1).
        token = Token(token_number=1, zone=TokenZone.TRACK, position=27)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=1,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISH_LANE
        assert result.new_position == 1

    def test_bump_at_landing(self):
        engine = _make_engine()
        my_token = Token(token_number=1, zone=TokenZone.TRACK, position=0)
        opp = Token(token_number=2, zone=TokenZone.TRACK, position=3)
        result = engine.simulate_move(
            seat_index=0,
            token=my_token,
            roll=3,
            opponent_tokens=[(1, opp)],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.bumped_owner_seat == 1
        assert result.bumped_token_number == 2

    def test_bump_respects_safe_positions(self):
        engine = _make_engine(safe_positions=frozenset({3}))
        my_token = Token(token_number=1, zone=TokenZone.TRACK, position=0)
        opp = Token(token_number=2, zone=TokenZone.TRACK, position=3)
        result = engine.simulate_move(
            seat_index=0,
            token=my_token,
            roll=3,
            opponent_tokens=[(1, opp)],
            six_to_leave_home=True,
        )
        assert result.legal
        # Landing allowed but no bump.
        assert result.bumped_owner_seat is None


# ==========================================================================
# Finish-lane movement under each finish mode
# ==========================================================================


class TestFinishLaneExact:
    def test_exact_finish(self):
        engine = _make_engine(finish_mode=FinishMode.EXACT)
        token = Token(token_number=1, zone=TokenZone.FINISH_LANE, position=3)
        # finish target = lane_length + 1 = 5. From lane 3 + roll 2 → 5 = FINISHED.
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=2,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISHED

    def test_overshoot_wastes_roll(self):
        engine = _make_engine(finish_mode=FinishMode.EXACT)
        token = Token(token_number=1, zone=TokenZone.FINISH_LANE, position=3)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=3,  # 3 + 3 = 6 > finish target 5
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert not result.legal
        assert result.reason == "overshoot-wastes"


class TestFinishLaneBounce:
    def test_overshoot_bounces_back(self):
        engine = _make_engine(finish_mode=FinishMode.BOUNCE)
        token = Token(token_number=1, zone=TokenZone.FINISH_LANE, position=3)
        # Lane 3 + roll 3 = 6. finish_target=5. overshoot=1. bounced to 5-1=4.
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=3,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISH_LANE
        assert result.new_position == 4

    def test_excessive_bounce_still_illegal(self):
        engine = _make_engine(
            finish_lane_length=4, finish_mode=FinishMode.BOUNCE
        )
        token = Token(token_number=1, zone=TokenZone.FINISH_LANE, position=1)
        # finish_target=5; lane 1 + roll 6 = 7; overshoot=2; bounced=5-2=3 (legal).
        # But with a really large roll we'd bounce past the start, which is illegal.
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=6,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        # 1 + 6 = 7; overshoot = 2; bounced = 3. Legal.
        assert result.legal
        assert result.new_position == 3

        token2 = Token(token_number=2, zone=TokenZone.FINISH_LANE, position=4)
        # 4 + 6 = 10; overshoot = 5; bounced = 0 → illegal (past start of lane).
        result2 = engine.simulate_move(
            seat_index=0,
            token=token2,
            roll=6,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert not result2.legal


class TestFinishLaneAllow:
    def test_overshoot_still_lands_finished(self):
        engine = _make_engine(finish_mode=FinishMode.ALLOW)
        token = Token(token_number=1, zone=TokenZone.FINISH_LANE, position=3)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=6,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISHED


# ==========================================================================
# Track-to-lane crossover with various track sizes
# ==========================================================================


class TestTrackToLaneCrossover:
    @pytest.mark.parametrize("track_length", [20, 24, 28, 32, 36, 40])
    def test_start_to_finish_distance_each_size(self, track_length):
        """Regardless of track size, a token must take exactly
        (track_length - 1) track steps from start before entering the lane."""
        engine = _make_engine(track_length=track_length, num_seats=4)
        geom = engine.seat_geometries[0]
        token = Token(
            token_number=1,
            zone=TokenZone.TRACK,
            position=geom.finish_entry_position,
        )
        # From finish_entry, roll 1 should enter lane position 1.
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=1,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISH_LANE
        assert result.new_position == 1

    def test_track_plus_lane_overflow(self):
        """Token at start, roll > remaining track space, overflows into lane."""
        engine = _make_engine(track_length=20, num_seats=4)
        # Seat 0 starts at 0, finish_entry at 19. Track moves remaining = 19.
        # Roll 20 → 1 overflow step into lane (lane pos 1).
        token = Token(token_number=1, zone=TokenZone.TRACK, position=18)
        # From pos 18, traveled = 18, track_moves_remaining = 19 - 18 = 1.
        # Roll 2 → 1 overflow → lane pos 1.
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=2,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert result.legal
        assert result.new_zone == TokenZone.FINISH_LANE
        assert result.new_position == 1


# ==========================================================================
# Already finished tokens
# ==========================================================================


class TestFinishedToken:
    def test_cannot_move_finished_token(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.FINISHED)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=6,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        assert not result.legal
        assert result.reason == "token-finished"


# ==========================================================================
# Safe-position helpers
# ==========================================================================


class TestSafePositions:
    def test_home_stretch_policy(self):
        geoms = SeatGeometry.all_seats(num_seats=4, track_length=28)
        safe = home_stretch_safe_positions(geoms)
        # Each seat's finish_entry_position should be in the set.
        for geom in geoms:
            assert geom.finish_entry_position in safe
        assert len(safe) == 4

    def test_every_nth_policy(self):
        safe = every_nth_safe_positions(track_length=28, n=7)
        assert safe == frozenset({0, 7, 14, 21})

    def test_every_nth_policy_zero_n(self):
        safe = every_nth_safe_positions(track_length=28, n=0)
        assert safe == frozenset()


# ==========================================================================
# apply_move actually mutates
# ==========================================================================


class TestApplyMove:
    def test_apply_move_mutates_token(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.TRACK, position=0)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=5,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        engine.apply_move(token, result)
        assert token.zone == TokenZone.TRACK
        assert token.position == 5

    def test_apply_move_rejects_illegal(self):
        engine = _make_engine()
        token = Token(token_number=1, zone=TokenZone.HOME)
        result = engine.simulate_move(
            seat_index=0,
            token=token,
            roll=3,
            opponent_tokens=[],
            six_to_leave_home=True,
        )
        with pytest.raises(ValueError):
            engine.apply_move(token, result)
