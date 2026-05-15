# Liar's Dice — ru
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Каждый игрок тайно бросает кости в стакане. По очереди делайте всё более высокие ставки на общее число выпавшей грани на столе — или крикните «Лжец!», если не верите последней ставке. Ошибся — теряешь кость. Побеждает тот, у кого остались кости.

liarsdice-rules =
    Liar's Dice — это игра в кости на блеф для 2-6 игроков.
    Каждый игрок начинает с 5 костями в стакане. В начале каждого раунда все тайно бросают.
    По очереди делайте ставки на общее число выпавшей грани на всех костях — например, «три 4» означает, что на столе есть как минимум три 4, когда все стаканы откроются.
    Каждая новая ставка должна быть выше предыдущей: та же грань с большим количеством, или более высокая грань с равным или большим количеством.
    Единицы — джокеры: они засчитываются для любой ставки, кроме ставок на сами единицы.
    Переход к ставке на единицы делит количество пополам (с округлением вверх). Возврат от единиц к обычной грани требует более чем удвоенного предыдущего количества.
    Вместо ставки можно крикнуть «Лжец!» и оспорить последнюю ставку. Все стаканы открываются: если ставка верна, оспоривший теряет кость; если нет, ставивший теряет кость.
    Если включён Spot On, можно крикнуть «Spot On», ставя на то, что ставка точно правильна. Если угадал — все остальные теряют по кости; если нет — ты теряешь две кости.
    Выбываешь при нуле костей. Побеждает последний, у кого есть кости.
    Нажмите S, чтобы проверить стол.

ld-set-starting-dice = Начальные кости на игрока: { $dice }
ld-desc-starting-dice = Сколько костей у каждого игрока в начале. По умолчанию 5. Больше костей = дольше партии и больше пространства для блефа.
ld-prompt-starting-dice = Введите начальные кости (от 3 до 8)
ld-option-changed-starting-dice = Начальные кости установлены: { $dice }.

ld-toggle-wild-ones = Единицы — джокеры: { $enabled }
ld-desc-wild-ones = Включено: единицы засчитываются для любой ставки не на единицы. Ставка на единицы отключает джокеров для этой ставки. Выключено — игра становится чистой вероятностью, без джокеров.
ld-option-changed-wild-ones = Джокеры-единицы { $enabled }.

ld-toggle-spot-on = Объявление Spot On включено: { $enabled }
ld-desc-spot-on = Включено: помимо «Лжец», можно объявить «Spot On» — ставка на то, что предыдущая ставка точно совпадает. Угадал — остальные теряют по кости. Нет — ты теряешь две. Большой риск, большая награда.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Раунд { $round } начался. Всего костей на столе: { $total }. Все бросают.
ld-your-roll = Ваши кости в этом раунде: { $dice }.
ld-your-counts = Ваши количества: { $counts }.
ld-turn-start = Ход { $player }. { $bid_state }
ld-no-bid-yet = Ставок ещё нет — откройте раунд.
ld-current-bid = Текущая ставка: { $quantity } { $face }.

ld-action-bid = Сделать ставку
ld-action-call-liar = Объявить Лжеца
ld-action-call-spot-on = Объявить Spot On
ld-bid-prompt = Выберите вашу ставку.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Вы ставите { $quantity } { $face }.
    *[player] { $player } ставит { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Вы объявляете Лжеца на ставку { $target }: { $quantity } { $face }.
    *[player] { $player } объявляет Лжеца на ставку { $target }: { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Вы объявляете Spot On на ставку { $target }: { $quantity } { $face }.
    *[player] { $player } объявляет Spot On на ставку { $target }: { $quantity } { $face }.
}
ld-reveal-header = Стаканы вверх! Считаем { $face } на столе.
ld-reveal-line = { $player } выбросил: { $dice }.
ld-actual-count = Фактическое число { $face } (с джокерами-1): { $count }. Ставка была { $quantity }.
ld-actual-count-no-wild = Фактическое число { $face } (без джокеров): { $count }. Ставка была { $quantity }.

ld-liar-bidder-loses = { $bidder } перебил — теряет кость.
ld-liar-caller-loses = Ставка была честной — { $caller } теряет кость.
ld-spot-on-correct = Spot on! { $caller } угадал точно — остальные теряют по кости.
ld-spot-on-wrong = Не spot on. { $caller } теряет две кости.

ld-lost-die = { $who ->
    [you] Вы потеряли кость. У вас { $remaining } { $remaining ->
        [one] кость
        *[other] костей
    }.
    *[player] { $player } потерял кость. Осталось { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Вы потеряли { $count } костей. У вас { $remaining } { $remaining ->
        [one] кость
        *[other] костей
    }.
    *[player] { $player } потерял { $count } костей. Осталось { $remaining }.
}
ld-eliminated = { $player } остался без костей и выбывает! Осталось { $remaining } { $remaining ->
    [one] игрок
    *[other] игроков
}.
ld-winner = { $player } — последний с костями, побеждает!

ld-status-round = Раунд { $round }.
ld-status-your-dice = Ваши кости: { $dice }.
ld-status-your-counts = Ваши количества: { $counts }.
ld-status-no-dice = У вас нет костей — вы выбыли.
ld-status-current-bid = Текущая ставка: { $quantity } { $face }.
ld-status-no-bid = Ставок в этом раунде нет.
ld-status-table-total = Всего костей на столе: { $total }.
ld-status-detailed-header = Подробный статус — осталось { $count } игроков.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] кость
    *[other] костей
}.
ld-status-detailed-out = { $player }: выбыл.
ld-status-detailed-self-suffix = {" "}(вы)

ld-face-1 = единицы
ld-face-2 = двойки
ld-face-3 = тройки
ld-face-4 = четвёрки
ld-face-5 = пятёрки
ld-face-6 = шестёрки

ld-action-not-your-turn = Сейчас не ваш ход.
ld-action-not-playing = Партия не идёт.
ld-action-no-bid-to-call = Пока нет ставки для оспаривания.
ld-action-eliminated = Вы выбыли.
