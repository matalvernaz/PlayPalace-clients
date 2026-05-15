# Trouble — fr
game-name-trouble = Trouble

trouble-rules =
    Trouble est un jeu de course de la famille Parcheesi.
    Chaque joueur commence avec ses pions dans sa Maison.
    À ton tour, déclenche le dé et déplace l'un de tes pions.
    Par défaut tu dois faire 6 pour sortir un pion de la Maison sur la piste.
    Par défaut, faire 6 donne aussi un tour supplémentaire.
    Les pions avancent dans le sens horaire sur la piste partagée jusqu'à la zone d'arrivée.
    Tomber sur le pion d'un adversaire le renvoie à sa Maison, sauf si la case est protégée.
    Quand tous tes pions atteignent l'arrivée, tu gagnes.
    En mode équipe, ton équipe gagne quand tous ses coéquipiers ont fini.
    Utilise les touches 1 à 6 pour choisir un pion à déplacer, ou R pour lancer.
    Appuie sur E à tout moment pour entendre l'état complet du plateau.

trouble-action-roll = Déclencher le dé
trouble-action-move-token = Déplacer le pion { $token }
trouble-action-check-board = Voir le plateau

trouble-token-label-home = Pion { $token } : à la Maison
trouble-token-label-track = Pion { $token } : case { $position } de la piste
trouble-token-label-finish-lane = Pion { $token } : couloir d'arrivée { $position } sur { $total }
trouble-token-label-finished = Pion { $token } : arrivé

trouble-rolled = { $player } a déclenché un { $roll }.
trouble-leave-home = { $player } sort le pion { $token } sur la piste.
trouble-advance-track = { $player } déplace le pion { $token } à la case { $position }.
trouble-enter-finish-lane = { $player } place le pion { $token } dans le couloir d'arrivée.
trouble-advance-finish-lane =
    { $player } avance le pion { $token } à la case { $position } sur { $total } du couloir d'arrivée.
trouble-token-finished = Le pion { $token } de { $player } atteint l'arrivée.
trouble-bump =
    Le pion { $token } de { $player } renvoie le pion { $opp_token } de { $opponent } à sa Maison.
trouble-no-legal-move = { $player } n'a pas de coup valable. Le tour passe.
trouble-extra-turn = { $player } obtient un tour supplémentaire pour son 6.

trouble-winner = { $player } gagne ! Tous les pions sont arrivés.
trouble-team-winner = L'équipe { $team } gagne ! Tous les coéquipiers ont fini.
trouble-final-standing = { $player } : { $finished } pions arrivés sur { $total }.

trouble-turn-summary =
    Tu as { $own_home } à la Maison, { $own_track } sur la piste, { $own_finished } arrivés.
    Adversaires : { $opponents }.
trouble-opponent-summary = { $name } : { $home } maison, { $track } piste, { $finished } arrivés

trouble-board-status =
    Tes pions : { $own_tokens }.
    Pions adverses : { $opp_tokens }.

trouble-reason-not-rolled = Déclenche d'abord le dé.
trouble-reason-already-rolled = Tu as déjà déclenché. Choisis un pion à déplacer.
trouble-reason-no-legal-moves = Aucun coup légal pour ce lancer.
trouble-reason-token-home-needs-six = Ce pion est à la Maison. Il faut un 6 pour le sortir.
trouble-reason-token-home-needs-any = Ce pion est à la Maison. N'importe quel résultat le sort.
trouble-reason-token-home-no-qualifying-roll =
    Ce pion est à la Maison et ton lancer ne permet pas de le sortir.
trouble-reason-token-finished = Ce pion est déjà arrivé.
trouble-reason-overshoot-wastes = Ce pion ne peut pas avancer de { $roll } sans dépasser l'arrivée.
trouble-reason-blocked = Ce mouvement est bloqué.

trouble-option-track-size = Taille de la piste : { $track_size } cases
trouble-option-select-track-size = Choisis le nombre de cases sur la piste.
trouble-option-changed-track-size = Piste réglée sur { $track_size } cases.
trouble-option-desc-track-size = Nombre de cases sur la piste partagée.

trouble-option-tokens-per-player = Pions par joueur : { $tokens }
trouble-option-enter-tokens-per-player = Entre le nombre de pions par joueur (2 à 6) :
trouble-option-changed-tokens-per-player = Pions par joueur réglés sur { $tokens }.
trouble-option-desc-tokens-per-player = Nombre de pions que chaque joueur fait avancer.

trouble-option-extra-turn-on-six = Tour supplémentaire sur 6 : { $enabled }
trouble-option-changed-extra-turn-on-six = Tour supplémentaire sur 6 { $enabled ->
    [on] activé.
    [off] désactivé.
   *[other] mis à jour.
}
trouble-option-desc-extra-turn-on-six =
    Activé, un 6 donne un tour supplémentaire (règle classique Hasbro).

trouble-option-six-to-leave-home = Exiger un 6 pour quitter la Maison : { $enabled }
trouble-option-changed-six-to-leave-home = Six pour quitter la Maison { $enabled ->
    [on] activé.
    [off] désactivé.
   *[other] mis à jour.
}
trouble-option-desc-six-to-leave-home =
    Activé, il faut un 6 pour sortir un pion de la Maison. Désactivé, n'importe quel lancer le sort.

trouble-option-safe-spaces = Cases sûres : { $mode }
trouble-option-select-safe-spaces = Choisis le mode des cases sûres.
trouble-option-changed-safe-spaces = Cases sûres réglées sur { $mode }.
trouble-option-desc-safe-spaces = Choisis si les pions peuvent être protégés des renvois.

trouble-safe-mode-none = Aucune
trouble-safe-mode-home-stretch = Couloir d'arrivée seulement
trouble-safe-mode-every-seventh = Toutes les 7 cases

trouble-option-finish-behavior = Arrivée : { $mode }
trouble-option-select-finish-behavior = Choisis le comportement d'arrivée.
trouble-option-changed-finish-behavior = Comportement d'arrivée réglé sur { $mode }.
trouble-option-desc-finish-behavior = Comment gérer un lancer qui dépasse l'arrivée.

trouble-finish-mode-exact = Lancer exact requis
trouble-finish-mode-bounce = Le dépassement rebondit
trouble-finish-mode-allow = Dépassement autorisé

trouble-option-bot-difficulty = Difficulté du bot : { $level }
trouble-option-select-bot-difficulty = Choisis la difficulté du bot.
trouble-option-changed-bot-difficulty = Difficulté du bot réglée sur { $level }.
trouble-option-desc-bot-difficulty = Force des bots intégrés.

trouble-bot-difficulty-naive = Naïf
trouble-bot-difficulty-greedy = Avide

trouble-option-preset = Préréglage : { $preset }
trouble-option-select-preset = Choisis une variante. L'hôte peut ensuite ajuster chaque règle.
trouble-option-changed-preset = Préréglage appliqué : { $preset }.
trouble-option-desc-preset = Ensembles d'options préconfigurés pour des variantes courantes.

trouble-preset-classic = Classique Hasbro
trouble-preset-fast = Rapide
trouble-preset-brutal = Brutal
trouble-preset-custom = Personnalisé
