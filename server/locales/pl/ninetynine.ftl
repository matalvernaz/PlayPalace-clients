# ninetynine.ftl for locale pl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Ninety Nine
# Round
ninetynine-round = Round { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = You play { $card }. The count is now { $count }.
ninetynine-player-plays = { $player } plays { $card }. The count is now { $count }.
# Direction reverse
ninetynine-direction-reverses = The direction of play reverses!
# Skip
ninetynine-player-skipped = { $player } is skipped.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    You lose { $amount } { $amount ->
        [one] token
       *[other] tokens
    }.
ninetynine-player-loses-tokens =
    { $player } loses { $amount } { $amount ->
        [one] token
       *[other] tokens
    }.
# Elimination
ninetynine-player-eliminated = { $player } has been eliminated!
# Game end
ninetynine-player-wins = { $player } wins the game!
# Drawing cards
ninetynine-you-draw = You draw { $card }.
ninetynine-player-draws = { $player } draws a card.
# No valid cards
ninetynine-no-valid-cards = { $player } has no cards that won't go over 99!
# Status - for C key
ninetynine-current-count = The count is { $count }.
# Ace choice
ninetynine-ace-choice = Play Ace as +1 or +11?
ninetynine-ace-add-eleven = Add 11
ninetynine-ace-add-one = Add 1
# Ten choice
ninetynine-ten-choice = Play 10 as +10 or -10?
ninetynine-ten-add = Add 10
ninetynine-ten-subtract = Subtract 10
# Manual draw
ninetynine-draw-card = Draw card
ninetynine-draw-prompt = Press Space or D to draw a card.
# Options
ninetynine-set-tokens = Starting tokens: { $tokens }
ninetynine-enter-tokens = Enter number of starting tokens:
ninetynine-option-changed-tokens = Starting tokens set to { $tokens }.
ninetynine-set-rules = Rules variant: { $rules }
ninetynine-select-rules = Select rules variant
ninetynine-option-changed-rules = Rules variant set to { $rules }.
ninetynine-set-hand-size = Hand size: { $size }
ninetynine-enter-hand-size = Enter hand size:
ninetynine-option-changed-hand-size = Hand size set to { $size }.
ninetynine-set-autodraw = Automatic drawing: { $enabled }
ninetynine-option-changed-autodraw = Automatic drawing set to { $enabled }.
# Disabled action reasons
ninetynine-choose-first = You need to make a choice first.
