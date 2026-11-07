# ninetynine.ftl for locale uk. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Дев'яносто дев'ять
# Round
ninetynine-round = Раунд { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Ви граєте { $card }. Рахунок тепер { $count }.
ninetynine-player-plays = { $player } грає { $card }. Рахунок тепер { $count }.
# Direction reverse
ninetynine-direction-reverses = Напрямок гри змінюється!
# Skip
ninetynine-player-skipped = { $player } пропущений.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Ви втрачаєте { $amount } { $amount ->
        [one] жетон
       *[other] жетонів
    }.
ninetynine-player-loses-tokens =
    { $player } втрачає { $amount } { $amount ->
        [one] жетон
       *[other] жетонів
    }.
# Elimination
ninetynine-player-eliminated = { $player } вибув!
# Game end
ninetynine-player-wins = { $player } виграє гру!
# Drawing cards
ninetynine-you-draw = Ви берете { $card }.
ninetynine-player-draws = { $player } бере карту.
# No valid cards
ninetynine-no-valid-cards = { $player } не має карт, які не перевищать 99!
# Status - for C key
ninetynine-current-count = Рахунок { $count }.
# Ace choice
ninetynine-ace-choice = Грати туза як +1 або +11?
ninetynine-ace-add-eleven = Додати 11
ninetynine-ace-add-one = Додати 1
# Ten choice
ninetynine-ten-choice = Грати 10 як +10 або -10?
ninetynine-ten-add = Додати 10
ninetynine-ten-subtract = Відняти 10
# Manual draw
ninetynine-draw-card = Взяти карту
ninetynine-draw-prompt = Натисніть Пробіл або D, щоб взяти карту.
# Options
ninetynine-set-tokens = Початкові жетони: { $tokens }
ninetynine-enter-tokens = Введіть кількість початкових жетонів:
ninetynine-option-changed-tokens = Початкові жетони встановлено на { $tokens }.
ninetynine-set-rules = Варіант правил: { $rules }
ninetynine-select-rules = Виберіть варіант правил
ninetynine-option-changed-rules = Варіант правил встановлено на { $rules }.
ninetynine-set-hand-size = Розмір руки: { $size }
ninetynine-enter-hand-size = Введіть розмір руки:
ninetynine-option-changed-hand-size = Розмір руки встановлено на { $size }.
ninetynine-set-autodraw = Автоматичне взяття: { $enabled }
ninetynine-option-changed-autodraw = Автоматичне взяття встановлено на { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Спочатку потрібно зробити вибір.
