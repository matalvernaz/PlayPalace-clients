# Liar's Dice — uk
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Кожен гравець таємно кидає кубики у своєму стаканчику. По черзі робите все вищі ставки на загальну кількість певної грані на всьому столі — або кричите "Брехун!", якщо не вірите останній ставці. Помилка коштує кубика. Останній з кубиками перемагає.

liarsdice-rules =
    Liar's Dice — це гра в кубики на блеф для 2-6 гравців.
    Кожен гравець починає з 5 кубиками в стаканчику. На початку кожного раунду всі таємно кидають.
    По черзі робите ставки на загальну кількість певної грані по всіх кубиках — наприклад, "три 4" означає, що на столі є щонайменше три 4, коли всі стаканчики відкриються.
    Кожна нова ставка має бути вищою: та сама грань з більшою кількістю, або вища грань з рівною чи більшою кількістю.
    Одиниці — джокери: вони зараховуються в будь-яку ставку, крім ставок на самі одиниці.
    Перехід до ставки на одиниці ділить кількість навпіл (округлення вгору). Повернення від одиниць до звичайної грані вимагає більш ніж подвоєної попередньої кількості.
    Замість ставки можна крикнути "Брехун!" і оскаржити останню ставку. Усі стаканчики відкриваються: якщо ставка вірна, той, хто оскаржив, втрачає кубик; якщо ні — той, хто ставив, втрачає кубик.
    Якщо ввімкнено Spot On, можна крикнути "Spot On", ставлячи, що ставка точно правильна. Якщо вгадав — усі інші втрачають по кубику; якщо ні — ти втрачаєш два кубики.
    Вибуваєш при нулі кубиків. Останній з кубиками перемагає.
    Натисніть S, щоб перевірити стіл.

ld-set-starting-dice = Початкові кубики на гравця: { $dice }
ld-desc-starting-dice = Скільки кубиків у кожного гравця на початку. За замовчуванням 5. Більше кубиків = довші партії і більше простору для блефу.
ld-prompt-starting-dice = Введіть початкові кубики (від 3 до 8)
ld-option-changed-starting-dice = Початкові кубики встановлено: { $dice }.

ld-toggle-wild-ones = Одиниці — джокери: { $enabled }
ld-desc-wild-ones = Увімкнено: одиниці зараховуються в будь-яку ставку не на одиниці. Ставка на одиниці вимикає джокерів для цієї ставки. Вимкнено — гра стає чистою ймовірністю без джокерів.
ld-option-changed-wild-ones = Джокери-одиниці { $enabled }.

ld-toggle-spot-on = Виклик Spot On увімкнено: { $enabled }
ld-desc-spot-on = Увімкнено: окрім "Брехуна" можна крикнути "Spot On" — ставка на те, що ставка точно правильна. Якщо вгадав — інші втрачають по кубику. Якщо ні — ти втрачаєш два. Високий ризик, висока нагорода.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Раунд { $round } починається. Усього кубиків на столі: { $total }. Усі кидають.
ld-your-roll = Ваші кубики в цьому раунді: { $dice }.
ld-your-counts = Ваші кількості: { $counts }.
ld-turn-start = Хід { $player }. { $bid_state }
ld-no-bid-yet = Ставок ще немає — відкрийте раунд.
ld-current-bid = Поточна ставка: { $quantity } { $face }.

ld-action-bid = Зробити ставку
ld-action-call-liar = Назвати Брехуном
ld-action-call-spot-on = Назвати Spot On
ld-bid-prompt = Виберіть свою ставку.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Ви ставите { $quantity } { $face }.
    *[player] { $player } ставить { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Ви називаєте Брехуном ставку { $target }: { $quantity } { $face }.
    *[player] { $player } називає Брехуном ставку { $target }: { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Ви називаєте Spot On ставку { $target }: { $quantity } { $face }.
    *[player] { $player } називає Spot On ставку { $target }: { $quantity } { $face }.
}
ld-reveal-header = Стаканчики вгору! Рахуємо { $face } на столі.
ld-reveal-line = { $player } викинув: { $dice }.
ld-actual-count = Фактична кількість { $face } (з джокерами-1): { $count }. Ставка була { $quantity }.
ld-actual-count-no-wild = Фактична кількість { $face } (без джокерів): { $count }. Ставка була { $quantity }.

ld-liar-bidder-loses = { $bidder } перевищив — втрачає кубик.
ld-liar-caller-loses = Ставка була чесною — { $caller } втрачає кубик.
ld-spot-on-correct = Spot on! { $caller } вгадав точно — інші втрачають по кубику.
ld-spot-on-wrong = Не spot on. { $caller } втрачає два кубики.

ld-lost-die = { $who ->
    [you] Ви втратили кубик. У вас { $remaining } { $remaining ->
        [one] кубик
        *[other] кубиків
    }.
    *[player] { $player } втратив кубик. Залишилося { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Ви втратили { $count } кубиків. У вас { $remaining } { $remaining ->
        [one] кубик
        *[other] кубиків
    }.
    *[player] { $player } втратив { $count } кубиків. Залишилося { $remaining }.
}
ld-eliminated = { $player } залишився без кубиків і вибуває! Залишилося { $remaining } { $remaining ->
    [one] гравець
    *[other] гравців
}.
ld-winner = { $player } — останній з кубиками, перемагає!

ld-status-round = Раунд { $round }.
ld-status-your-dice = Ваші кубики: { $dice }.
ld-status-your-counts = Ваші кількості: { $counts }.
ld-status-no-dice = У вас немає кубиків — ви вибули.
ld-status-current-bid = Поточна ставка: { $quantity } { $face }.
ld-status-no-bid = У цьому раунді ставок немає.
ld-status-table-total = Усього кубиків на столі: { $total }.
ld-status-detailed-header = Детальний статус — залишилося { $count } гравців.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] кубик
    *[other] кубиків
}.
ld-status-detailed-out = { $player }: вибув.
ld-status-detailed-self-suffix = {" "}(ви)

ld-face-1 = одиниці
ld-face-2 = двійки
ld-face-3 = трійки
ld-face-4 = четвірки
ld-face-5 = п'ятірки
ld-face-6 = шістки

ld-action-not-your-turn = Зараз не ваш хід.
ld-action-not-playing = Партія не йде.
ld-action-no-bid-to-call = Поки немає ставки для оскарження.
ld-action-eliminated = Ви вибули.
