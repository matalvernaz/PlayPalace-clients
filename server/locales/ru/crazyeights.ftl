# crazyeights.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

game-name-crazyeights = Безумные восьмёрки
crazyeights-set-winning-score = Победный счёт: { $score }
crazyeights-enter-winning-score = Введите победный счёт
crazyeights-option-changed-winning-score = Победный счёт установлен на { $score }.
crazyeights-set-turn-timer = Таймер хода: { $mode }
crazyeights-select-turn-timer = Выберите таймер хода
crazyeights-option-changed-turn-timer = Таймер хода установлен на { $mode }.
crazyeights-draw = Взять карту
crazyeights-pass = Пас
crazyeights-read-top = Посмотреть верхнюю карту
crazyeights-read-counts = Посмотреть количество карт
crazyeights-deck-count = в колоде: { $count }
crazyeights-new-hand = Раунд { $round }.
crazyeights-start-card = { $player } открывает карту: { $card }.
crazyeights-no-players = Нет игроков.
crazyeights-no-top = Нет верхней карты.
crazyeights-wild = Безумная восьмёрка
crazyeights-wild-suit = Безумная восьмёрка, масть: { $suit }
crazyeights-reverse = Смена направления ({ $suit })
crazyeights-skip = Пропуск хода ({ $suit })
crazyeights-draw-two = Возьмите две ({ $suit })
crazyeights-round-summary = { $player } побеждает. { $details }. { $player } получает { $total }.
crazyeights-round-details-none = Очки у противников не набраны.
crazyeights-round-points-from = { $points } от игрока { $player }
crazyeights-dealt-cards =
    Всем роздано по { $cards } { $cards ->
        [one] карте
        [few] карты
       *[other] карт
    }.
crazyeights-game-winner =
    { $player } побеждает в игре, набрав { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }.
crazyeights-you-play = Вы кладёте карту: { $card }.
crazyeights-player-plays = { $player } кладёт карту: { $card }.
crazyeights-you-draw-one = Вы берёте карту.
crazyeights-you-draw-many =
    Вы берёте { $count } { $count ->
        [one] карту
        [few] карты
       *[other] карт
    }.
crazyeights-player-draws-one = { $player } берёт карту.
crazyeights-player-draws-many =
    { $player } берёт { $count } { $count ->
        [one] карту
        [few] карты
       *[other] карт
    }.
crazyeights-you-pass = Вы пасуете.
crazyeights-player-passes = { $player } пасует.
