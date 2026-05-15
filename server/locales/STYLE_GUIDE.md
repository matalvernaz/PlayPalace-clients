# PlayPalace localisation style guide

All player-facing text in PlayPalace is read aloud — by VoiceOver, by an in-app screen reader, or by Apple's text-to-speech engine. The rules below keep narration consistent across the 41+ games on the server so players don't have to relearn conventions per-game.

## 1. Use the first-person variant for the acting player

Whenever a message describes something the active player did, send a `you-…` variant to that player and a `player-…` variant to everyone else.

Use `broadcast_personal_l` from `GameCommunicationMixin`:

```python
self.broadcast_personal_l(
    player,
    personal_message_id="pig-you-rolled",
    others_message_id="pig-player-rolled",
    roll=roll,
    total=pig_player.round_score,
)
```

Naming convention:

```
{game}-you-{verb}        — sent to the acting player
{game}-player-{verb}     — sent to everyone else (player= filled in automatically)
```

For game-level events that aren't tied to a single actor (round start, deal counter), keep a single key and use `broadcast_l`.

## 2. Re-use shared keys for shared concepts

Before inventing a new key in a game-specific `.ftl`, check `games.ftl` and `main.ftl`. Shared keys that every game should use:

| Concept | Key |
|---|---|
| Winner announcement | `game-winner = { $player } wins!` |
| Winner with score | `game-winner-score = { $player } wins with { $score } points!` |
| Tiebreaker | `game-tiebreaker-players` |
| Round start / end | `game-round-start`, `game-round-end` |
| Turn change | `game-turn-start`, `game-your-turn` |
| Score header / line | `game-scores-header`, `game-score-line` |
| Eliminated | `game-eliminated` |
| Dice rolled (first / third person) | `dice-you-rolled`, `dice-player-rolled` |
| Rolls remaining | `dice-rolls-remaining` |
| Card dealt / drawn / played | `card-name`, plus per-game first/third-person play keys |
| Not your turn | `action-not-your-turn` |
| Need more players | `action-need-more-players` |

Pig's `pig-winner` was retired for `game-winner` for exactly this reason — every game's winner announcement now reads the same way.

## 3. Always include units

VoiceOver doesn't infer "points" from context. Anything that's a quantity needs a unit:

- `{ $player } gains 10` — wrong
- `{ $player } gains 10 points` — right
- `Deck: 12` — wrong
- `Deck: 12 cards` — right

For pluralisation, use Fluent plural selectors:

```ftl
crazyeights-deck-count =
    { $count ->
        [one] Deck: 1 card.
       *[other] Deck: { $count } cards.
    }
```

## 4. No ellipses, no abbreviations

- Ellipses (`...`) read aloud as "dot dot dot" on some voices. Drop them.
- `min` / `max` get read as "minute". Use `minimum` / `maximum`, or rewrite as "Minimum 2, maximum 4 players."
- `1st` / `2nd` / etc. — Apple voices normalise these inconsistently. Prefer `first`, `second` or write the digit followed by a unit.

## 5. Sentence shape

- End every sentence with a period.
- Use a comma + space before a continuation, not a colon, when the continuation is a free clause:
  - `pig-you-bank = You bank { $points } points. Your total is { $total } points.`
- Use a colon when the continuation is a list or value:
  - `dice-rolls-remaining = Rolls remaining: { $remaining }.`
- One sentence per spoken event, two at most. If you need more, break them into separate `broadcast_*` calls so each gets its own announcement (and can be queued/interrupted independently).

## 6. Imperative for action labels, indicative for events

- Action labels (menu items): `Roll the die`, `Bank { $points } points`, `Reroll dice. { $count } rolls left.`
- Events (broadcasts): `You rolled { $roll }. Round total: { $total }.`, `{ $player } rolled { $roll }.`

Never use ambiguous phrasing like "Rolling…" in a menu item — that reads like a status, not an action you can take.

## 7. Spell out card and game numbers consistently

If the game's own name uses words (Crazy Eights, Twenty One), use words inside its messages: `Wild Eight`, `Twenty One`. If the game's name uses digits (1-2-3, Nine, 99), use digits. Don't mix.

## 8. Naming and casing

- Localisation keys: `kebab-case`.
- Game keys: prefix with the game type. `pig-you-rolled`, `holdem-pre-flop`. Never collide across games.
- Within a game, group keys by phase: setup options → action labels → events → option-changed confirmations → disabled reasons → validation errors.

## 9. When you add a new game

1. Copy `pig.ftl` as the template — it follows every rule above.
2. Wire `get_help_text` via the default base implementation; just provide `<game-type>-rules` in your `.ftl`.
3. Use `broadcast_personal_l` for any event the acting player caused.
4. Re-use shared keys from §2 wherever they fit; don't invent a per-game `<game>-winner`.

## Style debts (known)

These are tracked but not yet fixed in every game:

- First/third-person variants are still missing in some games' draw/pass/play paths (notably Crazy Eights' `crazyeights-draw`, `crazyeights-pass`).
- A few games (mostly older ones) still emit `{ $player } …s the …` style events without a `you-` variant.
- Yahtzee's `yahtzee-roll` action label is the only place we use `Re-roll` (with a hyphen). New games should use `Reroll`.

When you add or refactor a game, knock one of these off.
