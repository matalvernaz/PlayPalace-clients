"""Merge PlayAural's translation files into ours, message by message, without losing our own.

PlayAural ships seven languages for its games and engine; this server ships
thirty languages and has its own core messages (login, menus, documents,
voice) that PlayAural doesn't. The rules, applied per language and per file:

- Every message PlayAural defines in English is "theirs". Its text comes from
  PlayAural's translation in that language when they have one. Otherwise our
  existing translation is kept, but only if it uses no variable PlayAural's
  English doesn't pass, since the game code now supplies PlayAural's
  variables. Anything else is left out and falls back to English at runtime.
- Every message only we define is "ours" and is kept as it is. So is any
  message only our own core code names (login, menus, voice chat, accounts),
  even if PlayAural defines one with the same id: our wording describes what
  this server does, and PlayAural's says "PlayAural" or describes features we
  don't have. A message the game engine also uses stays PlayAural's.
- Files only we have (our own games) are kept as they are. In a file that
  belongs to one of PlayAural's games, a message only we define is a
  leftover from our old version of that game and is dropped; our extra
  messages are kept only in the shared core files (OUR_SHARED_FILES).
- A message that both sides define with different variables is a conflict;
  PlayAural's version wins because the engine passes its variables, and the
  conflict is listed so someone can check our core doesn't use that id.
- Each language keeps every file English has, so the locale parity test
  passes; a file with nothing translated holds just a header comment.

Usage:
    uv run python tools/merge_playaural_locales.py /path/to/PlayAural <commit> [--dry-run]
"""

from __future__ import annotations

import argparse
import io
import re
import subprocess
import sys
import tarfile
from dataclasses import dataclass, field
from pathlib import Path

from fluent.syntax import FluentParser, FluentSerializer, ast as fluent_ast
from fluent.syntax.visitor import Visitor

SERVER_DIR = Path(__file__).resolve().parent.parent
LOCALES_DIR = SERVER_DIR / "locales"
SOURCE_LOCALE = "en"

# PlayAural files we don't take: games held back here, and PlayAural's own
# help-desk feature, which this server doesn't have.
SKIPPED_FILES = {"breachpoint.ftl", "lastoutpost.ftl", "support.ftl"}

# Code that belongs to this server rather than to PlayAural's engine. Any
# message id named in it keeps our wording.
CORE_CODE = ("core", "auth", "voice", "persistence", "users/network_user.py", "users/virtual_user.py", "cli.py", "main.py")
# PlayAural's engine and games. A message id named here is the engine's.
ENGINE_CODE = ("games", "game_utils", "ui", "users/base.py", "users/bot.py", "users/test_user.py", "audio.py", "documentation")
MESSAGE_ID_PATTERN = re.compile(r"[\"']([a-z][a-z0-9]*(?:-[a-z0-9]+)+)[\"']")

# Files where our own extra messages live alongside PlayAural's: core UI
# text, game names (our own games' names too) and language names.
OUR_SHARED_FILES = {"main.ftl", "games.ftl", "languages.ftl"}

PARSER = FluentParser(with_spans=False)
SERIALIZER = FluentSerializer(with_junk=False)


class _ReferenceCollector(Visitor):
    """Collects the variables and other messages one message refers to."""

    def __init__(self) -> None:
        super().__init__()
        self.variables: set[str] = set()
        self.messages: set[str] = set()

    def visit_VariableReference(self, node: fluent_ast.VariableReference) -> None:
        self.variables.add(node.id.name)
        self.generic_visit(node)

    def visit_MessageReference(self, node: fluent_ast.MessageReference) -> None:
        self.messages.add(node.id.name)
        self.generic_visit(node)


@dataclass
class Entry:
    """One parsed message with the names it depends on."""

    node: fluent_ast.Message
    variables: frozenset[str]
    references: frozenset[str]


@dataclass
class MergeReport:
    """What the merge did, for the summary and for review."""

    conflicts: list[tuple[str, str, str, list[str], list[str]]] = field(default_factory=list)
    kept_ours: int = 0
    dropped_ours: int = 0
    taken_theirs: int = 0


def _message_ids_named_in(paths: tuple[str, ...]) -> set[str]:
    """Collect every string literal shaped like a message id in the given code."""
    ids: set[str] = set()
    for relative in paths:
        path = SERVER_DIR / relative
        files = [path] if path.is_file() else sorted(path.rglob("*.py"))
        for code_file in files:
            ids.update(MESSAGE_ID_PATTERN.findall(code_file.read_text(encoding="utf-8")))
    return ids


def core_message_ids() -> set[str]:
    """Message ids only our own core code names; the engine doesn't use them."""
    return _message_ids_named_in(CORE_CODE) - _message_ids_named_in(ENGINE_CODE)


def parse_entries(text: str) -> dict[str, Entry]:
    """Parse a Fluent file into its messages, keyed by id, in file order."""
    entries: dict[str, Entry] = {}
    for node in PARSER.parse(text).body:
        if not isinstance(node, fluent_ast.Message):
            continue
        collector = _ReferenceCollector()
        collector.visit(node)
        entries[node.id.name] = Entry(node, frozenset(collector.variables), frozenset(collector.messages))
    return entries


def read_playaural_locales(clone: Path, commit: str) -> dict[str, dict[str, str]]:
    """Return PlayAural's locale files at the commit as {locale: {file name: text}}."""
    archive = subprocess.run(
        ["git", "-C", str(clone), "archive", "--format=tar", commit, "server/locales"],
        check=True,
        capture_output=True,
    ).stdout
    files: dict[str, dict[str, str]] = {}
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        for member in tar.getmembers():
            parts = Path(member.name).parts
            if len(parts) != 4 or not member.isfile() or not parts[3].endswith(".ftl"):
                continue
            locale, name = parts[2], parts[3]
            if name in SKIPPED_FILES:
                continue
            content = tar.extractfile(member).read().decode("utf-8")
            files.setdefault(locale, {})[name] = content
    return files


def read_our_locales() -> dict[str, dict[str, str]]:
    """Return our current locale files as {locale: {file name: text}}."""
    files: dict[str, dict[str, str]] = {}
    for locale_dir in sorted(LOCALES_DIR.iterdir()):
        if not locale_dir.is_dir():
            continue
        for path in sorted(locale_dir.glob("*.ftl")):
            files.setdefault(locale_dir.name, {})[path.name] = path.read_text(encoding="utf-8")
    return files


def header(locale: str, name: str) -> str:
    """Comment that opens every merged file, so no file is ever empty."""
    return (
        f"# {name} for locale {locale}. Messages missing here are spoken in English.\n"
        "# Merged from PlayAural and this server by tools/merge_playaural_locales.py.\n\n"
    )


def serialize(locale: str, name: str, entries: list[fluent_ast.Message]) -> str:
    """Write the chosen messages back out as one Fluent file."""
    resource = fluent_ast.Resource(body=entries)
    return header(locale, name) + SERIALIZER.serialize(resource)


def merge(
    theirs: dict[str, dict[str, str]],
    ours: dict[str, dict[str, str]],
    core_ids: set[str] = frozenset(),
) -> tuple[dict[str, dict[str, str]], MergeReport]:
    """Merge both sides' files; returns the new {locale: {name: text}} and a report."""
    report = MergeReport()
    their_source = {name: parse_entries(text) for name, text in theirs.get(SOURCE_LOCALE, {}).items()}
    our_source = {name: parse_entries(text) for name, text in ours.get(SOURCE_LOCALE, {}).items()}
    our_ids = {message_id for entries in our_source.values() for message_id in entries}

    # Our core's messages stay ours: take them out of PlayAural's files.
    kept_for_core = core_ids & our_ids
    for entries in their_source.values():
        for message_id in kept_for_core & set(entries):
            del entries[message_id]

    # Which message ids PlayAural owns, and in which file.
    their_ids: dict[str, str] = {}
    for name, entries in their_source.items():
        for message_id in entries:
            their_ids[message_id] = name

    # Conflicts: both sides define an id with different variables.
    for name, entries in our_source.items():
        for message_id, entry in entries.items():
            their_file = their_ids.get(message_id)
            if their_file is None:
                continue
            their_entry = their_source[their_file][message_id]
            if their_entry.variables != entry.variables:
                report.conflicts.append(
                    (message_id, name, their_file, sorted(entry.variables), sorted(their_entry.variables))
                )

    all_names = sorted(set(their_source) | set(our_source))
    all_locales = sorted(set(theirs) | set(ours))
    merged: dict[str, dict[str, str]] = {}
    for locale in all_locales:
        their_files = {name: parse_entries(text) for name, text in theirs.get(locale, {}).items()}
        our_files = {name: parse_entries(text) for name, text in ours.get(locale, {}).items()}
        chosen: dict[str, dict[str, Entry]] = {}

        for name in all_names:
            selected: dict[str, Entry] = {}
            # Their messages, in their English order.
            for message_id, source_entry in their_source.get(name, {}).items():
                if locale == SOURCE_LOCALE:
                    selected[message_id] = source_entry
                    report.taken_theirs += 1
                    continue
                their_translation = their_files.get(name, {}).get(message_id)
                if their_translation is not None:
                    selected[message_id] = their_translation
                    report.taken_theirs += 1
                    continue
                our_translation = _find_our_translation(our_files, message_id)
                if our_translation is not None and our_translation.variables <= source_entry.variables:
                    selected[message_id] = our_translation
                    report.kept_ours += 1
                elif our_translation is not None:
                    report.dropped_ours += 1
            # Our own messages, in our English order. In a file of one of
            # PlayAural's games they're leftovers from our old version.
            if name in their_source and name not in OUR_SHARED_FILES:
                chosen[name] = selected
                continue
            for message_id, source_entry in our_source.get(name, {}).items():
                if message_id in their_ids:
                    continue
                if locale == SOURCE_LOCALE:
                    selected[message_id] = source_entry
                    continue
                our_translation = our_files.get(name, {}).get(message_id)
                if our_translation is not None:
                    selected[message_id] = our_translation
            chosen[name] = selected

        _drop_dangling_references(chosen)
        merged[locale] = {
            name: serialize(locale, name, [entry.node for entry in entries.values()])
            for name, entries in chosen.items()
        }
    return merged, report


def _find_our_translation(our_files: dict[str, dict[str, Entry]], message_id: str) -> Entry | None:
    """Find our translation of a message, whichever of our files it lived in."""
    for entries in our_files.values():
        entry = entries.get(message_id)
        if entry is not None:
            return entry
    return None


def _drop_dangling_references(chosen: dict[str, dict[str, Entry]]) -> None:
    """Remove messages that refer to a message this language no longer has, until none do."""
    while True:
        present = {message_id for entries in chosen.values() for message_id in entries}
        removed = False
        for entries in chosen.values():
            for message_id in list(entries):
                if not entries[message_id].references <= present:
                    del entries[message_id]
                    removed = True
        if not removed:
            return


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("clone", type=Path, help="local clone of PlayAural")
    parser.add_argument("commit", help="PlayAural commit to merge from")
    parser.add_argument("--dry-run", action="store_true", help="report without writing files")
    arguments = parser.parse_args()

    theirs = read_playaural_locales(arguments.clone, arguments.commit)
    ours = read_our_locales()
    merged, report = merge(theirs, ours, core_message_ids())

    print(f"Languages: {len(merged)}; messages taken from PlayAural: {report.taken_theirs}; "
          f"our translations kept: {report.kept_ours}; dropped for changed variables: {report.dropped_ours}.")
    if report.conflicts:
        print(f"{len(report.conflicts)} ids defined by both sides with different variables (PlayAural's kept):")
        for message_id, our_file, their_file, our_vars, their_vars in report.conflicts:
            print(f"  {message_id}: ours {our_file} {our_vars} / theirs {their_file} {their_vars}")
    if arguments.dry_run:
        return 0

    for locale, files in merged.items():
        locale_dir = LOCALES_DIR / locale
        locale_dir.mkdir(parents=True, exist_ok=True)
        for name, text in files.items():
            (locale_dir / name).write_text(text, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
