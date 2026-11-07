# games.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Round and turn flow
game-round-start = Раунд { $round }.
game-round-end = Раунд { $round } завершён.
game-turn-start = Ход игрока { $player }.
game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-no-turn = Сейчас никто не ходит.
game-score-line =
    { $player }: { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points =
    { $count ->
        [one] point
       *[other] points
    }
game-score-unit-chips =
    { $count ->
        [one] chip
       *[other] chips
    }
game-score-unit-coins =
    { $count ->
        [one] coin
       *[other] coins
    }
game-score-unit-health = health
game-score-unit-ninetynine-tokens =
    { $count ->
        [one] token
       *[other] tokens
    }
game-score-unit-tokens-home =
    { $count ->
        [one] token home
       *[other] tokens home
    }
game-score-unit-pawns-home =
    { $count ->
        [one] pawn home
       *[other] pawns home
    }
game-score-unit-hand-wins =
    { $count ->
        [one] hand win
       *[other] hand wins
    }
game-score-unit-light = light
game-final-scores-header = Итоговый счёт:
# Win/loss
game-winner = { $player } побеждает!
game-winner-you = You win!
game-winner-score =
    { $player } побеждает, набрав { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }!
game-tiebreaker = Ничья! Раунд для определения победителя!
game-eliminated =
    Игрок { $player } выбывает из игры с результатом { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }.
# Common options
game-set-target-score = Конечный счёт: { $score }
game-enter-target-score = Введите конечный счёт:
game-option-changed-target = Конечный счёт установлен на { $score }.
game-set-team-mode = Командный режим: { $mode }
game-select-team-mode = Выберите командный режим
game-option-changed-team = Командный режим изменён на { $mode }.
game-team-mode-individual = Индивидуальный
game-team-mode-x-teams-of-y =
    { $num_teams } { $num_teams ->
        [one] команда
        [few] команды
       *[other] команд
    } по { $team_size } { $team_size ->
        [one] игроку
        [few] игрока
       *[other] игроков
    }
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
# Game end
game-leave = Покинуть игру
# Round timer
round-timer-paused = Игрок { $player } поставил игру на паузу (нажмите «p», чтобы начать следующий раунд).
# Dice games - keeping/releasing dice
dice-keeping = Оставляем: { $value }.
dice-rerolling = Перебрасываем: { $value }.
dice-locked = Этот кубик заблокирован, его нельзя изменить.
dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)
# Dealing (card games)
game-deal-counter = Раздача { $current }/{ $total }.
game-you-deal = Вы раздаёте карты.
game-player-deals = { $player } раздаёт карты.
# Card names
card-name = { $rank } { $suit }
no-cards = Нет карт
# Suit names (in genitive plural for phrases like "Ace of clubs" -> "Туз треф")
suit-diamonds = бубен
suit-clubs = треф
suit-hearts = червей
suit-spades = пик
# Rank names
rank-ace = Туз
rank-two = Двойка
rank-three = Тройка
rank-four = Четвёрка
rank-five = Пятёрка
rank-six = Шестёрка
rank-seven = Семёрка
rank-eight = Восьмёрка
rank-nine = Девятка
rank-ten = Десятка
rank-jack = Валет
rank-queen = Дама
rank-king = Король
rank-ace-plural = Тузов
rank-two-plural = Двоек
rank-three-plural = Троек
rank-four-plural = Четвёрок
rank-five-plural = Пятёрок
rank-six-plural = Шестёрок
rank-seven-plural = Семёрок
rank-eight-plural = Восьмёрок
rank-nine-plural = Девяток
rank-ten-plural = Десяток
rank-jack-plural = Валетов
rank-queen-plural = Дам
rank-king-plural = Королей
# Poker hand descriptions
poker-high-card-with = Старшая карта { $high }, кикер { $rest }
poker-high-card = Старшая карта { $high }
poker-pair-with = Пара { $pair }, кикер { $rest }
poker-pair = Пара { $pair }
poker-two-pair-with = Две пары: { $high } и { $low }, кикер { $kicker }
poker-two-pair = Две пары: { $high } и { $low }
poker-trips-with = Сет: { $trips }, кикер { $rest }
poker-trips = Сет: { $trips }
poker-straight-high = Стрит до { $high }
poker-flush-high-with = Флеш до { $high }, кикер { $rest }
poker-full-house = Фулл-хаус: { $trips } и { $pair }
poker-quads-with = Каре: { $quads }, кикер { $kicker }
poker-quads = Каре: { $quads }
poker-royal-flush = Royal Flush
poker-straight-flush-high = Стрит-флеш до { $high }
poker-unknown-hand = Неизвестная комбинация
# Validation errors (common across games)
game-error-invalid-team-mode = Выбранный командный режим недопустим для текущего количества игроков.
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
document-not-found = Document not found.
help = Help
# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: { $game }
game-info-players = Players: { $count }
game-info-host = Host: { $host }
game-info-status = Status: { $status }
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.
# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for { $game } are not available yet.
game-your-turn = Ваш ход.
# Score display
game-scores-header = Текущий счёт:
game-tiebreaker-players = Ничья между игроками: { $players }! Раунд для определения победителя!
round-timer-resumed = Таймер раунда возобновлён.
round-timer-countdown = Следующий раунд через { $seconds }...
dice-status-locked = locked
dice-status-kept = kept
# Colors (with gendered forms: m = masculine, f = feminine)
color-black = чёрный
color-black-m = чёрный
color-black-f = чёрная
color-blue = синий
color-blue-m = синий
color-blue-f = синяя
color-brown = коричневый
color-brown-m = коричневый
color-brown-f = коричневая
color-gray = серый
color-gray-m = серый
color-gray-f = серая
color-green = зелёный
color-green-m = зелёный
color-green-f = зелёная
color-indigo = индиго
color-indigo-m = индиго
color-indigo-f = индиго
color-orange = оранжевый
color-orange-m = оранжевый
color-orange-f = оранжевая
color-pink = розовый
color-pink-m = розовый
color-pink-f = розовая
color-purple = пурпурный
color-purple-m = пурпурный
color-purple-f = пурпурная
color-red = красный
color-red-m = красный
color-red-f = красная
color-violet = фиолетовый
color-violet-m = фиолетовый
color-violet-f = фиолетовая
color-white = белый
color-white-m = белый
color-white-f = белая
color-yellow = жёлтый
color-yellow-m = жёлтый
color-yellow-f = жёлтая
team-arrangement-swapped = { $first } and { $second } have swapped teams.
contact = Contact
