# Mancala game messages — ar
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = مانكالا

# Actions
mancala-pit-label = حفرة { $pit }: { $stones } حجر

# Game events
mancala-sow = { $player } يزرع { $stones } حجر من الحفرة { $pit }
mancala-capture = { $player } يأسر { $captured } حجر!
mancala-extra-turn = آخر حجر في المخزن! { $player } يحصل على دور إضافي.
mancala-winner = { $player } يفوز بـ { $score } حجر!
mancala-draw = تعادل! كلا اللاعبين لديهما { $score } حجر.

# Board status
mancala-board-status =
    حفرك: { $own_pits }. مخزنك: { $own_store }. حفر الخصم: { $opp_pits }. مخزن الخصم: { $opp_store }.

# Options
mancala-set-stones = أحجار لكل حفرة: { $stones }
mancala-desc-stones = عدد الأحجار في كل حفرة في البداية
mancala-enter-stones = أدخل عدد الأحجار الابتدائية لكل حفرة:
mancala-option-changed-stones = تم تغيير الأحجار الابتدائية إلى { $stones }

# Disabled reasons
mancala-pit-empty = هذه الحفرة فارغة.

# Rules
mancala-rules =
    مانكالا هي لعبة حفر وأحجار للاعبين اثنين.
    كل لاعب لديه 6 حفر ومخزن.
    في دورك، اختر حفرة من حفرك لتزرع منها.
    توزع الأحجار واحدة تلو الأخرى في كل حفرة حول اللوحة، بما في ذلك مخزنك ولكن مع تخطي مخزن خصمك.
    إذا سقط آخر حجر في مخزنك، تحصل على دور إضافي.
    إذا سقط آخر حجر في حفرة فارغة في جانبك، تأسر ذلك الحجر وجميع الأحجار في الحفرة المقابلة.
    تنتهي اللعبة عندما يكون جانب أحد اللاعبين فارغاً تماماً. الأحجار المتبقية تذهب إلى مخزن ذلك اللاعب.
    اللاعب الذي لديه أكثر أحجار يفوز.
    استخدم المفاتيح 1 إلى 6 لاختيار حفرة. اضغط E لفحص اللوحة.

# End screen
mancala-final-score = { $player }: { $score } حجر
mancala-check-board = Check board
