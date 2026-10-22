# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Nittionio

# Round and turn flow
game-round-start = Omgång { $round }.
game-round-end = Omgång { $round } slutförd.
game-turn-start = Det är { $player }s tur.
game-your-turn = Det är din tur.
game-no-turn = Det är ingen tur just nu.

# Score display
game-scores-header = Aktuella poäng:
game-score-line = { $player }: { $score } poäng
game-final-scores-header = Slutliga poäng:

# Win/loss
game-winner = { $player } vinner!
game-winner-score = { $player } vinner med { $score } poäng!
game-tiebreaker = Det är oavgjort! Utslagningsomgång!
game-tiebreaker-players = Det är oavgjort mellan { $players }! Utslagningsomgång!
game-eliminated = { $player } har blivit eliminerad med { $score } poäng.

# Common options
game-set-target-score = Målpoäng: { $score }
game-enter-target-score = Ange målpoäng:
game-option-changed-target = Målpoäng satt till { $score }.

game-set-team-mode = Lagläge: { $mode }
game-select-team-mode = Välj lagläge
game-option-changed-team = Lagläge satt till { $mode }.
game-team-mode-individual = Individuellt
game-team-mode-x-teams-of-y = { $num_teams } lag om { $team_size }

# Boolean option values
option-on = på
option-off = av

# Status box

# Game end
game-leave = Lämna spelet

# Round timer
round-timer-paused = { $player } har pausat spelet (tryck p för att starta nästa omgång).
round-timer-resumed = Omgångstimer återupptagen.
round-timer-countdown = Nästa omgång om { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Behåller { $value }.
dice-rerolling = Slår om { $value }.
dice-locked = Den tärningen är låst och kan inte ändras.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Ger { $current }/{ $total }.
game-you-deal = Du ger ut korten.
game-player-deals = { $player } ger ut korten.

# Card names
card-name = { $suit } { $rank }
no-cards = Inga kort

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = svart
color-black-m = svart
color-black-f = svart
color-blue = blå
color-blue-m = blå
color-blue-f = blå
color-brown = brun
color-brown-m = brun
color-brown-f = brun
color-gray = grå
color-gray-m = grå
color-gray-f = grå
color-green = grön
color-green-m = grön
color-green-f = grön
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = orange
color-orange-m = orange
color-orange-f = orange
color-pink = rosa
color-pink-m = rosa
color-pink-f = rosa
color-purple = lila
color-purple-m = lila
color-purple-f = lila
color-red = röd
color-red-m = röd
color-red-f = röd
color-violet = violett
color-violet-m = violett
color-violet-f = violett
color-white = vit
color-white-m = vit
color-white-f = vit
color-yellow = gul
color-yellow-m = gul
color-yellow-f = gul

# Suit names
suit-diamonds = ruter
suit-clubs = klöver
suit-hearts = hjärter
suit-spades = spader

# Rank names
rank-ace = ess
rank-ace-plural = ess
rank-two = 2
rank-two-plural = 2:or
rank-three = 3
rank-three-plural = 3:or
rank-four = 4
rank-four-plural = 4:or
rank-five = 5
rank-five-plural = 5:or
rank-six = 6
rank-six-plural = 6:or
rank-seven = 7
rank-seven-plural = 7:or
rank-eight = 8
rank-eight-plural = 8:or
rank-nine = 9
rank-nine-plural = 9:or
rank-ten = 10
rank-ten-plural = 10:or
rank-jack = knekt
rank-jack-plural = knektar
rank-queen = dam
rank-queen-plural = damer
rank-king = kung
rank-king-plural = kungar

# Poker hand descriptions
poker-high-card-with = { $high } högt, med { $rest }
poker-high-card = { $high } högt
poker-pair-with = Par i { $pair }, med { $rest }
poker-pair = Par i { $pair }
poker-two-pair-with = Två par, { $high } och { $low }, med { $kicker }
poker-two-pair = Två par, { $high } och { $low }
poker-trips-with = Triss, { $trips }, med { $rest }
poker-trips = Triss, { $trips }
poker-straight-high = { $high } högt stege
poker-flush-high-with = { $high } högt färg, med { $rest }
poker-full-house = Kåk, { $trips } över { $pair }
poker-quads-with = Fyrtal, { $quads }, med { $kicker }
poker-quads = Fyrtal, { $quads }
poker-straight-flush-high = { $high } högt färgstege
poker-unknown-hand = Okänd hand

# Validation errors (common across games)
game-error-invalid-team-mode = Det valda lagläget är inte giltigt för det aktuella antalet spelare.

game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] point
   *[other] points
}
game-score-unit-chips = { $count ->
    [one] chip
   *[other] chips
}
game-score-unit-coins = { $count ->
    [one] coin
   *[other] coins
}
game-score-unit-health = health
game-score-unit-ninetynine-tokens = { $count ->
    [one] token
   *[other] tokens
}
game-score-unit-tokens-home = { $count ->
    [one] token home
   *[other] tokens home
}
game-score-unit-pawns-home = { $count ->
    [one] pawn home
   *[other] pawns home
}
game-score-unit-hand-wins = { $count ->
    [one] hand win
   *[other] hand wins
}
game-score-unit-light = light
game-winner-you = You win!
game-team-name = Team { $index }
team-arrangement-started = Team arrangement started. Review the teams, swap members if needed, then confirm to start.
team-arrangement-confirm = Confirm teams and start
team-arrangement-read = Read teams
team-arrangement-select-member-action = Select team member
team-arrangement-select-member = Select a team member
team-arrangement-select-swap-target = Select a player to swap with
team-arrangement-swap-member = Choose swap target
team-arrangement-swap-member-selected = Swap { $player } with...
team-arrangement-cancel = Cancel team arrangement
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Turn order: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selected
team-arrangement-not-selected = not selected
team-arrangement-member-selected = { $player } from { $team } selected. Choose a player from another team to swap with.
team-arrangement-swapped = { $first } and { $second } have swapped teams.
team-arrangement-cancelled = Team arrangement cancelled.
team-arrangement-cancelled-roster = Team arrangement cancelled because the player list changed.
team-arrangement-refreshed = The player list changed. Team arrangement has been refreshed.
team-arrangement-in-progress = Finish or cancel team arrangement first.
team-arrangement-not-active = Team arrangement is not active.
team-arrangement-select-first = Select a team member first.
team-arrangement-player-missing = That player is no longer available for team arrangement.
team-arrangement-same-team = Choose someone from a different team.
team-arrangement-swap-failed = Could not swap those team members.

status-box-closed = Status information closed.

dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)

poker-royal-flush = Royal Flush
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
contact = Contact
document-not-found = Document not found.
help = Help

# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: {$game}
game-info-players = Players: {$count}
game-info-host = Host: {$host}
game-info-status = Status: {$status}
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.

# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for {$game} are not available yet.
