# leftrightcenter.ftl for locale sk. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Vľavo Vpravo Stred
# Actions
lrc-roll =
    Hodiť { $count } { $count ->
        [one] kockou
        [few] kockami
        [many] kockami
       *[other] kockami
    }
# Dice faces
lrc-face-left = Vľavo
lrc-face-center = Stred
lrc-face-right = Vpravo
lrc-face-dot = Bodka
lrc-center-pot =
    { $count } { $count ->
        [one] žetón
        [few] žetóny
        [many] žetónov
       *[other] žetónov
    } v strede.
# Options
lrc-set-starting-chips = Počiatočné žetóny: { $count }
lrc-enter-starting-chips = Zadajte počiatočné žetóny:
lrc-option-changed-starting-chips = Počiatočné žetóny nastavené na { $count }.
