# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = نود و نه

# Round and turn flow
game-round-start = دور { $round }.
game-round-end = دور { $round } تمام شد.
game-turn-start = نوبت { $player }.
game-your-turn = نوبت شماست.
game-no-turn = الان نوبت کسی نیست.

# Score display
game-scores-header = امتیازات فعلی:
game-score-line = { $player }: { $score } امتیاز
game-final-scores-header = امتیازات نهایی:

# Win/loss
game-winner = { $player } برنده می‌شود!
game-winner-score = { $player } با { $score } امتیاز برنده می‌شود!
game-tiebreaker = مساوی! دور تعیین‌کننده!
game-tiebreaker-players = مساوی بین { $players }! دور تعیین‌کننده!
game-eliminated = { $player } با { $score } امتیاز حذف شد.

# Common options
game-set-target-score = امتیاز هدف: { $score }
game-enter-target-score = امتیاز هدف را وارد کنید:
game-option-changed-target = امتیاز هدف به { $score } تنظیم شد.

game-set-team-mode = حالت تیمی: { $mode }
game-select-team-mode = حالت تیمی را انتخاب کنید
game-option-changed-team = حالت تیمی به { $mode } تنظیم شد.
game-team-mode-individual = انفرادی
game-team-mode-x-teams-of-y = { $num_teams } تیم { $team_size } نفره

# Boolean option values
option-on = روشن
option-off = خاموش

# Status box

# Game end
game-leave = خروج از بازی

# Round timer
round-timer-paused = { $player } بازی را متوقف کرده است (برای شروع دور بعدی p را فشار دهید).
round-timer-resumed = تایمر دور از سر گرفته شد.
round-timer-countdown = دور بعدی در { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = نگه‌داری { $value }.
dice-rerolling = انداختن دوباره { $value }.
dice-locked = آن تاس قفل است و نمی‌توان تغییر داد.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = پخش { $current }/{ $total }.
game-you-deal = شما کارت‌ها را پخش می‌کنید.
game-player-deals = { $player } کارت‌ها را پخش می‌کند.

# Card names
card-name = { $rank } { $suit }
no-cards = بدون کارت

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = سیاه
color-black-m = سیاه
color-black-f = سیاه
color-blue = آبی
color-blue-m = آبی
color-blue-f = آبی
color-brown = قهوه‌ای
color-brown-m = قهوه‌ای
color-brown-f = قهوه‌ای
color-gray = خاکستری
color-gray-m = خاکستری
color-gray-f = خاکستری
color-green = سبز
color-green-m = سبز
color-green-f = سبز
color-indigo = نیلی
color-indigo-m = نیلی
color-indigo-f = نیلی
color-orange = نارنجی
color-orange-m = نارنجی
color-orange-f = نارنجی
color-pink = صورتی
color-pink-m = صورتی
color-pink-f = صورتی
color-purple = بنفش
color-purple-m = بنفش
color-purple-f = بنفش
color-red = قرمز
color-red-m = قرمز
color-red-f = قرمز
color-violet = بنفش
color-violet-m = بنفش
color-violet-f = بنفش
color-white = سفید
color-white-m = سفید
color-white-f = سفید
color-yellow = زرد
color-yellow-m = زرد
color-yellow-f = زرد

# Suit names
suit-diamonds = خشت
suit-clubs = گشنیز
suit-hearts = دل
suit-spades = پیک

# Rank names
rank-ace = اُس
rank-ace-plural = اُس‌ها
rank-two = ۲
rank-two-plural = ۲ها
rank-three = ۳
rank-three-plural = ۳ها
rank-four = ۴
rank-four-plural = ۴ها
rank-five = ۵
rank-five-plural = ۵ها
rank-six = ۶
rank-six-plural = ۶ها
rank-seven = ۷
rank-seven-plural = ۷ها
rank-eight = ۸
rank-eight-plural = ۸ها
rank-nine = ۹
rank-nine-plural = ۹ها
rank-ten = ۱۰
rank-ten-plural = ۱۰ها
rank-jack = سرباز
rank-jack-plural = سربازها
rank-queen = بی‌بی
rank-queen-plural = بی‌بی‌ها
rank-king = شاه
rank-king-plural = شاه‌ها

# Poker hand descriptions
poker-high-card-with = { $high } بالا، با { $rest }
poker-high-card = { $high } بالا
poker-pair-with = یک جفت { $pair }، با { $rest }
poker-pair = یک جفت { $pair }
poker-two-pair-with = دو جفت، { $high } و { $low }، با { $kicker }
poker-two-pair = دو جفت، { $high } و { $low }
poker-trips-with = سه‌تا یکی، { $trips }، با { $rest }
poker-trips = سه‌تا یکی، { $trips }
poker-straight-high = ترتیب { $high } بالا
poker-flush-high-with = فلاش { $high } بالا، با { $rest }
poker-full-house = فول هاوس، { $trips } روی { $pair }
poker-quads-with = چهارتا یکی، { $quads }، با { $kicker }
poker-quads = چهارتا یکی، { $quads }
poker-straight-flush-high = استریت فلاش { $high } بالا
poker-unknown-hand = دست ناشناخته

# Validation errors (common across games)
game-error-invalid-team-mode = حالت تیمی انتخاب شده برای تعداد بازیکنان فعلی معتبر نیست.

game-turn-start-you = نوبت شماست.
game-turn-start-player = نوبت { $player } است.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] امتیاز
   *[other] امتیاز
}
game-score-unit-chips = { $count ->
    [one] تراشه
   *[other] تراشه
}
game-score-unit-coins = { $count ->
    [one] سکه
   *[other] سکه
}
game-score-unit-health = سلامتی
game-score-unit-ninetynine-tokens = { $count ->
    [one] نشان
   *[other] نشان
}
game-score-unit-tokens-home = { $count ->
    [one] نشان در خانه
   *[other] نشان در خانه
}
game-score-unit-pawns-home = { $count ->
    [one] مهره در خانه
   *[other] مهره در خانه
}
game-score-unit-hand-wins = { $count ->
    [one] برد دست
   *[other] برد دست
}
game-score-unit-light = نور
game-winner-you = شما برنده شدید!
game-team-name = تیم { $index }
team-arrangement-started = چینش تیم‌ها آغاز شد. تیم‌ها را بررسی کنید، در صورت نیاز اعضا را جابه‌جا کنید، سپس برای شروع تأیید کنید.
team-arrangement-confirm = تأیید تیم‌ها و شروع
team-arrangement-read = مشاهده‌ی تیم‌ها
team-arrangement-select-member-action = انتخاب عضو تیم
team-arrangement-select-member = یک عضو تیم انتخاب کنید
team-arrangement-select-swap-target = یک بازیکن را برای جابه‌جایی انتخاب کنید
team-arrangement-swap-member = انتخاب هدف جابه‌جایی
team-arrangement-swap-member-selected = جابه‌جایی { $player } با...
team-arrangement-cancel = لغو چینش تیم‌ها
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = ترتیب نوبت: { $players }
team-arrangement-member-option = { $player }، { $team }، { $selected }
team-arrangement-selected = انتخاب شد
team-arrangement-not-selected = انتخاب نشد
team-arrangement-member-selected = { $player } از { $team } انتخاب شد. یک بازیکن از تیم دیگر را برای جابه‌جایی انتخاب کنید.
team-arrangement-swapped = { $first } و { $second } تیم‌های خود را عوض کردند.
team-arrangement-cancelled = چینش تیم‌ها لغو شد.
team-arrangement-cancelled-roster = چینش تیم‌ها به دلیل تغییر لیست بازیکنان لغو شد.
team-arrangement-refreshed = لیست بازیکنان تغییر کرد. چینش تیم‌ها به‌روزرسانی شد.
team-arrangement-in-progress = ابتدا چینش تیم‌ها را تمام یا لغو کنید.
team-arrangement-not-active = چینش تیم‌ها فعال نیست.
team-arrangement-select-first = ابتدا یک عضو تیم انتخاب کنید.
team-arrangement-player-missing = آن بازیکن دیگر برای چینش تیم‌ها در دسترس نیست.
team-arrangement-same-team = از یک تیم دیگر انتخاب کنید.
team-arrangement-swap-failed = جابه‌جایی آن اعضای تیم امکان‌پذیر نبود.

status-box-closed = اطلاعات وضعیت بسته شد.

dice-status-label-locked = { $value } (قفل)
dice-status-label-kept = { $value } (نگهداشته‌شده)

poker-royal-flush = رویال فلاش
documentation-menu = مستندات
introduction = مقدمه
community-rules = قوانین جامعه
global-keys = کنترل‌های عمومی
game-rules = قوانین بازی
changelog = تغییرات
donation = کمک مالی
contact = تماس
document-not-found = سند یافت نشد.
help = راهنما

# اطلاعات بازی (Ctrl+I)
game-info = اطلاعات بازی
game-info-header = اطلاعات بازی فعلی
game-info-name = بازی: {$game}
game-info-players = بازیکنان: {$count}
game-info-host = میزبان: {$host}
game-info-status = وضعیت: {$status}
game-info-status-waiting = در انتظار در لابی
game-info-status-playing = در حال اجرا
game-info-options-header = تنظیمات:
game-info-no-options = این بازی گزینه‌های پیکربندی سفارشی ندارد.

# نحوه‌ی بازی (Ctrl+F1)
how-to-play = نحوه‌ی بازی
game-rules-not-available = قوانین {$game} هنوز در دسترس نیست.
