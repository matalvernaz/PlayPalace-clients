# Trouble — vi
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble là trò chơi đua thuộc dòng Parcheesi.
    Mỗi người chơi bắt đầu với các quân ở khu Nhà.
    Lượt của bạn, bấm xúc xắc và di chuyển một quân.
    Mặc định bạn phải đổ 6 để đưa một quân từ Nhà ra đường đua.
    Mặc định đổ 6 cũng cho thêm một lượt.
    Các quân di chuyển theo chiều kim đồng hồ trên đường đua chung tới khu đích.
    Đáp xuống quân đối phương đẩy nó về Nhà, trừ khi ô đó được bảo vệ.
    Khi tất cả quân của bạn đến đích, bạn thắng.
    Trong chế độ đội, đội của bạn thắng khi tất cả đồng đội hoàn thành.
    Phím 1-6 chọn quân, R đổ xúc xắc.
    Nhấn E bất kỳ lúc nào để nghe trạng thái bàn cờ đầy đủ.

trouble-action-roll = Bấm xúc xắc
trouble-action-move-token = Di chuyển quân { $token }
trouble-action-check-board = Xem bàn cờ

trouble-token-label-home = Quân { $token }: ở Nhà
trouble-token-label-track = Quân { $token }: ô { $position } đường đua
trouble-token-label-finish-lane = Quân { $token }: làn đích { $position } / { $total }
trouble-token-label-finished = Quân { $token }: đã về đích

trouble-rolled = { $player } đổ ra { $roll }.
trouble-leave-home = { $player } đưa quân { $token } ra đường đua.
trouble-advance-track = { $player } di chuyển quân { $token } đến ô { $position }.
trouble-enter-finish-lane = { $player } đưa quân { $token } vào làn đích.
trouble-advance-finish-lane =
    { $player } tiến quân { $token } đến ô { $position } / { $total } của làn đích.
trouble-token-finished = Quân { $token } của { $player } đến đích.
trouble-bump =
    Quân { $token } của { $player } đẩy quân { $opp_token } của { $opponent } về Nhà.
trouble-no-legal-move = { $player } không có nước đi hợp lệ. Lượt chuyển tiếp.
trouble-extra-turn = { $player } được lượt thêm nhờ đổ 6.

trouble-winner = { $player } thắng! Tất cả quân về đích.
trouble-team-winner = Đội { $team } thắng! Tất cả đồng đội đã hoàn thành.
trouble-final-standing = { $player }: { $finished } / { $total } quân về đích.

trouble-turn-summary =
    Bạn có { $own_home } ở Nhà, { $own_track } trên đường, { $own_finished } ở đích.
    Đối thủ: { $opponents }.
trouble-opponent-summary = { $name }: { $home } nhà, { $track } đường, { $finished } đích

trouble-board-status =
    Quân của bạn: { $own_tokens }.
    Quân đối thủ: { $opp_tokens }.

trouble-reason-not-rolled = Bấm xúc xắc trước đã.
trouble-reason-already-rolled = Đã bấm rồi. Chọn quân để di chuyển.
trouble-reason-no-legal-moves = Không có nước đi hợp lệ với điểm này.
trouble-reason-token-home-needs-six = Quân này ở Nhà. Cần 6 để đưa ra.
trouble-reason-token-home-needs-any = Quân này ở Nhà. Bất kỳ điểm nào đều đưa ra được.
trouble-reason-token-home-no-qualifying-roll =
    Quân này ở Nhà và điểm của bạn không đủ điều kiện đưa ra.
trouble-reason-token-finished = Quân này đã về đích rồi.
trouble-reason-overshoot-wastes = Quân này không thể đi { $roll } ô mà không vượt qua đích.
trouble-reason-blocked = Nước đi này bị chặn.

trouble-option-track-size = Kích thước đường đua: { $track_size } ô
trouble-option-select-track-size = Chọn số ô của đường đua.
trouble-option-changed-track-size = Đường đua đặt ở { $track_size } ô.
trouble-option-desc-track-size = Số ô trên đường đua chung.

trouble-option-tokens-per-player = Quân mỗi người chơi: { $tokens }
trouble-option-enter-tokens-per-player = Nhập số quân mỗi người chơi (2-6):
trouble-option-changed-tokens-per-player = Quân mỗi người chơi đặt ở { $tokens }.
trouble-option-desc-tokens-per-player = Số quân mỗi người chơi đưa về đích.

trouble-option-extra-turn-on-six = Lượt thêm khi đổ 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Lượt thêm khi đổ 6 { $enabled ->
    [on] bật.
    [off] tắt.
   *[other] cập nhật.
}
trouble-option-desc-extra-turn-on-six =
    Bật: đổ 6 cho thêm một lượt (quy tắc cổ điển Hasbro).

trouble-option-six-to-leave-home = Yêu cầu 6 để rời Nhà: { $enabled }
trouble-option-changed-six-to-leave-home = Sáu để rời Nhà { $enabled ->
    [on] bật.
    [off] tắt.
   *[other] cập nhật.
}
trouble-option-desc-six-to-leave-home =
    Bật: người chơi phải đổ 6 để đưa quân khỏi Nhà. Tắt: bất kỳ điểm nào cũng đưa ra được.

trouble-option-safe-spaces = Ô an toàn: { $mode }
trouble-option-select-safe-spaces = Chọn chế độ ô an toàn.
trouble-option-changed-safe-spaces = Ô an toàn đặt ở { $mode }.
trouble-option-desc-safe-spaces = Quyết định quân có được bảo vệ khỏi va chạm hay không.

trouble-safe-mode-none = Không
trouble-safe-mode-home-stretch = Chỉ đoạn cuối
trouble-safe-mode-every-seventh = Mỗi 7 ô

trouble-option-finish-behavior = Đích: { $mode }
trouble-option-select-finish-behavior = Chọn hành vi tại đích.
trouble-option-changed-finish-behavior = Hành vi đích đặt ở { $mode }.
trouble-option-desc-finish-behavior = Cách xử lý điểm vượt qua đích.

trouble-finish-mode-exact = Cần điểm chính xác
trouble-finish-mode-bounce = Vượt bị bật lại
trouble-finish-mode-allow = Cho phép vượt

trouble-option-bot-difficulty = Độ khó của bot: { $level }
trouble-option-select-bot-difficulty = Chọn độ khó của bot.
trouble-option-changed-bot-difficulty = Độ khó của bot đặt ở { $level }.
trouble-option-desc-bot-difficulty = Sức mạnh của bot tích hợp.

trouble-bot-difficulty-naive = Ngây thơ
trouble-bot-difficulty-greedy = Tham lam

trouble-option-preset = Cài đặt sẵn: { $preset }
trouble-option-select-preset = Chọn biến thể. Chủ phòng có thể điều chỉnh quy tắc riêng sau.
trouble-option-changed-preset = Cài đặt sẵn áp dụng: { $preset }.
trouble-option-desc-preset = Bộ tùy chọn đóng gói sẵn cho các biến thể phổ biến.

trouble-preset-classic = Cổ điển Hasbro
trouble-preset-fast = Nhanh
trouble-preset-brutal = Tàn bạo
trouble-preset-custom = Tùy chỉnh
