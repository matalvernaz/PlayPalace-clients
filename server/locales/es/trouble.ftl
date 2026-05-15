# Trouble — es
game-name-trouble = Trouble

trouble-rules =
    Trouble es un juego de carreras de la familia Parcheesi.
    Cada jugador empieza con sus fichas en su área de Casa.
    En tu turno, dispara el dado y mueve una de tus fichas.
    Por defecto debes sacar un 6 para liberar una ficha de Casa al recorrido.
    Por defecto, sacar un 6 también otorga un turno extra.
    Las fichas avanzan en el sentido de las agujas del reloj por el recorrido compartido hacia la meta.
    Caer sobre la ficha de un rival la devuelve a su Casa, salvo que el espacio esté protegido.
    Cuando todas tus fichas llegan a la meta, ganas.
    En modo equipo, tu equipo gana cuando todos los compañeros han terminado.
    Usa las teclas del 1 al 6 para elegir qué ficha mover, o pulsa R para tirar.
    Pulsa E para escuchar el estado completo del tablero en cualquier momento.

trouble-action-roll = Disparar el dado
trouble-action-move-token = Mover ficha { $token }
trouble-action-check-board = Ver el tablero

trouble-token-label-home = Ficha { $token }: en Casa
trouble-token-label-track = Ficha { $token }: espacio { $position } del recorrido
trouble-token-label-finish-lane = Ficha { $token }: carril de meta { $position } de { $total }
trouble-token-label-finished = Ficha { $token }: en meta

trouble-rolled = { $player } sacó un { $roll }.
trouble-leave-home = { $player } libera la ficha { $token } al recorrido.
trouble-advance-track = { $player } mueve la ficha { $token } al espacio { $position }.
trouble-enter-finish-lane = { $player } mete la ficha { $token } en el carril de meta.
trouble-advance-finish-lane =
    { $player } avanza la ficha { $token } al espacio { $position } de { $total } del carril de meta.
trouble-token-finished = La ficha { $token } de { $player } llega a la meta.
trouble-bump =
    La ficha { $token } de { $player } devuelve la ficha { $opp_token } de { $opponent } a su Casa.
trouble-no-legal-move = { $player } no tiene movimientos válidos. Pasa el turno.
trouble-extra-turn = { $player } recibe un turno extra por sacar un 6.

trouble-winner = ¡{ $player } gana! Todas las fichas en la meta.
trouble-team-winner = ¡Gana el equipo { $team }! Todos los compañeros han terminado.
trouble-final-standing = { $player }: { $finished } de { $total } fichas en meta.

trouble-turn-summary =
    Tienes { $own_home } en Casa, { $own_track } en el recorrido, { $own_finished } en meta.
    Rivales: { $opponents }.
trouble-opponent-summary = { $name }: { $home } casa, { $track } recorrido, { $finished } meta

trouble-board-status =
    Tus fichas: { $own_tokens }.
    Fichas rivales: { $opp_tokens }.

trouble-reason-not-rolled = Dispara primero el dado.
trouble-reason-already-rolled = Ya disparaste. Elige una ficha para mover.
trouble-reason-no-legal-moves = No hay movimientos legales para esta tirada.
trouble-reason-token-home-needs-six = Esta ficha está en Casa. Necesitas un 6 para liberarla.
trouble-reason-token-home-needs-any = Esta ficha está en Casa. Cualquier valor la libera.
trouble-reason-token-home-no-qualifying-roll =
    Esta ficha está en Casa y tu tirada no cumple para liberarla.
trouble-reason-token-finished = Esta ficha ya está en meta.
trouble-reason-overshoot-wastes = Esta ficha no puede moverse { $roll } espacios sin pasarse de la meta.
trouble-reason-blocked = Este movimiento está bloqueado.

trouble-option-track-size = Tamaño del recorrido: { $track_size } espacios
trouble-option-select-track-size = Selecciona el número de espacios del recorrido.
trouble-option-changed-track-size = Recorrido fijado en { $track_size } espacios.
trouble-option-desc-track-size = Número de espacios del recorrido compartido.

trouble-option-tokens-per-player = Fichas por jugador: { $tokens }
trouble-option-enter-tokens-per-player = Introduce las fichas por jugador (2 a 6):
trouble-option-changed-tokens-per-player = Fichas por jugador fijadas en { $tokens }.
trouble-option-desc-tokens-per-player = Número de fichas que cada jugador lleva a la meta.

trouble-option-extra-turn-on-six = Turno extra al sacar 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Turno extra al 6 { $enabled ->
    [on] activado.
    [off] desactivado.
   *[other] actualizado.
}
trouble-option-desc-extra-turn-on-six =
    Si está activado, sacar un 6 da un turno extra (regla clásica de Hasbro).

trouble-option-six-to-leave-home = Exigir 6 para salir de Casa: { $enabled }
trouble-option-changed-six-to-leave-home = Seis para salir de Casa { $enabled ->
    [on] activado.
    [off] desactivado.
   *[other] actualizado.
}
trouble-option-desc-six-to-leave-home =
    Si está activado, el jugador debe sacar un 6 para liberar una ficha de Casa. Si no, cualquier tirada libera.

trouble-option-safe-spaces = Espacios seguros: { $mode }
trouble-option-select-safe-spaces = Selecciona el modo de espacios seguros.
trouble-option-changed-safe-spaces = Espacios seguros fijados a { $mode }.
trouble-option-desc-safe-spaces = Decide si las fichas pueden protegerse de los golpes.

trouble-safe-mode-none = Ninguno
trouble-safe-mode-home-stretch = Solo recta final
trouble-safe-mode-every-seventh = Cada 7º espacio

trouble-option-finish-behavior = Meta: { $mode }
trouble-option-select-finish-behavior = Selecciona el comportamiento en la meta.
trouble-option-changed-finish-behavior = Comportamiento de meta fijado a { $mode }.
trouble-option-desc-finish-behavior = Cómo se maneja una tirada que se pasa de la meta.

trouble-finish-mode-exact = Tirada exacta requerida
trouble-finish-mode-bounce = Rebote por exceso
trouble-finish-mode-allow = Exceso permitido

trouble-option-bot-difficulty = Dificultad del bot: { $level }
trouble-option-select-bot-difficulty = Selecciona la dificultad del bot.
trouble-option-changed-bot-difficulty = Dificultad del bot fijada a { $level }.
trouble-option-desc-bot-difficulty = Fuerza de los bots integrados.

trouble-bot-difficulty-naive = Ingenuo
trouble-bot-difficulty-greedy = Codicioso

trouble-option-preset = Preajuste: { $preset }
trouble-option-select-preset = Elige una variante. El anfitrión puede ajustar reglas individuales después.
trouble-option-changed-preset = Preajuste aplicado: { $preset }.
trouble-option-desc-preset = Conjuntos de opciones preconfigurados para variantes comunes.

trouble-preset-classic = Clásico Hasbro
trouble-preset-fast = Rápido
trouble-preset-brutal = Brutal
trouble-preset-custom = Personalizado
