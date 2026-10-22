# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Novantanove

# Round and turn flow
game-round-start = Round { $round }.
game-round-end = Round { $round } completato.
game-turn-start = È il turno di { $player }.
game-your-turn = È il tuo turno.
game-no-turn = Nessuno sta giocando in questo momento.

# Score display
game-scores-header = Punteggi attuali:
game-score-line = { $player }: { $score } punti
game-final-scores-header = Punteggi finali:

# Win/loss
game-winner = { $player } vince!
game-winner-score = { $player } vince con { $score } punti!
game-tiebreaker = È un pareggio! Round di spareggio!
game-tiebreaker-players = È un pareggio tra { $players }! Round di spareggio!
game-eliminated = { $player } è stato/a eliminato/a con { $score } punti.

# Common options
game-set-target-score = Punteggio obiettivo: { $score }
game-enter-target-score = Inserisci il punteggio obiettivo:
game-option-changed-target = Punteggio obiettivo impostato a { $score }.

game-set-team-mode = Modalità squadra: { $mode }
game-select-team-mode = Seleziona modalità squadra
game-option-changed-team = Modalità squadra impostata a { $mode }.
game-team-mode-individual = Individuale
game-team-mode-x-teams-of-y = { $num_teams } squadre da { $team_size }

# Boolean option values
option-on = attivo
option-off = disattivo

# Status box

# Game end
game-leave = Abbandona partita

# Round timer
round-timer-paused = { $player } ha messo in pausa il gioco (premi p per iniziare il prossimo round).
round-timer-resumed = Timer del round ripreso.
round-timer-countdown = Prossimo round tra { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Tengo { $value }.
dice-rerolling = Rilancio { $value }.
dice-locked = Quel dado è bloccato e non può essere cambiato.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Distribuzione { $current }/{ $total }.
game-you-deal = Tu distribuisci le carte.
game-player-deals = { $player } distribuisce le carte.

# Card names
card-name = { $rank } di { $suit }
no-cards = Nessuna carta

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = nero
color-black-m = nero
color-black-f = nera
color-blue = blu
color-blue-m = blu
color-blue-f = blu
color-brown = marrone
color-brown-m = marrone
color-brown-f = marrone
color-gray = grigio
color-gray-m = grigio
color-gray-f = grigia
color-green = verde
color-green-m = verde
color-green-f = verde
color-indigo = indaco
color-indigo-m = indaco
color-indigo-f = indaco
color-orange = arancione
color-orange-m = arancione
color-orange-f = arancione
color-pink = rosa
color-pink-m = rosa
color-pink-f = rosa
color-purple = porpora
color-purple-m = porpora
color-purple-f = porpora
color-red = rosso
color-red-m = rosso
color-red-f = rossa
color-violet = viola
color-violet-m = viola
color-violet-f = viola
color-white = bianco
color-white-m = bianco
color-white-f = bianca
color-yellow = giallo
color-yellow-m = giallo
color-yellow-f = gialla

# Suit names
suit-diamonds = quadri
suit-clubs = fiori
suit-hearts = cuori
suit-spades = picche

# Rank names
rank-ace = asso
rank-ace-plural = assi
rank-two = 2
rank-two-plural = 2
rank-three = 3
rank-three-plural = 3
rank-four = 4
rank-four-plural = 4
rank-five = 5
rank-five-plural = 5
rank-six = 6
rank-six-plural = 6
rank-seven = 7
rank-seven-plural = 7
rank-eight = 8
rank-eight-plural = 8
rank-nine = 9
rank-nine-plural = 9
rank-ten = 10
rank-ten-plural = 10
rank-jack = fante
rank-jack-plural = fanti
rank-queen = regina
rank-queen-plural = regine
rank-king = re
rank-king-plural = re

# Poker hand descriptions
poker-high-card-with = { $high } alto, con { $rest }
poker-high-card = { $high } alto
poker-pair-with = Coppia di { $pair }, con { $rest }
poker-pair = Coppia di { $pair }
poker-two-pair-with = Doppia coppia, { $high } e { $low }, con { $kicker }
poker-two-pair = Doppia coppia, { $high } e { $low }
poker-trips-with = Tris, { $trips }, con { $rest }
poker-trips = Tris, { $trips }
poker-straight-high = Scala con { $high } alto
poker-flush-high-with = Colore con { $high } alto, con { $rest }
poker-full-house = Full house, { $trips } su { $pair }
poker-quads-with = Poker, { $quads }, con { $kicker }
poker-quads = Poker, { $quads }
poker-straight-flush-high = Scala colore con { $high } alto
poker-unknown-hand = Mano sconosciuta

# Validation errors (common across games)
game-error-invalid-team-mode = La modalità squadra selezionata non è valida per il numero attuale di giocatori.

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
