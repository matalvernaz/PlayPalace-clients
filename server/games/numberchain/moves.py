"""Move generation and application for Number Chain."""

from __future__ import annotations

from dataclasses import dataclass

from .state import (
    NUM_CELLS,
    NumberChainState,
    neighbors,
    required_next_number,
)


@dataclass(frozen=True)
class NumberChainMove:
    """A single tile placement.

    ``index`` is the destination cell (0..31).  ``number`` is the number on
    the placed tile and is always equal to ``required_next_number(state)``
    at the time the move is generated; carrying it on the move object keeps
    history entries self-describing.
    """

    index: int
    number: int


def generate_legal_moves(
    state: NumberChainState, player_num: int
) -> list[NumberChainMove]:
    """Enumerate every legal placement the given player could make right now.

    Unlike some game frameworks this does not check whose turn it is —
    callers that care about turn order check ``state.current_player_num``
    separately.  This keeps the function usable for hypothetical
    analysis (e.g. bot lookahead) without temporary state mutation.
    """
    required = required_next_number(state)
    if state.inventory[player_num][required] <= 0:
        return []

    if state.last_index == -1:
        candidates = range(NUM_CELLS)
    else:
        candidates = neighbors(state.last_index)

    return [
        NumberChainMove(index=i, number=required)
        for i in candidates
        if state.numbers[i] == 0
    ]


def apply_move(
    state: NumberChainState, move: NumberChainMove, player_num: int
) -> None:
    """Apply a move in place. The caller is responsible for turn switching."""
    state.numbers[move.index] = move.number
    state.owners[move.index] = player_num
    state.inventory[player_num][move.number] -= 1
    state.last_index = move.index
    state.last_number = move.number


def has_any_legal_move(state: NumberChainState, player_num: int) -> bool:
    return len(generate_legal_moves(state, player_num)) > 0
