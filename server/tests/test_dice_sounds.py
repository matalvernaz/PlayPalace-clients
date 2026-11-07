"""Tests for shared dice sound selection."""

from pathlib import Path

import pytest

from ..game_utils.dice import DICE_THROW_SOUNDS, random_dice_throw_sound


ROOT = Path(__file__).resolve().parents[2]
EXPECTED_DICE_THROW_SOUNDS = (
    "game_dice/dieThrow1.ogg",
    "game_dice/dieThrow2.ogg",
    "game_dice/dieThrow3.ogg",
)
EXPECTED_DICE_ASSETS = {
    "dieGrab1.ogg",
    "dieGrab2.ogg",
    "dieShuffle1.ogg",
    "dieShuffle2.ogg",
    "dieShuffle3.ogg",
    "dieThrow1.ogg",
    "dieThrow2.ogg",
    "dieThrow3.ogg",
}


def test_shared_dice_throw_manifest_is_complete() -> None:
    assert DICE_THROW_SOUNDS == EXPECTED_DICE_THROW_SOUNDS


@pytest.mark.parametrize("expected", EXPECTED_DICE_THROW_SOUNDS)
def test_random_dice_throw_sound_can_select_each_variant(
    monkeypatch: pytest.MonkeyPatch,
    expected: str,
) -> None:
    monkeypatch.setattr(
        "server.game_utils.dice._SOUND_RANDOM.choice", lambda sounds: expected
    )

    assert random_dice_throw_sound() == expected


def test_shared_dice_assets_match_across_clients() -> None:
    reference_bytes: dict[str, bytes] = {}

    for pack in ("client", "web_client", "mobile_client"):
        shared_dir = ROOT / pack / "sounds" / "game_dice"
        assert {path.name for path in shared_dir.glob("*.ogg")} == EXPECTED_DICE_ASSETS
        assert not (ROOT / pack / "sounds" / "game_pig" / "roll.ogg").exists()

        for name in EXPECTED_DICE_ASSETS:
            data = (shared_dir / name).read_bytes()
            assert data.startswith(b"OggS"), f"invalid Ogg asset: {pack}/{name}"
            if name in reference_bytes:
                assert data == reference_bytes[name]
            else:
                reference_bytes[name] = data
