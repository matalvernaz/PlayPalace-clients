# Number Chain — es

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } es el jugador 1, { $p2 } es el jugador 2. { $first } empieza. Coloca un 1 en cualquier sitio para iniciar la cadena.

# Placement
numberchain-place-you = Colocas { $number } en fila { $row }, columna { $col }.
numberchain-place-other = { $player } coloca { $number } en fila { $row }, columna { $col }.

# Errors
numberchain-illegal-move = Ese movimiento no es válido.

# Status / info
numberchain-status = Turno de { $current }. Siguiente número: { $required }.
numberchain-inventory = Tus fichas restantes: { $inventory }.
numberchain-required = Siguiente número a colocar: { $required }.

# Square labels
numberchain-sq-empty = Fila { $row }, columna { $col }, vacía
numberchain-sq-own = Fila { $row }, columna { $col }, { $number }, tuya
numberchain-sq-opponent = Fila { $row }, columna { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Estado
numberchain-check-inventory = Inventario
numberchain-check-required = Siguiente número

# Win
numberchain-wins = ¡{ $player } gana! El oponente no tiene jugadas válidas.
numberchain-final = { $winner } gana.

# Options
numberchain-option-bot-difficulty = Dificultad del bot: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Selecciona la dificultad del bot
numberchain-option-changed-bot-difficulty = Dificultad del bot cambiada a { $bot_difficulty }.
numberchain-difficulty-random = Aleatoria
numberchain-difficulty-simple = Simple
