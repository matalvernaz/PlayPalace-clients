# Mancala game messages — mn
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Манкала

# Actions
mancala-pit-label = Нүх { $pit }: { $stones } чулуу

# Game events
mancala-sow = { $player } { $pit }-р нүхнээс { $stones } чулуу тарина
mancala-capture = { $player } { $captured } чулуу барьлав!
mancala-extra-turn = Сүүлийн чулуу агуулахад! { $player } дахин тоглоно.
mancala-winner = { $player } { $score } чулуугаар ялав!
mancala-draw = Тэнцэв! Хоёр тоглогч тус бүр { $score } чулуутай.

# Board status
mancala-board-status =
    Таны нүхнүүд: { $own_pits }. Таны агуулах: { $own_store }. Өрсөлдөгчийн нүхнүүд: { $opp_pits }. Өрсөлдөгчийн агуулах: { $opp_store }.

# Options
mancala-set-stones = Нүх тус бүрийн чулуу: { $stones }
mancala-desc-stones = Эхлэхэд нүх бүрт байх чулууны тоо
mancala-enter-stones = Нүх тус бүрийн эхлэл чулууны тоог оруулна уу:
mancala-option-changed-stones = Эхлэл чулуу { $stones } болж өөрчлөгдлөө

# Disabled reasons
mancala-pit-empty = Тэр нүх хоосон байна.

# Rules
mancala-rules =
    Манкала бол хоёр тоглогчийн нүх ба чулууны тоглоом юм.
    Тоглогч бүр 6 нүх, 1 агуулахтай.
    Ээлжиндээ тарих нүхээ сонгоно.
    Чулууг самбар дагуу нүх бүрт нэг нэгээр тавина, агуулахдаа тавьж болох ч өрсөлдөгчийн агуулахыг алгасна.
    Сүүлийн чулуу агуулахад орвол дахин тоглоно.
    Сүүлийн чулуу өөрийн тал дахь хоосон нүхэнд орвол тэр чулуу болон эсрэг талын бүх чулууг авна.
    Нэг тал бүрэн хоосорвол тоглоом дуусна.
    Хамгийн олон чулуутай тоглогч ялна.
    1-6 товчлуураар нүх сонгоно. E дарж самбарыг шалгана.

# End screen
mancala-final-score = { $player }: { $score } чулуу
mancala-check-board = Check board
