# leftrightcenter.ftl for locale sv. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Vänster Höger Mitten
# Actions
lrc-roll =
    Kasta { $count } { $count ->
        [one] tärning
       *[other] tärningar
    }
# Dice faces
lrc-face-left = Vänster
lrc-face-center = Mitten
lrc-face-right = Höger
lrc-face-dot = Prick
lrc-center-pot =
    { $count } { $count ->
        [one] mark
       *[other] marker
    } i mitten.
# Options
lrc-set-starting-chips = Startmarker: { $count }
lrc-enter-starting-chips = Ange startmarker:
lrc-option-changed-starting-chips = Startmarker inställda på { $count }.
