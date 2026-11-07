# ninetynine.ftl for locale hu. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Kilencvenkilenc
# Round
ninetynine-round = { $round }. kör.
# Playing cards - match v10 exactly
ninetynine-you-play = Játszod: { $card }. A számláló most { $count }.
ninetynine-player-plays = { $player } játssza: { $card }. A számláló most { $count }.
# Direction reverse
ninetynine-direction-reverses = A játék iránya megfordul!
# Skip
ninetynine-player-skipped = { $player } kihagyva.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Veszítesz { $amount } { $amount ->
        [one] zsetont
       *[other] zsetont
    }.
ninetynine-player-loses-tokens =
    { $player } veszít { $amount } { $amount ->
        [one] zsetont
       *[other] zsetont
    }.
# Elimination
ninetynine-player-eliminated = { $player } kiesett!
# Game end
ninetynine-player-wins = { $player } megnyeri a játékot!
# Drawing cards
ninetynine-you-draw = Húzol: { $card }.
ninetynine-player-draws = { $player } húz egy kártyát.
# No valid cards
ninetynine-no-valid-cards = { $player }nak nincs olyan kártyája, ami ne menne 99 fölé!
# Status - for C key
ninetynine-current-count = A számláló { $count }.
# Ace choice
ninetynine-ace-choice = Ász játszása +1 vagy +11 ként?
ninetynine-ace-add-eleven = Adj hozzá 11-et
ninetynine-ace-add-one = Adj hozzá 1-et
# Ten choice
ninetynine-ten-choice = 10-es játszása +10 vagy -10 értékkel?
ninetynine-ten-add = Adj hozzá 10-et
ninetynine-ten-subtract = Vonj ki 10-et
# Manual draw
ninetynine-draw-card = Kártya húzása
ninetynine-draw-prompt = Nyomd meg a szóközt vagy D-t a kártya húzásához.
# Options
ninetynine-set-tokens = Kezdő zsetonok: { $tokens }
ninetynine-enter-tokens = Add meg a kezdő zsetonok számát:
ninetynine-option-changed-tokens = Kezdő zsetonok beállítva: { $tokens }.
ninetynine-set-rules = Szabály variáns: { $rules }
ninetynine-select-rules = Válassz szabály variánst
ninetynine-option-changed-rules = Szabály variáns beállítva: { $rules }.
ninetynine-set-hand-size = Kéz méret: { $size }
ninetynine-enter-hand-size = Add meg a kéz méretet:
ninetynine-option-changed-hand-size = Kéz méret beállítva: { $size }.
ninetynine-set-autodraw = Automatikus húzás: { $enabled }
ninetynine-option-changed-autodraw = Automatikus húzás beállítva: { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Először választanod kell.
