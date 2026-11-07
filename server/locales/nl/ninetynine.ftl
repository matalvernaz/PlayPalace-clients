# ninetynine.ftl for locale nl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Ninety Nine
# Round
ninetynine-round = Ronde { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Je speelt { $card }. De telling is nu { $count }.
ninetynine-player-plays = { $player } speelt { $card }. De telling is nu { $count }.
# Direction reverse
ninetynine-direction-reverses = De speelrichting draait om!
# Skip
ninetynine-player-skipped = { $player } wordt overgeslagen.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Je verliest { $amount } { $amount ->
        [one] token
       *[other] tokens
    }.
ninetynine-player-loses-tokens =
    { $player } verliest { $amount } { $amount ->
        [one] token
       *[other] tokens
    }.
# Elimination
ninetynine-player-eliminated = { $player } is geëlimineerd!
# Game end
ninetynine-player-wins = { $player } wint het spel!
# Drawing cards
ninetynine-you-draw = Je trekt { $card }.
ninetynine-player-draws = { $player } trekt een kaart.
# No valid cards
ninetynine-no-valid-cards = { $player } heeft geen kaarten die niet boven de 99 uitkomen!
# Status - for C key
ninetynine-current-count = De telling is { $count }.
# Ace choice
ninetynine-ace-choice = Speel Aas als +1 of +11?
ninetynine-ace-add-eleven = Tel 11 op
ninetynine-ace-add-one = Tel 1 op
# Ten choice
ninetynine-ten-choice = Speel 10 als +10 of -10?
ninetynine-ten-add = Tel 10 op
ninetynine-ten-subtract = Trek 10 af
# Manual draw
ninetynine-draw-card = Trek kaart
ninetynine-draw-prompt = Druk op Spatie of D om een kaart te trekken.
# Options
ninetynine-set-tokens = Starttokens: { $tokens }
ninetynine-enter-tokens = Voer aantal starttokens in:
ninetynine-option-changed-tokens = Starttokens ingesteld op { $tokens }.
ninetynine-set-rules = Regelsvariant: { $rules }
ninetynine-select-rules = Selecteer regelsvariant
ninetynine-option-changed-rules = Regelsvariant ingesteld op { $rules }.
ninetynine-set-hand-size = Handgrootte: { $size }
ninetynine-enter-hand-size = Voer handgrootte in:
ninetynine-option-changed-hand-size = Handgrootte ingesteld op { $size }.
ninetynine-set-autodraw = Automatisch trekken: { $enabled }
ninetynine-option-changed-autodraw = Automatisch trekken ingesteld op { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Je moet eerst een keuze maken.
