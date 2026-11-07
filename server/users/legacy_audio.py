"""Turn PlayAural audio commands into the sound packets this server's clients understand.

The game engine speaks PlayAural's audio protocol: one command per sound with
handles, numbered families, multi-part sequences, positions and buses. Our
iOS app, our desktop and web clients and stock PlayPalace clients only know
four packets: play_sound (name, volume, pan, pitch), play_music, stop_music,
play_ambience and stop_ambience. This module maps one onto the other as
faithfully as those packets allow:

- A position becomes stereo pan (the engine already derives it), and distance
  falloff and source gain scale the volume.
- A family plays one randomly chosen numbered file from our sound pack, the
  same rule PlayAural's clients use.
- A sequence plays each part in turn, spaced by the real length of our own
  sound files, because these clients can't schedule a chain themselves.
- Music pause and resume stop the track and start it again from the top.
- Things the packets can't express (stopping one sound effect, looping a
  sound effect, buses, ducking, motion) are skipped. A looping effect plays
  once.
"""

from __future__ import annotations

import random
import re
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import Any, Callable

from ..audio import AudioCommand, distance_attenuation_gain, pan_from_position
from ..game_utils.audio_duration import measure_audio_duration_ticks

# Where our clients' sound pack lives, both in the repository and in the
# server container (/app/clients/desktop/sounds next to /app/server).
DEFAULT_SOUNDS_DIR = Path(__file__).resolve().parents[2] / "clients" / "desktop" / "sounds"

# Used to space a sequence when a part's length can't be measured, for
# example a sound our pack doesn't have yet.
UNKNOWN_SEGMENT_MS = 600

MILLISECONDS_PER_SECOND = 1000

# Sounds PlayAural's engine asks for under names our pack doesn't have yet,
# mapped to the sound our clients played for the same moment before the
# switch. An alias only applies while the requested file is missing, so
# adding the real file to the pack takes over without a code change.
SOUND_ALIASES = {
    "turn.ogg": "game_pig/turn.ogg",
    "table_join.ogg": "join.ogg",
    "table_leave.ogg": "leave.ogg",
    "table_kick.ogg": "leave.ogg",
    "disconnect.ogg": "leave.ogg",
    "reconnect.ogg": "join.ogg",
}
FAMILY_ALIASES = {
    "game_dice/dieThrow": "game_pig/roll.ogg",
}
# The dice helper picks game_dice/dieThrow1.ogg, 2 or 3 itself rather than
# asking for the family, so the numbered files need the same fallback.
for _number in range(1, 10):
    SOUND_ALIASES[f"game_dice/dieThrow{_number}.ogg"] = "game_pig/roll.ogg"


@dataclass
class ScheduledPacket:
    """A packet waiting for its time, tagged with the sequence it belongs to."""

    due: float
    packet: dict[str, Any]
    handle: str = ""


@dataclass
class LegacyAudioState:
    """Per-user translation state: delayed sequence parts, the music to resume and the ambience layers."""

    scheduled: list[ScheduledPacket] = field(default_factory=list)
    paused_music: dict[str, Any] | None = None
    current_music: dict[str, Any] | None = None
    # Ambience layers the game has running, oldest first, keyed by the
    # engine's scope:context:layer target, and the one the client plays.
    ambience_layers: dict[str, dict[str, str]] = field(default_factory=dict)
    audible_ambience: str | None = None


class SoundPack:
    """Answers questions about the sound files our clients ship."""

    def __init__(self, root: Path = DEFAULT_SOUNDS_DIR) -> None:
        self.root = root

    def family_members(self, family: str) -> tuple[str, ...]:
        """Return the numbered files of a family, in number order."""
        return _family_members(str(self.root), family)

    def has(self, asset: str) -> bool:
        """Whether our pack has this file."""
        return _pack_has(str(self.root), asset)

    def duration_ms(self, asset: str) -> int | None:
        """Return a sound's length in milliseconds, or None if we can't tell."""
        if not asset or ".." in Path(asset).parts:
            return None
        return measure_audio_duration_ticks(
            self.root / asset,
            ticks_per_second=MILLISECONDS_PER_SECOND,
        )


@lru_cache(maxsize=2048)
def _pack_has(root: str, asset: str) -> bool:
    """Whether a file exists in the pack; cached because packs only change on deploy."""
    if not asset or ".." in Path(asset).parts:
        return False
    return (Path(root) / asset).is_file()


@lru_cache(maxsize=512)
def _family_members(root: str, family: str) -> tuple[str, ...]:
    """Scan one directory of the sound pack for a family's numbered files."""
    directory, _, stem = family.rpartition("/")
    folder = Path(root) / directory if directory else Path(root)
    pattern = re.compile(rf"^{re.escape(stem)}([1-9][0-9]*)\.(ogg|wav|mp3)$", re.IGNORECASE)
    try:
        names = [entry.name for entry in folder.iterdir() if entry.is_file()]
    except OSError:
        return ()
    numbered = []
    for name in names:
        match = pattern.fullmatch(name)
        if match:
            numbered.append((int(match.group(1)), name))
    prefix = f"{directory}/" if directory else ""
    return tuple(prefix + name for _, name in sorted(numbered))


def _volume(command: AudioCommand, gain: float, position: Any, attenuation: Any) -> int:
    """Fold source gain and distance falloff into the 0-100 packet volume."""
    falloff = 1.0
    if position is not None and attenuation is not None:
        falloff = distance_attenuation_gain(position, attenuation)
    scaled = command.volume * gain * falloff
    return max(0, min(100, round(scaled)))


def _sound_packet(name: str, volume: int, pan: int, pitch: int) -> dict[str, Any]:
    return {"type": "play_sound", "name": name, "volume": volume, "pan": pan, "pitch": pitch}


class LegacyAudioTranslator:
    """Translates audio commands for one user and holds back delayed sequence parts."""

    def __init__(self, sound_pack: SoundPack | None = None, clock: Callable[[], float] | None = None) -> None:
        import time

        self.sound_pack = sound_pack or SoundPack()
        self.clock = clock or time.monotonic
        self.state = LegacyAudioState()

    # The engine's commands, one handler each.

    def translate(self, command: AudioCommand) -> list[dict[str, Any]]:
        """Return the packets to send now; sequence parts after the first are scheduled."""
        handler = getattr(self, f"_on_{command.command}", None)
        if handler is None:
            return []
        return handler(command)

    def _on_play(self, command: AudioCommand) -> list[dict[str, Any]]:
        if command.kind == "music":
            return self._play_music(command)
        if command.kind == "ambience":
            return self._play_ambience(command)
        if command.segments:
            return self._play_sequence(command)
        if command.family:
            members = self.sound_pack.family_members(command.family)
            if members:
                name = random.choice(members)
            else:
                name = FAMILY_ALIASES.get(command.family, f"{command.family}1.ogg")
        else:
            name = self._available(command.asset)
        volume = _volume(command, command.gain, command.position, command.attenuation)
        return [_sound_packet(name, volume, command.pan, command.pitch)]

    def _play_music(self, command: AudioCommand) -> list[dict[str, Any]]:
        packet = {"type": "play_music", "name": command.asset, "looping": command.loop}
        self.state.current_music = packet
        self.state.paused_music = None
        return [packet]

    def _play_sequence(self, command: AudioCommand) -> list[dict[str, Any]]:
        """Play the first part now and schedule the rest by measured length."""
        now = self.clock()
        offset_ms = 0.0
        speed = command.pitch / 100.0
        immediate: list[dict[str, Any]] = []
        for segment in command.segments:
            pan = pan_from_position(segment.position) if segment.position is not None else command.pan
            volume = _volume(command, segment.gain, segment.position, segment.attenuation)
            packet = _sound_packet(segment.asset, volume, pan, command.pitch)
            if offset_ms <= 0:
                immediate.append(packet)
            else:
                self.state.scheduled.append(
                    ScheduledPacket(due=now + offset_ms / MILLISECONDS_PER_SECOND, packet=packet, handle=command.handle)
                )
            length = self.sound_pack.duration_ms(segment.asset) or UNKNOWN_SEGMENT_MS
            offset_ms += (length / speed) * segment.next_start_ratio
        return immediate

    def _on_stop(self, command: AudioCommand) -> list[dict[str, Any]]:
        if command.kind == "music":
            self.state.current_music = None
            self.state.paused_music = None
            return [{"type": "stop_music"}]
        if command.kind == "ambience":
            return self._stop_ambience(command)
        # A sound effect that's already playing can't be stopped on these
        # clients, but the unplayed parts of a sequence can be dropped.
        self._cancel_scheduled(command.handle)
        return []

    def _on_stop_all(self, command: AudioCommand) -> list[dict[str, Any]]:
        self.state.scheduled.clear()
        self.state.current_music = None
        self.state.paused_music = None
        self.state.ambience_layers.clear()
        self.state.audible_ambience = None
        return [{"type": "stop_music"}, {"type": "stop_ambience"}]

    # Ambience. Games may run several layers at once (a crowd, a bar, a fan);
    # these clients have one ambience slot, so the newest running layer is the
    # one heard, and stopping it falls back to the next newest.

    def _play_ambience(self, command: AudioCommand) -> list[dict[str, Any]]:
        layer = {
            # A replay after a reconnect or restore asks for no intro.
            "intro": (command.intro or "") if command.play_intro else "",
            "loop": command.asset,
            "outro": command.outro or "",
        }
        self.state.ambience_layers.pop(command.target, None)
        self.state.ambience_layers[command.target] = {**layer, "handle": command.handle}
        self.state.audible_ambience = command.target
        return [{"type": "play_ambience", **layer}]

    def _stop_ambience(self, command: AudioCommand) -> list[dict[str, Any]]:
        if command.all_layers:
            self.state.ambience_layers.clear()
        else:
            # A stop names its layer by handle, or by scope, context and layer.
            target = command.target
            if command.handle:
                target = next(
                    (key for key, layer in self.state.ambience_layers.items() if layer["handle"] == command.handle),
                    target,
                )
            self.state.ambience_layers.pop(target, None)
            if target != self.state.audible_ambience:
                # A layer the client wasn't playing; nothing changes for it.
                return []
        if not self.state.ambience_layers:
            self.state.audible_ambience = None
            return [{"type": "stop_ambience"}]
        fallback_target, fallback = next(reversed(self.state.ambience_layers.items()))
        self.state.audible_ambience = fallback_target
        return [{"type": "play_ambience", "intro": "", "loop": fallback["loop"], "outro": fallback["outro"]}]

    def _on_pause(self, command: AudioCommand) -> list[dict[str, Any]]:
        if self.state.current_music is None:
            return []
        self.state.paused_music = self.state.current_music
        self.state.current_music = None
        return [{"type": "stop_music"}]

    def _on_resume(self, command: AudioCommand) -> list[dict[str, Any]]:
        if self.state.paused_music is None:
            return []
        packet = self.state.paused_music
        self.state.current_music = packet
        self.state.paused_music = None
        return [packet]

    def _available(self, asset: str) -> str:
        """The asset itself, or what we played for that moment before, if our pack lacks it."""
        alias = SOUND_ALIASES.get(asset)
        if alias and not self.sound_pack.has(asset) and self.sound_pack.has(alias):
            return alias
        return asset

    # Delayed parts of sequences.

    def _cancel_scheduled(self, handle: str) -> None:
        if not handle:
            return
        self.state.scheduled = [item for item in self.state.scheduled if item.handle != handle]

    def due_packets(self) -> list[dict[str, Any]]:
        """Release scheduled packets whose time has come, oldest first."""
        if not self.state.scheduled:
            return []
        now = self.clock()
        ready = [item for item in self.state.scheduled if item.due <= now]
        if not ready:
            return []
        self.state.scheduled = [item for item in self.state.scheduled if item.due > now]
        ready.sort(key=lambda item: item.due)
        return [item.packet for item in ready]
