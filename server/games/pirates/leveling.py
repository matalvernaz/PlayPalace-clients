"""
Leveling System for Pirates of the Lost Seas.

Handles XP gain, level-ups, and skill unlock detection.
Skill unlock levels are defined on each skill class - this system reads from them.

This class inherits from DataClassJSONMixin to ensure serializability.
The game object is NEVER stored - it is only passed as a parameter to methods.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import TYPE_CHECKING

from mashumaro.mixins.json import DataClassJSONMixin

from ...messages.localization import Localization
from .skills import ALL_SKILLS

if TYPE_CHECKING:
    from .game import PiratesGame
    from .skills import Skill


def get_xp_for_level(level: int) -> int:
    """Get the XP required to reach a specific level."""
    return level * 20


@dataclass
class LevelingSystem(DataClassJSONMixin):
    """
    Manages a player's experience and level progression.

    Tied to a specific player via user_id.
    Skill unlock levels are read from the skill singletons in skills.py.

    The game object is NEVER stored - it is only passed as a parameter to methods.
    This ensures the leveling system remains serializable.
    """

    user_id: str
    level: int = 0
    xp: int = 0

    def get_xp_to_next_level(self) -> int:
        """Get XP needed to reach the next level."""
        return get_xp_for_level(self.level + 1) - self.xp

    def get_xp_progress(self) -> tuple[int, int]:
        """Get current XP and XP needed for next level."""
        current_level_xp = get_xp_for_level(self.level)
        next_level_xp = get_xp_for_level(self.level + 1)
        progress = self.xp - current_level_xp
        needed = next_level_xp - current_level_xp
        return progress, needed

    def can_level_up(self) -> bool:
        """Check if the player has enough XP to level up."""
        return self.xp >= get_xp_for_level(self.level + 1)

    def get_unlocked_skills(self) -> list["Skill"]:
        """Get list of skills unlocked at or below current level."""
        return [
            skill for skill in ALL_SKILLS
            if skill.required_level <= self.level
        ]

    def get_locked_skills(self) -> list["Skill"]:
        """Get list of skills not yet unlocked."""
        return [
            skill for skill in ALL_SKILLS
            if skill.required_level > self.level
        ]

    def get_next_skill_unlock(self) -> tuple[int, "Skill"] | None:
        """Get the next skill unlock (level, skill) or None if all unlocked."""
        locked = self.get_locked_skills()
        if not locked:
            return None

        # Find the skill with lowest required level above current
        next_skill = min(locked, key=lambda s: s.required_level)
        return next_skill.required_level, next_skill

    def get_skills_at_level(self, level: int) -> list["Skill"]:
        """Get skills that unlock exactly at the given level."""
        return [
            skill for skill in ALL_SKILLS
            if skill.required_level == level
        ]

    def give_xp(
        self,
        game: "PiratesGame",
        player_name: str,
        base_xp: int,
        golden_moon_multiplier: float = 1.0,
        global_multiplier: float = 1.0,
        reason: str = "generic",
    ) -> list["Skill"]:
        """
        Give XP to this leveling system and process level ups.

        Args:
            game: The game instance for announcements
            player_name: Legacy caller-provided name; player state is authoritative
            base_xp: Base XP amount to give
            golden_moon_multiplier: Multiplier from golden moon (default 1.0)
            global_multiplier: Global XP multiplier from game options (default 1.0)

        Returns:
            List of newly unlocked skills
        """
        total_multiplier = golden_moon_multiplier * global_multiplier
        xp_gained = int(base_xp * total_multiplier)
        self.xp += xp_gained

        # Get skill manager for this player to check unlocks
        player = game.get_player_by_id(self.user_id)
        if not player:
            return []

        game._broadcast_actor_l(
            player,
            "pirates-xp-gained-you",
            "pirates-xp-gained-player",
            brief_personal_key="pirates-xp-gained-you-brief",
            brief_others_key="pirates-xp-gained-player-brief",
            xp=xp_gained,
            total=self.xp,
            reason=reason,
        )

        # Process level ups
        starting_level = self.level
        skills_unlocked: list["Skill"] = []

        while self.can_level_up():
            self.level += 1

            # Check for skill unlocks at this level
            newly_unlocked = self.get_skills_at_level(self.level)
            skills_unlocked.extend(newly_unlocked)

        # Announce level ups if any
        if self.level > starting_level:
            game.play_sound("game_pig/win.ogg", volume=80)
            levels_gained = self.level - starting_level
            if levels_gained == 1:
                game._broadcast_actor_l(
                    player,
                    "pirates-level-up-you",
                    "pirates-level-up",
                    brief_personal_key="pirates-level-up-you-brief",
                    brief_others_key="pirates-level-up-brief",
                    level=self.level,
                )
            else:
                game._broadcast_actor_l(
                    player,
                    "pirates-level-up-multiple-you",
                    "pirates-level-up-multiple",
                    brief_personal_key="pirates-level-up-multiple-you-brief",
                    brief_others_key="pirates-level-up-multiple-brief",
                    levels=levels_gained,
                    level=self.level,
                )

            if skills_unlocked:
                for listener in game.players:
                    user = game.get_user(listener)
                    if not user:
                        continue
                    skill_names = Localization.format_list_and(
                        user.locale,
                        [
                            Localization.get(user.locale, skill.name)
                            for skill in skills_unlocked
                        ],
                    )
                    if listener.id == player.id:
                        key = "pirates-skills-unlocked-you"
                        if game._wants_brief(user):
                            key += "-brief"
                        user.speak_l(
                            key,
                            buffer="game",
                            skills=skill_names,
                            level=self.level,
                        )
                    else:
                        key = "pirates-skills-unlocked"
                        if game._wants_brief(user):
                            key += "-brief"
                        user.speak_l(
                            key,
                            buffer="game",
                            player=player.name,
                            skills=skill_names,
                            level=self.level,
                        )

        return skills_unlocked

    def has_skill_unlocked(self, skill: "Skill") -> bool:
        """Check if a specific skill is unlocked based on current level."""
        return self.level >= skill.required_level
