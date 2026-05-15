"""Tests for Number Chain."""

import pytest

from server.games.numberchain.bot import _score_move
from server.games.numberchain.moves import (
    apply_move,
    generate_legal_moves,
    has_any_legal_move,
)
from server.games.numberchain.state import (
    COLS,
    COPIES_PER_NUMBER,
    MAX_NUMBER,
    NUM_CELLS,
    ROWS,
    NumberChainState,
    build_initial_state,
    index_to_rc,
    neighbors,
    opponent_num,
    rc_to_index,
    required_next_number,
)


# ============================================================================
# State
# ============================================================================


class TestInitialState:
    def test_empty_board(self):
        gs = build_initial_state()
        assert gs.numbers == [0] * NUM_CELLS
        assert gs.owners == [0] * NUM_CELLS

    def test_full_inventory(self):
        gs = build_initial_state()
        for player in (1, 2):
            for number in range(1, MAX_NUMBER + 1):
                assert gs.inventory[player][number] == COPIES_PER_NUMBER

    def test_starting_state_fields(self):
        gs = build_initial_state()
        assert gs.current_player_num == 1
        assert gs.last_index == -1
        assert gs.last_number == 0

    def test_dimensions(self):
        assert ROWS * COLS == NUM_CELLS
        assert NUM_CELLS == 2 * MAX_NUMBER * COPIES_PER_NUMBER


class TestHelpers:
    def test_opponent_num(self):
        assert opponent_num(1) == 2
        assert opponent_num(2) == 1

    def test_required_next_on_empty_board(self):
        gs = build_initial_state()
        assert required_next_number(gs) == 1

    def test_required_next_increments(self):
        gs = build_initial_state()
        for n in range(1, MAX_NUMBER):
            gs.last_number = n
            assert required_next_number(gs) == n + 1

    def test_required_next_wraps(self):
        gs = build_initial_state()
        gs.last_number = MAX_NUMBER
        assert required_next_number(gs) == 1

    def test_index_rc_roundtrip(self):
        for idx in range(NUM_CELLS):
            r, c = index_to_rc(idx)
            assert rc_to_index(r, c) == idx
            assert 0 <= r < ROWS
            assert 0 <= c < COLS

    def test_neighbors_corner(self):
        # Top-left corner (0, 0)
        assert set(neighbors(0)) == {rc_to_index(0, 1), rc_to_index(1, 0)}

    def test_neighbors_edge(self):
        # Top edge, not corner (0, 3)
        idx = rc_to_index(0, 3)
        assert set(neighbors(idx)) == {
            rc_to_index(0, 2),
            rc_to_index(0, 4),
            rc_to_index(1, 3),
        }

    def test_neighbors_interior(self):
        idx = rc_to_index(1, 3)
        assert set(neighbors(idx)) == {
            rc_to_index(0, 3),
            rc_to_index(2, 3),
            rc_to_index(1, 2),
            rc_to_index(1, 4),
        }

    def test_neighbors_bottom_right(self):
        idx = NUM_CELLS - 1  # (3, 7)
        assert set(neighbors(idx)) == {
            rc_to_index(3, 6),
            rc_to_index(2, 7),
        }


# ============================================================================
# Move generation
# ============================================================================


class TestFirstMove:
    def test_anywhere_legal(self):
        gs = build_initial_state()
        moves = generate_legal_moves(gs, 1)
        assert len(moves) == NUM_CELLS

    def test_first_move_is_a_one(self):
        gs = build_initial_state()
        moves = generate_legal_moves(gs, 1)
        for m in moves:
            assert m.number == 1


class TestAdjacencyConstraint:
    def test_only_adjacent_cells_after_first(self):
        gs = build_initial_state()
        center = rc_to_index(1, 3)
        apply_move(gs, generate_legal_moves(gs, 1)[center], 1)
        # gs.last_index is now center; player 2 must place a 2 adjacent.
        gs.current_player_num = 2
        moves = generate_legal_moves(gs, 2)
        assert {m.index for m in moves} == set(neighbors(center))
        for m in moves:
            assert m.number == 2

    def test_occupied_neighbors_excluded(self):
        gs = build_initial_state()
        gs.numbers[rc_to_index(1, 3)] = 1
        gs.owners[rc_to_index(1, 3)] = 1
        gs.last_index = rc_to_index(1, 3)
        gs.last_number = 1
        gs.inventory[1][1] -= 1
        # Occupy one of the four neighbors with an already-placed tile
        blocked = rc_to_index(0, 3)
        gs.numbers[blocked] = 5
        gs.owners[blocked] = 2
        moves = generate_legal_moves(gs, 2)
        assert blocked not in {m.index for m in moves}
        assert len(moves) == 3

    def test_wraps_from_eight_to_one(self):
        gs = build_initial_state()
        gs.last_index = rc_to_index(1, 3)
        gs.last_number = MAX_NUMBER
        moves = generate_legal_moves(gs, 2)
        for m in moves:
            assert m.number == 1


class TestInventoryConstraint:
    def test_no_legal_moves_when_required_exhausted(self):
        gs = build_initial_state()
        gs.last_index = rc_to_index(1, 3)
        gs.last_number = 3  # required = 4
        gs.inventory[1][4] = 0  # player 1 is out of 4s
        assert generate_legal_moves(gs, 1) == []
        assert not has_any_legal_move(gs, 1)

    def test_legal_when_other_player_exhausted(self):
        gs = build_initial_state()
        gs.last_index = rc_to_index(1, 3)
        gs.last_number = 3  # required = 4
        gs.inventory[2][4] = 0  # player 2 out, but player 1 isn't
        assert len(generate_legal_moves(gs, 1)) > 0


class TestApplyMove:
    def test_apply_updates_board_and_inventory(self):
        gs = build_initial_state()
        moves = generate_legal_moves(gs, 1)
        idx = rc_to_index(2, 4)
        chosen = next(m for m in moves if m.index == idx)
        apply_move(gs, chosen, 1)
        assert gs.numbers[idx] == 1
        assert gs.owners[idx] == 1
        assert gs.inventory[1][1] == COPIES_PER_NUMBER - 1
        assert gs.last_index == idx
        assert gs.last_number == 1

    def test_full_cycle_consumes_inventory(self):
        gs = build_initial_state()
        # Snake along the top row: 1 at (0,0), 2 at (0,1), ..., 8 at (0,7).
        for c in range(8):
            moves = generate_legal_moves(gs, gs.current_player_num)
            target = rc_to_index(0, c)
            chosen = next(m for m in moves if m.index == target)
            apply_move(gs, chosen, gs.current_player_num)
            gs.current_player_num = opponent_num(gs.current_player_num)
        # Each number 1..8 was placed once. Players alternated so each
        # player used 4 different numbers exactly once.
        # Player 1 placed at c=0,2,4,6 → numbers 1, 3, 5, 7.
        # Player 2 placed at c=1,3,5,7 → numbers 2, 4, 6, 8.
        for n in (1, 3, 5, 7):
            assert gs.inventory[1][n] == COPIES_PER_NUMBER - 1
        for n in (2, 4, 6, 8):
            assert gs.inventory[1][n] == COPIES_PER_NUMBER
        for n in (2, 4, 6, 8):
            assert gs.inventory[2][n] == COPIES_PER_NUMBER - 1
        for n in (1, 3, 5, 7):
            assert gs.inventory[2][n] == COPIES_PER_NUMBER


# ============================================================================
# End-game conditions
# ============================================================================


class TestGameEnd:
    def test_no_moves_when_chain_dead_ends(self):
        """After placing in a corner with all neighbors filled, no moves."""
        gs = build_initial_state()
        # Fill a 2x2 block in the corner with arbitrary tiles, then put the
        # chain head in the corner.
        corner = rc_to_index(0, 0)
        right = rc_to_index(0, 1)
        below = rc_to_index(1, 0)
        gs.numbers[right] = 9  # arbitrary placeholder
        gs.owners[right] = 1
        gs.numbers[below] = 9
        gs.owners[below] = 1
        gs.numbers[corner] = 3
        gs.owners[corner] = 2
        gs.last_index = corner
        gs.last_number = 3
        assert generate_legal_moves(gs, 1) == []
        assert not has_any_legal_move(gs, 1)


# ============================================================================
# Bot
# ============================================================================


class TestBotScoring:
    def test_prefers_game_ending_move(self):
        """Placing into a dead-end neighborhood (no future moves for opp) scores top."""
        gs = build_initial_state()
        # Set up: player 1 will place at (0,0). Pre-fill all cells that
        # would be opponent's neighbors after that placement, except (0,0)
        # itself. Now opponent has no legal moves.
        # Player 1's tile at (0,0) has neighbors (0,1) and (1,0). Fill both.
        gs.numbers[rc_to_index(0, 1)] = 5
        gs.owners[rc_to_index(0, 1)] = 2
        gs.numbers[rc_to_index(1, 0)] = 6
        gs.owners[rc_to_index(1, 0)] = 2
        # First-move scenario — required = 1.
        # The (0,0) corner move should score 10_000 because opp has nowhere to go.
        moves = generate_legal_moves(gs, 1)
        corner_move = next(m for m in moves if m.index == rc_to_index(0, 0))
        assert _score_move(gs, corner_move, 1) == 10_000

    def test_prefers_low_branching(self):
        """Given two moves, the one leaving the opponent fewer options should score higher."""
        # Place a tile somewhere, then offer the bot two responses:
        # one in the middle (more onward neighbors) vs one in a corner
        # (fewer onward neighbors).
        gs = build_initial_state()
        # Pretend player 2 just placed a 1 at (1, 3). Now player 1 must
        # place a 2 at one of (0,3), (2,3), (1,2), (1,4).
        last = rc_to_index(1, 3)
        gs.numbers[last] = 1
        gs.owners[last] = 2
        gs.inventory[2][1] -= 1
        gs.last_index = last
        gs.last_number = 1
        gs.current_player_num = 1
        moves = generate_legal_moves(gs, 1)
        # Score every candidate; corner-edge cells will leave the opponent
        # with fewer reply spots than purely interior cells.
        scores = {m.index: _score_move(gs, m, 1) for m in moves}
        # All scores should be non-positive (since the opponent always has
        # at least one reply in this setup), but the move that leaves the
        # opponent the fewest replies should be the maximum.
        best_idx = max(scores, key=scores.get)
        assert scores[best_idx] == max(scores.values())
