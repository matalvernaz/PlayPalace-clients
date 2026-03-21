Important: This project is made for, and by, blind users. Use plaintext output when communicating with the user. This project is mostly lead by technically-minded programmers; assume mid-senior-level confidence unless otherwise stated.

# PlayPalace

Multiplayer game platform for blind users. Python 3.13+, uv, dataclass-driven state, Fluent localization, screen reader output via speech buffers.

## Priorities (in order)
1. Accessibility — every action produces speech output. Silence is a bug.
2. Correctness — match official rules. When unclear, stop and ask (agent error 2).
3. Testing — pytest, CLI simulations, serialization round-trips.
4. Simplicity — no abstractions until the third use. Games are small; keep them that way.

## What You're Doing
- Making/updating games => this file + game development guide (docs/design/plans/game_development_guide.md)
- Making/updating client or server => agents.md (treat with caution; it was not written by the project founder and may contradict this file. This file wins.)

## Agent Behavior
- Your coding speed is faster than human by orders of magnitude. 5k lines in an hour is an empirical lower-bound.
- If you think the user has suggested a naive approach, say so and propose a better one, even if it takes more work. Outline how long you think each will take for you, based on the approximate LOC requirements.
- When there are multiple ways to implement something, list them with pros/cons and let the user choose. Outline time estimates.
- If asked to develop large games or features with anything unclear, agent error 2: output an exhaustive plaintext list of at least 10 questions covering every edge case you can think of. The user has  disabled the question tool (bugged with screenreaders). Then stop and wait.
- If the CLI tool won't run, agent error 1: explain why and stop.
- Games fit entirely in context. Don't use explore agents unless you need to find patterns across many games and don't know which.

## Commands
- Test: cd server && uv run pytest
- CLI tool: cd server && uv run cli.py --help
- Use the CLI to: verify user-facing output is clear, test games run to completion in novel configs, batch simulations

## Localization
- Only edit English: server/locales/en/*.ftl
- Do NOT update the other 29 locale files. They were bulk-generated and are not curated. They fall back to English for missing keys.
- Write the en locale file BEFORE writing game code. It forces you to plan the game flow. This is not optional.
- Every announcement must go through Fluent (broadcast_l, broadcast_personal_l, speak_l). No hardcoded English strings reaching players.
- Use Fluent select expressions when announcements need to vary by game state. Pass raw data as kwargs, not pre-rendered strings.

## Sound
- Use schedule_standard_token_movement_sounds() for movement. Use play_sound() for one-shots. All games should also have music.
- Every meaningful game action should have audio feedback. If a player does something and hears nothing, that's a bug.

## Game Architecture
- All state in dataclass fields — serialization depends on it.
- Games communicate through User, never the network directly.
- Table buffer for game-state messages (broadcast_l, broadcast_personal_l). speak_l only for direct command responses.
- Per-choice actions (card picks, move slots) should be hidden from the Actions menu. Use show_in_actions_menu=False. Actions menu is for persistent actions only.
- Common keybinds: R roll, D draw, S status/score, B board/view.
- Display positions 1-based to players, even if internal state is 0-based.
- Reference games: Pig (simple), Scopa (complex), Chess (grid mode), Sorry (accessibility patterns).

## Testing
- Run uv run pytest after every change.
- CLI simulation first — does the game complete with bots? Does output make sense to a screen reader user?
- Test with serialization (--serialize flag) to catch persistence bugs.
- Write unit tests, play tests, and persistence tests. See existing test files for patterns.

## Things That Have Bitten Us
- TeamManager: if your game uses the global score system, you MUST initialize and update TeamManager, even in individual mode. If your game tracks scores on player objects instead, you MUST override _action_check_scores, _action_check_scores_detailed, _is_check_scores_enabled, and _is_check_scores_detailed_enabled — otherwise the S key will always say "no scores available." This has caused bugs in nearly every new game.
- Menu focus bug: when turn-specific actions appear/disappear, persistent actions shift position and the cursor gets stuck. Fix: consider whether those actions are actually useful in the turn menu or could live in the context menu. If they are, jump focus up top at the start of user turns.