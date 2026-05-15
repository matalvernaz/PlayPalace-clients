"""Serializable state models for Number Chain.

Number Chain is a two-player abstract game on a 4x8 grid.  Each player has
two copies of every number from 1 to 8 (16 tiles per player, 32 total —
exactly enough to fill the board).  Players take turns placing one tile,
and the placed numbers form a single shared chain: 1 -> 2 -> ... -> 8 -> 1
-> 2 -> ...  Each tile must be placed orthogonally adjacent to the most
recently placed tile and must equal the next number in the chain.  A
player loses when it is their turn and they cannot make any legal move
(either no copies of the required number remain in their inventory, or no
empty cell is adjacent to the previous tile).
"""

from dataclasses import dataclass, field


ROWS = 4
COLS = 8
NUM_CELLS = ROWS * COLS  # 32
MIN_NUMBER = 1
MAX_NUMBER = 8
COPIES_PER_NUMBER = 2  # each player has two of each


def _initial_inventory() -> list[list[int]]:
    """Inventory[player_num][number] = remaining count.

    Index 0 is unused in each axis to keep player and number 1-based.
    """
    return [
        [0] * (MAX_NUMBER + 1),  # player 0 — unused, kept for 1-based indexing
        [0] + [COPIES_PER_NUMBER] * MAX_NUMBER,  # player 1
        [0] + [COPIES_PER_NUMBER] * MAX_NUMBER,  # player 2
    ]


@dataclass
class NumberChainState:
    """Serializable game state for Number Chain.

    ``numbers[i]`` holds the number on cell ``i`` (0 for empty, 1..8 otherwise).
    ``owners[i]`` holds the player who placed that tile (0 for empty, 1 or 2).
    The two lists are kept parallel rather than packed so they serialize as
    plain lists of ints with no codec gymnastics.
    """

    numbers: list[int] = field(default_factory=lambda: [0] * NUM_CELLS)
    owners: list[int] = field(default_factory=lambda: [0] * NUM_CELLS)
    inventory: list[list[int]] = field(default_factory=_initial_inventory)
    current_player_num: int = 1
    last_index: int = -1  # -1 means no tile has been placed yet
    last_number: int = 0  # 0 means no tile has been placed yet


def opponent_num(player_num: int) -> int:
    return 3 - player_num


def required_next_number(state: NumberChainState) -> int:
    """The number that must be placed next given the current chain head."""
    if state.last_number == 0:
        return MIN_NUMBER
    return (state.last_number % MAX_NUMBER) + 1


def index_to_rc(index: int) -> tuple[int, int]:
    return divmod(index, COLS)


def rc_to_index(row: int, col: int) -> int:
    return row * COLS + col


def neighbors(index: int) -> list[int]:
    """Orthogonal neighbors of a cell index. No diagonals."""
    r, c = index_to_rc(index)
    out: list[int] = []
    if r > 0:
        out.append(rc_to_index(r - 1, c))
    if r < ROWS - 1:
        out.append(rc_to_index(r + 1, c))
    if c > 0:
        out.append(rc_to_index(r, c - 1))
    if c < COLS - 1:
        out.append(rc_to_index(r, c + 1))
    return out


def build_initial_state() -> NumberChainState:
    return NumberChainState()
