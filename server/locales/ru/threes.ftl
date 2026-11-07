# threes.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-threes = Тройки
# Actions
threes-roll = Бросить кубики
threes-bank = Зафиксировать счёт и закончить ход
threes-check-hand = Проверить кубики
# Rolling
threes-you-rolled = Вы выбросили: { $dice }
threes-player-rolled = { $player } выбрасывает: { $dice }
threes-your-dice = Ваши кубики: { $dice }
# Dice status (keeping messages now in games.ftl)
threes-no-dice-yet = Вы ещё не бросали кубики.
# Scoring
threes-you-scored =
    Вы набрали { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    } за этот ход.
threes-scored =
    { $player } набрал { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    } за этот ход.
threes-you-shot-moon = «Выстрел по луне»! Вы набрали -30 очков!
threes-shot-moon = «Выстрел по луне»! { $player } набрал -30 очков!
# Round flow
threes-round-start = Раунд { $round } из { $total }.
# Game end
threes-winner =
    { $player } побеждает с результатом { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }!
threes-tie =
    Ничья ({ $players }) с результатом { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }!
# Options
threes-set-rounds = Раундов: { $rounds }
threes-enter-rounds = Введите количество раундов:
threes-option-changed-rounds = Количество раундов установлено на { $rounds }.
threes-keep-all-first = Чтобы зафиксировать счёт, сначала нужно выбрать все кубики.
