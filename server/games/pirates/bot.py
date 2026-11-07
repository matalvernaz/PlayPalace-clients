"""
Bot AI Logic for Pirates of the Lost Seas.

Bots follow the exact same rules as human players: they return action IDs and
let the normal action/input/skill machinery validate and execute every choice.
The AI below scores the tactical value of movement, combat, escape, and skill
timing instead of drifting randomly around the map.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from .game import PiratesGame
    from .player import PiratesPlayer
    from .skills import Skill

from . import combat, gems, skills
from .skills import (
    BATTLESHIP,
    DOUBLE_DEVASTATION,
    GEM_SEEKER,
    PORTAL,
    PUSH,
    SKILLED_CAPTAIN,
    SWORD_FIGHTER,
)

MAP_MIN = 1
FALLBACK_MAP_MAX = 40
OCEAN_SIZE = 10
MIN_ATTACK_SCORE = 18.0


@dataclass
class BotDecision:
    """Represents a bot's decision for this turn."""

    action_id: str
    target: "PiratesPlayer | None" = None
    skill_name: str | None = None
    direction: str | None = None
    portal_random: bool = False


@dataclass(frozen=True)
class MoveOption:
    """A legal movement action and the position it would reach."""

    action_id: str
    direction: str
    steps: int
    position: int


@dataclass(frozen=True)
class TargetAssessment:
    """Tactical value for attacking one target."""

    target: "PiratesPlayer"
    score: float
    hit_probability: float
    steal_probability: float
    gem_swing: float
    distance: int


def bot_think(game: "PiratesGame", player: "PiratesPlayer") -> str | None:
    """
    Determine what action a bot should take.

    The returned action is executed by the same action system used for humans.
    Follow-up selectors (target, skill, boarding, Portal destination) reuse the
    stored decision context when the framework asks for input.
    """
    decision = _analyze_and_decide(game, player)
    if decision:
        game._bot_decision = decision
        if decision.skill_name == GEM_SEEKER.skill_id:
            _mark_skill_used_this_turn(game, player, GEM_SEEKER.skill_id)
        return decision.action_id
    return None


def _analyze_and_decide(
    game: "PiratesGame", player: "PiratesPlayer"
) -> BotDecision | None:
    """
    Score the current position and choose the strongest legal action.

    High-level priorities emerge from the scores:
    - resolve pending multi-step actions before anything else
    - collect valuable nearby gems when they beat combat pressure
    - attack gem carriers and leaders when the expected steal/XP value is high
    - activate combat skills before a valuable attack
    - use Portal as a real escape/repositioning tool, including Random
    """
    if getattr(game, "status", "") != "playing":
        return None
    if getattr(game, "current_player", None) is not player:
        return None

    if _has_pending_boarding(game, player):
        return BotDecision(action_id="resolve_boarding")
    if _has_pending_portal(game, player):
        return BotDecision(action_id="resolve_portal")

    movement = _best_movement_decision(game, player)
    movement_score = movement[0] if movement else -999.0
    attack = _best_attack_assessment(game, player)
    attack_score = attack.score if attack else -999.0

    skill_decision = _best_skill_decision(
        game, player, attack, movement_score, attack_score
    )
    if skill_decision:
        return skill_decision

    if attack and attack.score >= max(MIN_ATTACK_SCORE, movement_score + 4.0):
        return BotDecision(action_id="cannonball", target=attack.target)

    if movement:
        return movement[1]

    return None


def _best_skill_decision(
    game: "PiratesGame",
    player: "PiratesPlayer",
    attack: TargetAssessment | None,
    movement_score: float,
    attack_score: float,
) -> BotDecision | None:
    """Return a high-value skill action, if one beats direct play."""
    candidates: list[tuple[float, BotDecision]] = []

    double_plan = _double_devastation_plan(game, player, movement_score, attack_score)
    if double_plan:
        candidates.append(double_plan)

    portal_plan = _portal_plan(game, player, movement_score, attack_score)
    if portal_plan:
        candidates.append(portal_plan)

    precombat_plan = _precombat_skill_plan(
        game, player, attack, movement_score, attack_score
    )
    if precombat_plan:
        candidates.append(precombat_plan)

    battleship_plan = _battleship_plan(game, player, movement_score, attack_score)
    if battleship_plan:
        candidates.append(battleship_plan)

    seeker_plan = _gem_seeker_plan(game, player, movement_score, attack_score)
    if seeker_plan:
        candidates.append(seeker_plan)

    if not candidates:
        return None

    candidates.sort(key=lambda candidate: candidate[0], reverse=True)
    return candidates[0][1]


def _precombat_skill_plan(
    game: "PiratesGame",
    player: "PiratesPlayer",
    attack: TargetAssessment | None,
    movement_score: float,
    attack_score: float,
) -> tuple[float, BotDecision] | None:
    """Use buff skills when they materially improve a valuable attack."""
    if not attack or attack_score < MIN_ATTACK_SCORE:
        return None

    target = attack.target
    target_value = _player_gem_value(target)
    target_is_leader = _is_score_leader(game, target)
    candidates: list[tuple[float, BotDecision]] = []

    if _can_use_skill(game, player, SWORD_FIGHTER):
        buffed = _assess_target(game, player, target, extra_attack_bonus=2)
        delta = buffed.score - attack.score
        if target_value or target_is_leader or delta >= 4.0:
            score = buffed.score + 14.0 + max(0.0, delta)
            candidates.append(
                (
                    score,
                    BotDecision(
                        action_id="use_skill",
                        skill_name=SWORD_FIGHTER.skill_id,
                        target=target,
                    ),
                )
            )

    if _can_use_skill(game, player, SKILLED_CAPTAIN):
        buffed = _assess_target(game, player, target, extra_attack_bonus=1)
        defense_value = _incoming_threat_score(game, player, player.position) * 0.35
        delta = buffed.score - attack.score
        if defense_value >= 4.0 or target_value or target_is_leader or delta >= 3.0:
            score = buffed.score + 10.0 + defense_value + max(0.0, delta)
            candidates.append(
                (
                    score,
                    BotDecision(
                        action_id="use_skill",
                        skill_name=SKILLED_CAPTAIN.skill_id,
                        target=target,
                    ),
                )
            )

    if _can_use_skill(game, player, PUSH):
        steal_available = (
            game.options.gem_stealing != "disabled" and target.has_gems()
        )
        if not steal_available and attack.hit_probability >= 0.42:
            score = attack.score + 9.0 + _push_disruption_value(game, target)
            candidates.append(
                (
                    score,
                    BotDecision(
                        action_id="use_skill",
                        skill_name=PUSH.skill_id,
                        target=target,
                    ),
                )
            )

    if not candidates:
        return None

    candidates.sort(key=lambda candidate: candidate[0], reverse=True)
    best_score, decision = candidates[0]
    if best_score >= max(movement_score + 6.0, attack_score + 6.0):
        return best_score, decision
    return None


def _double_devastation_plan(
    game: "PiratesGame",
    player: "PiratesPlayer",
    movement_score: float,
    attack_score: float,
) -> tuple[float, BotDecision] | None:
    """Extend range when it unlocks a valuable target outside normal range."""
    if not _can_use_skill(game, player, DOUBLE_DEVASTATION):
        return None

    current_target_ids = {
        target.id for target in combat.get_targets_in_range(game, player, max_range=5)
    }
    extended_targets = [
        target
        for target in combat.get_targets_in_range(game, player, max_range=10)
        if target.id not in current_target_ids
    ]
    if not extended_targets:
        return None

    assessments = [_assess_target(game, player, target) for target in extended_targets]
    assessments.sort(key=lambda assessment: assessment.score, reverse=True)
    best = assessments[0]
    if best.score < MIN_ATTACK_SCORE:
        return None

    score = best.score + 16.0
    if score >= max(movement_score + 7.0, attack_score + 8.0):
        return (
            score,
            BotDecision(
                action_id="use_skill",
                skill_name=DOUBLE_DEVASTATION.skill_id,
                target=best.target,
            ),
        )
    return None


def _battleship_plan(
    game: "PiratesGame",
    player: "PiratesPlayer",
    movement_score: float,
    attack_score: float,
) -> tuple[float, BotDecision] | None:
    """Use Battleship for strong XP pressure, not when boarding is better."""
    if not _can_use_skill(game, player, BATTLESHIP):
        return None

    targets = combat.get_targets_in_range(game, player)
    if not targets:
        return None

    assessments = [_assess_target(game, player, target) for target in targets]
    assessments.sort(key=lambda assessment: assessment.score, reverse=True)
    best = assessments[0]

    shot_scores = sorted(
        (_score_battleship_shot(game, player, target) for target in targets),
        reverse=True,
    )
    if not shot_scores:
        return None

    total = shot_scores[0]
    if len(shot_scores) > 1:
        total += shot_scores[1] * 0.85
    else:
        total += shot_scores[0] * 0.55

    valuable_boarding_target = (
        best.target.has_gems() and game.options.gem_stealing != "disabled"
    )
    boarding_penalty = 14.0 if valuable_boarding_target else 0.0
    score = total - boarding_penalty

    if score >= max(24.0, movement_score + 7.0, attack_score + 3.0):
        return (
            score,
            BotDecision(
                action_id="use_skill",
                skill_name=BATTLESHIP.skill_id,
                target=best.target,
            ),
        )
    return None


def _portal_plan(
    game: "PiratesGame",
    player: "PiratesPlayer",
    movement_score: float,
    attack_score: float,
) -> tuple[float, BotDecision] | None:
    """Use Portal for escape or for a major repositioning advantage."""
    if not _can_use_skill(game, player, PORTAL):
        return None

    current_danger = _incoming_threat_score(game, player, player.position)
    closest_gem = _find_closest_gem(game, player)
    closest_distance = (
        abs(player.position - closest_gem) if closest_gem != -1 else 999
    )

    if player.has_gems() and current_danger >= 12.0:
        score = current_danger * 1.8 + _player_gem_value(player) * 12.0 + 18.0
        if score >= max(movement_score + 10.0, attack_score + 8.0):
            return (
                score,
                BotDecision(
                    action_id="use_skill",
                    skill_name=PORTAL.skill_id,
                    portal_random=True,
                ),
            )

    if attack_score >= MIN_ATTACK_SCORE:
        return None

    ocean_scores = _score_portal_oceans(game, player)
    if ocean_scores:
        best_ocean_score = ocean_scores[0][1]
        score = best_ocean_score + max(0, closest_distance - 6) * 2.5
        if closest_distance >= 8 and score >= max(
            movement_score + 9.0, attack_score + 7.0
        ):
            return (
                score,
                BotDecision(action_id="use_skill", skill_name=PORTAL.skill_id),
            )

    if closest_distance >= 14 and movement_score < 20.0:
        score = 22.0 + max(0, closest_distance - 14)
        if score >= attack_score + 5.0:
            return (
                score,
                BotDecision(
                    action_id="use_skill",
                    skill_name=PORTAL.skill_id,
                    portal_random=True,
                ),
            )

    return None


def _gem_seeker_plan(
    game: "PiratesGame",
    player: "PiratesPlayer",
    movement_score: float,
    attack_score: float,
) -> tuple[float, BotDecision] | None:
    """Use Gem Seeker sparingly when the bot lacks a strong concrete play."""
    if _skill_used_this_turn(game, player, GEM_SEEKER.skill_id):
        return None
    if not _can_use_skill(game, player, GEM_SEEKER):
        return None

    closest_gem = _find_closest_gem(game, player)
    if closest_gem == -1:
        return None
    distance = abs(player.position - closest_gem)
    if distance < 9 or movement_score >= 24.0 or attack_score >= MIN_ATTACK_SCORE:
        return None

    score = 20.0 + min(10.0, distance - 8)
    return (
        score,
        BotDecision(action_id="use_skill", skill_name=GEM_SEEKER.skill_id),
    )


def _best_attack_assessment(
    game: "PiratesGame", player: "PiratesPlayer"
) -> TargetAssessment | None:
    targets = combat.get_targets_in_range(game, player)
    if not targets:
        return None
    assessments = [_assess_target(game, player, target) for target in targets]
    assessments.sort(key=lambda assessment: assessment.score, reverse=True)
    return assessments[0]


def _assess_target(
    game: "PiratesGame",
    player: "PiratesPlayer",
    target: "PiratesPlayer",
    *,
    extra_attack_bonus: int = 0,
) -> TargetAssessment:
    """Score a normal cannonball attack against one target."""
    attack_bonus = skills.get_attack_bonus(player) + extra_attack_bonus
    defense_bonus = skills.get_defense_bonus(target)
    hit_probability = _roll_win_probability(attack_bonus, defense_bonus)

    steal_probability = 0.0
    gem_swing = 0.0
    target_gem_value = _player_gem_value(target)
    if target.has_gems() and game.options.gem_stealing != "disabled":
        if game.options.gem_stealing == "with_roll_bonus":
            steal_probability = _roll_win_probability(attack_bonus, defense_bonus)
        else:
            steal_probability = _roll_win_probability(0, 0)
        average_gem = target_gem_value / max(1, len(target.gems))
        # A successful steal both adds to us and removes from the defender.
        gem_swing = average_gem * 2.0

    score_gap = max(0, target.score - player.score)
    leader_pressure = 12.0 if _is_score_leader(game, target) else 0.0
    leader_pressure += score_gap * 3.5
    level_pressure = min(10.0, target.level / 18.0)
    steal_value = hit_probability * steal_probability * gem_swing * 34.0
    xp_value = hit_probability * 15.0 - (1.0 - hit_probability) * 6.0

    if target_gem_value:
        material_value = target_gem_value * 18.0 + len(target.gems) * 4.0
    else:
        material_value = 4.0 if _is_score_leader(game, target) else 0.0

    distance = combat.get_distance(player, target)
    close_threat_bonus = 0.0
    if player.has_gems() and distance <= skills.get_attack_range(target):
        close_threat_bonus = _player_gem_value(player) * 3.0

    score = (
        xp_value
        + steal_value
        + hit_probability * (material_value + leader_pressure + level_pressure)
        + close_threat_bonus
    )
    return TargetAssessment(
        target=target,
        score=score,
        hit_probability=hit_probability,
        steal_probability=steal_probability,
        gem_swing=gem_swing,
        distance=distance,
    )


def _score_battleship_shot(
    game: "PiratesGame", player: "PiratesPlayer", target: "PiratesPlayer"
) -> float:
    """Score one non-boarding Battleship shot."""
    hit_probability = _roll_win_probability(
        skills.get_attack_bonus(player), skills.get_defense_bonus(target)
    )
    target_gem_value = _player_gem_value(target)
    leader_pressure = 10.0 if _is_score_leader(game, target) else 0.0
    score_gap = max(0, target.score - player.score)
    return hit_probability * (
        18.0
        + min(8.0, target.level / 20.0)
        + target_gem_value * 7.0
        + leader_pressure
        + score_gap * 2.0
    )


def _best_movement_decision(
    game: "PiratesGame", player: "PiratesPlayer"
) -> tuple[float, BotDecision] | None:
    options = _movement_options(game, player)
    if not options:
        return None

    scored = [
        (
            _score_position(game, player, option.position),
            BotDecision(
                action_id=option.action_id,
                direction=option.direction,
            ),
        )
        for option in options
    ]
    scored.sort(key=lambda item: item[0], reverse=True)
    return scored[0]


def _movement_options(
    game: "PiratesGame", player: "PiratesPlayer"
) -> list[MoveOption]:
    max_tiles = _max_move_tiles(player)
    map_max = _map_max(game)
    options: list[MoveOption] = []
    for direction, sign in (("left", -1), ("right", 1)):
        for steps in range(1, max_tiles + 1):
            position = player.position + sign * steps
            if not MAP_MIN <= position <= map_max:
                continue
            options.append(
                MoveOption(
                    action_id=_move_action_id(direction, steps),
                    direction=direction,
                    steps=steps,
                    position=position,
                )
            )
    return options


def _score_position(
    game: "PiratesGame", player: "PiratesPlayer", position: int
) -> float:
    """Score a possible end-of-turn position."""
    score = _resource_score_at_position(game, player, position)
    score -= _incoming_threat_score(game, player, position)
    return score


def _resource_score_at_position(
    game: "PiratesGame", player: "PiratesPlayer", position: int
) -> float:
    """Score treasure access and attack access from a map position."""
    score = 0.0
    landing_gem = game.gem_positions.get(position, -1)
    if landing_gem != -1:
        value = gems.get_gem_value(landing_gem)
        score += 78.0 + value * 28.0
        if game.total_gems <= 3:
            score += 8.0

    uncollected = _uncollected_gems(game)
    if uncollected:
        best_route = max(
            (
                gems.get_gem_value(gem_type) * 26.0 - abs(position - gem_pos) * 3.6
                for gem_pos, gem_type in uncollected
            ),
            default=0.0,
        )
        score += max(0.0, best_route)

        nearest_distance = min(abs(position - gem_pos) for gem_pos, _ in uncollected)
        score += max(0.0, 15.0 - nearest_distance * 1.8)

    for rival in _rivals(game, player):
        distance = abs(position - rival.position)
        rival_value = _player_gem_value(rival)
        if rival_value:
            score += max(0.0, rival_value * 7.0 + rival.score * 1.5 - distance * 2.2)
        elif _is_score_leader(game, rival):
            score += max(0.0, 9.0 - distance)

    return score


def _incoming_threat_score(
    game: "PiratesGame", player: "PiratesPlayer", position: int
) -> float:
    """Estimate how dangerous this position is before the bot's next turn."""
    if not player.has_gems():
        return 0.0

    value_at_risk = max(1.0, _player_gem_value(player))
    score = 0.0
    for rival in _rivals(game, player):
        distance = abs(position - rival.position)
        if distance > skills.get_attack_range(rival):
            continue
        hit_probability = _roll_win_probability(
            skills.get_attack_bonus(rival), skills.get_defense_bonus(player)
        )
        rival_pressure = max(0, rival.score - player.score) * 1.6
        score += hit_probability * (
            18.0 + value_at_risk * 13.0 + rival_pressure
        )
        if distance <= 2:
            score += 5.0
    return score


def _score_portal_oceans(
    game: "PiratesGame", player: "PiratesPlayer"
) -> list[tuple[int, float]]:
    current_ocean = (player.position - 1) // OCEAN_SIZE
    ocean_scores: list[tuple[int, float]] = []
    ocean_count = max(1, len(getattr(game, "selected_oceans", [])))

    for ocean in range(ocean_count):
        if ocean == current_ocean:
            continue
        start = ocean * OCEAN_SIZE + 1
        end = start + OCEAN_SIZE - 1
        has_rival = any(
            start <= rival.position <= end for rival in _rivals(game, player)
        )
        if not has_rival:
            continue

        score = 0.0
        for pos in range(start, end + 1):
            gem_type = game.gem_positions.get(pos, -1)
            if gem_type != -1:
                score += 14.0 + gems.get_gem_value(gem_type) * 10.0
        for rival in _rivals(game, player):
            if start <= rival.position <= end:
                score += 8.0 + _player_gem_value(rival) * 12.0
                if _is_score_leader(game, rival):
                    score += 10.0
        ocean_scores.append((ocean, score))

    ocean_scores.sort(key=lambda item: item[1], reverse=True)
    return ocean_scores


def _score_portal_option(
    game: "PiratesGame", player: "PiratesPlayer", ocean_num: int
) -> float:
    scores = dict(_score_portal_oceans(game, player))
    return scores.get(ocean_num, 0.0)


def _find_closest_gem(game: "PiratesGame", player: "PiratesPlayer") -> int:
    """Find the position of the closest uncollected gem."""
    closest_pos = -1
    closest_distance = 999

    for pos, gem_type in game.gem_positions.items():
        if gem_type == -1:
            continue
        distance = abs(player.position - pos)
        if distance < closest_distance:
            closest_distance = distance
            closest_pos = pos

    return closest_pos


def _find_valuable_target(
    game: "PiratesGame",
    player: "PiratesPlayer",
    targets: list["PiratesPlayer"],
) -> "PiratesPlayer | None":
    """Find the target with the strongest tactical value."""
    if not targets:
        return None

    assessments = [_assess_target(game, player, target) for target in targets]
    assessments.sort(key=lambda assessment: assessment.score, reverse=True)
    if assessments[0].score >= 8.0:
        return assessments[0].target
    return None


def _calculate_attack_chance(
    game: "PiratesGame",
    player: "PiratesPlayer",
    target: "PiratesPlayer",
    has_attack_buff: bool,
    target_has_defense: bool,
    gem_distance: int,
) -> float:
    """
    Legacy compatibility wrapper for tests or external callers.

    The main bot now uses expected-value scoring, but this helper remains a
    sane probability-like value for code that imports it directly.
    """
    assessment = _assess_target(game, player, target)
    chance = assessment.hit_probability
    if has_attack_buff:
        chance += 0.08
    if target_has_defense:
        chance -= 0.08
    if target.has_gems():
        chance += 0.12
    if gem_distance > 10:
        chance += 0.08
    return max(0.1, min(0.95, chance))


def _is_other_player_near_gem(game: "PiratesGame", player: "PiratesPlayer") -> bool:
    """Check if another player is within 5 tiles of an uncollected gem."""
    for other in _rivals(game, player):
        for pos, gem_type in game.gem_positions.items():
            if gem_type != -1 and abs(other.position - pos) <= 5:
                return True
    return False


def _decide_movement(game: "PiratesGame", player: "PiratesPlayer") -> BotDecision:
    """Return the best legal movement decision."""
    movement = _best_movement_decision(game, player)
    if movement:
        return movement[1]
    direction = "right" if player.position <= MAP_MIN else "left"
    return _get_best_move_action(game, player, direction)


def _decide_movement_toward(
    game: "PiratesGame",
    player: "PiratesPlayer",
    target_pos: int,
) -> BotDecision:
    """Decide movement toward a target position without overshooting it."""
    if player.position < target_pos:
        direction = "right"
    elif player.position > target_pos:
        direction = "left"
    else:
        return _decide_movement(game, player)
    return _get_best_move_action(game, player, direction, target_pos)


def _get_best_move_action(
    game: "PiratesGame",
    player: "PiratesPlayer",
    direction: str,
    target_pos: int | None = None,
) -> BotDecision:
    """Get the strongest legal move action for the requested direction."""
    sign = -1 if direction == "left" else 1
    max_tiles = _max_move_tiles(player)
    if target_pos is not None:
        max_tiles = min(max_tiles, abs(player.position - target_pos))
    map_max = _map_max(game)
    while max_tiles > 1:
        position = player.position + sign * max_tiles
        if MAP_MIN <= position <= map_max:
            break
        max_tiles -= 1
    if max_tiles <= 0:
        max_tiles = 1
    return BotDecision(
        action_id=_move_action_id(direction, max_tiles),
        direction=direction,
    )


def _choose_push_direction(
    game: "PiratesGame",
    attacker: "PiratesPlayer",
    defender: "PiratesPlayer",
) -> str:
    """Push the defender toward the weaker future position."""
    expected_push = 5 + skills.get_push_bonus(attacker)
    map_max = _map_max(game)
    candidates = []
    for direction, sign in (("left", -1), ("right", 1)):
        position = max(MAP_MIN, min(map_max, defender.position + sign * expected_push))
        defender_score = _resource_score_at_position(game, defender, position)
        defender_score -= _incoming_threat_score(game, defender, position) * 0.5
        edge_bonus = 2.0 if position in {MAP_MIN, map_max} else 0.0
        candidates.append((defender_score - edge_bonus, direction))
    candidates.sort(key=lambda item: item[0])
    return candidates[0][1]


def _push_disruption_value(game: "PiratesGame", target: "PiratesPlayer") -> float:
    current = _resource_score_at_position(game, target, target.position)
    best_after_push = min(
        _resource_score_at_position(
            game,
            target,
            max(MAP_MIN, min(_map_max(game), target.position + delta)),
        )
        for delta in (-5, 5)
    )
    return max(0.0, current - best_after_push)


def _roll_win_probability(attack_bonus: int, defense_bonus: int) -> float:
    wins = 0
    for attack_die in range(1, 7):
        for defense_die in range(1, 7):
            if attack_die + attack_bonus > defense_die + defense_bonus:
                wins += 1
    return wins / 36.0


def _can_use_skill(
    game: "PiratesGame", player: "PiratesPlayer", skill: "Skill"
) -> bool:
    can_use, _ = skill.can_perform(game, player)
    return can_use


def _skill_used_this_turn(
    game: "PiratesGame", player: "PiratesPlayer", skill_id: str
) -> bool:
    marks = getattr(game, "_bot_skill_turn_marks", set())
    return (game.round, player.id, skill_id) in marks


def _mark_skill_used_this_turn(
    game: "PiratesGame", player: "PiratesPlayer", skill_id: str
) -> None:
    marks = getattr(game, "_bot_skill_turn_marks", None)
    if marks is None:
        marks = set()
        game._bot_skill_turn_marks = marks
    marks.add((game.round, player.id, skill_id))


def _has_pending_boarding(game: "PiratesGame", player: "PiratesPlayer") -> bool:
    pending = getattr(game, "_has_pending_boarding", None)
    return bool(pending and pending(player))


def _has_pending_portal(game: "PiratesGame", player: "PiratesPlayer") -> bool:
    pending = getattr(game, "_has_pending_portal", None)
    return bool(pending and pending(player))


def _rivals(
    game: "PiratesGame", player: "PiratesPlayer"
) -> list["PiratesPlayer"]:
    return [other for other in game.get_active_players() if other.id != player.id]


def _is_score_leader(game: "PiratesGame", player: "PiratesPlayer") -> bool:
    active = game.get_active_players()
    if not active:
        return False
    return player.score == max(other.score for other in active)


def _player_gem_value(player: "PiratesPlayer") -> int:
    return sum(gems.get_gem_value(gem_type) for gem_type in player.gems)


def _uncollected_gems(game: "PiratesGame") -> list[tuple[int, int]]:
    return [
        (position, gem_type)
        for position, gem_type in game.gem_positions.items()
        if gem_type != -1
    ]


def _max_move_tiles(player: "PiratesPlayer") -> int:
    if player.level >= 150:
        return 3
    if player.level >= 15:
        return 2
    return 1


def _move_action_id(direction: str, steps: int) -> str:
    if steps >= 3:
        return f"move_3_{direction}"
    if steps == 2:
        return f"move_2_{direction}"
    return f"move_{direction}"


def _map_max(game: "PiratesGame") -> int:
    if game.gem_positions:
        return max(game.gem_positions)
    return FALLBACK_MAP_MAX


# =============================================================================
# Bot response handlers for multi-step actions
# =============================================================================


def bot_select_target(
    game: "PiratesGame",
    player: "PiratesPlayer",
    targets: list["PiratesPlayer"],
) -> "PiratesPlayer | None":
    """
    Select a target for the bot to attack.

    Uses the pre-computed decision if available, otherwise picks the highest
    expected-value target.
    """
    if not targets:
        return None

    decision = getattr(game, "_bot_decision", None)
    if player.is_bot and decision and decision.target and decision.target in targets:
        return decision.target

    return _find_valuable_target(game, player, targets) or targets[0]


def bot_select_boarding_action(
    game: "PiratesGame",
    player: "PiratesPlayer",
    defender: "PiratesPlayer",
    can_steal: bool,
) -> str:
    """
    Select a boarding action for the bot.

    Steal when the expected score swing is strong; otherwise push the defender
    toward the least useful follow-up position.
    """
    if can_steal and defender.has_gems():
        use_bonuses = game.options.gem_stealing == "with_roll_bonus"
        attack_bonus = skills.get_attack_bonus(player) if use_bonuses else 0
        defense_bonus = skills.get_defense_bonus(defender) if use_bonuses else 0
        steal_probability = _roll_win_probability(attack_bonus, defense_bonus)
        defender_gem_value = _player_gem_value(defender)
        swing = (defender_gem_value / max(1, len(defender.gems))) * 2.0
        leader_bonus = 0.18 if _is_score_leader(game, defender) else 0.0
        pressure_bonus = min(0.18, max(0, defender.score - player.score) * 0.03)
        threshold = 0.34 - min(0.12, swing * 0.02) - leader_bonus - pressure_bonus
        if steal_probability >= max(0.12, threshold):
            return "steal"

    return _choose_push_direction(game, player, defender)


def bot_select_portal_ocean(
    game: "PiratesGame",
    player: "PiratesPlayer",
    ocean_options: list[tuple[int, str]],
) -> int | str | None:
    """
    Select an ocean for the bot to portal to.

    A stored escape decision can deliberately choose Random. Otherwise the bot
    chooses the strongest occupied ocean by treasure and target pressure.
    """
    decision = getattr(game, "_bot_decision", None)
    if (
        player.is_bot
        and decision
        and decision.skill_name == PORTAL.skill_id
        and decision.portal_random
    ):
        return "random"

    if not ocean_options:
        return None

    scored_oceans = [
        (ocean_num, _score_portal_option(game, player, ocean_num))
        for ocean_num, _ocean_name in ocean_options
    ]
    scored_oceans.sort(key=lambda item: item[1], reverse=True)

    if scored_oceans:
        return scored_oceans[0][0]
    return ocean_options[0][0]


def bot_select_skill_choice(
    game: "PiratesGame",
    player: "PiratesPlayer",
    skill_options: list[str],
) -> str:
    """
    Select a skill from the skill menu.

    Uses the pre-computed decision when it is still present in the menu, then
    falls back to the first currently usable skill.
    """
    decision = getattr(game, "_bot_decision", None)
    if decision and decision.skill_name and decision.skill_name in skill_options:
        skill = skills.SKILLS_BY_ID.get(decision.skill_name)
        if skill and _can_use_skill(game, player, skill):
            return decision.skill_name

    for skill_id in skill_options:
        skill = skills.SKILLS_BY_ID.get(skill_id)
        if skill and _can_use_skill(game, player, skill):
            return skill_id
    return skill_options[0]
