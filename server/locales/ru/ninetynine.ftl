# ninetynine.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Девяносто девять
# Round
ninetynine-round = Раунд { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Вы разыгрываете { $card }. Текущая сумма: { $count }.
ninetynine-player-plays = { $player } разыгрывает { $card }. Текущая сумма: { $count }.
# Direction reverse
ninetynine-direction-reverses = Направление игры меняется!
# Skip
ninetynine-player-skipped = { $player } пропускает ход.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Вы теряете { $amount } { $amount ->
        [one] жетон
        [few] жетона
       *[other] жетонов
    }.
ninetynine-player-loses-tokens =
    { $player } теряет { $amount } { $amount ->
        [one] жетон
        [few] жетона
       *[other] жетонов
    }.
# Elimination
ninetynine-player-eliminated = Игрок { $player } выбывает!
# Game end
ninetynine-player-wins = { $player } побеждает в игре!
# Drawing cards
ninetynine-you-draw = Вы берёте карту: { $card }.
ninetynine-player-draws = { $player } берёт карту.
# No valid cards
ninetynine-no-valid-cards = У игрока { $player } нет карт, которые не превысили бы порог в 99 очков!
# Status - for C key
ninetynine-current-count = Текущая сумма: { $count }.
# Ace choice
ninetynine-ace-choice = Разыграть туза как +1 или как +11?
ninetynine-ace-add-eleven = Прибавить 11
ninetynine-ace-add-one = Прибавить 1
# Ten choice
ninetynine-ten-choice = Разыграть десятку как +10 или как -10?
ninetynine-ten-add = Прибавить 10
ninetynine-ten-subtract = Вычесть 10
# Manual draw
ninetynine-draw-card = Взять карту
ninetynine-draw-prompt = Нажмите Пробел или D, чтобы взять карту.
# Options
ninetynine-set-tokens = Начальные жетоны: { $tokens }
ninetynine-enter-tokens = Введите количество начальных жетонов:
ninetynine-option-changed-tokens = Начальное количество жетонов установлено на { $tokens }.
ninetynine-set-rules = Вариант правил: { $rules }
ninetynine-select-rules = Выберите вариант правил
ninetynine-option-changed-rules = Вариант правил изменён на: { $rules }.
ninetynine-set-hand-size = Карт в руке: { $size }
ninetynine-enter-hand-size = Введите количество карт в руке:
ninetynine-option-changed-hand-size = Размер руки установлен на { $size }.
ninetynine-set-autodraw = Автоматический добор карт: { $enabled }
ninetynine-option-changed-autodraw = Автоматический добор карт: { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Сначала нужно сделать выбор.
