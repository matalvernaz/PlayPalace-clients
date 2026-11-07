# leftrightcenter.ftl for locale it. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Sinistra Destra Centro
# Actions
lrc-roll =
    Tira { $count } { $count ->
        [one] dado
       *[other] dadi
    }
# Dice faces
lrc-face-left = Sinistra
lrc-face-center = Centro
lrc-face-right = Destra
lrc-face-dot = Punto
lrc-center-pot =
    { $count } { $count ->
        [one] fiche
       *[other] fiches
    } al centro.
# Options
lrc-set-starting-chips = Fiches iniziali: { $count }
lrc-enter-starting-chips = Inserisci fiches iniziali:
lrc-option-changed-starting-chips = Fiches iniziali impostate a { $count }.
