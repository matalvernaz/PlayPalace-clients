# Trouble — th
# AI-translated with limited fluency, native review strongly recommended.
game-name-trouble = Trouble

trouble-rules =
    Trouble เป็นเกมแข่งจากตระกูล Parcheesi
    ผู้เล่นแต่ละคนเริ่มด้วยหมากของตนในพื้นที่บ้าน
    ในตาของคุณ กดลูกเต๋าและขยับหมากของคุณหนึ่งตัว
    โดยปกติคุณต้องทอยได้ 6 เพื่อปล่อยหมากจากบ้านไปยังทางเดิน
    โดยปกติทอยได้ 6 ยังให้ตาเพิ่ม
    หมากเคลื่อนตามเข็มนาฬิกาบนทางเดินร่วมไปยังพื้นที่เส้นชัย
    ลงบนหมากของฝ่ายตรงข้ามจะส่งกลับบ้านของฝ่ายนั้น เว้นแต่ช่องจะได้รับการป้องกัน
    เมื่อหมากทั้งหมดถึงเส้นชัย คุณชนะ
    ในโหมดทีม ทีมของคุณชนะเมื่อเพื่อนร่วมทีมทั้งหมดเสร็จ
    ปุ่ม 1-6 เลือกหมาก, R ทอย
    กด E ตลอดเวลาเพื่อฟังสถานะกระดานทั้งหมด

trouble-action-roll = กดลูกเต๋า
trouble-action-move-token = ขยับหมาก { $token }
trouble-action-check-board = ดูกระดาน

trouble-token-label-home = หมาก { $token }: ที่บ้าน
trouble-token-label-track = หมาก { $token }: ช่อง { $position } ของทางเดิน
trouble-token-label-finish-lane = หมาก { $token }: เลนเข้าเส้น { $position } จาก { $total }
trouble-token-label-finished = หมาก { $token }: เสร็จแล้ว

trouble-rolled = { $player } ทอยได้ { $roll }
trouble-leave-home = { $player } ปล่อยหมาก { $token } ลงทางเดิน
trouble-advance-track = { $player } ขยับหมาก { $token } ไปยังช่อง { $position }
trouble-enter-finish-lane = { $player } นำหมาก { $token } เข้าเลนเข้าเส้น
trouble-advance-finish-lane =
    { $player } ขยับหมาก { $token } ไปยังช่อง { $position } จาก { $total } ของเลนเข้าเส้น
trouble-token-finished = หมาก { $token } ของ { $player } ถึงเส้นชัย
trouble-bump =
    หมาก { $token } ของ { $player } ส่งหมาก { $opp_token } ของ { $opponent } กลับบ้าน
trouble-no-legal-move = { $player } ไม่มีการเดินที่ถูกต้อง ตาเปลี่ยน
trouble-extra-turn = { $player } ได้ตาเพิ่มจากการทอย 6

trouble-winner = { $player } ชนะ! หมากทั้งหมดถึงเส้นชัย
trouble-team-winner = ทีม { $team } ชนะ! เพื่อนร่วมทีมทั้งหมดเสร็จ
trouble-final-standing = { $player }: { $finished } จาก { $total } หมากเสร็จ

trouble-turn-summary =
    คุณมี { $own_home } ที่บ้าน, { $own_track } บนทางเดิน, { $own_finished } ที่เส้นชัย
    ฝ่ายตรงข้าม: { $opponents }
trouble-opponent-summary = { $name }: { $home } บ้าน, { $track } ทาง, { $finished } เส้นชัย

trouble-board-status =
    หมากของคุณ: { $own_tokens }
    หมากฝ่ายตรงข้าม: { $opp_tokens }

trouble-reason-not-rolled = กดลูกเต๋าก่อน
trouble-reason-already-rolled = กดแล้ว เลือกหมากที่จะขยับ
trouble-reason-no-legal-moves = ไม่มีการเดินที่ถูกต้องสำหรับการทอยนี้
trouble-reason-token-home-needs-six = หมากนี้ที่บ้าน ต้องการ 6 เพื่อปล่อย
trouble-reason-token-home-needs-any = หมากนี้ที่บ้าน การทอยใดๆ ก็ปล่อยได้
trouble-reason-token-home-no-qualifying-roll =
    หมากนี้ที่บ้านและการทอยของคุณไม่ผ่านเงื่อนไขปล่อย
trouble-reason-token-finished = หมากนี้เสร็จแล้ว
trouble-reason-overshoot-wastes = หมากนี้ไม่สามารถเดิน { $roll } ช่องโดยไม่เกินเส้นชัย
trouble-reason-blocked = การเดินนี้ถูกบล็อก

trouble-option-track-size = ขนาดทางเดิน: { $track_size } ช่อง
trouble-option-select-track-size = เลือกจำนวนช่องของทางเดิน
trouble-option-changed-track-size = ทางเดินตั้งเป็น { $track_size } ช่อง
trouble-option-desc-track-size = จำนวนช่องบนทางเดินร่วม

trouble-option-tokens-per-player = หมากต่อผู้เล่น: { $tokens }
trouble-option-enter-tokens-per-player = ป้อนหมากต่อผู้เล่น (2-6):
trouble-option-changed-tokens-per-player = หมากต่อผู้เล่นตั้งเป็น { $tokens }
trouble-option-desc-tokens-per-player = ผู้เล่นแต่ละคนนำหมากกี่ตัวไปเส้นชัย

trouble-option-extra-turn-on-six = ตาเพิ่มเมื่อทอย 6: { $enabled }
trouble-option-changed-extra-turn-on-six = ตาเพิ่มเมื่อทอย 6 { $enabled ->
    [on] เปิด
    [off] ปิด
   *[other] อัปเดต
}
trouble-option-desc-extra-turn-on-six =
    เปิด: 6 ให้ตาเพิ่ม (กฎคลาสสิก Hasbro)

trouble-option-six-to-leave-home = ต้องทอย 6 เพื่อออกจากบ้าน: { $enabled }
trouble-option-changed-six-to-leave-home = หกเพื่อออกจากบ้าน { $enabled ->
    [on] เปิด
    [off] ปิด
   *[other] อัปเดต
}
trouble-option-desc-six-to-leave-home =
    เปิด: ผู้เล่นต้องทอย 6 เพื่อปล่อยหมากจากบ้าน ปิด: การทอยใดๆ ก็ปล่อยได้

trouble-option-safe-spaces = ช่องปลอดภัย: { $mode }
trouble-option-select-safe-spaces = เลือกโหมดช่องปลอดภัย
trouble-option-changed-safe-spaces = ช่องปลอดภัยตั้งเป็น { $mode }
trouble-option-desc-safe-spaces = ตัดสินใจว่าหมากปลอดภัยจากการชนหรือไม่

trouble-safe-mode-none = ไม่มี
trouble-safe-mode-home-stretch = เฉพาะทางตรงเข้าเส้น
trouble-safe-mode-every-seventh = ทุก 7 ช่อง

trouble-option-finish-behavior = เส้นชัย: { $mode }
trouble-option-select-finish-behavior = เลือกพฤติกรรมเส้นชัย
trouble-option-changed-finish-behavior = พฤติกรรมเส้นชัยตั้งเป็น { $mode }
trouble-option-desc-finish-behavior = วิธีจัดการการทอยที่เกินเส้นชัย

trouble-finish-mode-exact = ต้องการการทอยที่แน่นอน
trouble-finish-mode-bounce = ส่วนเกินกระดอนกลับ
trouble-finish-mode-allow = อนุญาตส่วนเกิน

trouble-option-bot-difficulty = ระดับบอท: { $level }
trouble-option-select-bot-difficulty = เลือกระดับบอท
trouble-option-changed-bot-difficulty = ระดับบอทตั้งเป็น { $level }
trouble-option-desc-bot-difficulty = ความแข็งแกร่งของบอทในตัว

trouble-bot-difficulty-naive = ไร้เดียงสา
trouble-bot-difficulty-greedy = โลภ

trouble-option-preset = พรีเซ็ต: { $preset }
trouble-option-select-preset = เลือกตัวแปร เจ้าของห้องสามารถปรับกฎเดี่ยวภายหลัง
trouble-option-changed-preset = ใช้พรีเซ็ต: { $preset }
trouble-option-desc-preset = ชุดตัวเลือกบรรจุไว้ล่วงหน้าสำหรับตัวแปรทั่วไป

trouble-preset-classic = คลาสสิก Hasbro
trouble-preset-fast = เร็ว
trouble-preset-brutal = โหดร้าย
trouble-preset-custom = กำหนดเอง
