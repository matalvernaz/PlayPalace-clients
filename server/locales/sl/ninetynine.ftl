# ninetynine.ftl for locale sl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Devetindevetdeset
# Round
ninetynine-round = Krog { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Igrate { $card }. Števec je zdaj { $count }.
ninetynine-player-plays = { $player } igra { $card }. Števec je zdaj { $count }.
# Direction reverse
ninetynine-direction-reverses = Smer igre se obrne!
# Skip
ninetynine-player-skipped = { $player } je preskočen.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Izgubite { $amount } { $amount ->
        [one] žeton
       *[other] žetonov
    }.
ninetynine-player-loses-tokens =
    { $player } izgubi { $amount } { $amount ->
        [one] žeton
       *[other] žetonov
    }.
# Elimination
ninetynine-player-eliminated = { $player } je bil izločen!
# Game end
ninetynine-player-wins = { $player } zmaga igro!
# Drawing cards
ninetynine-you-draw = Vlečete { $card }.
ninetynine-player-draws = { $player } vleče karto.
# No valid cards
ninetynine-no-valid-cards = { $player } nima kart, ki ne bi presegle 99!
# Status - for C key
ninetynine-current-count = Števec je { $count }.
# Ace choice
ninetynine-ace-choice = Igrajte asa kot +1 ali +11?
ninetynine-ace-add-eleven = Dodaj 11
ninetynine-ace-add-one = Dodaj 1
# Ten choice
ninetynine-ten-choice = Igrajte 10 kot +10 ali -10?
ninetynine-ten-add = Dodaj 10
ninetynine-ten-subtract = Odštej 10
# Manual draw
ninetynine-draw-card = Vleci karto
ninetynine-draw-prompt = Pritisnite preslednico ali D za vleko karte.
# Options
ninetynine-set-tokens = Začetni žetoni: { $tokens }
ninetynine-enter-tokens = Vnesite število začetnih žetonov:
ninetynine-option-changed-tokens = Začetni žetoni nastavljeni na { $tokens }.
ninetynine-set-rules = Različica pravil: { $rules }
ninetynine-select-rules = Izberite različico pravil
ninetynine-option-changed-rules = Različica pravil nastavljena na { $rules }.
ninetynine-set-hand-size = Velikost roke: { $size }
ninetynine-enter-hand-size = Vnesite velikost roke:
ninetynine-option-changed-hand-size = Velikost roke nastavljena na { $size }.
ninetynine-set-autodraw = Samodejno vlečenje: { $enabled }
ninetynine-option-changed-autodraw = Samodejno vlečenje nastavljeno na { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Najprej morate narediti izbiro.
