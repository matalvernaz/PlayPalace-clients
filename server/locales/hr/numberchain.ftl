# Number Chain — hr
# AI-translated, native review pending — corrections welcome.

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } je igrač 1, { $p2 } je igrač 2. Počinje { $first }. Stavi 1 bilo gdje da započneš lanac.

# Placement
numberchain-place-you = Stavljaš { $number } u red { $row }, stupac { $col }.
numberchain-place-other = { $player } stavlja { $number } u red { $row }, stupac { $col }.

# Errors
numberchain-illegal-move = Taj potez nije dopušten.

# Status / info
numberchain-status = { $current } je na potezu. Sljedeći broj: { $required }.
numberchain-inventory = Tvoje preostale pločice: { $inventory }.
numberchain-required = Sljedeći broj za postavljanje: { $required }.

# Square labels
numberchain-sq-empty = Red { $row }, stupac { $col }, prazno
numberchain-sq-own = Red { $row }, stupac { $col }, { $number }, tvoje
numberchain-sq-opponent = Red { $row }, stupac { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Status
numberchain-check-inventory = Inventar
numberchain-check-required = Sljedeći broj

# Win
numberchain-wins = { $player } pobjeđuje! Protivnik nema legalnih poteza.
numberchain-final = { $winner } pobjeđuje.

# Options
numberchain-option-bot-difficulty = Težina bota: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Odaberi težinu bota
numberchain-option-changed-bot-difficulty = Težina bota postavljena na { $bot_difficulty }.
numberchain-difficulty-random = Nasumično
numberchain-difficulty-simple = Jednostavno
