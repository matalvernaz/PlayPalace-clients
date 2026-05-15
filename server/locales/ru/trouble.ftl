# Trouble — ru
game-name-trouble = Trouble

trouble-rules =
    Trouble — это гонка из семейства Parcheesi.
    Каждый игрок начинает со своими фишками в Доме.
    В свой ход вы запускаете кубик и перемещаете одну из своих фишек.
    По умолчанию нужно выбросить 6, чтобы выпустить фишку из Дома на дорожку.
    По умолчанию 6 также даёт дополнительный ход.
    Фишки движутся по часовой стрелке по общей дорожке к зоне финиша.
    Попадание на фишку соперника отправляет её обратно в Дом, если только клетка не защищена.
    Когда все ваши фишки достигают финиша, вы побеждаете.
    В режиме команд ваша команда побеждает, когда все её члены закончили.
    Используйте клавиши 1-6 для выбора фишки или R для броска.
    Нажмите E, чтобы услышать полное состояние стола в любой момент.

trouble-action-roll = Запустить кубик
trouble-action-move-token = Двигать фишку { $token }
trouble-action-check-board = Посмотреть стол

trouble-token-label-home = Фишка { $token }: в Доме
trouble-token-label-track = Фишка { $token }: клетка { $position } дорожки
trouble-token-label-finish-lane = Фишка { $token }: финишная полоса { $position } из { $total }
trouble-token-label-finished = Фишка { $token }: финиш

trouble-rolled = { $player } выбросил { $roll }.
trouble-leave-home = { $player } выпускает фишку { $token } на дорожку.
trouble-advance-track = { $player } перемещает фишку { $token } на клетку { $position }.
trouble-enter-finish-lane = { $player } заводит фишку { $token } на финишную полосу.
trouble-advance-finish-lane =
    { $player } продвигает фишку { $token } на клетку { $position } из { $total } финишной полосы.
trouble-token-finished = Фишка { $token } игрока { $player } достигает финиша.
trouble-bump =
    Фишка { $token } игрока { $player } отправляет фишку { $opp_token } игрока { $opponent } обратно в Дом.
trouble-no-legal-move = У { $player } нет допустимых ходов. Ход переходит.
trouble-extra-turn = { $player } получает дополнительный ход за 6.

trouble-winner = { $player } побеждает! Все фишки на финише.
trouble-team-winner = Команда { $team } побеждает! Все товарищи закончили.
trouble-final-standing = { $player }: { $finished } из { $total } фишек на финише.

trouble-turn-summary =
    У вас { $own_home } в Доме, { $own_track } на дорожке, { $own_finished } на финише.
    Соперники: { $opponents }.
trouble-opponent-summary = { $name }: { $home } дом, { $track } дорожка, { $finished } финиш

trouble-board-status =
    Ваши фишки: { $own_tokens }.
    Фишки соперников: { $opp_tokens }.

trouble-reason-not-rolled = Сначала запустите кубик.
trouble-reason-already-rolled = Вы уже бросили. Выберите фишку для хода.
trouble-reason-no-legal-moves = Нет допустимых ходов для этого броска.
trouble-reason-token-home-needs-six = Эта фишка в Доме. Нужна 6, чтобы её выпустить.
trouble-reason-token-home-needs-any = Эта фишка в Доме. Любой бросок её выпустит.
trouble-reason-token-home-no-qualifying-roll =
    Эта фишка в Доме, а ваш бросок не позволяет её выпустить.
trouble-reason-token-finished = Эта фишка уже на финише.
trouble-reason-overshoot-wastes = Эта фишка не может пройти { $roll } клеток, не выйдя за финиш.
trouble-reason-blocked = Этот ход заблокирован.

trouble-option-track-size = Размер дорожки: { $track_size } клеток
trouble-option-select-track-size = Выберите число клеток дорожки.
trouble-option-changed-track-size = Дорожка задана: { $track_size } клеток.
trouble-option-desc-track-size = Число клеток на общей дорожке.

trouble-option-tokens-per-player = Фишек на игрока: { $tokens }
trouble-option-enter-tokens-per-player = Введите число фишек на игрока (2-6):
trouble-option-changed-tokens-per-player = Фишек на игрока: { $tokens }.
trouble-option-desc-tokens-per-player = Сколько фишек каждый игрок ведёт к финишу.

trouble-option-extra-turn-on-six = Доп. ход при 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Доп. ход при 6 { $enabled ->
    [on] включён.
    [off] выключен.
   *[other] обновлён.
}
trouble-option-desc-extra-turn-on-six =
    Включено: 6 даёт дополнительный ход (классическое правило Hasbro).

trouble-option-six-to-leave-home = Требовать 6 для выхода из Дома: { $enabled }
trouble-option-changed-six-to-leave-home = Шесть для выхода из Дома { $enabled ->
    [on] включено.
    [off] выключено.
   *[other] обновлено.
}
trouble-option-desc-six-to-leave-home =
    Включено: чтобы выпустить фишку из Дома, нужен 6. Выключено: любой бросок выпускает.

trouble-option-safe-spaces = Безопасные клетки: { $mode }
trouble-option-select-safe-spaces = Выберите режим безопасных клеток.
trouble-option-changed-safe-spaces = Безопасные клетки: { $mode }.
trouble-option-desc-safe-spaces = Решите, можно ли защитить фишки от ударов.

trouble-safe-mode-none = Нет
trouble-safe-mode-home-stretch = Только финишная прямая
trouble-safe-mode-every-seventh = Каждая 7-я клетка

trouble-option-finish-behavior = Финиш: { $mode }
trouble-option-select-finish-behavior = Выберите поведение финиша.
trouble-option-changed-finish-behavior = Поведение финиша: { $mode }.
trouble-option-desc-finish-behavior = Как обрабатывается бросок, превышающий финиш.

trouble-finish-mode-exact = Нужен точный бросок
trouble-finish-mode-bounce = Перебор отскакивает
trouble-finish-mode-allow = Перебор разрешён

trouble-option-bot-difficulty = Сложность бота: { $level }
trouble-option-select-bot-difficulty = Выберите сложность бота.
trouble-option-changed-bot-difficulty = Сложность бота: { $level }.
trouble-option-desc-bot-difficulty = Сила встроенных ботов.

trouble-bot-difficulty-naive = Наивный
trouble-bot-difficulty-greedy = Жадный

trouble-option-preset = Предустановка: { $preset }
trouble-option-select-preset = Выберите вариант. Хост может изменить отдельные правила.
trouble-option-changed-preset = Предустановка применена: { $preset }.
trouble-option-desc-preset = Готовые наборы опций для распространённых вариантов.

trouble-preset-classic = Классический Hasbro
trouble-preset-fast = Быстрый
trouble-preset-brutal = Жестокий
trouble-preset-custom = Свой
