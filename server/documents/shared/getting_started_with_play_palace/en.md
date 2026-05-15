# Getting Started with PlayPalace

Welcome to PlayPalace, an online game room designed to work well with VoiceOver and other screen readers. Everything in the client speaks itself; you can play with friends, on a public server, or against bots.

## First steps

1. Use **Server Manager** to add the server you want to connect to (host name or IP, plus port — usually 8000).
2. Back on the main screen, pick the server.
3. Either **Register New Account** to create an account, or use Server Manager to save the login for an account you already have.
4. Choose **Connect**.

## The main menu

Once you are connected, the main menu offers:

- **Play** — pick a game and either join an existing table or host a new one.
- **View active tables** — see who is hosting what right now.
- **Options** — preferences that follow you across devices, such as music and ambience volume.
- **Leaderboards** and **My Stats** — see your record by game.
- **Logout**.

## Tables and games

A *table* is a single seat-able room. The host picks the game, adjusts options (target score, team mode, deck count, and so on), invites players or adds bots, and starts the game. Anyone can spectate.

Most games support 2–4 players, with bots available to fill empty seats. Bots play to a configurable difficulty and are designed to feel like reasonable human opponents, not opaque opponents who always win.

## Speech, sounds, and music

Every game pushes spoken events as they happen: turn changes, dice rolls, draws, scoring, wins. Background music and ambience play while you're connected; mute either or both in **Options**.

Chat sits beneath game events — it never interrupts a game announcement. Local chat goes to people at your table; global chat goes everywhere.

## In-game controls (iOS client)

The iOS client uses the entire screen as the game area. Gestures, not on-screen buttons:

- **One finger** — menu navigation. Swipe left/right to browse, double-tap to select, single tap to repeat the current item, long press for a status read-out.
- **Two fingers** — game actions. Scrub to go back, double-tap for the primary action (roll/draw/play), swipe up to check the score, swipe down to add a bot.
- **Three fingers** — message history. Swipe left/right between buffers, up/down between messages, tap to open the help screen.

A **Menu** button in the top-right corner is always available regardless of how you have remapped your gestures. It opens Help, Controls, and Chat. You can also reach those actions through VoiceOver's Actions rotor.

## In-game controls (desktop / web)

Desktop and web clients use keybinds and a menu list:

- **Arrows / Tab** — navigate the menu.
- **Enter / Space** — select.
- **Escape** — back / open the table-actions menu.
- **t** — chat at the table.
- **.** prefix — global chat (`.hello` sends "hello" to everyone online).
- **/** prefix — slash commands (try `/help`).
- **s** — check the current score.
- **r** — roll dice (in dice games).
- **b** — add a bot (lobby only).

Every game also has its own keybinds — open the **Actions menu** with Escape to see them in context.

## Customising

- **Audio and Gesture Settings** (iOS) and **Options → Display / Sounds / Gameplay** (all clients) let you tune volumes, dice behaviour, and confirmation prompts.
- Gesture remapping (iOS) is granular — every gesture can be reassigned. There is a preset that swaps two-finger and three-finger roles for left-handed players.
- Preferences set in **Options** sync to your account and follow you across devices. Local-only preferences are flagged as such in their description.

## If something goes wrong

- The client automatically reconnects on a dropped connection.
- If gestures stop responding the way you expect (iOS), open Audio and Gesture Settings and choose **Reset to defaults**.
- If the in-game help menu isn't reachable through gestures, the **Menu** button in the top-right corner always opens it.
- Server-side issues (account approval, ban, rate limit) come through as plain spoken messages.

## Where to find help

- **Help** in the game view shows the rules for the current game plus your gesture mappings.
- **Getting Started** on the login screen (iOS) is this document, available even before you connect.
- Server administrators can edit this document and other shared docs from the **Documents** menu.
