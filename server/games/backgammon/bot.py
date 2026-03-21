"""Bot AI for Backgammon — GNUBG engine with random/simple fallback."""

from __future__ import annotations

import random
from typing import TYPE_CHECKING

from .gnubg import GnubgProcess, is_gnubg_available
from .moves import BackgammonMove, generate_legal_moves, has_any_legal_move
from .state import (
    bar_count,
    color_sign,
    off_count,
    opponent_color,
    point_count,
    point_owner,
    remaining_dice_unique,
)

if TYPE_CHECKING:
    from .game import BackgammonGame, BackgammonPlayer


def bot_think(game: BackgammonGame, player: BackgammonPlayer) -> str | None:
    """Decide the bot's next action."""
    gs = game.game_state
    color = player.color

    if gs.turn_phase == "pre_roll":
        game._bot_action_queue.clear()
        # GNUBG bots consider doubling before rolling
        cube_action = _maybe_offer_double(game, player)
        if cube_action:
            return cube_action
        return "point_0"

    if gs.turn_phase == "doubling":
        return _decide_take_or_drop(game, player)

    if gs.turn_phase == "moving":
        if not has_any_legal_move(gs, color):
            game._end_moving_phase()
            return None
        # Pop from queued GNUBG actions if available
        if game._bot_action_queue:
            return game._bot_action_queue.pop(0)
        return _pick_move(game, player)

    return None


def _maybe_offer_double(game: BackgammonGame, player: BackgammonPlayer) -> str | None:
    """Check if a GNUBG-backed bot should offer a double before rolling."""
    from .game import DIFFICULTY_PLY

    difficulty = game.options.bot_difficulty
    if difficulty in ("random", "simple"):
        return None

    ply = DIFFICULTY_PLY.get(difficulty)
    if ply is None:
        return None

    # Whackgammon never doubles (it's trying to lose)
    if difficulty == "whackgammon":
        return None

    # Can this player even double?
    if not game._can_double(player):
        return None

    gnubg_proc = _get_gnubg_process(game, ply)
    if gnubg_proc is None:
        return None

    decision = gnubg_proc.get_cube_decision(game.game_state, player.color)
    if decision == "double":
        return "offer_double"
    return None


def _decide_take_or_drop(game: BackgammonGame, player: BackgammonPlayer) -> str:
    """Decide whether to take or drop a double offer."""
    from .game import DIFFICULTY_PLY

    difficulty = game.options.bot_difficulty
    if difficulty in ("random", "simple"):
        return "accept_double"

    ply = DIFFICULTY_PLY.get(difficulty)
    if ply is None:
        return "accept_double"

    # Whackgammon always takes (it's trying to lose, taking a bad double helps)
    if difficulty == "whackgammon":
        return "accept_double"

    gnubg_proc = _get_gnubg_process(game, ply)
    if gnubg_proc is None:
        return "accept_double"

    # Query from the perspective of the opponent (who offered the double)
    # to get "double, pass" vs "double, take" — but it's easier to just
    # check the equity of taking vs dropping from our perspective.
    # GNUBG's cube decision from the receiver's perspective:
    decision = gnubg_proc.get_cube_decision(game.game_state, player.color)
    if decision == "drop":
        return "drop_double"
    return "accept_double"


def _pick_move(game: BackgammonGame, player: BackgammonPlayer) -> str | None:
    """Pick a move based on the configured difficulty."""
    from .game import DIFFICULTY_PLY

    gs = game.game_state
    color = player.color
    difficulty = game.options.bot_difficulty

    if difficulty == "random":
        return _pick_random_move(game, color)

    if difficulty == "simple":
        return _pick_simple_move(game, color)

    # GNUBG-based difficulties
    ply = DIFFICULTY_PLY.get(difficulty)
    if ply is None:
        return _pick_random_move(game, color)

    is_whack = difficulty == "whackgammon"
    gnubg_proc = _get_gnubg_process(game, ply)
    if gnubg_proc is not None:
        if is_whack:
            actions = gnubg_proc.get_worst_move(gs, color)
        else:
            actions = gnubg_proc.get_best_move(gs, color)
        if actions:
            # Queue all sub-moves; return the first, queue the rest
            action_strs = [f"point_{src}_{dst}" for src, dst in actions]
            game._bot_action_queue = action_strs[1:]
            return action_strs[0]

    # Fallback to simple if GNUBG unavailable
    _notify_fallback(game)
    return _pick_simple_move(game, color)


def _pick_random_move(game: BackgammonGame, color: str) -> str | None:
    """Pick a random legal move, trying all unused die values."""
    gs = game.game_state
    for die_val in remaining_dice_unique(gs):
        moves = generate_legal_moves(gs, color, die_val)
        if moves:
            move = random.choice(moves)  # nosec B311
            return f"point_{move.source}_{move.destination}"
    return None


def _pick_simple_move(game: BackgammonGame, color: str) -> str | None:
    """Pick a move using simple heuristics.

    Priority scoring:
    - Bearing off is great
    - Hitting an opponent blot is good
    - Making a new point (landing where we have exactly 1) is good
    - Escaping from opponent's home board is decent
    - Leaving a blot in a dangerous area is bad
    """
    gs = game.game_state
    best_move: BackgammonMove | None = None
    best_score = -9999

    for die_val in remaining_dice_unique(gs):
        for move in generate_legal_moves(gs, color, die_val):
            score = _score_move(gs, move, color)
            if score > best_score:
                best_score = score
                best_move = move

    if best_move is None:
        return None
    return f"point_{best_move.source}_{best_move.destination}"


def _score_move(gs, move: BackgammonMove, color: str) -> int:
    """Score a move with simple heuristics. Higher is better."""
    score = 0
    sign = color_sign(color)
    opp = opponent_color(color)

    # Bear off: strongly prefer
    if move.is_bear_off:
        score += 100

    # Hit: good, especially in our home board
    if move.is_hit:
        score += 40
        # Hitting in our home board is even better (harder to re-enter)
        if color == "red" and move.destination <= 5:
            score += 20
        elif color == "white" and move.destination >= 18:
            score += 20

    # Making a point (landing where we have exactly 1 checker already)
    if not move.is_bear_off and move.destination >= 0 and move.destination <= 23:
        current = gs.board.points[move.destination]
        if current * sign == 1:
            # We have 1 there — this makes a 2-stack (a point!)
            score += 35
            # Making points in our home board is premium
            if color == "red" and move.destination <= 5:
                score += 15
            elif color == "white" and move.destination >= 18:
                score += 15

    # Leaving a blot (source had 2, now will have 1)
    if move.source >= 0:
        src_count = abs(gs.board.points[move.source])
        if src_count == 2:
            # We're exposing a blot
            score -= 15
            # Worse if in opponent's home board
            if color == "red" and move.source >= 18:
                score -= 15
            elif color == "white" and move.source <= 5:
                score -= 15

    # Landing alone (creating a blot) on an empty point
    if not move.is_bear_off and move.destination >= 0 and move.destination <= 23:
        dest_val = gs.board.points[move.destination]
        if dest_val * sign == 0 and not move.is_hit:
            # Landing alone on empty point = blot
            score -= 10
            # Worse in dangerous territory
            if color == "red" and move.destination >= 18:
                score -= 10
            elif color == "white" and move.destination <= 5:
                score -= 10

    # Prefer advancing runners from opponent's home board
    if move.source >= 0:
        if color == "red" and move.source >= 18:
            score += 8
        elif color == "white" and move.source <= 5:
            score += 8

    # Bar entry: just do it (no penalty, no bonus beyond the hit check)
    if move.source == -1:
        score += 5

    # Small tiebreaker: prefer moving from higher points (advance)
    if move.source >= 0:
        if color == "red":
            score += move.source // 6
        else:
            score += (23 - move.source) // 6

    return score


def _notify_fallback(game: BackgammonGame) -> None:
    """Notify players once that GNUBG is unavailable and bot is using fallback."""
    if getattr(game, "_gnubg_fallback_notified", False):
        return
    game._gnubg_fallback_notified = True
    game.broadcast_l("backgammon-gnubg-fallback")


def _get_gnubg_process(game: BackgammonGame, ply: int) -> GnubgProcess | None:
    """Get or create the GNUBG process for this game."""
    proc = getattr(game, "_gnubg_proc", None)
    if proc is not None:
        return proc

    if not is_gnubg_available():
        return None

    proc = GnubgProcess(ply=ply)
    if proc.start():
        game._gnubg_proc = proc
        return proc

    return None


def cleanup_gnubg(game: BackgammonGame) -> None:
    """Stop GNUBG processes when the game ends."""
    for attr in ("_gnubg_proc", "_hint_proc"):
        proc = getattr(game, attr, None)
        if proc is not None:
            proc.stop()
            setattr(game, attr, None)
