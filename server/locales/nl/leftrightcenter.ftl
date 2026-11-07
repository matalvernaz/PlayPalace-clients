# leftrightcenter.ftl for locale nl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Left Right Center
# Actions
lrc-roll =
    Gooi { $count } { $count ->
        [one] dobbelsteen
       *[other] dobbelstenen
    }
# Dice faces
lrc-face-left = Links
lrc-face-center = Midden
lrc-face-right = Rechts
lrc-face-dot = Stip
lrc-center-pot =
    { $count } { $count ->
        [one] fiche
       *[other] fiches
    } in het midden.
# Options
lrc-set-starting-chips = Startfiches: { $count }
lrc-enter-starting-chips = Voer startfiches in:
lrc-option-changed-starting-chips = Startfiches ingesteld op { $count }.
