# Number Chain localization

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } is player 1, { $p2 } is player 2. { $first } goes first. Place a 1 anywhere to begin the chain.

# Placement
numberchain-place-you = You place { $number } at row { $row }, column { $col }.
numberchain-place-other = { $player } places { $number } at row { $row }, column { $col }.

# Errors
numberchain-illegal-move = That move is not legal.

# Status / info
numberchain-status = { $current } to play. Next number: { $required }.
numberchain-inventory = Your remaining tiles: { $inventory }.
numberchain-required = Next number to place: { $required }.

# Square labels
numberchain-sq-empty = Row { $row }, column { $col }, empty
numberchain-sq-own = Row { $row }, column { $col }, { $number }, yours
numberchain-sq-opponent = Row { $row }, column { $col }, { $number }, { $owner }

# Action labels (used by the keybind list)
numberchain-check-status = Status
numberchain-check-inventory = Inventory
numberchain-check-required = Next number

# Win
numberchain-wins = { $player } wins! Opponent has no legal moves.
numberchain-final = { $winner } wins.

# Options
numberchain-option-bot-difficulty = Bot difficulty: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Select bot difficulty
numberchain-option-changed-bot-difficulty = Bot difficulty set to { $bot_difficulty }.
numberchain-difficulty-random = Random
numberchain-difficulty-simple = Simple
