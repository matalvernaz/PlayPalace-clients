"""Parcheesi-family board primitives.

Shared state model and movement engine for games in the Parcheesi family
— games where each player races a set of tokens from a starting Home area
around a shared track and into a private finish lane.

Current users:
  - Trouble (server.games.trouble)

Sorry (server.games.sorry) and Ludo (server.games.ludo) predate this module
and each reimplement the primitives in their own game.py. They remain on
their own implementations; they can be migrated to this base
opportunistically when someone is already touching those games for other
reasons. Do not start a migration for its own sake — they work, and
touching them to migrate risks breaking two shipped games for zero
gameplay gain.

Design: the engine is stateless. Callers pass in the current state and
the engine returns a MoveResult describing what would happen. This keeps
the engine trivial to unit-test and cheap to reuse in bot lookahead
without cloning state.
"""

from dataclasses import dataclass
from enum import Enum


class TokenZone(str, Enum):
    """Where a token currently is on the board."""

    HOME = "home"  # In the starting Home area (pre-release)
    TRACK = "track"  # On the shared outer track
    FINISH_LANE = "finish_lane"  # In the private finish lane
    FINISHED = "finished"  # At the finish


@dataclass
class Token:
    """State for a single token."""

    token_number: int  # 1-based for speech ("token 3")
    zone: TokenZone = TokenZone.HOME
    # Meaning depends on zone:
    #   TRACK:       absolute position on the shared track, 0..track_length-1
    #   FINISH_LANE: 1-based position within the finish lane (1..finish_lane_length)
    #   HOME / FINISHED: 0 (unused)
    position: int = 0


@dataclass(frozen=True)
class SeatGeometry:
    """Per-seat anchor positions on the shared track.

    Parcheesi-family games seat players around the track at regular
    intervals. For a track of length L divided into N seats, seat i's
    start is at i * (L // N) and its finish-lane entry is the track
    space one before that.
    """

    seat_index: int
    start_position: int  # Track position where this seat's tokens enter
    finish_entry_position: int  # Track space one before the finish-lane entry

    @classmethod
    def for_seat(
        cls, seat_index: int, num_seats: int, track_length: int
    ) -> "SeatGeometry":
        """Compute geometry for seat_index given num_seats and track_length."""
        if num_seats <= 0:
            raise ValueError("num_seats must be positive")
        if track_length <= 0:
            raise ValueError("track_length must be positive")
        gap = track_length // num_seats
        if gap == 0:
            raise ValueError("track_length must be at least num_seats")
        start_pos = (seat_index % num_seats) * gap
        finish_entry = (start_pos - 1) % track_length
        return cls(
            seat_index=seat_index,
            start_position=start_pos,
            finish_entry_position=finish_entry,
        )

    @classmethod
    def all_seats(
        cls, num_seats: int, track_length: int
    ) -> "list[SeatGeometry]":
        """Build geometry for every seat 0..num_seats-1."""
        return [cls.for_seat(i, num_seats, track_length) for i in range(num_seats)]


def normalize_track_position(position: int, track_length: int) -> int:
    """Wrap a track position into [0, track_length)."""
    return position % track_length


def clockwise_distance(start: int, end: int, track_length: int) -> int:
    """Clockwise distance from start to end around a track of length track_length."""
    return (end - start) % track_length


class FinishMode(str, Enum):
    """How rolls that would overshoot the finish are handled."""

    EXACT = "exact"  # Overshoot wastes the roll; token does not move
    BOUNCE = "bounce"  # Overshoot bounces back from the finish
    ALLOW = "allow"  # Overshoot lands at finish anyway


@dataclass
class MoveResult:
    """Outcome of simulating (or applying) a move."""

    legal: bool
    new_zone: TokenZone | None = None
    new_position: int = 0
    # If the move would bump an opponent, (owner_seat, token_number) of the bumped token.
    bumped_owner_seat: int | None = None
    bumped_token_number: int | None = None
    # Short identifier ("token-home-needs-six", "overshoot-wastes", ...) when illegal.
    reason: str | None = None


class MovementEngine:
    """Stateless engine that computes the result of moving a token.

    The engine does not own the token list. Callers pass in current state
    and the engine tells them what would happen on a given roll.
    """

    def __init__(
        self,
        *,
        track_length: int,
        finish_lane_length: int,
        seat_geometries: list[SeatGeometry],
        finish_mode: FinishMode,
        safe_positions: frozenset[int] = frozenset(),
    ):
        self.track_length = track_length
        self.finish_lane_length = finish_lane_length
        self.seat_geometries = seat_geometries
        self.finish_mode = finish_mode
        self.safe_positions = safe_positions

    # --------------------------------------------------------------
    # Public API
    # --------------------------------------------------------------

    def simulate_move(
        self,
        *,
        seat_index: int,
        token: Token,
        roll: int,
        opponent_tokens: list[tuple[int, Token]],
        six_to_leave_home: bool,
    ) -> MoveResult:
        """Compute the result of moving `token` by `roll` steps.

        opponent_tokens: list of (owner_seat_index, token) for all tokens
        on the board. Tokens owned by seat_index itself are ignored for
        bump detection but may be included in the list harmlessly.
        """
        if roll < 1:
            return MoveResult(legal=False, reason="invalid-roll")
        if token.zone == TokenZone.FINISHED:
            return MoveResult(legal=False, reason="token-finished")

        if token.zone == TokenZone.HOME:
            return self._resolve_home_release(
                seat_index=seat_index,
                roll=roll,
                opponent_tokens=opponent_tokens,
                six_to_leave_home=six_to_leave_home,
            )

        if token.zone == TokenZone.TRACK:
            return self._resolve_track_move(
                seat_index=seat_index,
                token=token,
                roll=roll,
                opponent_tokens=opponent_tokens,
            )

        if token.zone == TokenZone.FINISH_LANE:
            return self._resolve_finish_lane_move(
                lane_position_before=token.position, steps=roll
            )

        return MoveResult(legal=False, reason="unknown-zone")

    def apply_move(self, token: Token, result: MoveResult) -> None:
        """Mutate `token` in place using a MoveResult known to be legal.

        Bumped opponent tokens are the caller's responsibility to reset —
        this engine is stateless and doesn't own the opponent's Token objects.
        """
        if not result.legal or result.new_zone is None:
            raise ValueError("apply_move called with an illegal result")
        token.zone = result.new_zone
        token.position = result.new_position

    # --------------------------------------------------------------
    # Internals
    # --------------------------------------------------------------

    def _resolve_home_release(
        self,
        *,
        seat_index: int,
        roll: int,
        opponent_tokens: list[tuple[int, Token]],
        six_to_leave_home: bool,
    ) -> MoveResult:
        if six_to_leave_home:
            if roll != 6:
                return MoveResult(legal=False, reason="token-home-needs-six")
        # When six_to_leave_home is off, any positive roll releases (roll < 1
        # was already rejected above).
        start_pos = self.seat_geometries[seat_index].start_position
        bump = self._detect_bump_at_track(start_pos, seat_index, opponent_tokens)
        return MoveResult(
            legal=True,
            new_zone=TokenZone.TRACK,
            new_position=start_pos,
            bumped_owner_seat=bump[0] if bump else None,
            bumped_token_number=bump[1] if bump else None,
        )

    def _resolve_track_move(
        self,
        *,
        seat_index: int,
        token: Token,
        roll: int,
        opponent_tokens: list[tuple[int, Token]],
    ) -> MoveResult:
        geom = self.seat_geometries[seat_index]
        traveled = clockwise_distance(
            geom.start_position, token.position, self.track_length
        )
        # Track moves remaining = steps until the next step would cross into the
        # finish lane. The finish-lane entry is one past finish_entry_position.
        track_moves_remaining = self.track_length - 1 - traveled

        if roll <= track_moves_remaining:
            new_pos = normalize_track_position(
                token.position + roll, self.track_length
            )
            bump = self._detect_bump_at_track(
                new_pos, seat_index, opponent_tokens
            )
            return MoveResult(
                legal=True,
                new_zone=TokenZone.TRACK,
                new_position=new_pos,
                bumped_owner_seat=bump[0] if bump else None,
                bumped_token_number=bump[1] if bump else None,
            )

        # Steps overflow into the finish lane. overflow=1 lands at lane pos 1.
        overflow = roll - track_moves_remaining
        return self._resolve_finish_lane_move(lane_position_before=0, steps=overflow)

    def _resolve_finish_lane_move(
        self, *, lane_position_before: int, steps: int
    ) -> MoveResult:
        # Finish target: the conceptual position one past the last lane slot.
        finish_target = self.finish_lane_length + 1
        new_pos = lane_position_before + steps

        if new_pos < 1:
            # Only possible with non-positive steps; invalid-roll catches that earlier.
            return MoveResult(legal=False, reason="invalid-move")
        if new_pos < finish_target:
            return MoveResult(
                legal=True,
                new_zone=TokenZone.FINISH_LANE,
                new_position=new_pos,
            )
        if new_pos == finish_target:
            return MoveResult(
                legal=True,
                new_zone=TokenZone.FINISHED,
                new_position=0,
            )
        # Overshoot
        overshoot = new_pos - finish_target
        if self.finish_mode == FinishMode.EXACT:
            return MoveResult(legal=False, reason="overshoot-wastes")
        if self.finish_mode == FinishMode.ALLOW:
            return MoveResult(
                legal=True,
                new_zone=TokenZone.FINISHED,
                new_position=0,
            )
        # BOUNCE: reflect off the finish. New lane position = finish_target - overshoot.
        bounced = finish_target - overshoot
        if bounced < 1:
            # Bounced past the start of the lane. Treat as overshoot-wastes.
            return MoveResult(legal=False, reason="overshoot-wastes")
        return MoveResult(
            legal=True,
            new_zone=TokenZone.FINISH_LANE,
            new_position=bounced,
        )

    def _detect_bump_at_track(
        self,
        position: int,
        acting_seat: int,
        opponent_tokens: list[tuple[int, Token]],
    ) -> tuple[int, int] | None:
        """Return (owner_seat, token_number) of any opponent bumped at position."""
        if position in self.safe_positions:
            return None
        for owner_seat, tok in opponent_tokens:
            if owner_seat == acting_seat:
                continue
            if tok.zone == TokenZone.TRACK and tok.position == position:
                return (owner_seat, tok.token_number)
        return None


# ------------------------------------------------------------------
# Safe-space policies (precomputed position sets)
# ------------------------------------------------------------------


def home_stretch_safe_positions(
    seat_geometries: "list[SeatGeometry]",
) -> frozenset[int]:
    """Safe-space policy: the last track space before each seat's finish lane.

    Intuition: gives a player a 'last chance' safe space right before they
    turn into their private finish lane.
    """
    return frozenset(geom.finish_entry_position for geom in seat_geometries)


def every_nth_safe_positions(
    track_length: int, n: int = 7
) -> frozenset[int]:
    """Safe-space policy: every Nth track position starting from 0."""
    if n <= 0:
        return frozenset()
    return frozenset(range(0, track_length, n))


__all__ = [
    "TokenZone",
    "Token",
    "SeatGeometry",
    "normalize_track_position",
    "clockwise_distance",
    "FinishMode",
    "MoveResult",
    "MovementEngine",
    "home_stretch_safe_positions",
    "every_nth_safe_positions",
]
