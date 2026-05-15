# Liar's Dice — vi
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Mỗi người chơi đổ xúc xắc bí mật dưới cốc của mình. Lần lượt đặt cược ngày càng cao về tổng số mặt nào đó trên cả bàn — hoặc hét "Nói dối!" nếu không tin lần cược cuối. Sai sẽ mất một xúc xắc. Người cuối cùng còn xúc xắc sẽ thắng.

liarsdice-rules =
    Liar's Dice là trò chơi đoán-mò bằng xúc xắc cho 2 đến 6 người chơi.
    Mỗi người bắt đầu với 5 xúc xắc trong cốc. Đầu mỗi vòng tất cả đổ bí mật.
    Lần lượt đặt cược về tổng số mặt nào đó trên tất cả xúc xắc — ví dụ "ba con 4" nghĩa là khi mở tất cả cốc, có ít nhất ba con 4.
    Mỗi lần cược mới phải cao hơn: cùng mặt với số lượng lớn hơn, hoặc mặt cao hơn với số lượng bằng hoặc lớn hơn.
    1 là chủ — tính vào mọi cược trừ cược trên chính số 1.
    Chuyển sang cược trên 1 sẽ chia đôi số lượng (làm tròn lên). Quay lại từ 1 về mặt thường cần hơn gấp đôi số lượng trước.
    Thay vì cược bạn có thể hét "Nói dối!" để thách thức cược trước. Tất cả cốc mở ra: nếu cược đúng, người thách thức mất một xúc xắc; nếu sai, người cược mất một xúc xắc.
    Khi Spot On bật, bạn có thể hét "Spot On" cược rằng số chính xác. Đúng — mọi người khác mất một xúc xắc; sai — bạn mất hai.
    Bị loại khi hết xúc xắc. Người cuối cùng còn xúc xắc thắng.
    Nhấn S để kiểm tra bàn.

ld-set-starting-dice = Xúc xắc khởi đầu mỗi người: { $dice }
ld-desc-starting-dice = Mỗi người chơi bắt đầu với bao nhiêu xúc xắc. Mặc định 5. Nhiều xúc xắc = ván dài hơn, không gian đoán-mò rộng hơn.
ld-prompt-starting-dice = Nhập số xúc xắc khởi đầu (3 đến 8)
ld-option-changed-starting-dice = Xúc xắc khởi đầu đặt thành { $dice }.

ld-toggle-wild-ones = 1 là chủ: { $enabled }
ld-desc-wild-ones = Bật: 1 tính vào mọi cược không phải trên 1. Cược trên 1 tắt chủ cho cược đó. Tắt — trò chơi thuần xác suất không có chủ.
ld-option-changed-wild-ones = Chủ 1 { $enabled }.

ld-toggle-spot-on = Gọi Spot On bật: { $enabled }
ld-desc-spot-on = Bật: ngoài "Nói dối" bạn có thể gọi "Spot On" cược rằng cược chính xác. Đúng — người khác mất một xúc xắc mỗi người. Sai — bạn mất hai. Rủi ro cao, phần thưởng cao.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Vòng { $round } bắt đầu. Tổng xúc xắc trên bàn: { $total }. Tất cả đổ.
ld-your-roll = Xúc xắc của bạn vòng này: { $dice }.
ld-your-counts = Số đếm của bạn: { $counts }.
ld-turn-start = Lượt của { $player }. { $bid_state }
ld-no-bid-yet = Chưa có cược — mở vòng.
ld-current-bid = Cược hiện tại: { $quantity } { $face }.

ld-action-bid = Đặt cược
ld-action-call-liar = Gọi Nói dối
ld-action-call-spot-on = Gọi Spot On
ld-bid-prompt = Chọn cược của bạn.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Bạn cược { $quantity } { $face }.
    *[player] { $player } cược { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Bạn gọi Nói dối cược của { $target } { $quantity } { $face }.
    *[player] { $player } gọi Nói dối cược của { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Bạn gọi Spot On cược của { $target } { $quantity } { $face }.
    *[player] { $player } gọi Spot On cược của { $target } { $quantity } { $face }.
}
ld-reveal-header = Lật cốc! Đếm { $face } trên bàn.
ld-reveal-line = { $player } đổ: { $dice }.
ld-actual-count = Số { $face } thực tế (có chủ 1): { $count }. Cược là { $quantity }.
ld-actual-count-no-wild = Số { $face } thực tế (không chủ): { $count }. Cược là { $quantity }.

ld-liar-bidder-loses = { $bidder } cược quá cao — mất một xúc xắc.
ld-liar-caller-loses = Cược trung thực — { $caller } mất một xúc xắc.
ld-spot-on-correct = Spot on! { $caller } đoán chính xác — người khác mất một xúc xắc mỗi người.
ld-spot-on-wrong = Không phải spot on. { $caller } mất hai xúc xắc.

ld-lost-die = { $who ->
    [you] Bạn mất một xúc xắc. Hiện có { $remaining } { $remaining ->
        [one] xúc xắc
        *[other] xúc xắc
    }.
    *[player] { $player } mất một xúc xắc. Hiện có { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Bạn mất { $count } xúc xắc. Hiện có { $remaining } { $remaining ->
        [one] xúc xắc
        *[other] xúc xắc
    }.
    *[player] { $player } mất { $count } xúc xắc. Hiện có { $remaining }.
}
ld-eliminated = { $player } hết xúc xắc và bị loại! Còn lại { $remaining } { $remaining ->
    [one] người chơi
    *[other] người chơi
}.
ld-winner = { $player } là người cuối còn xúc xắc — thắng!

ld-status-round = Vòng { $round }.
ld-status-your-dice = Xúc xắc của bạn: { $dice }.
ld-status-your-counts = Số đếm của bạn: { $counts }.
ld-status-no-dice = Bạn không còn xúc xắc — bị loại.
ld-status-current-bid = Cược hiện tại: { $quantity } { $face }.
ld-status-no-bid = Chưa có cược vòng này.
ld-status-table-total = Tổng xúc xắc trên bàn: { $total }.
ld-status-detailed-header = Trạng thái chi tiết — còn { $count } người chơi.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] xúc xắc
    *[other] xúc xắc
}.
ld-status-detailed-out = { $player }: bị loại.
ld-status-detailed-self-suffix = {" "}(bạn)

ld-face-1 = 1
ld-face-2 = 2
ld-face-3 = 3
ld-face-4 = 4
ld-face-5 = 5
ld-face-6 = 6

ld-action-not-your-turn = Chưa đến lượt bạn.
ld-action-not-playing = Trò chơi không diễn ra.
ld-action-no-bid-to-call = Chưa có cược để thách thức.
ld-action-eliminated = Bạn đã bị loại.
