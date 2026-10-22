# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Ninety Nine

# Round and turn flow
game-round-start = Ronda { $round }.
game-round-end = Ronda { $round } completa.
game-turn-start = Turno de { $player }.
game-your-turn = Tu turno.
game-no-turn = No es el turno de nadie ahora mismo.

# Score display
game-scores-header = Puntuaciones Actuales:
game-score-line = { $player }: { $score } puntos
game-final-scores-header = Puntuaciones Finales:

# Win/loss
game-winner = ¡{ $player } gana!
game-winner-score = ¡{ $player } gana con { $score } puntos!
game-tiebreaker = ¡Es un empate! ¡Ronda de desempate!
game-tiebreaker-players = ¡Es un empate entre { $players }! ¡Ronda de desempate!
game-eliminated = { $player } ha sido eliminado con { $score } puntos.

# Common options
game-set-target-score = Puntuación objetivo: { $score }
game-enter-target-score = Ingresa la puntuación objetivo:
game-option-changed-target = Puntuación objetivo establecida en { $score }.

game-set-team-mode = Modo de equipos: { $mode }
game-select-team-mode = Selecciona el modo de equipos
game-option-changed-team = Modo de equipos establecido en { $mode }.
game-team-mode-individual = Individual
game-team-mode-x-teams-of-y = { $num_teams } equipos de { $team_size }

# Boolean option values
option-on = activado
option-off = desactivado

# Status box

# Game end
game-leave = Salir del juego

# Round timer
round-timer-paused = { $player } ha pausado el juego (presiona p para iniciar la siguiente ronda).
round-timer-resumed = Temporizador de ronda reanudado.
round-timer-countdown = Siguiente ronda en { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Manteniendo { $value }.
dice-rerolling = Volviendo a tirar { $value }.
dice-locked = Ese dado está bloqueado y no puede ser cambiado.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Reparto { $current }/{ $total }.
game-you-deal = Repartes las cartas.
game-player-deals = { $player } reparte las cartas.

# Card names
card-name = { $rank } de { $suit }
no-cards = Sin cartas

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = negro
color-black-m = negro
color-black-f = negra
color-blue = azul
color-blue-m = azul
color-blue-f = azul
color-brown = marrón
color-brown-m = marrón
color-brown-f = marrón
color-gray = gris
color-gray-m = gris
color-gray-f = gris
color-green = verde
color-green-m = verde
color-green-f = verde
color-indigo = índigo
color-indigo-m = índigo
color-indigo-f = índigo
color-orange = naranja
color-orange-m = naranja
color-orange-f = naranja
color-pink = rosa
color-pink-m = rosa
color-pink-f = rosa
color-purple = púrpura
color-purple-m = púrpura
color-purple-f = púrpura
color-red = rojo
color-red-m = rojo
color-red-f = roja
color-violet = violeta
color-violet-m = violeta
color-violet-f = violeta
color-white = blanco
color-white-m = blanco
color-white-f = blanca
color-yellow = amarillo
color-yellow-m = amarillo
color-yellow-f = amarilla

# Suit names
suit-diamonds = diamantes
suit-clubs = tréboles
suit-hearts = corazones
suit-spades = picas

# Rank names
rank-ace = as
rank-ace-plural = ases
rank-two = 2
rank-two-plural = 2s
rank-three = 3
rank-three-plural = 3s
rank-four = 4
rank-four-plural = 4s
rank-five = 5
rank-five-plural = 5s
rank-six = 6
rank-six-plural = 6s
rank-seven = 7
rank-seven-plural = 7s
rank-eight = 8
rank-eight-plural = 8s
rank-nine = 9
rank-nine-plural = 9s
rank-ten = 10
rank-ten-plural = 10s
rank-jack = sota
rank-jack-plural = sotas
rank-queen = reina
rank-queen-plural = reinas
rank-king = rey
rank-king-plural = reyes

# Poker hand descriptions
poker-high-card-with = { $high } alta, con { $rest }
poker-high-card = { $high } alta
poker-pair-with = Par de { $pair }, con { $rest }
poker-pair = Par de { $pair }
poker-two-pair-with = Doble Par, { $high } y { $low }, con { $kicker }
poker-two-pair = Doble Par, { $high } y { $low }
poker-trips-with = Trío, { $trips }, con { $rest }
poker-trips = Trío, { $trips }
poker-straight-high = Escalera alta de { $high }
poker-flush-high-with = Color alta de { $high }, con { $rest }
poker-full-house = Full House, { $trips } sobre { $pair }
poker-quads-with = Póker, { $quads }, con { $kicker }
poker-quads = Póker, { $quads }
poker-straight-flush-high = Escalera de Color alta de { $high }
poker-unknown-hand = Mano desconocida

# Validation errors (common across games)
game-error-invalid-team-mode = El modo de equipos seleccionado no es válido para el número actual de jugadores.

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
