# midnight.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-midnight = 1-4-24
# Actions
midnight-roll = Бросить кубики
midnight-bank = Банковать
midnight-you-rolled = Вы выбросили: { $dice }.
midnight-player-rolled = { $player } выбрасывает: { $dice }.
# Keeping dice
midnight-you-keep = Вы оставляете { $die }.
midnight-player-keeps = { $player } оставляет { $die }.
midnight-you-unkeep = Вы отменяете выбор { $die }.
midnight-player-unkeeps = { $player } отменяет выбор { $die }.
# Scoring
midnight-you-scored =
    Вы набрали { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }.
midnight-scored =
    { $player } набирает { $score } { $score ->
        [one] очко
        [few] очка
       *[other] очков
    }.
midnight-you-disqualified = У вас нет единицы и четвёрки одновременно. Вы дисквалифицированы!
midnight-player-disqualified = У игрока { $player } нет единицы и четвёрки. Он дисквалифицирован!
# Round results
midnight-round-winner = { $player } побеждает в раунде!
midnight-round-tie = В раунде ничья между игроками: { $players }.
midnight-all-disqualified = Все игроки дисквалифицированы! В этом раунде нет победителя.
# Game winner
midnight-game-winner =
    { $player } побеждает в игре с результатом { $wins } { $wins ->
        [one] победа
        [few] победы
       *[other] побед
    } в раундах!
midnight-game-tie =
    Ничья! { $players } одержали по { $wins } { $wins ->
        [one] победе
        [few] победы
       *[other] побед
    }.
# Options
midnight-set-rounds = Количество раундов: { $rounds }
midnight-enter-rounds = Введите количество раундов:
midnight-option-changed-rounds = Количество раундов изменено на { $rounds }.
# Disabled reasons
midnight-need-to-roll = Сначала нужно бросить кубики.
midnight-no-dice-to-keep = Нет доступных кубиков, чтобы их оставить.
midnight-must-keep-one = Вы должны оставлять как минимум один кубик за бросок.
midnight-must-roll-first = Сначала нужно бросить кубики.
midnight-keep-all-first = Нужно выбрать все кубики перед тем, как зафиксировать счёт.
