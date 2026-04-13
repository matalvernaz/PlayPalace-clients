# Mancala game messages — fa
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = منقله

# Actions
mancala-pit-label = چاله { $pit }: { $stones } سنگ

# Game events
mancala-sow = { $player } { $stones } سنگ از چاله { $pit } می‌کارد
mancala-capture = { $player } { $captured } سنگ گرفت!
mancala-extra-turn = آخرین سنگ در انبار! { $player } نوبت اضافی دارد.
mancala-winner = { $player } با { $score } سنگ برنده شد!
mancala-draw = مساوی! هر دو بازیکن { $score } سنگ دارند.

# Board status
mancala-board-status =
    چاله‌های شما: { $own_pits }. انبار شما: { $own_store }. چاله‌های حریف: { $opp_pits }. انبار حریف: { $opp_store }.

# Options
mancala-set-stones = سنگ در هر چاله: { $stones }
mancala-desc-stones = تعداد سنگ‌ها در هر چاله در شروع
mancala-enter-stones = تعداد سنگ‌های اولیه هر چاله را وارد کنید:
mancala-option-changed-stones = سنگ‌های اولیه به { $stones } تغییر کرد

# Disabled reasons
mancala-pit-empty = این چاله خالی است.

# Rules
mancala-rules =
    منقله یک بازی دو نفره با چاله و سنگ است.
    هر بازیکن ۶ چاله و یک انبار دارد.
    در نوبت خود، یکی از چاله‌هایتان را برای کاشتن انتخاب کنید.
    سنگ‌ها یکی یکی در هر چاله دور تخته قرار می‌گیرند، شامل انبار شما اما با رد شدن از انبار حریف.
    اگر آخرین سنگ در انبار شما بیفتد، نوبت اضافی می‌گیرید.
    اگر آخرین سنگ در چاله خالی سمت شما بیفتد، آن سنگ و تمام سنگ‌های چاله مقابل را می‌گیرید.
    بازی زمانی تمام می‌شود که یک طرف کاملاً خالی باشد.
    بازیکنی که سنگ بیشتری دارد برنده است.
    از کلیدهای ۱ تا ۶ برای انتخاب چاله استفاده کنید. E را برای بررسی تخته فشار دهید.

# End screen
mancala-final-score = { $player }: { $score } سنگ
mancala-check-board = Check board
