# Liar's Dice — fa
# AI-translated with limited fluency, native review strongly recommended.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = هر بازیکن تاس‌هایش را به‌طور پنهانی زیر فنجان می‌ریزد. به‌نوبت پیشنهادهای بالاتر و بالاتر روی تعداد کل یک وجه در کل میز ارائه می‌دهید — یا اگر آخرین پیشنهاد را باور ندارید، "دروغگو!" فریاد می‌زنید. اشتباه یک تاس می‌گیرد. آخرین فرد با تاس برنده می‌شود.

liarsdice-rules =
    Liar's Dice یک بازی بلوف با تاس برای ۲ تا ۶ بازیکن است.
    هر بازیکن با ۵ تاس در فنجان شروع می‌کند. در ابتدای هر دور همه به‌طور پنهانی می‌ریزند.
    به‌نوبت روی تعداد کل یک وجه روی تمام تاس‌ها شرط می‌گذارید — مثلاً "سه ۴" یعنی هنگام برداشتن همه فنجان‌ها حداقل سه ۴ وجود دارد.
    هر شرط جدید باید بالاتر باشد: همان وجه با تعداد بیشتر، یا وجه بالاتر با تعداد مساوی یا بیشتر.
    یک‌ها واید هستند — در هر شرطی غیر از شرط بر یک‌ها حساب می‌شوند.
    رفتن به شرط روی یک‌ها تعداد را نصف می‌کند (گرد به بالا). بازگشت از یک‌ها به یک وجه عادی نیاز به بیش از دو برابر تعداد قبلی دارد.
    به جای شرط می‌توانید "دروغگو!" فریاد بزنید تا آخرین شرط را به چالش بکشید. همه فنجان‌ها بالا می‌روند: اگر شرط درست بود، چالش‌کننده یک تاس می‌بازد؛ اگر نه، شرط‌گذار یک تاس می‌بازد.
    با فعال بودن Spot On می‌توانید "Spot On" فریاد بزنید و شرط ببندید که شرط دقیقاً درست است. درست — دیگران هر کدام یک تاس می‌بازند؛ غلط — شما دو تاس می‌بازید.
    وقتی تاس‌هایتان به صفر می‌رسد حذف می‌شوید. آخرین فرد با تاس برنده است.
    برای بررسی میز S را بزنید.

ld-set-starting-dice = تاس‌های شروع به ازای هر بازیکن: { $dice }
ld-desc-starting-dice = هر بازیکن با چند تاس شروع می‌کند. پیش‌فرض ۵. تاس بیشتر = بازی‌های طولانی‌تر و فضای بیشتر برای بلوف.
ld-prompt-starting-dice = تعداد تاس‌های شروع را وارد کنید (۳ تا ۸)
ld-option-changed-starting-dice = تاس‌های شروع روی { $dice } تنظیم شد.

ld-toggle-wild-ones = یک‌ها واید: { $enabled }
ld-desc-wild-ones = روشن: یک‌ها در هر شرطی غیر از یک‌ها حساب می‌شوند. شرط روی یک‌ها واید را برای آن شرط غیرفعال می‌کند. خاموش — بازی احتمال محض بدون واید می‌شود.
ld-option-changed-wild-ones = واید یک‌ها { $enabled }.

ld-toggle-spot-on = فراخوانی Spot On فعال: { $enabled }
ld-desc-spot-on = روشن: علاوه بر "دروغگو" می‌توانید "Spot On" فریاد بزنید و شرط ببندید که شرط دقیق است. درست — دیگران یک تاس هر یک می‌بازند. غلط — شما دو می‌بازید. ریسک بالا، پاداش بالا.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = دور { $round } شروع می‌شود. کل تاس‌های روی میز: { $total }. همه می‌ریزند.
ld-your-roll = تاس‌های شما در این دور: { $dice }.
ld-your-counts = شمارش‌های شما: { $counts }.
ld-turn-start = نوبت { $player }. { $bid_state }
ld-no-bid-yet = هنوز شرطی نیست — دور را باز کنید.
ld-current-bid = شرط فعلی: { $quantity } { $face }.

ld-action-bid = شرط بگذار
ld-action-call-liar = دروغگو بگو
ld-action-call-spot-on = Spot On بگو
ld-bid-prompt = شرط خود را انتخاب کنید.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] شما { $quantity } { $face } شرط می‌گذارید.
    *[player] { $player } { $quantity } { $face } شرط می‌گذارد.
}

ld-call-liar = { $who ->
    [you] شما به شرط { $target } { $quantity } { $face } دروغگو می‌گویید.
    *[player] { $player } به شرط { $target } { $quantity } { $face } دروغگو می‌گوید.
}
ld-call-spot-on = { $who ->
    [you] شما به شرط { $target } { $quantity } { $face } Spot On می‌گویید.
    *[player] { $player } به شرط { $target } { $quantity } { $face } Spot On می‌گوید.
}
ld-reveal-header = فنجان‌ها بالا! { $face } روی میز شمرده می‌شود.
ld-reveal-line = { $player } ریخت: { $dice }.
ld-actual-count = تعداد واقعی { $face } (با یک‌های واید): { $count }. شرط { $quantity } بود.
ld-actual-count-no-wild = تعداد واقعی { $face } (بدون واید): { $count }. شرط { $quantity } بود.

ld-liar-bidder-loses = { $bidder } بیش از حد شرط گذاشت — یک تاس می‌بازد.
ld-liar-caller-loses = شرط صادقانه بود — { $caller } یک تاس می‌بازد.
ld-spot-on-correct = Spot on! { $caller } دقیق حدس زد — دیگران هر کدام یک تاس می‌بازند.
ld-spot-on-wrong = Spot on نیست. { $caller } دو تاس می‌بازد.

ld-lost-die = { $who ->
    [you] شما یک تاس باختید. اکنون { $remaining } { $remaining ->
        [one] تاس
        *[other] تاس
    } دارید.
    *[player] { $player } یک تاس باخت. اکنون { $remaining } دارد.
}
ld-lost-dice-multi = { $who ->
    [you] شما { $count } تاس باختید. اکنون { $remaining } { $remaining ->
        [one] تاس
        *[other] تاس
    } دارید.
    *[player] { $player } { $count } تاس باخت. اکنون { $remaining } دارد.
}
ld-eliminated = { $player } تاس‌هایش تمام شد و حذف شد! { $remaining } { $remaining ->
    [one] بازیکن
    *[other] بازیکن
} باقی ماند.
ld-winner = { $player } آخرین کسی است که تاس دارد — برنده!

ld-status-round = دور { $round }.
ld-status-your-dice = تاس‌های شما: { $dice }.
ld-status-your-counts = شمارش‌های شما: { $counts }.
ld-status-no-dice = تاسی ندارید — حذف شدید.
ld-status-current-bid = شرط فعلی: { $quantity } { $face }.
ld-status-no-bid = در این دور شرطی نیست.
ld-status-table-total = کل تاس‌های روی میز: { $total }.
ld-status-detailed-header = وضعیت تفصیلی — { $count } بازیکن باقی مانده.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] تاس
    *[other] تاس
}.
ld-status-detailed-out = { $player }: حذف شد.
ld-status-detailed-self-suffix = {" "}(شما)

ld-face-1 = یک‌ها
ld-face-2 = دوها
ld-face-3 = سه‌ها
ld-face-4 = چهارها
ld-face-5 = پنج‌ها
ld-face-6 = شش‌ها

ld-action-not-your-turn = نوبت شما نیست.
ld-action-not-playing = بازی در جریان نیست.
ld-action-no-bid-to-call = هنوز شرطی برای چالش نیست.
ld-action-eliminated = شما حذف شده‌اید.
