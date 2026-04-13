# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = Risk

# Phase announcements
risk-reinforce-start = { $player } recibe { $armies } ejércitos para colocar.
risk-attack-phase = { $player } ahora puede atacar.
risk-fortify-phase = { $player } ahora puede fortificar.

# Reinforce
risk-placed-army = { $player } refuerza { $territory } ({ $troops } tropas). Quedan { $remaining }.

# Attack
risk-attack-from = { $player } ataca desde { $territory }.
risk-combat-result =
    { $attacker } ataca { $def_territory } desde { $att_territory }.
    Atacante tira: { $att_rolls }. Defensor tira: { $def_rolls }.
    Atacante pierde { $att_losses }, defensor pierde { $def_losses }.
risk-conquered = ¡{ $player } conquista { $territory }! { $moved } tropas entran.
risk-eliminated = ¡{ $player } ha sido eliminado!
risk-skip-attack = Saltar ataque
risk-cancel-attack = Cancelar ataque

# Fortify
risk-fortify-from = { $player } fortifica desde { $territory }.
risk-fortified = { $player } mueve { $moved } tropas de { $source } a { $dest }.
risk-skip-fortify = Saltar fortificar
risk-cancel-fortify = Cancelar fortificar

# Cards
risk-cards-traded = { $player } cambia cartas por { $armies } ejércitos extra.

# Territory labels by phase
risk-territory-reinforce = { $name }: { $troops } tropas ({ $remaining } por colocar)
risk-territory-attack-from = { $name }: { $troops } tropas (atacar desde aquí)
risk-territory-attack-target = { $name }: { $troops } tropas ({ $owner })
risk-territory-fortify-from = { $name }: { $troops } tropas (mover desde aquí)
risk-territory-fortify-to = { $name }: { $troops } tropas (mover aquí)

# Status
risk-status-header = Controlas { $territories } territorios con { $troops } tropas en total.
risk-status-continent = { $name }: { $owned }/{ $total } territorios. Bonus: { $bonus }.

# Winner
risk-winner = ¡{ $player } ha conquistado el mundo!
risk-final-score = { $player }: { $territories } territorios

# Disabled reasons
risk-not-your-territory = Ese no es tu territorio.
risk-need-more-troops = Necesitas al menos 2 tropas para atacar o fortificar desde aquí.
risk-no-adjacent-enemy = No hay territorios enemigos adyacentes.
risk-cannot-attack-own = No puedes atacar tu propio territorio.
risk-not-adjacent = Ese territorio no es adyacente.
risk-same-territory = No puedes fortificar al mismo territorio.

# Options
risk-set-starting-armies = Ejércitos iniciales: { $armies }
risk-desc-starting-armies = Ejércitos adicionales por jugador al inicio (0 = auto)
risk-enter-starting-armies = Ingresa ejércitos iniciales por jugador (0 para auto):
risk-option-changed-armies = Ejércitos iniciales cambiados a { $armies }

# Rules
risk-rules =
    Risk es un juego de conquista mundial para 2 a 6 jugadores.
    El tablero tiene 42 territorios en 6 continentes.
    Cada turno tiene 3 fases: reforzar, atacar y fortificar.
    Reforzar: Coloca ejércitos en tus territorios. Recibes ejércitos según territorios y bonus de continente.
    Atacar: Selecciona un territorio con 2 o más tropas, luego un territorio enemigo adyacente. Los dados deciden el combate.
    El atacante tira hasta 3 dados, el defensor hasta 2. Los dados más altos se comparan: el más alto gana, los empates van al defensor.
    Si eliminas todos los defensores, conquistas el territorio.
    Fortificar: Mueve tropas a un territorio amigo adyacente.
    Conquista al menos un territorio por turno para ganar una carta. Cambia sets de 3 cartas por ejércitos extra.
    Elimina a todos los oponentes para ganar.
    Presiona E para ver tu estado.
risk-check-status = Check status
