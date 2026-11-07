# ninetynine.ftl for locale sk. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Deväťdesiatdeväť
# Round
ninetynine-round = Kolo { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Hráte { $card }. Počítadlo je teraz { $count }.
ninetynine-player-plays = { $player } hrá { $card }. Počítadlo je teraz { $count }.
# Direction reverse
ninetynine-direction-reverses = Smer hry sa otáča!
# Skip
ninetynine-player-skipped = { $player } je preskočený.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Strácate { $amount } { $amount ->
        [one] žetón
        [few] žetóny
        [many] žetónov
       *[other] žetónov
    }.
ninetynine-player-loses-tokens =
    { $player } stráca { $amount } { $amount ->
        [one] žetón
        [few] žetóny
        [many] žetónov
       *[other] žetónov
    }.
# Elimination
ninetynine-player-eliminated = { $player } bol vyradený!
# Game end
ninetynine-player-wins = { $player } vyhráva hru!
# Drawing cards
ninetynine-you-draw = Ťaháte { $card }.
ninetynine-player-draws = { $player } ťahá kartu.
# No valid cards
ninetynine-no-valid-cards = { $player } nemá karty, ktoré by neprešli 99!
# Status - for C key
ninetynine-current-count = Počítadlo je { $count }.
# Ace choice
ninetynine-ace-choice = Zahrať eso ako +1 alebo +11?
ninetynine-ace-add-eleven = Pridať 11
ninetynine-ace-add-one = Pridať 1
# Ten choice
ninetynine-ten-choice = Zahrať 10 ako +10 alebo -10?
ninetynine-ten-add = Pridať 10
ninetynine-ten-subtract = Odčítať 10
# Manual draw
ninetynine-draw-card = Ťahnúť kartu
ninetynine-draw-prompt = Stlačte medzerník alebo D pre ťahanie karty.
# Options
ninetynine-set-tokens = Začiatočné žetóny: { $tokens }
ninetynine-enter-tokens = Zadajte počet začiatočných žetónov:
ninetynine-option-changed-tokens = Začiatočné žetóny nastavené na { $tokens }.
ninetynine-set-rules = Varianta pravidiel: { $rules }
ninetynine-select-rules = Vyberte variantu pravidiel
ninetynine-option-changed-rules = Varianta pravidiel nastavená na { $rules }.
ninetynine-set-hand-size = Veľkosť ruky: { $size }
ninetynine-enter-hand-size = Zadajte veľkosť ruky:
ninetynine-option-changed-hand-size = Veľkosť ruky nastavená na { $size }.
ninetynine-set-autodraw = Automatické ťahanie: { $enabled }
ninetynine-option-changed-autodraw = Automatické ťahanie nastavené na { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Najprv musíte urobiť voľbu.
