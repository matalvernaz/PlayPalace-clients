# Syncing with PlayAural

This server runs PlayAural's game engine and games (github.com/Daoductrung/PlayAural,
GPL-3.0-or-later) inside its own core, which keeps this server's protocol, accounts,
clients and voice chat. Nothing from PlayAural goes into `clients/`.

Last synced: PlayAural `afde6699cfc0338ba89fb05cf00c2e7301bada29` (2026-10-23).

Held back: Breach Point, until our clients play positional 3D audio. Last Outpost isn't
in PlayAural's public repository.

## How to sync

1. Update a local clone of PlayAural and pick the commit.
2. `uv run python tools/import_playaural.py /path/to/PlayAural <commit>` copies the
   engine, the games, their tests and the rules manuals. It keeps the files listed in
   its `KEPT_LOCAL` and our own games.
3. `uv run python tools/merge_playaural_locales.py /path/to/PlayAural <commit>` merges
   translations message by message. Messages only our core uses keep our wording.
4. Add any new PlayAural game to `games/__init__.py`.
5. Run the full suite and the bot games for every game. Tests that don't apply here, or
   that wait on our sound pack, are listed with reasons in `tests/playpalace_test_policy.py`.
6. New games usually need sounds our pack doesn't have; PlayAural's sound files carry no
   license, so ours come from elsewhere (see `clients/desktop/sounds/THIRD_PARTY_AUDIO.md`).
7. Update the commit above.

## Where the two meet

- `users/network_user.py` and `users/legacy_audio.py`: the engine's user API spoken in
  this server's protocol (sound commands become play_sound, play_music and ambience
  packets; speech buffers are renamed to the ones our clients keep).
- `core/client_menu_extras.py`: the iOS app's rules text and primary action.
- `core/tables/table.py`: what the engine expects from a table.
- `persistence/game_format.py`: the marker that keeps games saved by an older engine from
  being restored half-right.
- `users/preferences.py` and `users/trust_level.py`: our settings and account roles.
