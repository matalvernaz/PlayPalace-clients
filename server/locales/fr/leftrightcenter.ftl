# leftrightcenter.ftl for locale fr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Nom du jeu
game-name-leftrightcenter = Left Right Center
# Actions
lrc-roll =
    Lancer { $count } { $count ->
        [0] dé
        [1] dé
       *[other] dés
    }
# Faces des dés
lrc-face-left = Gauche
lrc-face-center = Centre
lrc-face-right = Droite
lrc-face-dot = Point
lrc-center-pot =
    { $count } { $count ->
        [0] jeton
        [1] jeton
       *[other] jetons
    } au centre.
# Options
lrc-set-starting-chips = Jetons de départ : { $count }
lrc-enter-starting-chips = Entrez les jetons de départ :
lrc-option-changed-starting-chips = Jetons de départ définis sur { $count }.
