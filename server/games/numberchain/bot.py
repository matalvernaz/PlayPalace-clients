"""Bot AI for Number Chain."""

from __future__ import annotations

import copy
import random
from typing import TYPE_CHECKING

from .moves import NumberChainMove, apply_move, generate_legal_moves
from .state import opponent_num

if TYPE_CHECKING:
    from .game import NumberChainGame, NumberChainPlayer


def bot_think(game: NumberChainGame, player: NumberChainPlayer) -> str | None:
    gs = game.game_state
    if gs.current_player_num != player.player_num:
        return None

    moves = generate_legal_moves(gs, player.player_num)
    if not moves:
        return None

    difficulty = game.options.bot_difficulty
    if difficulty == "random":
        move = random.choice(moves)  # nosec B311
    else:
        move = max(moves, key=lambda m: _score_move(gs, m, player.player_num))

    return f"sq_{move.index}"


def _score_move(gs, move: NumberChainMove, player_num: int) -> int:
    """One-ply lookahead: prefer moves that minimize the opponent's reply count.

    The board is tiny (max four legal moves per turn), so a deepcopy +
    re-evaluation is cheap enough to do on every candidate without
    bothering with incremental undo.
    """
    sim = copy.deepcopy(gs)
    apply_move(sim, move, player_num)
    opp = opponent_num(player_num)
    opp_moves = generate_legal_moves(sim, opp)
    if not opp_moves:
        # Game-ending move — strongly prefer.
        return 10_000
    # Fewer opponent responses is better for us.
    return -len(opp_moves)
