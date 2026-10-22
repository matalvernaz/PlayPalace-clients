# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Devetindevetdeset

# Round and turn flow
game-round-start = Krog { $round }.
game-round-end = Krog { $round } končan.
game-turn-start = { $player } je na potezi.
game-your-turn = Vi ste na potezi.
game-no-turn = Trenutno ni nikogar na potezi.

# Score display
game-scores-header = Trenutni rezultati:
game-score-line = { $player }: { $score } točk
game-final-scores-header = Končni rezultati:

# Win/loss
game-winner = { $player } zmaga!
game-winner-score = { $player } zmaga s { $score } točkami!
game-tiebreaker = Neodločeno! Odločilni krog!
game-tiebreaker-players = Neodločeno med { $players }! Odločilni krog!
game-eliminated = { $player } je bil/a izločen/a s { $score } točkami.

# Common options
game-set-target-score = Ciljni rezultat: { $score }
game-enter-target-score = Vnesite ciljni rezultat:
game-option-changed-target = Ciljni rezultat nastavljen na { $score }.

game-set-team-mode = Ekipni način: { $mode }
game-select-team-mode = Izberite ekipni način
game-option-changed-team = Ekipni način nastavljen na { $mode }.
game-team-mode-individual = Posamezno
game-team-mode-x-teams-of-y = { $num_teams } ekip po { $team_size }

# Boolean option values
option-on = vključeno
option-off = izključeno

# Status box

# Game end
game-leave = Zapusti igro

# Round timer
round-timer-paused = { $player } je ustavil/a igro (pritisnite p za začetek naslednjega kroga).
round-timer-resumed = Časovnik kroga nadaljuje.
round-timer-countdown = Naslednji krog čez { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Obdržim { $value }.
dice-rerolling = Ponovno mečem { $value }.
dice-locked = Ta kocka je zaklenjena in je ni mogoče spremeniti.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Deljenje { $current }/{ $total }.
game-you-deal = Vi delite karte.
game-player-deals = { $player } deli karte.

# Card names
card-name = { $rank } { $suit }
no-cards = Ni kart

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = črna
color-black-m = črn
color-black-f = črna
color-blue = modra
color-blue-m = moder
color-blue-f = modra
color-brown = rjava
color-brown-m = rjav
color-brown-f = rjava
color-gray = siva
color-gray-m = siv
color-gray-f = siva
color-green = zelena
color-green-m = zelen
color-green-f = zelena
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = oranžna
color-orange-m = oranžen
color-orange-f = oranžna
color-pink = roza
color-pink-m = roza
color-pink-f = roza
color-purple = vijolična
color-purple-m = vijoličen
color-purple-f = vijolična
color-red = rdeča
color-red-m = rdeč
color-red-f = rdeča
color-violet = vijolična
color-violet-m = vijoličen
color-violet-f = vijolična
color-white = bela
color-white-m = bel
color-white-f = bela
color-yellow = rumena
color-yellow-m = rumen
color-yellow-f = rumena

# Suit names
suit-diamonds = kara
suit-clubs = križ
suit-hearts = srce
suit-spades = pik

# Rank names
rank-ace = as
rank-ace-plural = asi
rank-two = 2
rank-two-plural = dvojke
rank-three = 3
rank-three-plural = trojke
rank-four = 4
rank-four-plural = četrtke
rank-five = 5
rank-five-plural = petke
rank-six = 6
rank-six-plural = šestke
rank-seven = 7
rank-seven-plural = sedmice
rank-eight = 8
rank-eight-plural = osmice
rank-nine = 9
rank-nine-plural = devetke
rank-ten = 10
rank-ten-plural = desetke
rank-jack = fant
rank-jack-plural = fanti
rank-queen = dama
rank-queen-plural = dame
rank-king = kralj
rank-king-plural = kralji

# Poker hand descriptions
poker-high-card-with = { $high } visoko, z { $rest }
poker-high-card = { $high } visoko
poker-pair-with = Par { $pair }, z { $rest }
poker-pair = Par { $pair }
poker-two-pair-with = Dva para, { $high } in { $low }, z { $kicker }
poker-two-pair = Dva para, { $high } in { $low }
poker-trips-with = Tri enake, { $trips }, z { $rest }
poker-trips = Tri enake, { $trips }
poker-straight-high = { $high } visoka lestvica
poker-flush-high-with = { $high } visok flush, z { $rest }
poker-full-house = Full house, { $trips } nad { $pair }
poker-quads-with = Štiri enake, { $quads }, z { $kicker }
poker-quads = Štiri enake, { $quads }
poker-straight-flush-high = { $high } visoka barvna lestvica
poker-unknown-hand = Neznana roka

# Validation errors (common across games)
game-error-invalid-team-mode = Izbrani ekipni način ni veljaven za trenutno število igralcev.

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
