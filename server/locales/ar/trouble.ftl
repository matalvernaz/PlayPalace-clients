# Trouble — ar
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble لعبة سباق من عائلة Parcheesi.
    يبدأ كل لاعب بقطعه في منطقة المنزل.
    في دورك، اضغط على النرد وحرّك إحدى قطعك.
    افتراضياً يجب أن ترمي 6 لإطلاق قطعة من المنزل إلى المسار.
    افتراضياً، رمي 6 يمنحك أيضاً دوراً إضافياً.
    تتحرك القطع باتجاه عقارب الساعة على المسار المشترك نحو منطقة النهاية.
    الهبوط على قطعة الخصم يعيدها إلى منزله إلا إذا كانت الخانة محمية.
    عندما تصل كل قطعك إلى النهاية، تفوز.
    في وضع الفرق، يفوز فريقك عندما يكمل جميع زملاءه.
    استخدم 1-6 لاختيار قطعة، و R للرمي.
    اضغط E في أي وقت لسماع حالة اللوحة كاملة.

trouble-action-roll = اضغط النرد
trouble-action-move-token = حرّك القطعة { $token }
trouble-action-check-board = افحص اللوحة

trouble-token-label-home = القطعة { $token }: في المنزل
trouble-token-label-track = القطعة { $token }: خانة { $position } من المسار
trouble-token-label-finish-lane = القطعة { $token }: مسار النهاية { $position } من { $total }
trouble-token-label-finished = القطعة { $token }: انتهت

trouble-rolled = { $player } رمى { $roll }.
trouble-leave-home = { $player } يطلق القطعة { $token } إلى المسار.
trouble-advance-track = { $player } يحرك القطعة { $token } إلى خانة { $position }.
trouble-enter-finish-lane = { $player } يدخل القطعة { $token } إلى مسار النهاية.
trouble-advance-finish-lane =
    { $player } يقدّم القطعة { $token } إلى خانة { $position } من { $total } في مسار النهاية.
trouble-token-finished = القطعة { $token } للاعب { $player } وصلت إلى النهاية.
trouble-bump =
    القطعة { $token } للاعب { $player } تعيد قطعة { $opp_token } للاعب { $opponent } إلى المنزل.
trouble-no-legal-move = ليس لدى { $player } حركة مشروعة. الدور يمرّ.
trouble-extra-turn = { $player } يحصل على دور إضافي لرميه 6.

trouble-winner = { $player } فاز! جميع القطع وصلت إلى النهاية.
trouble-team-winner = الفريق { $team } فاز! جميع الأعضاء أنهوا.
trouble-final-standing = { $player }: { $finished } من { $total } قطع منتهية.

trouble-turn-summary =
    لديك { $own_home } في المنزل، { $own_track } على المسار، { $own_finished } انتهت.
    الخصوم: { $opponents }.
trouble-opponent-summary = { $name }: منزل { $home }، مسار { $track }، نهاية { $finished }

trouble-board-status =
    قطعك: { $own_tokens }.
    قطع الخصم: { $opp_tokens }.

trouble-reason-not-rolled = اضغط النرد أولاً.
trouble-reason-already-rolled = ضغطت بالفعل. اختر قطعة لتحريكها.
trouble-reason-no-legal-moves = لا توجد حركات مشروعة لهذا الرمي.
trouble-reason-token-home-needs-six = هذه القطعة في المنزل. تحتاج 6 لإطلاقها.
trouble-reason-token-home-needs-any = هذه القطعة في المنزل. أي رمية تطلقها.
trouble-reason-token-home-no-qualifying-roll =
    هذه القطعة في المنزل ورميتك لا تستوفي شرط الإطلاق.
trouble-reason-token-finished = هذه القطعة انتهت بالفعل.
trouble-reason-overshoot-wastes = لا تستطيع هذه القطعة التحرك { $roll } خانات دون تجاوز النهاية.
trouble-reason-blocked = هذه الحركة محجوبة.

trouble-option-track-size = حجم المسار: { $track_size } خانة
trouble-option-select-track-size = اختر عدد خانات المسار.
trouble-option-changed-track-size = حجم المسار { $track_size } خانة.
trouble-option-desc-track-size = عدد الخانات على المسار المشترك.

trouble-option-tokens-per-player = قطع لكل لاعب: { $tokens }
trouble-option-enter-tokens-per-player = أدخل قطع لكل لاعب (2-6):
trouble-option-changed-tokens-per-player = قطع لكل لاعب { $tokens }.
trouble-option-desc-tokens-per-player = عدد القطع التي يحضرها كل لاعب للنهاية.

trouble-option-extra-turn-on-six = دور إضافي عند 6: { $enabled }
trouble-option-changed-extra-turn-on-six = دور إضافي عند 6 { $enabled ->
    [on] مفعّل.
    [off] معطّل.
   *[other] محدّث.
}
trouble-option-desc-extra-turn-on-six =
    مفعّل: 6 يمنح دوراً إضافياً (قاعدة Hasbro الكلاسيكية).

trouble-option-six-to-leave-home = اشتراط 6 لمغادرة المنزل: { $enabled }
trouble-option-changed-six-to-leave-home = ستة لمغادرة المنزل { $enabled ->
    [on] مفعّل.
    [off] معطّل.
   *[other] محدّث.
}
trouble-option-desc-six-to-leave-home =
    مفعّل: على اللاعب رمي 6 لإطلاق قطعة. معطّل: أي رمية تطلق.

trouble-option-safe-spaces = خانات آمنة: { $mode }
trouble-option-select-safe-spaces = اختر وضع الخانات الآمنة.
trouble-option-changed-safe-spaces = الخانات الآمنة { $mode }.
trouble-option-desc-safe-spaces = حدد ما إذا كانت القطع محمية من الصد.

trouble-safe-mode-none = لا شيء
trouble-safe-mode-home-stretch = خط النهاية فقط
trouble-safe-mode-every-seventh = كل 7 خانات

trouble-option-finish-behavior = النهاية: { $mode }
trouble-option-select-finish-behavior = اختر سلوك النهاية.
trouble-option-changed-finish-behavior = سلوك النهاية { $mode }.
trouble-option-desc-finish-behavior = كيف تتم معالجة رمية تتجاوز النهاية.

trouble-finish-mode-exact = رمية دقيقة مطلوبة
trouble-finish-mode-bounce = التجاوز يرتد
trouble-finish-mode-allow = التجاوز مسموح

trouble-option-bot-difficulty = صعوبة الروبوت: { $level }
trouble-option-select-bot-difficulty = اختر صعوبة الروبوت.
trouble-option-changed-bot-difficulty = صعوبة الروبوت { $level }.
trouble-option-desc-bot-difficulty = قوة الروبوتات المدمجة.

trouble-bot-difficulty-naive = ساذج
trouble-bot-difficulty-greedy = جشع

trouble-option-preset = نمط جاهز: { $preset }
trouble-option-select-preset = اختر تنويعاً. يمكن للمضيف لاحقاً تعديل القواعد.
trouble-option-changed-preset = نمط جاهز مطبّق: { $preset }.
trouble-option-desc-preset = مجموعات خيارات معدّة سلفاً للتنويعات الشائعة.

trouble-preset-classic = كلاسيكي Hasbro
trouble-preset-fast = سريع
trouble-preset-brutal = قاسٍ
trouble-preset-custom = مخصّص
