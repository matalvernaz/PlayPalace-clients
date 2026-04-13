# Mancala game messages — uk
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Манкала

# Actions
mancala-pit-label = Лунка { $pit }: { $stones } каменів

# Game events
mancala-sow = { $player } сіє { $stones } каменів з лунки { $pit }
mancala-capture = { $player } захоплює { $captured } каменів!
mancala-extra-turn = Останній камінь у сховищі! { $player } ходить ще раз.
mancala-winner = { $player } перемагає з { $score } каменями!
mancala-draw = Нічия! Обидва гравці мають по { $score } каменів.

# Board status
mancala-board-status =
    Ваші лунки: { $own_pits }. Ваше сховище: { $own_store }. Лунки суперника: { $opp_pits }. Сховище суперника: { $opp_store }.

# Options
mancala-set-stones = Каменів на лунку: { $stones }
mancala-desc-stones = Кількість каменів у кожній лунці на початку
mancala-enter-stones = Введіть кількість початкових каменів на лунку:
mancala-option-changed-stones = Початкові камені змінено на { $stones }

# Disabled reasons
mancala-pit-empty = Ця лунка порожня.

# Rules
mancala-rules =
    Манкала — гра для двох гравців з лунками та каменями.
    Кожен гравець має 6 лунок і сховище.
    На своєму ходу оберіть одну зі своїх лунок для посіву.
    Камені розкладаються по одному в кожну лунку навколо дошки, включаючи ваше сховище, але пропускаючи сховище суперника.
    Якщо останній камінь потрапляє у ваше сховище, ви ходите ще раз.
    Якщо останній камінь потрапляє в порожню лунку на вашій стороні, ви захоплюєте цей камінь і всі камені з протилежної лунки.
    Гра закінчується, коли одна сторона повністю порожня.
    Гравець з найбільшою кількістю каменів перемагає.
    Використовуйте клавіші 1-6 для вибору лунки. Натисніть E для перевірки дошки.

# End screen
mancala-final-score = { $player }: { $score } каменів
mancala-check-board = Check board
