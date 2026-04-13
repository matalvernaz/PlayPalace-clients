# Mancala game messages — sr
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Манкала

# Actions
mancala-pit-label = Рупа { $pit }: { $stones } каменчића

# Game events
mancala-sow = { $player } сеје { $stones } каменчића из рупе { $pit }
mancala-capture = { $player } заробљава { $captured } каменчића!
mancala-extra-turn = Последњи каменчић у спремишту! { $player } игра поново.
mancala-winner = { $player } побеђује са { $score } каменчића!
mancala-draw = Нерешено! Оба играча имају { $score } каменчића.

# Board status
mancala-board-status =
    Ваше рупе: { $own_pits }. Ваше спремиште: { $own_store }. Противникове рупе: { $opp_pits }. Противниково спремиште: { $opp_store }.

# Options
mancala-set-stones = Каменчића по рупи: { $stones }
mancala-desc-stones = Број каменчића у свакој рупи на почетку
mancala-enter-stones = Унесите број почетних каменчића по рупи:
mancala-option-changed-stones = Почетни каменчићи промењени на { $stones }

# Disabled reasons
mancala-pit-empty = Та рупа је празна.

# Rules
mancala-rules =
    Манкала је игра за два играча са рупама и каменчићима.
    Сваки играч има 6 рупа и спремиште.
    На свом потезу изаберите једну од својих рупа за сејање.
    Каменчићи се стављају један по један у сваку рупу око табле, укључујући ваше спремиште али прескачући противниково.
    Ако ваш последњи каменчић падне у ваше спремиште, играте поново.
    Ако ваш последњи каменчић падне у празну рупу на вашој страни, заробљавате тај каменчић и све каменчиће из супротне рупе.
    Игра се завршава кад је једна страна потпуно празна.
    Играч са највише каменчића побеђује.
    Користите тастере 1-6 за избор рупе. Притисните E за проверу табле.

# End screen
mancala-final-score = { $player }: { $score } каменчића
mancala-check-board = Check board
