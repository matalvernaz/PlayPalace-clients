# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Ninety Nine

# Round and turn flow
game-round-start = Ronde { $round }.
game-round-end = Ronde { $round } voltooid.
game-turn-start = { $player } is aan de beurt.
game-your-turn = Jij bent aan de beurt.
game-no-turn = Niemand is nu aan de beurt.

# Score display
game-scores-header = Huidige Scores:
game-score-line = { $player }: { $score } punten
game-final-scores-header = Eindscores:

# Win/loss
game-winner = { $player } wint!
game-winner-score = { $player } wint met { $score } punten!
game-tiebreaker = Het is gelijk! Tie-breaker ronde!
game-tiebreaker-players = Het is gelijk tussen { $players }! Tie-breaker ronde!
game-eliminated = { $player } is geëlimineerd met { $score } punten.

# Common options
game-set-target-score = Doelscore: { $score }
game-enter-target-score = Voer doelscore in:
game-option-changed-target = Doelscore ingesteld op { $score }.

game-set-team-mode = Teammodus: { $mode }
game-select-team-mode = Selecteer teammodus
game-option-changed-team = Teammodus ingesteld op { $mode }.
game-team-mode-individual = Individueel
game-team-mode-x-teams-of-y = { $num_teams } teams van { $team_size }

# Boolean option values
option-on = aan
option-off = uit

# Status box

# Game end
game-leave = Verlaat spel

# Round timer
round-timer-paused = { $player } heeft het spel gepauzeerd (druk op p om de volgende ronde te starten).
round-timer-resumed = Rondetimer hervat.
round-timer-countdown = Volgende ronde over { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = { $value } bewaren.
dice-rerolling = { $value } opnieuw gooien.
dice-locked = Die dobbelsteen is vergrendeld en kan niet worden gewijzigd.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Deel { $current }/{ $total }.
game-you-deal = Jij deelt de kaarten uit.
game-player-deals = { $player } deelt de kaarten uit.

# Card names
card-name = { $rank } van { $suit }
no-cards = Geen kaarten

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = zwart
color-black-m = zwart
color-black-f = zwart
color-blue = blauw
color-blue-m = blauw
color-blue-f = blauw
color-brown = bruin
color-brown-m = bruin
color-brown-f = bruin
color-gray = grijs
color-gray-m = grijs
color-gray-f = grijs
color-green = groen
color-green-m = groen
color-green-f = groen
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = oranje
color-orange-m = oranje
color-orange-f = oranje
color-pink = roze
color-pink-m = roze
color-pink-f = roze
color-purple = paars
color-purple-m = paars
color-purple-f = paars
color-red = rood
color-red-m = rood
color-red-f = rood
color-violet = violet
color-violet-m = violet
color-violet-f = violet
color-white = wit
color-white-m = wit
color-white-f = wit
color-yellow = geel
color-yellow-m = geel
color-yellow-f = geel

# Suit names
suit-diamonds = ruiten
suit-clubs = klaveren
suit-hearts = harten
suit-spades = schoppen

# Rank names
rank-ace = aas
rank-ace-plural = azen
rank-two = 2
rank-two-plural = 2's
rank-three = 3
rank-three-plural = 3's
rank-four = 4
rank-four-plural = 4's
rank-five = 5
rank-five-plural = 5's
rank-six = 6
rank-six-plural = 6's
rank-seven = 7
rank-seven-plural = 7's
rank-eight = 8
rank-eight-plural = 8's
rank-nine = 9
rank-nine-plural = 9's
rank-ten = 10
rank-ten-plural = 10's
rank-jack = boer
rank-jack-plural = boeren
rank-queen = vrouw
rank-queen-plural = vrouwen
rank-king = heer
rank-king-plural = heren

# Poker hand descriptions
poker-high-card-with = { $high } hoog, met { $rest }
poker-high-card = { $high } hoog
poker-pair-with = Paar { $pair }, met { $rest }
poker-pair = Paar { $pair }
poker-two-pair-with = Twee Paar, { $high } en { $low }, met { $kicker }
poker-two-pair = Twee Paar, { $high } en { $low }
poker-trips-with = Three of a Kind, { $trips }, met { $rest }
poker-trips = Three of a Kind, { $trips }
poker-straight-high = { $high } hoog Straat
poker-flush-high-with = { $high } hoog Flush, met { $rest }
poker-full-house = Full House, { $trips } over { $pair }
poker-quads-with = Four of a Kind, { $quads }, met { $kicker }
poker-quads = Four of a Kind, { $quads }
poker-straight-flush-high = { $high } hoog Straight Flush
poker-unknown-hand = Onbekende hand

# Validation errors (common across games)
game-error-invalid-team-mode = De geselecteerde teammodus is niet geldig voor het huidige aantal spelers.

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
