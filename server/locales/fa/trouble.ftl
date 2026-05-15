# Trouble — fa
# AI-translated with limited fluency, native review strongly recommended.
game-name-trouble = Trouble

trouble-rules =
    Trouble بازی مسابقه‌ای از خانواده پارچیزی است.
    هر بازیکن با مهره‌هایش در منطقه خانه شروع می‌کند.
    در نوبت خود تاس را فشار دهید و یکی از مهره‌هایتان را حرکت دهید.
    به‌طور پیش‌فرض باید 6 بیاورید تا مهره‌ای را از خانه به مسیر آزاد کنید.
    به‌طور پیش‌فرض 6 آوردن یک نوبت اضافه نیز می‌دهد.
    مهره‌ها در جهت عقربه‌های ساعت در مسیر مشترک به سمت منطقه پایان حرکت می‌کنند.
    فرود روی مهره حریف آن را به خانه خودش برمی‌گرداند، مگر اینکه فضا محافظت‌شده باشد.
    وقتی تمام مهره‌هایتان به پایان رسیدند، برنده می‌شوید.
    در حالت تیمی، تیم شما وقتی برنده می‌شود که همه هم‌تیمی‌ها تمام کنند.
    کلیدهای 1-6 مهره را انتخاب می‌کنند، R تاس می‌اندازد.
    هر زمان E را بزنید تا وضعیت کامل تخته را بشنوید.

trouble-action-roll = فشار دادن تاس
trouble-action-move-token = حرکت مهره { $token }
trouble-action-check-board = بررسی تخته

trouble-token-label-home = مهره { $token }: در خانه
trouble-token-label-track = مهره { $token }: فضای { $position } مسیر
trouble-token-label-finish-lane = مهره { $token }: مسیر پایان { $position } از { $total }
trouble-token-label-finished = مهره { $token }: تمام شده

trouble-rolled = { $player } { $roll } آورد.
trouble-leave-home = { $player } مهره { $token } را به مسیر آزاد می‌کند.
trouble-advance-track = { $player } مهره { $token } را به فضای { $position } می‌برد.
trouble-enter-finish-lane = { $player } مهره { $token } را به مسیر پایان وارد می‌کند.
trouble-advance-finish-lane =
    { $player } مهره { $token } را به فضای { $position } از { $total } مسیر پایان می‌برد.
trouble-token-finished = مهره { $token } { $player } به پایان رسید.
trouble-bump =
    مهره { $token } { $player } مهره { $opp_token } { $opponent } را به خانه برمی‌گرداند.
trouble-no-legal-move = { $player } حرکت قانونی ندارد. نوبت رد می‌شود.
trouble-extra-turn = { $player } برای 6 یک نوبت اضافه می‌گیرد.

trouble-winner = { $player } برنده شد! همه مهره‌ها در پایان.
trouble-team-winner = تیم { $team } برنده شد! همه هم‌تیمی‌ها تمام کردند.
trouble-final-standing = { $player }: { $finished } از { $total } مهره تمام شده.

trouble-turn-summary =
    شما { $own_home } در خانه، { $own_track } روی مسیر، { $own_finished } در پایان دارید.
    حریفان: { $opponents }.
trouble-opponent-summary = { $name }: خانه { $home }، مسیر { $track }، پایان { $finished }

trouble-board-status =
    مهره‌های شما: { $own_tokens }.
    مهره‌های حریف: { $opp_tokens }.

trouble-reason-not-rolled = اول تاس را فشار دهید.
trouble-reason-already-rolled = قبلاً فشار داده‌اید. مهره‌ای را برای حرکت انتخاب کنید.
trouble-reason-no-legal-moves = برای این تاس حرکت قانونی نیست.
trouble-reason-token-home-needs-six = این مهره در خانه است. برای آزادی به 6 نیاز دارید.
trouble-reason-token-home-needs-any = این مهره در خانه است. هر تاسی آن را آزاد می‌کند.
trouble-reason-token-home-no-qualifying-roll =
    این مهره در خانه است و تاس شما برای آزادی کافی نیست.
trouble-reason-token-finished = این مهره قبلاً تمام شده.
trouble-reason-overshoot-wastes = این مهره نمی‌تواند { $roll } فضا بدون گذشتن از پایان حرکت کند.
trouble-reason-blocked = این حرکت مسدود است.

trouble-option-track-size = اندازه مسیر: { $track_size } فضا
trouble-option-select-track-size = تعداد فضاهای مسیر را انتخاب کنید.
trouble-option-changed-track-size = مسیر روی { $track_size } فضا تنظیم شد.
trouble-option-desc-track-size = تعداد فضاها در مسیر مشترک.

trouble-option-tokens-per-player = مهره به ازای بازیکن: { $tokens }
trouble-option-enter-tokens-per-player = تعداد مهره به ازای بازیکن را وارد کنید (2-6):
trouble-option-changed-tokens-per-player = مهره به ازای بازیکن روی { $tokens } تنظیم شد.
trouble-option-desc-tokens-per-player = هر بازیکن چند مهره را به پایان می‌برد.

trouble-option-extra-turn-on-six = نوبت اضافه با 6: { $enabled }
trouble-option-changed-extra-turn-on-six = نوبت اضافه با 6 { $enabled ->
    [on] فعال.
    [off] غیرفعال.
   *[other] به‌روز شد.
}
trouble-option-desc-extra-turn-on-six =
    فعال: 6 یک نوبت اضافه می‌دهد (قانون کلاسیک Hasbro).

trouble-option-six-to-leave-home = نیاز به 6 برای ترک خانه: { $enabled }
trouble-option-changed-six-to-leave-home = شش برای ترک خانه { $enabled ->
    [on] فعال.
    [off] غیرفعال.
   *[other] به‌روز شد.
}
trouble-option-desc-six-to-leave-home =
    فعال: بازیکن باید 6 بیاورد تا مهره را از خانه آزاد کند. غیرفعال: هر تاسی آزاد می‌کند.

trouble-option-safe-spaces = فضاهای امن: { $mode }
trouble-option-select-safe-spaces = حالت فضاهای امن را انتخاب کنید.
trouble-option-changed-safe-spaces = فضاهای امن روی { $mode } تنظیم شد.
trouble-option-desc-safe-spaces = تعیین کنید آیا مهره‌ها از برخورد محافظت می‌شوند.

trouble-safe-mode-none = هیچ‌کدام
trouble-safe-mode-home-stretch = فقط خط پایان
trouble-safe-mode-every-seventh = هر 7 فضا

trouble-option-finish-behavior = پایان: { $mode }
trouble-option-select-finish-behavior = رفتار پایان را انتخاب کنید.
trouble-option-changed-finish-behavior = رفتار پایان روی { $mode } تنظیم شد.
trouble-option-desc-finish-behavior = چگونه با تاسی که از پایان عبور می‌کند، رفتار شود.

trouble-finish-mode-exact = تاس دقیق لازم
trouble-finish-mode-bounce = اضافه برمی‌گردد
trouble-finish-mode-allow = اضافه مجاز

trouble-option-bot-difficulty = سختی ربات: { $level }
trouble-option-select-bot-difficulty = سختی ربات را انتخاب کنید.
trouble-option-changed-bot-difficulty = سختی ربات روی { $level } تنظیم شد.
trouble-option-desc-bot-difficulty = قدرت ربات‌های داخلی.

trouble-bot-difficulty-naive = ساده
trouble-bot-difficulty-greedy = حریص

trouble-option-preset = پیش‌تنظیم: { $preset }
trouble-option-select-preset = نوع را انتخاب کنید. میزبان می‌تواند بعداً قوانین جداگانه را تنظیم کند.
trouble-option-changed-preset = پیش‌تنظیم اعمال شد: { $preset }.
trouble-option-desc-preset = مجموعه گزینه‌های آماده برای انواع متداول.

trouble-preset-classic = کلاسیک Hasbro
trouble-preset-fast = سریع
trouble-preset-brutal = بی‌رحم
trouble-preset-custom = سفارشی
