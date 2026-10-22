# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Дев'яносто дев'ять

# Round and turn flow
game-round-start = Раунд { $round }.
game-round-end = Раунд { $round } завершено.
game-turn-start = Хід { $player }.
game-your-turn = Ваш хід.
game-no-turn = Зараз нічий хід.

# Score display
game-scores-header = Поточні рахунки:
game-score-line = { $player }: { $score } очок
game-final-scores-header = Фінальні рахунки:

# Win/loss
game-winner = { $player } виграє!
game-winner-score = { $player } виграє з { $score } очками!
game-tiebreaker = Нічия! Додатковий раунд!
game-tiebreaker-players = Нічия між { $players }! Додатковий раунд!
game-eliminated = { $player } вибув з { $score } очками.

# Common options
game-set-target-score = Цільовий рахунок: { $score }
game-enter-target-score = Введіть цільовий рахунок:
game-option-changed-target = Цільовий рахунок встановлено на { $score }.

game-set-team-mode = Командний режим: { $mode }
game-select-team-mode = Виберіть командний режим
game-option-changed-team = Командний режим встановлено на { $mode }.
game-team-mode-individual = Індивідуальний
game-team-mode-x-teams-of-y = { $num_teams } команд по { $team_size }

# Boolean option values
option-on = увімкнено
option-off = вимкнено

# Status box

# Game end
game-leave = Покинути гру

# Round timer
round-timer-paused = { $player } призупинив гру (натисніть p, щоб почати наступний раунд).
round-timer-resumed = Таймер раунду відновлено.
round-timer-countdown = Наступний раунд через { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Зберігаємо { $value }.
dice-rerolling = Перекидаємо { $value }.
dice-locked = Цей кубик заблокований і не може бути змінений.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Роздача { $current }/{ $total }.
game-you-deal = Ви роздаєте карти.
game-player-deals = { $player } роздає карти.

# Card names
card-name = { $rank } { $suit }
no-cards = Немає карт

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = чорний
color-black-m = чорний
color-black-f = чорна
color-blue = синій
color-blue-m = синій
color-blue-f = синя
color-brown = коричневий
color-brown-m = коричневий
color-brown-f = коричнева
color-gray = сірий
color-gray-m = сірий
color-gray-f = сіра
color-green = зелений
color-green-m = зелений
color-green-f = зелена
color-indigo = індиго
color-indigo-m = індиго
color-indigo-f = індиго
color-orange = помаранчевий
color-orange-m = помаранчевий
color-orange-f = помаранчева
color-pink = рожевий
color-pink-m = рожевий
color-pink-f = рожева
color-purple = пурпурний
color-purple-m = пурпурний
color-purple-f = пурпурна
color-red = червоний
color-red-m = червоний
color-red-f = червона
color-violet = фіолетовий
color-violet-m = фіолетовий
color-violet-f = фіолетова
color-white = білий
color-white-m = білий
color-white-f = біла
color-yellow = жовтий
color-yellow-m = жовтий
color-yellow-f = жовта

# Suit names
suit-diamonds = бубни
suit-clubs = трефи
suit-hearts = черви
suit-spades = піки

# Rank names
rank-ace = туз
rank-ace-plural = тузи
rank-two = 2
rank-two-plural = двійки
rank-three = 3
rank-three-plural = трійки
rank-four = 4
rank-four-plural = четвірки
rank-five = 5
rank-five-plural = п'ятірки
rank-six = 6
rank-six-plural = шістки
rank-seven = 7
rank-seven-plural = сімки
rank-eight = 8
rank-eight-plural = вісімки
rank-nine = 9
rank-nine-plural = дев'ятки
rank-ten = 10
rank-ten-plural = десятки
rank-jack = валет
rank-jack-plural = валети
rank-queen = дама
rank-queen-plural = дами
rank-king = король
rank-king-plural = королі

# Poker hand descriptions
poker-high-card-with = Старша { $high }, з { $rest }
poker-high-card = Старша { $high }
poker-pair-with = Пара { $pair }, з { $rest }
poker-pair = Пара { $pair }
poker-two-pair-with = Дві пари, { $high } і { $low }, з { $kicker }
poker-two-pair = Дві пари, { $high } і { $low }
poker-trips-with = Трійка, { $trips }, з { $rest }
poker-trips = Трійка, { $trips }
poker-straight-high = Стріт до { $high }
poker-flush-high-with = Флеш до { $high }, з { $rest }
poker-full-house = Фул-хаус, { $trips } над { $pair }
poker-quads-with = Каре, { $quads }, з { $kicker }
poker-quads = Каре, { $quads }
poker-straight-flush-high = Стріт-флеш до { $high }
poker-unknown-hand = Невідома комбінація

# Validation errors (common across games)
game-error-invalid-team-mode = Вибраний командний режим недійсний для поточної кількості гравців.

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
