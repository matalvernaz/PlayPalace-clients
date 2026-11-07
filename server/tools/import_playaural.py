"""Copy PlayAural's game engine and games into this server, so a sync with PlayAural is one repeatable command.

PlayAural (github.com/Daoductrung/PlayAural, GPL-3.0-or-later) publishes the
games and the game engine this server now runs on. Everything listed in
ENGINE_PATHS and every game directory is copied verbatim from a local clone
at the given commit. Files listed in KEPT_LOCAL stay ours because they carry
this server's own protocol, preferences and client support, and the games in
LOCAL_GAMES exist only here. Nothing from PlayAural may be copied into
clients/, which is MIT and ships through the App Store.

Usage:
    uv run python tools/import_playaural.py /path/to/PlayAural <commit>

Afterwards: review the diff, run the full test suite and the bot games, and
update PLAYAURAL_SYNC.md with the commit.
"""

from __future__ import annotations

import argparse
import io
import re
import shutil
import subprocess
import sys
import tarfile
from pathlib import Path

SERVER_DIR = Path(__file__).resolve().parent.parent

# Engine modules and packages taken from PlayAural as they are.
ENGINE_PATHS = (
    "documentation",
    "game_utils",
    "messages",
    "ui",
    "users",
    "audio.py",
    "chat_channels.py",
    "copy_protocol.py",
    "gender.py",
    "games/base.py",
    "games/categories.py",
    "games/registry.py",
)

# Paths inside the copied engine that stay ours. Our network user speaks this
# server's protocol, and our preferences drive the options menu every client
# reads, so PlayAural's versions of those are never copied over them.
KEPT_LOCAL = (
    "users/network_user.py",
    "users/virtual_user.py",
    "users/preferences.py",
    "users/__init__.py",
    "users/trust_level.py",
    "users/legacy_audio.py",
    "documentation/content/en/games/lastcard.md",
    "documentation/content/en/games/liarsdice.md",
    "documentation/content/en/games/life.md",
    "documentation/content/en/games/mancala.md",
    "documentation/content/en/games/numberchain.md",
    "documentation/content/en/games/risk.md",
    "documentation/content/en/games/trouble.md",
)

# Game-layer helpers that only our own games use. PlayAural doesn't have
# them, so copying game_utils must not delete them.
LOCAL_GAME_UTILS = (
    "game_utils/game_status.py",
    "game_utils/parcheesi.py",
    "game_utils/round_based_game_mixin.py",
)

# Games that exist only on this server.
LOCAL_GAMES = (
    "lastcard",
    "liarsdice",
    "life",
    "mancala",
    "numberchain",
    "risk",
    "trouble",
)

# PlayAural games we hold back, with the reason.
HELD_BACK_GAMES = {
    "breachpoint": "needs positional 3D audio in our clients first",
}

# PlayAural tests that come along: everything that exercises the games and the
# engine. Tests of PlayAural's own server, tables, accounts and tooling are
# left out because this server keeps its own core; a test that imports from
# any of these packages is one of those.
PLAYAURAL_CORE_PACKAGES = ("core", "tables", "administration", "persistence", "auth", "network", "moderation", "voice", "chat_channels")
SKIPPED_TESTS = {
    "test_server_management_script.py": "tests PlayAural's Linux management script, which this repository doesn't have",
}


def read_playaural_tree(clone: Path, commit: str) -> tarfile.TarFile:
    """Return the server/ tree of the PlayAural clone at the commit, as an in-memory tar."""
    archive = subprocess.run(
        ["git", "-C", str(clone), "archive", "--format=tar", commit, "server"],
        check=True,
        capture_output=True,
    ).stdout
    return tarfile.open(fileobj=io.BytesIO(archive))


def extract_to(tree: tarfile.TarFile, destination: Path) -> Path:
    """Unpack the tar into destination and return the unpacked server directory."""
    tree.extractall(destination, filter="data")
    return destination / "server"


def save_local_files(paths: tuple[str, ...], holding: Path) -> None:
    """Copy files that must survive the import into a holding directory."""
    for relative in paths:
        source = SERVER_DIR / relative
        if not source.exists():
            continue
        target = holding / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def restore_local_files(paths: tuple[str, ...], holding: Path) -> None:
    """Put held files back after the import overwrote or deleted them."""
    for relative in paths:
        source = holding / relative
        if not source.exists():
            continue
        target = SERVER_DIR / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def replace_path(source_root: Path, relative: str) -> None:
    """Replace one file or directory of this server with PlayAural's copy."""
    source = source_root / relative
    target = SERVER_DIR / relative
    if not source.exists():
        raise SystemExit(f"PlayAural has no {relative}; check the commit and update ENGINE_PATHS.")
    if target.is_dir():
        shutil.rmtree(target)
    elif target.exists():
        target.unlink()
    if source.is_dir():
        shutil.copytree(source, target, ignore=shutil.ignore_patterns("__pycache__"))
    else:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)


def playaural_games(source_root: Path) -> list[str]:
    """List PlayAural's game directories, minus the ones held back."""
    games = []
    for entry in sorted((source_root / "games").iterdir()):
        if not entry.is_dir() or entry.name == "__pycache__":
            continue
        if entry.name in HELD_BACK_GAMES:
            continue
        games.append(entry.name)
    return games


def copy_tests(source_root: Path) -> list[str]:
    """Copy PlayAural's engine and game tests, their conftest and the audio test data."""
    core_import = re.compile(r"(from|import)\s+(\.\.|server\.)(" + "|".join(PLAYAURAL_CORE_PACKAGES) + r")\b")
    copied = []
    for test_file in sorted((source_root / "tests").glob("*.py")):
        name = test_file.name
        if name in SKIPPED_TESTS or any(game in name for game in HELD_BACK_GAMES) or "lastoutpost" in name:
            continue
        text = test_file.read_text(encoding="utf-8")
        if name != "conftest.py" and (name == "__init__.py" or core_import.search(text)):
            continue
        shutil.copy2(test_file, SERVER_DIR / "tests" / name)
        copied.append(name)
    return copied


def copy_conformance_data(clone: Path, commit: str) -> None:
    """PlayAural keeps its audio math test data at its repository root; ours lives with the tests."""
    data = subprocess.run(
        ["git", "-C", str(clone), "show", f"{commit}:audio_protocol_v3_conformance.json"],
        check=True,
        capture_output=True,
    ).stdout
    target = SERVER_DIR / "tests" / "data" / "audio_protocol_v3_conformance.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(data)


def drop_held_back_docs() -> None:
    """Remove manuals for games we hold back, in every language."""
    for game in HELD_BACK_GAMES:
        for manual in (SERVER_DIR / "documentation" / "content").glob(f"*/games/{game}.md"):
            manual.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("clone", type=Path, help="local clone of PlayAural")
    parser.add_argument("commit", help="PlayAural commit to import")
    arguments = parser.parse_args()

    # Work from a temporary copy of PlayAural's server tree at the commit.
    scratch = SERVER_DIR.parent / ".playaural-import"
    if scratch.exists():
        shutil.rmtree(scratch)
    scratch.mkdir()
    try:
        source_root = extract_to(read_playaural_tree(arguments.clone, arguments.commit), scratch)

        # Keep our own files safe while the engine directories are replaced.
        holding = scratch / "held"
        save_local_files(KEPT_LOCAL + LOCAL_GAME_UTILS, holding)

        for relative in ENGINE_PATHS:
            replace_path(source_root, relative)

        # Every PlayAural game replaces ours of the same name; our own games stay.
        games = playaural_games(source_root)
        for game in games:
            replace_path(source_root, f"games/{game}")

        restore_local_files(KEPT_LOCAL + LOCAL_GAME_UTILS, holding)
        drop_held_back_docs()
        tests = copy_tests(source_root)
        copy_conformance_data(arguments.clone, arguments.commit)

        # PlayAural's own network user would shadow ours; it never ships here.
        stray = SERVER_DIR / "users" / "network_user.py"
        if not (holding / "users" / "network_user.py").exists() and stray.exists():
            stray.unlink()

        print(f"Imported PlayAural {arguments.commit}: {len(ENGINE_PATHS)} engine paths, {len(games)} games, {len(tests)} test files.")
        for game, reason in HELD_BACK_GAMES.items():
            print(f"Held back {game}: {reason}.")
        print("games/__init__.py is ours: add any new PlayAural game to it by hand.")
        print("Next: tools/merge_playaural_locales.py, then the full test suite and the bot games.")
    finally:
        shutil.rmtree(scratch, ignore_errors=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
