# leftrightcenter.ftl for locale zu. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Left Right Center
# Actions
lrc-roll =
    Phonsa { $count } { $count ->
        [one] idayisi
       *[other] amadayisi
    }
# Dice faces
lrc-face-left = Kwesokunxele
lrc-face-center = Maphakathi
lrc-face-right = Kwesokudla
lrc-face-dot = Ichashazi
lrc-center-pot =
    { $count } { $count ->
        [one] i-chip
       *[other] ama-chips
    } maphakathi.
# Options
lrc-set-starting-chips = Ama-chips okuqala: { $count }
lrc-enter-starting-chips = Faka ama-chips okuqala:
lrc-option-changed-starting-chips = Ama-chips okuqala asetelwe ku-{ $count }.
