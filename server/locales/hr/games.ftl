# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Devedeset devet

# Round and turn flow
game-round-start = Runda { $round }.
game-round-end = Runda { $round } završena.
game-turn-start = { $player } je na potezu.
game-your-turn = Vi ste na potezu.
game-no-turn = Nitko trenutno nije na potezu.

# Score display
game-scores-header = Trenutni rezultati:
game-score-line = { $player }: { $score } bodova
game-final-scores-header = Konačni rezultati:

# Win/loss
game-winner = { $player } pobjeđuje!
game-winner-score = { $player } pobjeđuje sa { $score } bodova!
game-tiebreaker = Neriješeno! Runda za prekid izjednačenja!
game-tiebreaker-players = Neriješeno između { $players }! Runda za prekid izjednačenja!
game-eliminated = { $player } je eliminiran/a sa { $score } bodova.

# Common options
game-set-target-score = Ciljni rezultat: { $score }
game-enter-target-score = Unesite ciljni rezultat:
game-option-changed-target = Ciljni rezultat postavljen na { $score }.

game-set-team-mode = Timski način: { $mode }
game-select-team-mode = Odaberite timski način
game-option-changed-team = Timski način postavljen na { $mode }.
game-team-mode-individual = Individualno
game-team-mode-x-teams-of-y = { $num_teams } timova od { $team_size }

# Boolean option values
option-on = uključeno
option-off = isključeno

# Status box

# Game end
game-leave = Napusti igru

# Round timer
round-timer-paused = { $player } je pauzirao/la igru (pritisnite p za početak sljedeće runde).
round-timer-resumed = Odbrojavanje runde nastavljeno.
round-timer-countdown = Sljedeća runda za { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Zadržavam { $value }.
dice-rerolling = Ponovno bacam { $value }.
dice-locked = Ta kocka je zaključana i ne može se promijeniti.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Dijeljenje { $current }/{ $total }.
game-you-deal = Vi dijelite karte.
game-player-deals = { $player } dijeli karte.

# Card names
card-name = { $rank } { $suit }
no-cards = Nema karata

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = crna
color-black-m = crni
color-black-f = crna
color-blue = plava
color-blue-m = plavi
color-blue-f = plava
color-brown = smeđa
color-brown-m = smeđi
color-brown-f = smeđa
color-gray = siva
color-gray-m = sivi
color-gray-f = siva
color-green = zelena
color-green-m = zeleni
color-green-f = zelena
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = narančasta
color-orange-m = narančasti
color-orange-f = narančasta
color-pink = ružičasta
color-pink-m = ružičasti
color-pink-f = ružičasta
color-purple = ljubičasta
color-purple-m = ljubičasti
color-purple-f = ljubičasta
color-red = crvena
color-red-m = crveni
color-red-f = crvena
color-violet = ljubičasta
color-violet-m = ljubičasti
color-violet-f = ljubičasta
color-white = bijela
color-white-m = bijeli
color-white-f = bijela
color-yellow = žuta
color-yellow-m = žuti
color-yellow-f = žuta

# Suit names
suit-diamonds = karo
suit-clubs = tref
suit-hearts = herc
suit-spades = pik

# Rank names
rank-ace = as
rank-ace-plural = asevi
rank-two = 2
rank-two-plural = dvojke
rank-three = 3
rank-three-plural = trojke
rank-four = 4
rank-four-plural = četvorke
rank-five = 5
rank-five-plural = petice
rank-six = 6
rank-six-plural = šestice
rank-seven = 7
rank-seven-plural = sedmice
rank-eight = 8
rank-eight-plural = osmice
rank-nine = 9
rank-nine-plural = devetke
rank-ten = 10
rank-ten-plural = desetke
rank-jack = dečko
rank-jack-plural = dečki
rank-queen = dama
rank-queen-plural = dame
rank-king = kralj
rank-king-plural = kraljevi

# Poker hand descriptions
poker-high-card-with = { $high } visoko, sa { $rest }
poker-high-card = { $high } visoko
poker-pair-with = Par { $pair }, sa { $rest }
poker-pair = Par { $pair }
poker-two-pair-with = Dva para, { $high } i { $low }, sa { $kicker }
poker-two-pair = Dva para, { $high } i { $low }
poker-trips-with = Tri iste, { $trips }, sa { $rest }
poker-trips = Tri iste, { $trips }
poker-straight-high = { $high } visoko skala
poker-flush-high-with = { $high } visoko flush, sa { $rest }
poker-full-house = Full house, { $trips } preko { $pair }
poker-quads-with = Četiri iste, { $quads }, sa { $kicker }
poker-quads = Četiri iste, { $quads }
poker-straight-flush-high = { $high } visoko skala boja
poker-unknown-hand = Nepoznata ruka

# Validation errors (common across games)
game-error-invalid-team-mode = Odabrani timski način nije valjan za trenutni broj igrača.

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
