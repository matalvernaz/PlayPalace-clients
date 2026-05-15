# Liar's Dice — sr
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Сваки играч баца своје коцке тајно под чашом. Наизменично подижете улоге на укупан број једне стране на целом столу — или вичете "Лажов!" ако не верујете последњи улог. Грешка = губитак коцке. Последњи са коцкама побеђује.

liarsdice-rules =
    Liar's Dice је блеф игра коцкама за 2 до 6 играча.
    Сваки играч почиње са 5 коцки у чаши. На почетку сваке руке сви тајно бацају.
    Наизменично постављате улоге на укупан број једне стране преко свих коцки — нпр. "три 4" значи да након откривања чаша има најмање три 4.
    Сваки нови улог мора бити већи: иста страна с већом количином или већа страна с истом или већом количином.
    Јединице су џокери — рачунају се у сваком улогу осим улога на јединице.
    Прелазак на улог на јединице полови количину (заокружено навише). Повратак из јединица на обичну страну захтева више од двоструке претходне количине.
    Уместо улога можеш викнути "Лажов!" да оспориш последњи улог. Све чаше горе: ако је улог био тачан, изазивач губи коцку; иначе губи онај ко је положио улог.
    Са Spot On укљученим можеш викнути "Spot On" опкладивши се да је улог тачно тачан. Ако си у праву, остали губе по коцку; ако не, ти губиш две.
    Елиминисан када имаш нула коцки. Последњи са коцкама побеђује.
    Притисни S за преглед стола.

ld-set-starting-dice = Почетне коцке по играчу: { $dice }
ld-desc-starting-dice = Са колико коцки сваки играч почиње. Подразумевано 5. Више коцки = дуже игре и више простора за блеф.
ld-prompt-starting-dice = Унеси почетне коцке (3 до 8)
ld-option-changed-starting-dice = Почетне коцке постављене на { $dice }.

ld-toggle-wild-ones = Јединице су џокери: { $enabled }
ld-desc-wild-ones = Укључено: јединице се рачунају у сваком улогу који није на јединице. Улог на јединице искључује џокере за тај улог. Искључено — игра је чиста вероватноћа без џокера.
ld-option-changed-wild-ones = Џокер јединице { $enabled }.

ld-toggle-spot-on = Позив Spot On омогућен: { $enabled }
ld-desc-spot-on = Укључено: уз "Лажов" можеш викнути "Spot On" опкладивши се да је улог тачно тачан. Тачно — остали губе по коцку. Погрешно — ти губиш две. Висок ризик, висока награда.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Рунда { $round } почиње. Укупно коцки на столу: { $total }. Сви бацају.
ld-your-roll = Твоје коцке у овој рунди: { $dice }.
ld-your-counts = Твоји бројеви: { $counts }.
ld-turn-start = Ред је на { $player }. { $bid_state }
ld-no-bid-yet = Још нема улога — отвори рунду.
ld-current-bid = Тренутни улог: { $quantity } { $face }.

ld-action-bid = Положи улог
ld-action-call-liar = Викни Лажов
ld-action-call-spot-on = Викни Spot On
ld-bid-prompt = Изабери улог.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Полажеш улог од { $quantity } { $face }.
    *[player] { $player } полаже улог од { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Вичеш Лажов на улог { $target } од { $quantity } { $face }.
    *[player] { $player } виче Лажов на улог { $target } од { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Вичеш Spot On на улог { $target } од { $quantity } { $face }.
    *[player] { $player } виче Spot On на улог { $target } од { $quantity } { $face }.
}
ld-reveal-header = Чаше горе! Бројимо { $face } на столу.
ld-reveal-line = { $player } је бацио: { $dice }.
ld-actual-count = Стварни број { $face } (са џокер јединицама): { $count }. Улог је био { $quantity }.
ld-actual-count-no-wild = Стварни број { $face } (без џокера): { $count }. Улог је био { $quantity }.

ld-liar-bidder-loses = { $bidder } је превисоко уложио — губи коцку.
ld-liar-caller-loses = Улог је био поштен — { $caller } губи коцку.
ld-spot-on-correct = Spot on! { $caller } погодио тачно — остали губе по коцку.
ld-spot-on-wrong = Није spot on. { $caller } губи две коцке.

ld-lost-die = { $who ->
    [you] Изгубио си коцку. Имаш сада { $remaining } { $remaining ->
        [one] коцку
        [few] коцке
        *[other] коцки
    }.
    *[player] { $player } је изгубио коцку. Има сада { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Изгубио си { $count } коцки. Имаш сада { $remaining } { $remaining ->
        [one] коцку
        [few] коцке
        *[other] коцки
    }.
    *[player] { $player } је изгубио { $count } коцки. Има сада { $remaining }.
}
ld-eliminated = { $player } је остао без коцки и елиминисан је! Остало { $remaining } { $remaining ->
    [one] играч
    [few] играча
    *[other] играча
}.
ld-winner = { $player } је последњи са коцкама — побеђује!

ld-status-round = Рунда { $round }.
ld-status-your-dice = Твоје коцке: { $dice }.
ld-status-your-counts = Твоји бројеви: { $counts }.
ld-status-no-dice = Немаш коцки — елиминисан си.
ld-status-current-bid = Тренутни улог: { $quantity } { $face }.
ld-status-no-bid = У овој рунди нема улога.
ld-status-table-total = Укупно коцки на столу: { $total }.
ld-status-detailed-header = Детаљни статус — преостало { $count } играча.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] коцка
    [few] коцке
    *[other] коцки
}.
ld-status-detailed-out = { $player }: елиминисан.
ld-status-detailed-self-suffix = {" "}(ти)

ld-face-1 = јединице
ld-face-2 = двојке
ld-face-3 = тројке
ld-face-4 = четворке
ld-face-5 = петице
ld-face-6 = шестице

ld-action-not-your-turn = Није твој ред.
ld-action-not-playing = Игра није у току.
ld-action-no-bid-to-call = Још нема улога за оспоравање.
ld-action-eliminated = Елиминисан си.
