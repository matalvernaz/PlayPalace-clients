# farkle.ftl for locale uk. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-farkle = Фаркл
# Actions - Roll and Bank
farkle-roll =
    Кинути { $count } { $count ->
        [one] кубик
       *[other] кубиків
    }
farkle-bank = Зберегти { $points } очок
# Scoring combination actions (matching v10 exactly)
farkle-take-single-one = Одна 1 за { $points } очок
farkle-take-single-five = Одна 5 за { $points } очок
farkle-take-three-kind = Три { $number } за { $points } очок
farkle-take-four-kind = Чотири { $number } за { $points } очок
farkle-take-five-kind = П'ять { $number } за { $points } очок
farkle-take-six-kind = Шість { $number } за { $points } очок
farkle-take-small-straight = Малий стріт за { $points } очок
farkle-take-large-straight = Великий стріт за { $points } очок
farkle-take-three-pairs = Три пари за { $points } очок
farkle-take-double-triplets = Подвійні трійки за { $points } очок
farkle-take-full-house = Фул-хаус за { $points } очок
farkle-you-roll =
    Ви кидаєте { $count } { $count ->
        [one] кубик
       *[other] кубиків
    }...
farkle-roll-result = { $dice }
farkle-you-farkle = ФАРКЛ! Ви втрачаєте { $points } очок
farkle-you-take-combo = Ви берете { $combo } за { $points } очок
farkle-you-bank = Ви зберігаєте { $points } очок, всього { $total }
farkle-you-win = Ви перемагаєте з { $score } очками!
farkle-winner = { $player } перемагає з { $score } очками!
farkle-winners-tie = У нас нічия! Переможці: { $players }
# Check turn score action
farkle-turn-score = { $player } має { $points } очок цього ходу.
farkle-no-turn = Наразі ніхто не робить хід.
# Farkle-specific options
farkle-set-target-score = Цільовий рахунок: { $score }
farkle-enter-target-score = Введіть цільовий рахунок (500-5000):
farkle-option-changed-target = Цільовий рахунок встановлено на { $score }.
# Disabled action reasons
farkle-must-take-combo = Спочатку ви повинні взяти рахункову комбінацію.
farkle-cannot-bank = Ви не можете зберегти зараз.
