# ninetynine.ftl for locale fr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Noms de jeux
game-name-ninetynine = Quatre-vingt-dix-neuf
# Manche
ninetynine-round = Manche { $round }.
# Jouer des cartes - correspondant exactement à v10
ninetynine-you-play = Vous jouez { $card }. Le compte est maintenant { $count }.
ninetynine-player-plays = { $player } joue { $card }. Le compte est maintenant { $count }.
# Inversion de direction
ninetynine-direction-reverses = La direction du jeu s'inverse !
# Passer
ninetynine-player-skipped = { $player } est passé.
# Perte de jetons - correspondant exactement à v10
ninetynine-you-lose-tokens =
    Vous perdez { $amount } { $amount ->
        [0] jeton
        [1] jeton
       *[other] jetons
    }.
ninetynine-player-loses-tokens =
    { $player } perd { $amount } { $amount ->
        [0] jeton
        [1] jeton
       *[other] jetons
    }.
# Élimination
ninetynine-player-eliminated = { $player } a été éliminé !
# Fin de jeu
ninetynine-player-wins = { $player } gagne le jeu !
# Piocher des cartes
ninetynine-you-draw = Vous piochez { $card }.
ninetynine-player-draws = { $player } pioche une carte.
# Pas de cartes valides
ninetynine-no-valid-cards = { $player } n'a pas de cartes qui ne dépasseraient pas 99 !
# Statut - pour la touche C
ninetynine-current-count = Le compte est { $count }.
# Choix d'As
ninetynine-ace-choice = Jouer l'As comme +1 ou +11 ?
ninetynine-ace-add-eleven = Ajouter 11
ninetynine-ace-add-one = Ajouter 1
# Choix de Dix
ninetynine-ten-choice = Jouer le 10 comme +10 ou -10 ?
ninetynine-ten-add = Ajouter 10
ninetynine-ten-subtract = Soustraire 10
# Pioche manuelle
ninetynine-draw-card = Piocher une carte
ninetynine-draw-prompt = Appuyez sur Espace ou D pour piocher une carte.
# Options
ninetynine-set-tokens = Jetons de départ : { $tokens }
ninetynine-enter-tokens = Entrez le nombre de jetons de départ :
ninetynine-option-changed-tokens = Jetons de départ définis sur { $tokens }.
ninetynine-set-rules = Variante de règles : { $rules }
ninetynine-select-rules = Sélectionnez la variante de règles
ninetynine-option-changed-rules = Variante de règles définie sur { $rules }.
ninetynine-set-hand-size = Taille de main : { $size }
ninetynine-enter-hand-size = Entrez la taille de main :
ninetynine-option-changed-hand-size = Taille de main définie sur { $size }.
ninetynine-set-autodraw = Pioche automatique : { $enabled }
ninetynine-option-changed-autodraw = Pioche automatique définie sur { $enabled }.
# Raisons d'action désactivée
ninetynine-choose-first = Vous devez d'abord faire un choix.
