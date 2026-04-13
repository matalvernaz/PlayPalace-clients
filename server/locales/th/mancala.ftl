# Mancala game messages — th
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = มังคาลา

# Actions
mancala-pit-label = หลุม { $pit }: { $stones } เม็ด

# Game events
mancala-sow = { $player } หว่าน { $stones } เม็ดจากหลุม { $pit }
mancala-capture = { $player } จับ { $captured } เม็ด!
mancala-extra-turn = เม็ดสุดท้ายลงคลัง! { $player } ได้เล่นอีกครั้ง
mancala-winner = { $player } ชนะด้วย { $score } เม็ด!
mancala-draw = เสมอ! ผู้เล่นทั้งสองมี { $score } เม็ด

# Board status
mancala-board-status =
    หลุมของคุณ: { $own_pits } คลังของคุณ: { $own_store } หลุมฝ่ายตรงข้าม: { $opp_pits } คลังฝ่ายตรงข้าม: { $opp_store }

# Options
mancala-set-stones = เม็ดต่อหลุม: { $stones }
mancala-desc-stones = จำนวนเม็ดในแต่ละหลุมตอนเริ่ม
mancala-enter-stones = ใส่จำนวนเม็ดเริ่มต้นต่อหลุม:
mancala-option-changed-stones = เม็ดเริ่มต้นเปลี่ยนเป็น { $stones }

# Disabled reasons
mancala-pit-empty = หลุมนั้นว่างเปล่า

# Rules
mancala-rules =
    มังคาลาเป็นเกมหลุมและเม็ดสำหรับผู้เล่นสองคน
    ผู้เล่นแต่ละคนมี 6 หลุมและ 1 คลัง
    ในตาของคุณ เลือกหลุมหนึ่งเพื่อหว่าน
    เม็ดจะถูกวางทีละเม็ดในแต่ละหลุมรอบกระดาน รวมคลังของคุณแต่ข้ามคลังฝ่ายตรงข้าม
    ถ้าเม็ดสุดท้ายตกในคลังของคุณ คุณได้เล่นอีกครั้ง
    ถ้าเม็ดสุดท้ายตกในหลุมว่างฝั่งคุณ คุณจับเม็ดนั้นและเม็ดทั้งหมดในหลุมตรงข้าม
    เกมจบเมื่อฝั่งหนึ่งว่างหมด
    ผู้เล่นที่มีเม็ดมากที่สุดชนะ
    ใช้ปุ่ม 1-6 เลือกหลุม กด E ตรวจสอบกระดาน

# End screen
mancala-final-score = { $player }: { $score } เม็ด
mancala-check-board = Check board
