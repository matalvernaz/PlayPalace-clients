# Mancala game messages — es
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Hoyo { $pit }: { $stones } piedras

# Game events
mancala-sow = { $player } siembra { $stones } piedras del hoyo { $pit }
mancala-capture = ¡{ $player } captura { $captured } piedras!
mancala-extra-turn = ¡Última piedra en el almacén! { $player } tiene otro turno.
mancala-winner = ¡{ $player } gana con { $score } piedras!
mancala-draw = ¡Empate! Ambos jugadores tienen { $score } piedras.

# Board status
mancala-board-status =
    Tus hoyos: { $own_pits }. Tu almacén: { $own_store }. Hoyos del oponente: { $opp_pits }. Almacén del oponente: { $opp_store }.

# Options
mancala-set-stones = Piedras por hoyo: { $stones }
mancala-desc-stones = Número de piedras en cada hoyo al inicio
mancala-enter-stones = Ingresa el número de piedras iniciales por hoyo:
mancala-option-changed-stones = Piedras iniciales cambiadas a { $stones }

# Disabled reasons
mancala-pit-empty = Ese hoyo está vacío.

# Rules
mancala-rules =
    Mancala es un juego de hoyos y piedras para dos jugadores.
    Cada jugador tiene 6 hoyos y un almacén.
    En tu turno, elige uno de tus hoyos para sembrar.
    Las piedras se colocan una por una en cada hoyo alrededor del tablero, incluyendo tu almacén pero saltando el del oponente.
    Si tu última piedra cae en tu almacén, tienes otro turno.
    Si tu última piedra cae en un hoyo vacío de tu lado, capturas esa piedra y todas las del hoyo opuesto.
    El juego termina cuando un lado está completamente vacío. Las piedras restantes van al almacén de ese jugador.
    El jugador con más piedras gana.
    Usa las teclas 1 a 6 para elegir un hoyo. Presiona E para revisar el tablero.

# End screen
mancala-final-score = { $player }: { $score } piedras
mancala-check-board = Check board
