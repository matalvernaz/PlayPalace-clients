# Pig game messages
# Follows server/locales/STYLE_GUIDE.md.
# Shared keys (game-winner, etc.) live in games.ftl / main.ftl.

# Game info
game-name-pig = Pig
pig-category = Dice Games

# Help text shown in the in-game rules screen.
# One self-contained sentence per line — the iOS client splits on
# newlines so VoiceOver users can flick rule-by-rule.
pig-rules =
    On each turn you roll the die over and over, adding every roll to your round score.
    Bank at any time to add your round score to your total and pass the die.
    Roll a one and the round is lost — your round score zeroes out and the die passes anyway.
    First to the target score (default fifty) wins.

# Action labels (imperative, visible in the turn menu)
pig-roll = Roll the die
pig-bank = Bank { $points } points

# Turn events — first/third person split via broadcast_personal_l.
pig-you-rolled = You rolled { $roll }. Round total: { $total } points.
pig-player-rolled = { $player } rolled { $roll }. Round total: { $total } points.

pig-you-bust = You rolled a one. The round is lost — you lose { $points } round points.
pig-player-bust = { $player } rolled a one and loses { $points } round points.

pig-you-bank = You bank { $points } points. Your total is now { $total } points.
pig-player-bank = { $player } banks { $points } points. Total: { $total } points.

# Pig-specific options
pig-desc-target-score = The score needed to win the game

pig-set-min-bank = Minimum bank: { $points }
pig-desc-min-bank = Minimum round score required before banking is allowed
pig-enter-min-bank = Enter the minimum points to bank:
pig-option-changed-min-bank = Minimum bank points changed to { $points }.

pig-set-dice-sides = Dice sides: { $sides }
pig-desc-dice-sides = What type of dice to use
pig-enter-dice-sides = Enter the number of dice sides:
pig-option-changed-dice = Dice now has { $sides } sides.

# Disabled reasons
pig-need-more-points = You need more points to bank.

# Validation errors
pig-error-min-bank-too-high = Minimum bank points must be less than the target score.
