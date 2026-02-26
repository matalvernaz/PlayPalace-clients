"""Capability registry for Monopoly board-specific rule packs."""

from __future__ import annotations

from dataclasses import dataclass

from .board_rules import (
    animal_crossing,
    barbie,
    disney_animation,
    disney_lightyear,
    disney_lion_king,
    disney_mickey_friends,
    disney_princesses,
    disney_villains,
    fortnite,
    harry_potter,
    junior_super_mario,
    jurassic_park,
    lord_of_the_rings,
    mario_celebration,
    mario_collectors,
    mario_kart,
    mario_movie,
    marvel_80_years,
    marvel_avengers,
    marvel_black_panther_wf,
    marvel_deadpool,
    marvel_spider_man,
    marvel_super_villains,
    star_wars_40th,
    star_wars_boba_fett,
    star_wars_complete_saga,
    star_wars_light_side,
    star_wars_mandalorian,
    star_wars_the_child,
    stranger_things,
)

@dataclass(frozen=True)
class BoardRulePack:
    """Declarative capabilities for one board rule-pack."""

    rule_pack_id: str
    status: str
    capability_ids: tuple[str, ...]


RULE_PACKS: dict[str, BoardRulePack] = {
    "mario_collectors": BoardRulePack(
        rule_pack_id="mario_collectors",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "mario_kart": BoardRulePack(
        rule_pack_id="mario_kart",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "mario_celebration": BoardRulePack(
        rule_pack_id="mario_celebration",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "mario_movie": BoardRulePack(
        rule_pack_id="mario_movie",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "junior_super_mario": BoardRulePack(
        rule_pack_id="junior_super_mario",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_princesses": BoardRulePack(
        rule_pack_id="disney_princesses",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_animation": BoardRulePack(
        rule_pack_id="disney_animation",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_lion_king": BoardRulePack(
        rule_pack_id="disney_lion_king",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_mickey_friends": BoardRulePack(
        rule_pack_id="disney_mickey_friends",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_villains": BoardRulePack(
        rule_pack_id="disney_villains",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "disney_lightyear": BoardRulePack(
        rule_pack_id="disney_lightyear",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_80_years": BoardRulePack(
        rule_pack_id="marvel_80_years",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_avengers": BoardRulePack(
        rule_pack_id="marvel_avengers",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_spider_man": BoardRulePack(
        rule_pack_id="marvel_spider_man",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_black_panther_wf": BoardRulePack(
        rule_pack_id="marvel_black_panther_wf",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_super_villains": BoardRulePack(
        rule_pack_id="marvel_super_villains",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "marvel_deadpool": BoardRulePack(
        rule_pack_id="marvel_deadpool",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_40th": BoardRulePack(
        rule_pack_id="star_wars_40th",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_boba_fett": BoardRulePack(
        rule_pack_id="star_wars_boba_fett",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_light_side": BoardRulePack(
        rule_pack_id="star_wars_light_side",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_the_child": BoardRulePack(
        rule_pack_id="star_wars_the_child",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_mandalorian": BoardRulePack(
        rule_pack_id="star_wars_mandalorian",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "star_wars_complete_saga": BoardRulePack(
        rule_pack_id="star_wars_complete_saga",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "harry_potter": BoardRulePack(
        rule_pack_id="harry_potter",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "fortnite": BoardRulePack(
        rule_pack_id="fortnite",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "stranger_things": BoardRulePack(
        rule_pack_id="stranger_things",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "jurassic_park": BoardRulePack(
        rule_pack_id="jurassic_park",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "lord_of_the_rings": BoardRulePack(
        rule_pack_id="lord_of_the_rings",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "animal_crossing": BoardRulePack(
        rule_pack_id="animal_crossing",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
    "barbie": BoardRulePack(
        rule_pack_id="barbie",
        status="partial",
        capability_ids=(
            "pass_go_credit_override",
            "startup_board_announcement",
        ),
    ),
}
RULE_PACK_MODULES = {
    "mario_collectors": mario_collectors,
    "mario_kart": mario_kart,
    "mario_celebration": mario_celebration,
    "mario_movie": mario_movie,
    "junior_super_mario": junior_super_mario,
    "disney_princesses": disney_princesses,
    "disney_animation": disney_animation,
    "disney_lion_king": disney_lion_king,
    "disney_mickey_friends": disney_mickey_friends,
    "disney_villains": disney_villains,
    "disney_lightyear": disney_lightyear,
    "marvel_80_years": marvel_80_years,
    "marvel_avengers": marvel_avengers,
    "marvel_spider_man": marvel_spider_man,
    "marvel_black_panther_wf": marvel_black_panther_wf,
    "marvel_super_villains": marvel_super_villains,
    "marvel_deadpool": marvel_deadpool,
    "star_wars_40th": star_wars_40th,
    "star_wars_boba_fett": star_wars_boba_fett,
    "star_wars_light_side": star_wars_light_side,
    "star_wars_the_child": star_wars_the_child,
    "star_wars_mandalorian": star_wars_mandalorian,
    "star_wars_complete_saga": star_wars_complete_saga,
    "harry_potter": harry_potter,
    "fortnite": fortnite,
    "stranger_things": stranger_things,
    "jurassic_park": jurassic_park,
    "lord_of_the_rings": lord_of_the_rings,
    "animal_crossing": animal_crossing,
    "barbie": barbie,
}


def get_rule_pack(rule_pack_id: str) -> BoardRulePack | None:
    """Return one board rule-pack by id."""
    return RULE_PACKS.get(rule_pack_id)


def supports_capability(rule_pack_id: str, capability_id: str) -> bool:
    """Return True when a rule-pack advertises one capability id."""
    pack = get_rule_pack(rule_pack_id)
    return bool(pack and capability_id in pack.capability_ids)


def get_pass_go_credit_override(rule_pack_id: str) -> int | None:
    """Return pass-GO override for one rule-pack when declared."""
    module = RULE_PACK_MODULES.get(rule_pack_id)
    if module is None:
        return None
    value = getattr(module, "PASS_GO_CREDIT_OVERRIDE", None)
    if isinstance(value, int):
        return value
    return None
