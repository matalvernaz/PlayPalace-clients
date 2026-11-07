# leftrightcenter.ftl for locale hu. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Bal Jobb Közép
# Actions
lrc-roll =
    Dobj { $count } { $count ->
        [one] kockával
       *[other] kockával
    }
# Dice faces
lrc-face-left = Bal
lrc-face-center = Közép
lrc-face-right = Jobb
lrc-face-dot = Pont
lrc-center-pot =
    { $count } { $count ->
        [one] zseton
       *[other] zseton
    } a középen.
# Options
lrc-set-starting-chips = Kezdő zsetonok: { $count }
lrc-enter-starting-chips = Add meg a kezdő zsetonokat:
lrc-option-changed-starting-chips = Kezdő zsetonok { $count }-ra állítva.
