# leftrightcenter.ftl for locale pl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Left Right Center
# Actions
lrc-roll =
    Roll { $count } { $count ->
        [one] die
       *[other] dice
    }
# Dice faces
lrc-face-left = Left
lrc-face-center = Center
lrc-face-right = Right
lrc-face-dot = Dot
lrc-center-pot =
    { $count } { $count ->
        [one] chip
       *[other] chips
    } in the center.
# Options
lrc-set-starting-chips = Starting chips: { $count }
lrc-enter-starting-chips = Enter starting chips:
lrc-option-changed-starting-chips = Starting chips set to { $count }.
