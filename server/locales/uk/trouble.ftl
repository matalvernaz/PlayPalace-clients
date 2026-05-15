# Trouble — uk
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble — це перегонова гра з родини Parcheesi.
    Кожен гравець починає з фішками в зоні Дому.
    У свій хід натисни кубик і пересунь одну зі своїх фішок.
    За замовчуванням треба викинути 6, щоб випустити фішку з Дому на доріжку.
    За замовчуванням 6 також дає додатковий хід.
    Фішки рухаються за годинниковою стрілкою спільною доріжкою до зони фінішу.
    Приземлення на фішку суперника відсилає її назад до його Дому, якщо клітинка не захищена.
    Коли всі ваші фішки доходять до фінішу, ви виграєте.
    У командному режимі ваша команда перемагає, коли всі співкомандники закінчили.
    Клавіші 1-6 обирають фішку, R кидає.
    Натисніть E у будь-який момент, щоб почути повний стан дошки.

trouble-action-roll = Натиснути кубик
trouble-action-move-token = Пересунути фішку { $token }
trouble-action-check-board = Перевірити дошку

trouble-token-label-home = Фішка { $token }: у Домі
trouble-token-label-track = Фішка { $token }: клітинка { $position } доріжки
trouble-token-label-finish-lane = Фішка { $token }: фінішна смуга { $position } з { $total }
trouble-token-label-finished = Фішка { $token }: завершила

trouble-rolled = { $player } викинув { $roll }.
trouble-leave-home = { $player } випускає фішку { $token } на доріжку.
trouble-advance-track = { $player } пересуває фішку { $token } на клітинку { $position }.
trouble-enter-finish-lane = { $player } вводить фішку { $token } на фінішну смугу.
trouble-advance-finish-lane =
    { $player } просуває фішку { $token } на клітинку { $position } з { $total } фінішної смуги.
trouble-token-finished = Фішка { $token } гравця { $player } досягла фінішу.
trouble-bump =
    Фішка { $token } гравця { $player } відсилає фішку { $opp_token } гравця { $opponent } додому.
trouble-no-legal-move = У { $player } немає легальних ходів. Хід переходить.
trouble-extra-turn = { $player } отримує додатковий хід за 6.

trouble-winner = { $player } перемагає! Усі фішки на фініші.
trouble-team-winner = Команда { $team } перемагає! Усі співкомандники закінчили.
trouble-final-standing = { $player }: { $finished } з { $total } фішок завершено.

trouble-turn-summary =
    У вас { $own_home } удома, { $own_track } на доріжці, { $own_finished } на фініші.
    Супротивники: { $opponents }.
trouble-opponent-summary = { $name }: { $home } дім, { $track } доріжка, { $finished } фініш

trouble-board-status =
    Ваші фішки: { $own_tokens }.
    Фішки супротивників: { $opp_tokens }.

trouble-reason-not-rolled = Спочатку натисніть кубик.
trouble-reason-already-rolled = Ви вже натиснули. Оберіть фішку для пересування.
trouble-reason-no-legal-moves = Для цього кидка немає легальних ходів.
trouble-reason-token-home-needs-six = Ця фішка вдома. Потрібно 6 для випуску.
trouble-reason-token-home-needs-any = Ця фішка вдома. Будь-який кидок випускає.
trouble-reason-token-home-no-qualifying-roll =
    Ця фішка вдома, а ваш кидок не відповідає умові випуску.
trouble-reason-token-finished = Ця фішка вже завершила.
trouble-reason-overshoot-wastes = Ця фішка не може пройти { $roll } клітинок, не перетнувши фініш.
trouble-reason-blocked = Цей хід заблоковано.

trouble-option-track-size = Розмір доріжки: { $track_size } клітинок
trouble-option-select-track-size = Виберіть число клітинок доріжки.
trouble-option-changed-track-size = Доріжка задана: { $track_size } клітинок.
trouble-option-desc-track-size = Число клітинок на спільній доріжці.

trouble-option-tokens-per-player = Фішок на гравця: { $tokens }
trouble-option-enter-tokens-per-player = Введіть число фішок на гравця (2-6):
trouble-option-changed-tokens-per-player = Фішок на гравця: { $tokens }.
trouble-option-desc-tokens-per-player = Скільки фішок кожен гравець веде до фінішу.

trouble-option-extra-turn-on-six = Дод. хід при 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Дод. хід при 6 { $enabled ->
    [on] увімкнено.
    [off] вимкнено.
   *[other] оновлено.
}
trouble-option-desc-extra-turn-on-six =
    Увімкнено: 6 дає додатковий хід (класичне правило Hasbro).

trouble-option-six-to-leave-home = Вимагати 6 для виходу з Дому: { $enabled }
trouble-option-changed-six-to-leave-home = Шістка для виходу з Дому { $enabled ->
    [on] увімкнено.
    [off] вимкнено.
   *[other] оновлено.
}
trouble-option-desc-six-to-leave-home =
    Увімкнено: гравцю потрібно 6 для випуску фішки. Вимкнено: будь-який кидок випускає.

trouble-option-safe-spaces = Безпечні клітинки: { $mode }
trouble-option-select-safe-spaces = Виберіть режим безпечних клітинок.
trouble-option-changed-safe-spaces = Безпечні клітинки: { $mode }.
trouble-option-desc-safe-spaces = Виберіть, чи захищені фішки від ударів.

trouble-safe-mode-none = Немає
trouble-safe-mode-home-stretch = Тільки фінішна пряма
trouble-safe-mode-every-seventh = Кожна 7-а клітинка

trouble-option-finish-behavior = Фініш: { $mode }
trouble-option-select-finish-behavior = Виберіть поведінку фінішу.
trouble-option-changed-finish-behavior = Поведінка фінішу: { $mode }.
trouble-option-desc-finish-behavior = Як обробляється кидок, що перевищує фініш.

trouble-finish-mode-exact = Потрібен точний кидок
trouble-finish-mode-bounce = Надлишок відскакує
trouble-finish-mode-allow = Надлишок дозволено

trouble-option-bot-difficulty = Складність бота: { $level }
trouble-option-select-bot-difficulty = Виберіть складність бота.
trouble-option-changed-bot-difficulty = Складність бота: { $level }.
trouble-option-desc-bot-difficulty = Сила вбудованих ботів.

trouble-bot-difficulty-naive = Наївний
trouble-bot-difficulty-greedy = Жадібний

trouble-option-preset = Передустановка: { $preset }
trouble-option-select-preset = Виберіть варіант. Господар потім може змінити окремі правила.
trouble-option-changed-preset = Передустановку застосовано: { $preset }.
trouble-option-desc-preset = Готові набори опцій для поширених варіантів.

trouble-preset-classic = Класичний Hasbro
trouble-preset-fast = Швидкий
trouble-preset-brutal = Жорстокий
trouble-preset-custom = Власний
