"""Variant presets for Trouble.

Each preset is a dict of option values the host can apply as a bundle.
After applying a preset, the host may override any individual option;
the preset choice switches to "custom" automatically in that case.
"""

# All option keys that a preset can control. Keeping this explicit means
# tests can assert that every key is present in every preset.
PRESET_KEYS: tuple[str, ...] = (
    "track_size",
    "tokens_per_player",
    "extra_turn_on_six",
    "six_to_leave_home",
    "safe_spaces",
    "finish_behavior",
)


PRESETS: dict[str, dict[str, object]] = {
    # Hasbro classic rules. The one a purist expects when you say "Trouble."
    "classic": {
        "track_size": "28",
        "tokens_per_player": "4",
        "extra_turn_on_six": True,
        "six_to_leave_home": True,
        "safe_spaces": "none",
        "finish_behavior": "exact",
    },
    # Smaller, forgiving — good for short sessions or casual warm-up.
    "fast": {
        "track_size": "20",
        "tokens_per_player": "2",
        "extra_turn_on_six": True,
        "six_to_leave_home": False,
        "safe_spaces": "home_stretch",
        "finish_behavior": "bounce",
    },
    # Lots of tokens, no safe spaces, exact finish — bumping-heavy endgame.
    "brutal": {
        "track_size": "28",
        "tokens_per_player": "6",
        "extra_turn_on_six": True,
        "six_to_leave_home": True,
        "safe_spaces": "none",
        "finish_behavior": "exact",
    },
}


def apply_preset(options: "object", preset_id: str) -> bool:
    """Apply a preset's values to a TroubleOptions instance in place.

    Returns True if the preset exists and was applied, False otherwise.
    Any option key missing from the preset leaves the existing value
    alone. Callers are responsible for broadcasting change notifications.
    """
    preset = PRESETS.get(preset_id)
    if preset is None:
        return False
    for key, value in preset.items():
        if hasattr(options, key):
            setattr(options, key, value)
    return True


def matching_preset_id(options: "object") -> str | None:
    """Return the preset id whose values match the given options exactly,
    or None if the current configuration doesn't match any preset."""
    for preset_id, preset in PRESETS.items():
        if all(getattr(options, key, object()) == value for key, value in preset.items()):
            return preset_id
    return None


__all__ = ["PRESET_KEYS", "PRESETS", "apply_preset", "matching_preset_id"]
