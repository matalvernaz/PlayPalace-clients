"""Bot AI for Trouble.

Two difficulty levels selected by game.options.bot_difficulty:

- naive: pick any legal action at random (roll if needed, then any legal token).
- greedy: score each legal token move by impact (bump > finish > advance >
  release > tiny preference for tokens deeper into the track) and pick the
  best. Greedy does not look ahead across turns.

Both bots are stateless. They're called once per tick when the current
player is a bot; the first call returns 'roll' (unless already rolled),
the next call returns the chosen 'move_token_N'.
"""

from __future__ import annotations

import random
from typing import TYPE_CHECKING

from ...game_utils.parcheesi import Token, TokenZone

if TYPE_CHECKING:
    from .game import TroubleGame, TroublePlayer


def bot_think(game: "TroubleGame", player: "TroublePlayer") -> str | None:
    """Decide what the bot should do next. Returns an action_id or None."""
    # If the bot hasn't rolled yet this turn, roll.
    if player.last_roll == 0:
        return "roll"

    # If there are no legal moves, we shouldn't be here — the action
    # handler auto-ends the turn. But guard just in case.
    if not player.legal_move_tokens:
        return None

    # If only one legal move, the game auto-applied it already; nothing to do.
    if len(player.legal_move_tokens) == 1:
        return f"move_token_{player.legal_move_tokens[0]}"

    difficulty = game.options.bot_difficulty
    if difficulty == "greedy":
        return _greedy_choose(game, player)
    return _naive_choose(player)


# ==========================================================================
# Naive
# ==========================================================================


def _naive_choose(player: "TroublePlayer") -> str:
    token_number = random.choice(player.legal_move_tokens)  # nosec B311
    return f"move_token_{token_number}"


# ==========================================================================
# Greedy
# ==========================================================================


_SCORE_BUMP = 100.0
_SCORE_FINISH_TOKEN = 80.0
_SCORE_ENTER_FINISH_LANE = 30.0
_SCORE_RELEASE_FROM_HOME = 20.0
_SCORE_PER_TRACK_STEP = 1.0


def _greedy_choose(
    game: "TroubleGame", player: "TroublePlayer"
) -> str:
    engine = game._build_engine()
    opponent_tokens = game._opponent_tokens_for_seat(player.seat_index)

    best_token: int | None = None
    best_score = -float("inf")

    for token_number in player.legal_move_tokens:
        token = game._token(player, token_number)
        if token is None:
            continue
        result = engine.simulate_move(
            seat_index=player.seat_index,
            token=token,
            roll=player.last_roll,
            opponent_tokens=opponent_tokens,
            six_to_leave_home=game.options.six_to_leave_home,
        )
        if not result.legal:
            continue
        score = _score_move(token, result)
        # Tie-break with a tiny nudge per token_number so behavior is
        # deterministic in tests (lowest token_number wins ties).
        score -= 0.0001 * token_number
        if score > best_score:
            best_score = score
            best_token = token_number

    if best_token is None:
        # Shouldn't happen — legal_move_tokens was non-empty. Fall back.
        best_token = player.legal_move_tokens[0]
    return f"move_token_{best_token}"


def _score_move(token: Token, result) -> float:
    """Score a simulated move for the greedy bot."""
    score = 0.0
    if result.bumped_token_number is not None:
        score += _SCORE_BUMP
    if result.new_zone == TokenZone.FINISHED:
        score += _SCORE_FINISH_TOKEN
    elif result.new_zone == TokenZone.FINISH_LANE:
        # Entering the lane from track = big reward; advancing within lane = smaller.
        if token.zone == TokenZone.TRACK:
            score += _SCORE_ENTER_FINISH_LANE
        else:
            score += _SCORE_PER_TRACK_STEP * result.new_position
    elif result.new_zone == TokenZone.TRACK:
        if token.zone == TokenZone.HOME:
            score += _SCORE_RELEASE_FROM_HOME
        else:
            # Slight preference for advancing tokens further along the track.
            score += _SCORE_PER_TRACK_STEP * 1
    return score


__all__ = ["bot_think"]
