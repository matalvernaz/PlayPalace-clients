# Mancala game messages — ru
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Манкала

# Actions
mancala-pit-label = Лунка { $pit }: { $stones } камней

# Game events
mancala-sow = { $player } сеет { $stones } камней из лунки { $pit }
mancala-capture = { $player } захватывает { $captured } камней!
mancala-extra-turn = Последний камень в хранилище! { $player } ходит ещё раз.
mancala-winner = { $player } побеждает с { $score } камнями!
mancala-draw = Ничья! У обоих игроков по { $score } камней.

# Board status
mancala-board-status =
    Ваши лунки: { $own_pits }. Ваше хранилище: { $own_store }. Лунки соперника: { $opp_pits }. Хранилище соперника: { $opp_store }.

# Options
mancala-set-stones = Камней на лунку: { $stones }
mancala-desc-stones = Количество камней в каждой лунке в начале
mancala-enter-stones = Введите количество начальных камней на лунку:
mancala-option-changed-stones = Начальные камни изменены на { $stones }

# Disabled reasons
mancala-pit-empty = Эта лунка пуста.

# Rules
mancala-rules =
    Манкала — игра для двух игроков с лунками и камнями.
    У каждого игрока 6 лунок и хранилище.
    В свой ход выберите одну из своих лунок для посева.
    Камни раскладываются по одному в каждую лунку вокруг доски, включая ваше хранилище, но пропуская хранилище соперника.
    Если последний камень попадает в ваше хранилище, вы ходите ещё раз.
    Если последний камень попадает в пустую лунку на вашей стороне, вы захватываете этот камень и все камни из противоположной лунки.
    Игра заканчивается, когда одна сторона полностью пуста.
    Побеждает игрок с наибольшим количеством камней.
    Используйте клавиши 1-6 для выбора лунки. Нажмите E для проверки доски.

# End screen
mancala-final-score = { $player }: { $score } камней
