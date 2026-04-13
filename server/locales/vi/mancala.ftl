# Mancala game messages — vi
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Ô ăn quan

# Actions
mancala-pit-label = Ô { $pit }: { $stones } sỏi

# Game events
mancala-sow = { $player } rải { $stones } sỏi từ ô { $pit }
mancala-capture = { $player } bắt được { $captured } sỏi!
mancala-extra-turn = Sỏi cuối vào kho! { $player } được đi thêm lượt.
mancala-winner = { $player } thắng với { $score } sỏi!
mancala-draw = Hòa! Cả hai người chơi đều có { $score } sỏi.

# Board status
mancala-board-status =
    Ô của bạn: { $own_pits }. Kho của bạn: { $own_store }. Ô đối thủ: { $opp_pits }. Kho đối thủ: { $opp_store }.

# Options
mancala-set-stones = Sỏi mỗi ô: { $stones }
mancala-desc-stones = Số sỏi trong mỗi ô lúc bắt đầu
mancala-enter-stones = Nhập số sỏi ban đầu mỗi ô:
mancala-option-changed-stones = Sỏi ban đầu đổi thành { $stones }

# Disabled reasons
mancala-pit-empty = Ô đó trống.

# Rules
mancala-rules =
    Ô ăn quan là trò chơi ô và sỏi cho hai người.
    Mỗi người chơi có 6 ô và 1 kho.
    Đến lượt bạn, chọn một ô của mình để rải.
    Sỏi được đặt từng viên vào mỗi ô quanh bàn, bao gồm kho của bạn nhưng bỏ qua kho đối thủ.
    Nếu sỏi cuối rơi vào kho của bạn, bạn được đi thêm lượt.
    Nếu sỏi cuối rơi vào ô trống bên bạn, bạn bắt viên sỏi đó và tất cả sỏi ở ô đối diện.
    Trò chơi kết thúc khi một bên hoàn toàn trống.
    Người chơi có nhiều sỏi nhất thắng.
    Dùng phím 1-6 để chọn ô. Nhấn E để xem bàn.

# End screen
mancala-final-score = { $player }: { $score } sỏi
