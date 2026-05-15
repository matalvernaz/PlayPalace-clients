# Number Chain — ru

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } — игрок 1, { $p2 } — игрок 2. Первым ходит { $first }. Поставьте 1 в любое место, чтобы начать цепочку.

# Placement
numberchain-place-you = Вы ставите { $number } в строку { $row }, столбец { $col }.
numberchain-place-other = { $player } ставит { $number } в строку { $row }, столбец { $col }.

# Errors
numberchain-illegal-move = Этот ход недопустим.

# Status / info
numberchain-status = Ход { $current }. Следующее число: { $required }.
numberchain-inventory = Ваши оставшиеся плитки: { $inventory }.
numberchain-required = Следующее число для размещения: { $required }.

# Square labels
numberchain-sq-empty = Строка { $row }, столбец { $col }, пусто
numberchain-sq-own = Строка { $row }, столбец { $col }, { $number }, ваше
numberchain-sq-opponent = Строка { $row }, столбец { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Статус
numberchain-check-inventory = Инвентарь
numberchain-check-required = Следующее число

# Win
numberchain-wins = { $player } побеждает! У соперника нет допустимых ходов.
numberchain-final = { $winner } побеждает.

# Options
numberchain-option-bot-difficulty = Сложность бота: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Выбрать сложность бота
numberchain-option-changed-bot-difficulty = Сложность бота изменена на { $bot_difficulty }.
numberchain-difficulty-random = Случайная
numberchain-difficulty-simple = Простая
