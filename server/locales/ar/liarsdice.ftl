# Liar's Dice — ar
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = يرمي كل لاعب نرده سراً تحت الكوب. بالتناوب، تُقدَّم رهانات أعلى وأعلى على إجمالي عدد وجه معين على الطاولة كلها — أو يصرخ "كاذب!" إذا لم يصدق الرهان الأخير. خطأ يكلف نرداً. آخر من تبقى لديه نرد يفوز.

liarsdice-rules =
    Liar's Dice لعبة خداع بالنرد من 2 إلى 6 لاعبين.
    يبدأ كل لاعب بـ 5 نرود في كوب. في بداية كل جولة يرمي الجميع سراً.
    بالتناوب يتم الرهان على إجمالي عدد وجه معين على كل النرود — مثلاً "ثلاثة 4" تعني وجود ثلاثة 4 على الأقل عند كشف الأكواب.
    كل رهان جديد يجب أن يكون أعلى: نفس الوجه بعدد أكثر أو وجه أعلى بعدد مساوٍ أو أكثر.
    الـ 1 جوكر — يُحتسب في أي رهان غير الرهان على الـ 1 نفسه.
    الانتقال إلى الرهان على الـ 1 يقسم الكمية على النصف (تقريب لأعلى). العودة من الـ 1 إلى وجه عادي يتطلب أكثر من ضعف الكمية السابقة.
    بدلاً من الرهان، يمكنك صرخ "كاذب!" لتحدي الرهان السابق. كل الأكواب تكشف: إذا كان الرهان صحيحاً يخسر المتحدي نرداً؛ وإلا يخسر صاحب الرهان نرداً.
    عند تفعيل Spot On يمكنك صرخ "Spot On" مراهناً على أن الرهان صحيح تماماً. إذا أصبت يخسر كل لاعب آخر نرداً؛ وإلا تخسر أنت نردين.
    تخرج عند وصول نرودك إلى صفر. آخر من تبقى لديه نرد يفوز.
    اضغط S لفحص الطاولة.

ld-set-starting-dice = نرود البدء للاعب: { $dice }
ld-desc-starting-dice = كم نرداً يبدأ به كل لاعب. الافتراضي 5. نرود أكثر = ألعاب أطول ومساحة أوسع للخداع.
ld-prompt-starting-dice = أدخل نرود البدء (3 إلى 8)
ld-option-changed-starting-dice = ضُبطت نرود البدء على { $dice }.

ld-toggle-wild-ones = الـ 1 جوكر: { $enabled }
ld-desc-wild-ones = مفعّل: الـ 1 يُحتسب في كل رهان ليس على الـ 1. الرهان على الـ 1 يعطّل الجوكر لذلك الرهان. معطّل: تصبح اللعبة احتمالات صرفة بلا جوكر.
ld-option-changed-wild-ones = جوكر الـ 1 { $enabled }.

ld-toggle-spot-on = صرخة Spot On مفعّلة: { $enabled }
ld-desc-spot-on = مفعّل: إلى جانب "كاذب" يمكنك صرخ "Spot On" مراهناً على أن الرهان صحيح تماماً. صحّ — يخسر الآخرون نرداً لكل واحد. خطأ — تخسر أنت نردين. مخاطرة عالية ومكافأة عالية.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = الجولة { $round } تبدأ. مجموع النرود على الطاولة: { $total }. الجميع يرمي.
ld-your-roll = نرودك في هذه الجولة: { $dice }.
ld-your-counts = أعدادك: { $counts }.
ld-turn-start = دور { $player }. { $bid_state }
ld-no-bid-yet = لا رهان بعد — افتح الجولة.
ld-current-bid = الرهان الحالي: { $quantity } { $face }.

ld-action-bid = قدّم رهاناً
ld-action-call-liar = اصرخ كاذب
ld-action-call-spot-on = اصرخ Spot On
ld-bid-prompt = اختر رهانك.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] تراهن على { $quantity } { $face }.
    *[player] { $player } يراهن على { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] تصرخ كاذب على رهان { $target } { $quantity } { $face }.
    *[player] { $player } يصرخ كاذب على رهان { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] تصرخ Spot On على رهان { $target } { $quantity } { $face }.
    *[player] { $player } يصرخ Spot On على رهان { $target } { $quantity } { $face }.
}
ld-reveal-header = ارفعوا الأكواب! نعدّ { $face } على الطاولة.
ld-reveal-line = { $player } رمى: { $dice }.
ld-actual-count = العدد الفعلي للـ { $face } (مع جوكر الـ 1): { $count }. كان الرهان { $quantity }.
ld-actual-count-no-wild = العدد الفعلي للـ { $face } (بلا جوكر): { $count }. كان الرهان { $quantity }.

ld-liar-bidder-loses = { $bidder } بالغ في الرهان — يخسر نرداً.
ld-liar-caller-loses = كان الرهان صادقاً — { $caller } يخسر نرداً.
ld-spot-on-correct = Spot on! { $caller } أصاب تماماً — كل لاعب آخر يخسر نرداً.
ld-spot-on-wrong = ليس Spot on. { $caller } يخسر نردين.

ld-lost-die = { $who ->
    [you] خسرت نرداً. لديك الآن { $remaining } { $remaining ->
        [one] نرد
        *[other] نردات
    }.
    *[player] { $player } خسر نرداً. لديه الآن { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] خسرت { $count } نردات. لديك الآن { $remaining } { $remaining ->
        [one] نرد
        *[other] نردات
    }.
    *[player] { $player } خسر { $count } نردات. لديه الآن { $remaining }.
}
ld-eliminated = { $player } نفدت نروده وخرج! بقي { $remaining } { $remaining ->
    [one] لاعب
    *[other] لاعبين
}.
ld-winner = { $player } آخر من تبقى لديه نرد — يفوز!

ld-status-round = الجولة { $round }.
ld-status-your-dice = نرودك: { $dice }.
ld-status-your-counts = أعدادك: { $counts }.
ld-status-no-dice = لا نرود لك — أُقصيت.
ld-status-current-bid = الرهان الحالي: { $quantity } { $face }.
ld-status-no-bid = لا رهان في هذه الجولة.
ld-status-table-total = مجموع النرود على الطاولة: { $total }.
ld-status-detailed-header = حالة مفصّلة — تبقى { $count } لاعبين.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] نرد
    *[other] نردات
}.
ld-status-detailed-out = { $player }: أُقصي.
ld-status-detailed-self-suffix = {" "}(أنت)

ld-face-1 = الواحدات
ld-face-2 = الاثنينات
ld-face-3 = الثلاثات
ld-face-4 = الأربعات
ld-face-5 = الخماسات
ld-face-6 = الستات

ld-action-not-your-turn = ليس دورك.
ld-action-not-playing = اللعبة ليست جارية.
ld-action-no-bid-to-call = لا رهان لتحدّيه بعد.
ld-action-eliminated = أنت مُقصى.
