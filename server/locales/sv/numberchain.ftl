# Number Chain — sv
# AI-translated, native review pending — corrections welcome.

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } är spelare 1, { $p2 } är spelare 2. { $first } börjar. Lägg en 1:a var som helst för att starta kedjan.

# Placement
numberchain-place-you = Du lägger { $number } på rad { $row }, kolumn { $col }.
numberchain-place-other = { $player } lägger { $number } på rad { $row }, kolumn { $col }.

# Errors
numberchain-illegal-move = Det draget är inte tillåtet.

# Status / info
numberchain-status = Det är { $current }s tur. Nästa siffra: { $required }.
numberchain-inventory = Dina återstående brickor: { $inventory }.
numberchain-required = Nästa siffra att lägga: { $required }.

# Square labels
numberchain-sq-empty = Rad { $row }, kolumn { $col }, tom
numberchain-sq-own = Rad { $row }, kolumn { $col }, { $number }, din
numberchain-sq-opponent = Rad { $row }, kolumn { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Status
numberchain-check-inventory = Inventarium
numberchain-check-required = Nästa siffra

# Win
numberchain-wins = { $player } vinner! Motståndaren har inga lagliga drag.
numberchain-final = { $winner } vinner.

# Options
numberchain-option-bot-difficulty = Bot-svårighet: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Välj bot-svårighet
numberchain-option-changed-bot-difficulty = Bot-svårighet inställd på { $bot_difficulty }.
numberchain-difficulty-random = Slumpmässig
numberchain-difficulty-simple = Enkel
