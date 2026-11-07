"""The game engine's audio commands reach our clients as the sound packets they understand."""

from __future__ import annotations

import wave
from pathlib import Path

from server.audio import AudioCommand, AudioSequenceSegment, DistanceAttenuation
from server.users.legacy_audio import LegacyAudioTranslator, SoundPack
from server.users.network_user import NetworkUser


class Clock:
    """A clock the test moves by hand."""

    def __init__(self) -> None:
        self.now = 1000.0

    def __call__(self) -> float:
        return self.now


def write_wav(path: Path, milliseconds: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    rate = 8000
    with wave.open(str(path), "wb") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(rate)
        handle.writeframes(b"\x00\x00" * (rate * milliseconds // 1000))


def translator(tmp_path: Path) -> tuple[LegacyAudioTranslator, Clock]:
    clock = Clock()
    return LegacyAudioTranslator(SoundPack(tmp_path), clock=clock), clock


def test_plain_effect_becomes_play_sound(tmp_path):
    audio, _ = translator(tmp_path)
    packets = audio.translate(AudioCommand(command="play", kind="sfx", asset="game_pig/roll.ogg", volume=80, pan=-30, pitch=120))
    assert packets == [{"type": "play_sound", "name": "game_pig/roll.ogg", "volume": 80, "pan": -30, "pitch": 120}]


def test_position_turns_into_pan_and_distance_into_volume(tmp_path):
    audio, _ = translator(tmp_path)
    falloff = DistanceAttenuation(model="linear", reference_distance=1.0, max_distance=11.0, rolloff_factor=1.0, min_gain=0.0, max_gain=1.0)
    packets = audio.translate(
        AudioCommand(command="play", kind="sfx", asset="hit.ogg", position=(6.0, 0.0, 0.0), attenuation=falloff)
    )
    assert packets[0]["pan"] == 100
    assert packets[0]["volume"] == 50


def test_family_plays_one_of_its_numbered_files(tmp_path):
    for number in (1, 2, 3):
        write_wav(tmp_path / "game_cards" / f"shuffle{number}.wav", 100)
    write_wav(tmp_path / "game_cards" / "shuffle_extra.wav", 100)
    audio, _ = translator(tmp_path)
    names = {
        audio.translate(AudioCommand(command="play", kind="sfx", family="game_cards/shuffle"))[0]["name"]
        for _ in range(60)
    }
    assert names <= {f"game_cards/shuffle{number}.wav" for number in (1, 2, 3)}
    assert len(names) > 1


def test_family_missing_from_our_pack_still_names_its_first_file(tmp_path):
    audio, _ = translator(tmp_path)
    packets = audio.translate(AudioCommand(command="play", kind="sfx", family="game_new/beep"))
    assert packets[0]["name"] == "game_new/beep1.ogg"


def test_sequence_plays_each_part_after_the_one_before(tmp_path):
    write_wav(tmp_path / "a.wav", 400)
    write_wav(tmp_path / "b.wav", 200)
    write_wav(tmp_path / "c.wav", 100)
    audio, clock = translator(tmp_path)
    first = audio.translate(
        AudioCommand(
            command="play",
            kind="sfx",
            handle="chain",
            segments=(
                AudioSequenceSegment(asset="a.wav"),
                AudioSequenceSegment(asset="b.wav", next_start_ratio=0.5),
                AudioSequenceSegment(asset="c.wav"),
            ),
        )
    )
    assert [packet["name"] for packet in first] == ["a.wav"]
    clock.now += 0.39
    assert audio.due_packets() == []
    clock.now += 0.02
    assert [packet["name"] for packet in audio.due_packets()] == ["b.wav"]
    # b is 200 ms but hands over halfway, so c starts 100 ms after it (at 0.5 s).
    clock.now += 0.07
    assert audio.due_packets() == []
    clock.now += 0.03
    assert [packet["name"] for packet in audio.due_packets()] == ["c.wav"]


def test_stopping_a_sequence_drops_its_unplayed_parts(tmp_path):
    write_wav(tmp_path / "a.wav", 300)
    audio, clock = translator(tmp_path)
    audio.translate(
        AudioCommand(command="play", kind="sfx", handle="chain", segments=(AudioSequenceSegment(asset="a.wav"), AudioSequenceSegment(asset="b.wav")))
    )
    audio.translate(AudioCommand(command="stop", kind="sfx", handle="chain"))
    clock.now += 5
    assert audio.due_packets() == []


def test_music_and_ambience_use_their_own_packets(tmp_path):
    audio, _ = translator(tmp_path)
    assert audio.translate(AudioCommand(command="play", kind="music", asset="game_pig/music.ogg", handle="music", loop=True)) == [
        {"type": "play_music", "name": "game_pig/music.ogg", "looping": True}
    ]
    assert audio.translate(
        AudioCommand(command="play", kind="ambience", asset="loop.ogg", intro="in.ogg", outro="out.ogg", handle="amb")
    ) == [{"type": "play_ambience", "intro": "in.ogg", "loop": "loop.ogg", "outro": "out.ogg"}]
    assert audio.translate(AudioCommand(command="stop", kind="music", handle="music")) == [{"type": "stop_music"}]
    assert audio.translate(AudioCommand(command="stop", kind="ambience", handle="amb")) == [{"type": "stop_ambience"}]


def test_paused_music_starts_again_on_resume(tmp_path):
    audio, _ = translator(tmp_path)
    audio.translate(AudioCommand(command="play", kind="music", asset="theme.ogg", handle="music", loop=True))
    assert audio.translate(AudioCommand(command="pause", kind="music", handle="music")) == [{"type": "stop_music"}]
    assert audio.translate(AudioCommand(command="resume", kind="music", handle="music")) == [
        {"type": "play_music", "name": "theme.ogg", "looping": True}
    ]


def test_stop_all_stops_music_ambience_and_pending_parts(tmp_path):
    audio, clock = translator(tmp_path)
    audio.translate(AudioCommand(command="play", kind="sfx", handle="c", segments=(AudioSequenceSegment(asset="a.wav"), AudioSequenceSegment(asset="b.wav"))))
    assert audio.translate(AudioCommand(command="stop_all")) == [{"type": "stop_music"}, {"type": "stop_ambience"}]
    clock.now += 5
    assert audio.due_packets() == []


def test_network_user_sends_translated_sound_and_releases_delayed_parts(tmp_path):
    user = NetworkUser("alice", "en", connection=None)
    user._legacy_audio = LegacyAudioTranslator(SoundPack(tmp_path), clock=Clock())
    user.play_sound("game_pig/roll.ogg")
    user.play_music("theme.ogg")
    packets = user.get_queued_messages()
    assert [packet["type"] for packet in packets] == ["play_sound", "play_music"]
    assert user._current_music == {"name": "theme.ogg", "looping": True}

    clock = user._legacy_audio.clock
    user.play_sound_chain([AudioSequenceSegment(asset="a.wav"), AudioSequenceSegment(asset="b.wav")])
    assert [packet["name"] for packet in user.get_queued_messages()] == ["a.wav"]
    clock.now += 1
    assert [packet["name"] for packet in user.get_queued_messages()] == ["b.wav"]


def test_a_missing_engine_sound_plays_what_our_clients_played_before(tmp_path):
    write_wav(tmp_path / "game_pig" / "turn.ogg", 100)
    write_wav(tmp_path / "game_pig" / "roll.ogg", 100)
    write_wav(tmp_path / "join.ogg", 100)
    audio, _ = translator(tmp_path)
    assert audio.translate(AudioCommand(command="play", kind="sfx", asset="turn.ogg"))[0]["name"] == "game_pig/turn.ogg"
    assert audio.translate(AudioCommand(command="play", kind="sfx", asset="table_join.ogg"))[0]["name"] == "join.ogg"
    assert audio.translate(AudioCommand(command="play", kind="sfx", family="game_dice/dieThrow"))[0]["name"] == "game_pig/roll.ogg"


def test_the_real_file_wins_once_our_pack_has_it(tmp_path):
    write_wav(tmp_path / "game_pig" / "turn.ogg", 100)
    write_wav(tmp_path / "turn.ogg", 100)
    audio, _ = translator(tmp_path)
    assert audio.translate(AudioCommand(command="play", kind="sfx", asset="turn.ogg"))[0]["name"] == "turn.ogg"


def test_numbered_dice_throws_fall_back_to_our_roll_sound(tmp_path):
    write_wav(tmp_path / "game_pig" / "roll.ogg", 100)
    audio, _ = translator(tmp_path)
    for number in (1, 2, 3):
        assert audio.translate(AudioCommand(command="play", kind="sfx", asset=f"game_dice/dieThrow{number}.ogg"))[0]["name"] == "game_pig/roll.ogg"


def test_a_replayed_ambience_skips_its_intro(tmp_path):
    """After a reconnect the engine replays ambience with play_intro off; the intro mustn't play again."""
    audio, _ = translator(tmp_path)
    packets = audio.translate(
        AudioCommand(command="play", kind="ambience", asset="loop.ogg", intro="in.ogg", outro="out.ogg", handle="amb", play_intro=False)
    )
    assert packets == [{"type": "play_ambience", "intro": "", "loop": "loop.ogg", "outro": "out.ogg"}]


def test_ambience_layers_share_our_single_slot(tmp_path):
    audio, _ = translator(tmp_path)
    audio.translate(AudioCommand(command="play", kind="ambience", asset="crowd.ogg", handle="crowd", layer="crowd"))
    audio.translate(AudioCommand(command="play", kind="ambience", asset="bar.ogg", handle="bar", layer="bar"))
    # Stopping a layer the client isn't playing changes nothing it hears.
    assert audio.translate(AudioCommand(command="stop", kind="ambience", layer="crowd")) == []
    audio.translate(AudioCommand(command="play", kind="ambience", asset="fan.ogg", handle="fan", layer="fan"))
    # Stopping the audible layer, here by handle, falls back to the newest one left, without its intro.
    assert audio.translate(AudioCommand(command="stop", kind="ambience", handle="fan")) == [
        {"type": "play_ambience", "intro": "", "loop": "bar.ogg", "outro": ""}
    ]
    assert audio.translate(AudioCommand(command="stop", kind="ambience", layer="bar")) == [{"type": "stop_ambience"}]


def test_stopping_every_ambience_layer(tmp_path):
    audio, _ = translator(tmp_path)
    audio.translate(AudioCommand(command="play", kind="ambience", asset="a.ogg", handle="a", layer="a"))
    audio.translate(AudioCommand(command="play", kind="ambience", asset="b.ogg", handle="b", layer="b"))
    assert audio.translate(AudioCommand(command="stop", kind="ambience", all_layers=True)) == [{"type": "stop_ambience"}]
