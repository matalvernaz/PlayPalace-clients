# games.ftl for locale sr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Round and turn flow
game-round-start = Runda { $round }.
game-round-end = Runda { $round } završena.
game-turn-start = { $player } je na potezu.
game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-no-turn = Niko trenutno nije na potezu.
game-score-line = { $player }: { $score } poena
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points =
    { $count ->
        [one] point
       *[other] points
    }
game-score-unit-chips =
    { $count ->
        [one] chip
       *[other] chips
    }
game-score-unit-coins =
    { $count ->
        [one] coin
       *[other] coins
    }
game-score-unit-health = health
game-score-unit-ninetynine-tokens =
    { $count ->
        [one] token
       *[other] tokens
    }
game-score-unit-tokens-home =
    { $count ->
        [one] token home
       *[other] tokens home
    }
game-score-unit-pawns-home =
    { $count ->
        [one] pawn home
       *[other] pawns home
    }
game-score-unit-hand-wins =
    { $count ->
        [one] hand win
       *[other] hand wins
    }
game-score-unit-light = light
game-final-scores-header = Krajnji rezultat:
# Win/loss
game-winner = { $player } pobeđuje!
game-winner-you = You win!
game-winner-score = { $player } pobeđuje sa { $score } poena!
game-tiebreaker = Izjednačeno! Odlučujuća runda!
game-eliminated = { $player } ispada sa { $score } poena.
# Common options
game-set-target-score = Krajnji rezultat: { $score }
game-enter-target-score = Upišite krajnji rezultat:
game-option-changed-target = Krajnji rezultat podešen na { $score }.
game-set-team-mode = Režim timova: { $mode }
game-select-team-mode = Izaberite režim timova
game-option-changed-team = Režim timova podešen na { $mode }.
game-team-mode-individual = Individualni
game-team-mode-x-teams-of-y = { $num_teams } timova sa po { $team_size }
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
# Game end
game-leave = Napusti igru
# Round timer
round-timer-paused = { $player } pauzira igru (pritisnite P da započnete sledeću rundu).
# Dice games - keeping/releasing dice
dice-keeping = Zadržava se { $value }.
dice-rerolling = Ponovo se baca { $value }.
dice-locked = Ova kockica je zaključana i ne može se promeniti.
dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)
# Dealing (card games)
game-deal-counter = Deljenje { $current }/{ $total }.
game-you-deal = Delite karte.
game-player-deals = { $player } deli karte.
# Card names
card-name = { $rank }  { $suit }
no-cards = Nema karata
# Suit names
suit-diamonds = Karo
suit-clubs = Tref
suit-hearts = Herc
suit-spades = Pik
# Rank names
rank-ace = Kec
rank-two = 2
rank-three = 3
rank-four = 4
rank-five = 5
rank-six = 6
rank-seven = 7
rank-eight = 8
rank-nine = 9
rank-ten = 10
rank-jack = Žandar
rank-queen = Dama
rank-king = Kralj
rank-ace-plural = Kečevi
rank-two-plural = Dvojke
rank-three-plural = Trojke
rank-four-plural = Četvorke
rank-five-plural = Petice
rank-six-plural = Šestice
rank-seven-plural = Sedmice
rank-eight-plural = Osmice
rank-nine-plural = Devetke
rank-ten-plural = Desetke
rank-jack-plural = Žandari
rank-queen-plural = Dame
rank-king-plural = Kraljevi
# Poker hand descriptions
poker-high-card-with = { $high } najjača, sa { $rest }
poker-high-card = { $high } najjača
poker-pair-with = { $pair } par, uz { $rest }
poker-pair = { $pair } par
poker-two-pair-with = Dva para, { $high } i { $low }, uz { $kicker }
poker-two-pair = Dva para, { $high } i { $low }
poker-trips-with = Tri iste, { $trips }, uz { $rest }
poker-trips = Tri iste, { $trips }
poker-straight-high = { $high } kenta
poker-flush-high-with = { $high } boja, uz { $rest }
poker-full-house = Ful haus, { $trips } i { $pair }
poker-quads-with = Četiri iste, { $quads }, uz { $kicker }
poker-quads = Četiri iste, { $quads }
poker-royal-flush = Royal Flush
poker-straight-flush-high = { $high } kenta boje
poker-unknown-hand = Nepoznata ruka
# Validation errors (common across games)
game-error-invalid-team-mode = Izabran režim timova nije ispravan sa trenutnim brojem igrača.
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
document-not-found = Document not found.
help = Help
# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: { $game }
game-info-players = Players: { $count }
game-info-host = Host: { $host }
game-info-status = Status: { $status }
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.
# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for { $game } are not available yet.
# Game categories (shared)
category-party-games = Društvene igre
game-your-turn = Vi ste na potezu.
# Score display
game-scores-header = Trenutni rezultat:
game-tiebreaker-players = Izjednačeno je između igrača { $players }! Odlučujuća runda!
round-timer-resumed = Tajmer runde nastavljen.
round-timer-countdown = Sledeća runda za { $seconds }...
dice-status-locked = Zaključana
dice-status-kept = Zadržana
# Colors (with gendered forms: m = masculine, f = feminine)
color-black = Crna
color-black-m = crni
color-black-f = crna
color-blue = Plava
color-blue-m = plavi
color-blue-f = plava
color-brown = Braon
color-brown-m = braon
color-brown-f = braon
color-gray = Siva
color-gray-m = sivi
color-gray-f = siva
color-green = Zelena
color-green-m = zeleni
color-green-f = zelena
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = Narandžasta
color-orange-m = narandžasti
color-orange-f = narandžasta
color-pink = Ružičasta
color-pink-m = ružičasti
color-pink-f = ružičasta
color-purple = Ljubičasta
color-purple-m = ljubičasti
color-purple-f = ljubičasta
color-red = Crvena
color-red-m = crveni
color-red-f = crvena
color-violet = Ljubičasta
color-violet-m = ljubičasti
color-violet-f = ljubičasta
color-white = Bela
color-white-m = beli
color-white-f = bela
color-yellow = Žuta
color-yellow-m = žuti
color-yellow-f = žuta
rank-joker = Džoker
rank-joker-plural = Džokeri
# Shapes
shape-circle = Krug
shape-cone = Konus
shape-cylinder = Cilindar
shape-hexagon = heksagon
shape-oval = Ovalni
shape-pentagon = pentagon
shape-prism = Prizma
shape-rectangle = Pravougaonik
shape-square = Kvadrat
shape-triangle = Trougao
team-arrangement-swapped = { $first } and { $second } have swapped teams.
contact = Contact
