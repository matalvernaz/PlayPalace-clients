# Shared game messages for PlayPalace

# Game names
game-name-ninetynine = تسعة وتسعون

# Round and turn flow
game-round-start = الجولة { $round }.
game-round-end = انتهت الجولة { $round }.
game-turn-start = دور { $player }.
game-your-turn = دورك.
game-no-turn = لا يوجد دور لأحد الآن.

# Score display
game-scores-header = النتائج الحالية:
game-score-line = { $player }: { $score } نقطة
game-final-scores-header = النتائج النهائية:

# Win/loss
game-winner = { $player } يفوز!
game-winner-score = { $player } يفوز بـ { $score } نقطة!
game-tiebreaker = إنه تعادل! جولة حاسمة!
game-tiebreaker-players = إنه تعادل بين { $players }! جولة حاسمة!
game-eliminated = تم إقصاء { $player } بـ { $score } نقطة.

# Common options
game-set-target-score = النتيجة المستهدفة: { $score }
game-enter-target-score = أدخل النتيجة المستهدفة:
game-option-changed-target = تم تعيين النتيجة المستهدفة إلى { $score }.

game-set-team-mode = وضع الفريق: { $mode }
game-select-team-mode = اختر وضع الفريق
game-option-changed-team = تم تعيين وضع الفريق إلى { $mode }.
game-team-mode-individual = فردي
game-team-mode-x-teams-of-y = { $num_teams } فرق من { $team_size }

# Boolean option values
option-on = مفعل
option-off = معطل

# Status box

# Game end
game-leave = غادر اللعبة

# Round timer
round-timer-paused = { $player } أوقف اللعبة مؤقتاً (اضغط p لبدء الجولة التالية).
round-timer-resumed = تم استئناف مؤقت الجولة.
round-timer-countdown = الجولة التالية في { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = الاحتفاظ بـ { $value }.
dice-rerolling = إعادة رمي { $value }.
dice-locked = هذا الزهر مقفل ولا يمكن تغييره.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = التوزيع { $current }/{ $total }.
game-you-deal = أنت توزع الأوراق.
game-player-deals = { $player } يوزع الأوراق.

# Card names
card-name = { $rank } من { $suit }
no-cards = لا توجد أوراق

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = أسود
color-black-m = أسود
color-black-f = سوداء
color-blue = أزرق
color-blue-m = أزرق
color-blue-f = زرقاء
color-brown = بني
color-brown-m = بني
color-brown-f = بنية
color-gray = رمادي
color-gray-m = رمادي
color-gray-f = رمادية
color-green = أخضر
color-green-m = أخضر
color-green-f = خضراء
color-indigo = نيلي
color-indigo-m = نيلي
color-indigo-f = نيلية
color-orange = برتقالي
color-orange-m = برتقالي
color-orange-f = برتقالية
color-pink = وردي
color-pink-m = وردي
color-pink-f = وردية
color-purple = أرجواني
color-purple-m = أرجواني
color-purple-f = أرجوانية
color-red = أحمر
color-red-m = أحمر
color-red-f = حمراء
color-violet = بنفسجي
color-violet-m = بنفسجي
color-violet-f = بنفسجية
color-white = أبيض
color-white-m = أبيض
color-white-f = بيضاء
color-yellow = أصفر
color-yellow-m = أصفر
color-yellow-f = صفراء

# Suit names
suit-diamonds = الماس
suit-clubs = بستوني
suit-hearts = قلوب
suit-spades = سباتي

# Rank names
rank-ace = آس
rank-ace-plural = آسات
rank-two = 2
rank-two-plural = 2s
rank-three = 3
rank-three-plural = 3s
rank-four = 4
rank-four-plural = 4s
rank-five = 5
rank-five-plural = 5s
rank-six = 6
rank-six-plural = 6s
rank-seven = 7
rank-seven-plural = 7s
rank-eight = 8
rank-eight-plural = 8s
rank-nine = 9
rank-nine-plural = 9s
rank-ten = 10
rank-ten-plural = 10s
rank-jack = ولد
rank-jack-plural = أولاد
rank-queen = ملكة
rank-queen-plural = ملكات
rank-king = ملك
rank-king-plural = ملوك

# Poker hand descriptions
poker-high-card-with = { $high } عالي، مع { $rest }
poker-high-card = { $high } عالي
poker-pair-with = زوج من { $pair }، مع { $rest }
poker-pair = زوج من { $pair }
poker-two-pair-with = زوجان، { $high } و { $low }، مع { $kicker }
poker-two-pair = زوجان، { $high } و { $low }
poker-trips-with = ثلاثة من نوع، { $trips }، مع { $rest }
poker-trips = ثلاثة من نوع، { $trips }
poker-straight-high = سلسلة { $high } عالي
poker-flush-high-with = لون { $high } عالي، مع { $rest }
poker-full-house = فل هاوس، { $trips } على { $pair }
poker-quads-with = أربعة من نوع، { $quads }، مع { $kicker }
poker-quads = أربعة من نوع، { $quads }
poker-straight-flush-high = سلسلة لون { $high } عالي
poker-unknown-hand = يد غير معروفة

# Validation errors (common across games)
game-error-invalid-team-mode = وضع الفريق المحدد غير صالح لعدد اللاعبين الحالي.

game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] point
   *[other] points
}
game-score-unit-chips = { $count ->
    [one] chip
   *[other] chips
}
game-score-unit-coins = { $count ->
    [one] coin
   *[other] coins
}
game-score-unit-health = health
game-score-unit-ninetynine-tokens = { $count ->
    [one] token
   *[other] tokens
}
game-score-unit-tokens-home = { $count ->
    [one] token home
   *[other] tokens home
}
game-score-unit-pawns-home = { $count ->
    [one] pawn home
   *[other] pawns home
}
game-score-unit-hand-wins = { $count ->
    [one] hand win
   *[other] hand wins
}
game-score-unit-light = light
game-winner-you = You win!
game-team-name = Team { $index }
team-arrangement-started = Team arrangement started. Review the teams, swap members if needed, then confirm to start.
team-arrangement-confirm = Confirm teams and start
team-arrangement-read = Read teams
team-arrangement-select-member-action = Select team member
team-arrangement-select-member = Select a team member
team-arrangement-select-swap-target = Select a player to swap with
team-arrangement-swap-member = Choose swap target
team-arrangement-swap-member-selected = Swap { $player } with...
team-arrangement-cancel = Cancel team arrangement
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Turn order: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selected
team-arrangement-not-selected = not selected
team-arrangement-member-selected = { $player } from { $team } selected. Choose a player from another team to swap with.
team-arrangement-swapped = { $first } and { $second } have swapped teams.
team-arrangement-cancelled = Team arrangement cancelled.
team-arrangement-cancelled-roster = Team arrangement cancelled because the player list changed.
team-arrangement-refreshed = The player list changed. Team arrangement has been refreshed.
team-arrangement-in-progress = Finish or cancel team arrangement first.
team-arrangement-not-active = Team arrangement is not active.
team-arrangement-select-first = Select a team member first.
team-arrangement-player-missing = That player is no longer available for team arrangement.
team-arrangement-same-team = Choose someone from a different team.
team-arrangement-swap-failed = Could not swap those team members.

status-box-closed = Status information closed.

dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)

poker-royal-flush = Royal Flush
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
contact = Contact
document-not-found = Document not found.
help = Help

# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: {$game}
game-info-players = Players: {$count}
game-info-host = Host: {$host}
game-info-status = Status: {$status}
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.

# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for {$game} are not available yet.
