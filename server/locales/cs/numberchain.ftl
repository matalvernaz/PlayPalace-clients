# Number Chain — cs
# AI-translated, native review pending — corrections welcome.

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } je hráč 1, { $p2 } je hráč 2. Začíná { $first }. Polož 1 kamkoliv pro zahájení řetězu.

# Placement
numberchain-place-you = Pokládáš { $number } na řádek { $row }, sloupec { $col }.
numberchain-place-other = { $player } pokládá { $number } na řádek { $row }, sloupec { $col }.

# Errors
numberchain-illegal-move = Tento tah není dovolen.

# Status / info
numberchain-status = Na tahu je { $current }. Další číslo: { $required }.
numberchain-inventory = Tvé zbývající kameny: { $inventory }.
numberchain-required = Další číslo k položení: { $required }.

# Square labels
numberchain-sq-empty = Řádek { $row }, sloupec { $col }, prázdný
numberchain-sq-own = Řádek { $row }, sloupec { $col }, { $number }, tvoje
numberchain-sq-opponent = Řádek { $row }, sloupec { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Stav
numberchain-check-inventory = Inventář
numberchain-check-required = Další číslo

# Win
numberchain-wins = { $player } vyhrává! Soupeř nemá žádné legální tahy.
numberchain-final = { $winner } vyhrává.

# Options
numberchain-option-bot-difficulty = Obtížnost bota: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Vyber obtížnost bota
numberchain-option-changed-bot-difficulty = Obtížnost bota nastavena na { $bot_difficulty }.
numberchain-difficulty-random = Náhodná
numberchain-difficulty-simple = Jednoduchá
