"""Sound families resolve to real client files, chosen by the server.

PlayAural's clients pick a random variant of a sound family themselves; ours
need a concrete file, so the server picks one from SOUND_FAMILY_VARIANTS.
"""

import logging
from pathlib import Path

import server.game_utils.game_sound_mixin as game_sound_mixin
from server.core.users.test_user import MockUser
from server.game_utils.game_sound_mixin import SOUND_FAMILY_VARIANTS, resolve_sound_family
from server.games.pig.game import PigGame

SOUNDS_DIR = Path(__file__).resolve().parents[2] / "clients" / "desktop" / "sounds"


def test_registered_families_match_the_client_sound_files():
    for family, variant_count in SOUND_FAMILY_VARIANTS.items():
        for variant in range(1, variant_count + 1):
            assert (SOUNDS_DIR / f"{family}{variant}.ogg").is_file(), f"{family}{variant}.ogg"
        assert not (SOUNDS_DIR / f"{family}{variant_count + 1}.ogg").exists(), (
            f"{family} has more variants than SOUND_FAMILY_VARIANTS lists"
        )


def test_play_sound_family_plays_a_real_variant_centred_at_full_volume():
    game = PigGame()
    user = MockUser("Alice", uuid="family-1")
    game.add_player("Alice", user)

    played = {game.play_sound_family("game_cards/draw") for _ in range(60)}

    assert played <= {f"game_cards/draw{variant}.ogg" for variant in range(1, 5)}
    assert len(played) > 1
    sound_messages = [message.data for message in user.messages if message.type == "play_sound"]
    assert sound_messages
    assert all(data["volume"] == 100 and data["pan"] == 0 and data["pitch"] == 100 for data in sound_messages)


def test_play_sound_family_forwards_volume_pan_and_pitch():
    game = PigGame()
    user = MockUser("Alice", uuid="family-2")
    game.add_player("Alice", user)

    game.play_sound_family("game_humanitycards/submit", volume=70, pan=-40, pitch=110)

    data = [message.data for message in user.messages if message.type == "play_sound"][-1]
    assert data["name"] in {"game_humanitycards/submit1.ogg", "game_humanitycards/submit2.ogg"}
    assert (data["volume"], data["pan"], data["pitch"]) == (70, -40, 110)


def test_unknown_family_logs_once_and_plays_the_bare_name(caplog, monkeypatch):
    monkeypatch.setattr(game_sound_mixin, "_warned_families", set())
    with caplog.at_level(logging.WARNING, logger="playpalace.sound"):
        first = resolve_sound_family("game_cards/no_such_family")
        second = resolve_sound_family("game_cards/no_such_family")

    assert first == second == "game_cards/no_such_family.ogg"
    warnings = [record for record in caplog.records if record.name == "playpalace.sound"]
    assert len(warnings) == 1
