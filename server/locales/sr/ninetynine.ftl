# ninetynine.ftl for locale sr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Devedeset devet
# Round
ninetynine-round = Runda { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Igrate { $card }. Zbir je sada { $count }.
ninetynine-player-plays = { $player } igra { $card }. Zbir je sada { $count }.
# Direction reverse
ninetynine-direction-reverses = Pravac poteza je obrnut!
# Skip
ninetynine-player-skipped = { $player } se preskače.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Gubite { $amount } { $amount ->
        [one] žeton
       *[other] žetona
    }.
ninetynine-player-loses-tokens =
    { $player } gubi { $amount } { $amount ->
        [one] žeton
       *[other] žetona
    }.
# Elimination
ninetynine-player-eliminated = { $player } ispada!
# Game end
ninetynine-player-wins = { $player } pobeđuje!
# Drawing cards
ninetynine-you-draw = Vučete { $card }.
ninetynine-player-draws = { $player } vuče kartu.
# No valid cards
ninetynine-no-valid-cards = { $player } nema karata koje ne bi prebacile zbir iznad devedeset devet!
# Status - for C key
ninetynine-current-count = Zbir je { $count }.
# Ace choice
ninetynine-ace-choice = Igrati kec kao +1 ili kao +11?
ninetynine-ace-add-eleven = Dodaj 11
ninetynine-ace-add-one = Dodaj 1
# Ten choice
ninetynine-ten-choice = Igrati 10 kao +10 ili -10?
ninetynine-ten-add = Dodaj 10
ninetynine-ten-subtract = Oduzmi 10
# Manual draw
ninetynine-draw-card = Izvuci kartu
ninetynine-draw-prompt = Pritisnite razmak ili D da izvučete kartu.
# Options
ninetynine-set-tokens = Početni žetoni: { $tokens }
ninetynine-enter-tokens = Upišite broj početnih žetona:
ninetynine-option-changed-tokens = Početni žetoni podešeni na { $tokens }.
ninetynine-set-rules = Varijanta pravila: { $rules }
ninetynine-select-rules = Izaberite varijantu pravila
ninetynine-option-changed-rules = Varijanta pravila podešena na { $rules }.
ninetynine-set-hand-size = Veličina ruke: { $size }
ninetynine-enter-hand-size = Upišite veličinu ruke:
ninetynine-option-changed-hand-size = Veličina ruke podešena na { $size }.
ninetynine-set-autodraw = Automatsko izvlačenje: { $enabled }
ninetynine-option-changed-autodraw = Automatsko izvlačenje { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Prvo morate da izaberete.
