# leftrightcenter.ftl for locale cs. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Vlevo Vpravo Střed
# Actions
lrc-roll =
    Hodit { $count } { $count ->
        [one] kostkou
        [few] kostkami
        [many] kostkami
       *[other] kostkami
    }
# Dice faces
lrc-face-left = Vlevo
lrc-face-center = Střed
lrc-face-right = Vpravo
lrc-face-dot = Tečka
lrc-center-pot =
    { $count } { $count ->
        [one] žeton
        [few] žetony
        [many] žetonů
       *[other] žetonů
    } ve středu.
# Options
lrc-set-starting-chips = Počáteční žetony: { $count }
lrc-enter-starting-chips = Zadejte počáteční žetony:
lrc-option-changed-starting-chips = Počáteční žetony nastaveny na { $count }.
