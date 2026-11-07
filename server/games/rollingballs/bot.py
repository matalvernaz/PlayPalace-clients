"""Strategic bot decisions for Rolling Balls."""

from functools import lru_cache
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .game import RollingBallsGame, RollingBallsPlayer


def _legal_takes(game: "RollingBallsGame", remaining: int) -> list[int]:
    if remaining <= 0:
        return []
    if remaining < game.options.min_take:
        return [remaining]
    upper = min(game.options.max_take, remaining)
    return list(range(game.options.min_take, upper + 1))


def _score_vector(
    game: "RollingBallsGame",
    players: list["RollingBallsPlayer"],
) -> tuple[int, ...]:
    scores = []
    for player in players:
        team = game._team_manager.get_team(player.name)
        scores.append(team.total_score if team else 0)
    return tuple(scores)


def _projected_utility(
    game: "RollingBallsGame",
    player: "RollingBallsPlayer",
    values: tuple[int, ...],
    take: int,
) -> tuple[float, int, int]:
    """Project rational play through the known preview using max-n search."""
    turn_players = [
        candidate
        for candidate in game.turn_players
        if hasattr(candidate, "bot_pipe_memory")
    ]
    if player not in turn_players:
        return (float(sum(values[:take])), sum(values[:take]), -take)

    root_index = turn_players.index(player)
    starting_scores = _score_vector(game, turn_players)
    immediate = sum(values[:take])
    updated_scores = list(starting_scores)
    updated_scores[root_index] += immediate

    @lru_cache(maxsize=None)
    def search(
        offset: int,
        turn_index: int,
        scores: tuple[int, ...],
    ) -> tuple[int, ...]:
        remaining = len(values) - offset
        legal = _legal_takes(game, remaining)
        if not legal:
            return scores

        best_scores: tuple[int, ...] | None = None
        best_key: tuple[int, int, int] | None = None
        for count in legal:
            next_scores = list(scores)
            next_scores[turn_index] += sum(values[offset : offset + count])
            projected = search(
                offset + count,
                (turn_index + 1) % len(turn_players),
                tuple(next_scores),
            )
            opponents = [
                score
                for index, score in enumerate(projected)
                if index != turn_index
            ]
            key = (
                projected[turn_index] - max(opponents, default=0),
                projected[turn_index],
                -count,
            )
            if best_key is None or key > best_key:
                best_key = key
                best_scores = projected
        return best_scores if best_scores is not None else scores

    projected = search(
        take,
        (root_index + 1) % len(turn_players),
        tuple(updated_scores),
    )
    opponents = [
        score for index, score in enumerate(projected) if index != root_index
    ]
    advantage = projected[root_index] - max(opponents, default=0)
    return (float(advantage), immediate, -take)


def _should_reshuffle(
    game: "RollingBallsGame",
    player: "RollingBallsPlayer",
    perceived_pipe: list[dict],
    legal_takes: list[int],
    best_take: int,
) -> bool:
    if (
        player.has_reshuffled
        or player.reshuffle_uses >= game.options.reshuffle_limit
        or len(game.pipe) < 6
        or player.bot_pipe_memory <= 0
    ):
        return False

    outcomes = {
        count: sum(int(ball["value"]) for ball in perceived_pipe[:count])
        for count in legal_takes
    }
    best_immediate = outcomes[best_take]
    all_known_choices_negative = all(value < 0 for value in outcomes.values())
    penalty = game.options.reshuffle_penalty

    # Pay to escape a clearly bad known prefix, but never reshuffle a profitable
    # choice merely because another future branch might be better.
    if all_known_choices_negative and best_immediate <= -(penalty + 1):
        return True

    # Near the end, a reshuffle is also worthwhile when the best known draw
    # would leave the bot behind and the penalty is smaller than that loss.
    if len(game.pipe) <= player.bot_pipe_memory:
        team = game._team_manager.get_team(player.name)
        current_score = team.total_score if team else 0
        leader_score = max(
            (
                candidate.total_score
                for candidate in game._team_manager.teams
            ),
            default=current_score,
        )
        if (
            current_score + best_immediate < leader_score
            and best_immediate < -penalty
        ):
            return True
    return False


def bot_think(
    game: "RollingBallsGame", player: "RollingBallsPlayer"
) -> str | None:
    """Choose a take using known-prefix lookahead and score awareness."""
    perceived_pipe = game._get_bot_perceived_pipe(player)
    legal_takes = _legal_takes(game, len(game.pipe))
    if not legal_takes:
        return None

    known_length = max(
        min(len(perceived_pipe), player.bot_pipe_memory),
        min(len(perceived_pipe), game.options.max_take),
    )
    values = tuple(
        int(ball["value"]) for ball in perceived_pipe[:known_length]
    )
    best_take = max(
        legal_takes,
        key=lambda count: _projected_utility(
            game, player, values, count
        ),
    )

    if _should_reshuffle(
        game, player, perceived_pipe, legal_takes, best_take
    ):
        return "reshuffle"
    return f"take_{best_take}"
