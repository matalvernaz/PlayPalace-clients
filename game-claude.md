# PlayPalace Monopoly Handoff (for Claude)

## Session Goal
Continue Monopoly special-board parity/hardware audio work without losing context.

## Current Git State
- Repo: `/home/alek/git/PlayPalace`
- Branch: `monopoly`
- Worktree: clean
- Latest commit: `cdff1f9` (`Seed universal card text, add cash override evidence, and fix merge import breakage`)

## Recent Commit Chain (newest first)
- `cdff1f9` Seed universal card text, add cash override evidence, and fix merge import breakage
- `8da4b3f` Merge branch 'main' into monopoly
- `4374591` Implement Mario Celebration Question Block deeper mechanic modeling
- `69636e3` Add document browsing UI (read-only) to main menu

## What Is Done
- All 55 special boards are `manual_core`.
- Hardware audio framework is in place with original/placeholder fallback.
- Legal-source stand-in assets are installed and documented.
- Deterministic Mario Celebration Question Block mechanic (4 outcomes, hardware events).
- Jurassic Park Electronic Gate mechanic (theme/roar pass-GO payout).
- Full card text coverage: all 10 cards per board (550 total) now have `text` fields.
  - Universal cards: advance_to_go, go_to_jail, get_out_of_jail_free (seeded earlier).
  - Non-universal cards: bank_dividend_50, go_back_three, poor_tax_15, bank_error_collect_200, doctor_fee_pay_50, income_tax_refund_20 (329 new text fields).
- Full `text_note` evidence coverage: every card across all boards has evidence annotations.
- Cash override evidence metadata on all 29 boards with `CARD_CASH_OVERRIDES`.
- OCR quality grades documented for all 5 OCR sidecar boards.
- Added/updated tests for registry, parity, hardware resolver, card text coverage, and wave audio behavior.

## Current Hardware Events
- `play_theme`
- `star_wars_theme`
- `junior_coin_sound_powerup`
- `mario_question_block_coin_ping`
- `mario_question_block_bowser`
- `mario_question_block_power_up`
- `mario_question_block_game_over`
- `jurassic_park_gate_theme`
- `jurassic_park_gate_roar`

## Key Files To Start From
- `server/games/monopoly/game.py`
- `server/games/monopoly/hardware_emulation.py`
- `server/games/monopoly/board_rules_registry.py`
- `server/games/monopoly/board_rules/mario_celebration.py`
- `server/tests/test_monopoly_card_text_coverage.py`
- `client/sounds/game_monopoly_hardware/README.md`
- `docs/plans/2026-02-26-monopoly-special-boards-final-part-status.md`
- `docs/plans/2026-02-28-monopoly-hardware-audio-legal-shortlist.md`

## Last Verification Results
- Card text coverage tests: `212 passed, 63 skipped`
- Extraction artifact tests: `3 passed`

## Resume Commands
- Card text coverage:
  - `cd server && nix shell nixpkgs#uv -c uv run --extra dev pytest tests/test_monopoly_card_text_coverage.py -q`
- Targeted hardware/audio:
  - `cd server && nix shell nixpkgs#uv -c uv run --extra dev pytest tests/test_monopoly_hardware_emulation.py tests/test_monopoly_wave_special_audio_star_wars.py tests/test_monopoly_wave_special_audio_junior.py tests/test_monopoly_wave_special_audio_mario_celebration.py -q`
- Full Monopoly:
  - `cd server && nix shell nixpkgs#uv -c uv run --extra dev pytest -k monopoly -q`

## Recommended Next Work
- Refine themed/localized card text where authentic source text is available (e.g., Portuguese `disney_princesses` edition).
- Continue option-2 expansion: add hardware event mappings only where manual text shows deterministic sound-unit behavior.
- Keep legal-source stand-ins for new events with provenance in `client/sounds/game_monopoly_hardware/README.md`.
- Update parity/status docs each time a new hardware capability/event is added.

## Important Constraints
- Pac-Man game-unit behavior remains intentionally out of scope.
- Use manual evidence before enabling board hardware/audio capability flags.
- Keep old behavior safe: non-hardware boards should not emit hardware events.
