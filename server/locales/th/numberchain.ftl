# Number Chain — th
# AI-translated with limited fluency, native review strongly recommended.

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } เป็นผู้เล่น 1, { $p2 } เป็นผู้เล่น 2 { $first } เริ่มก่อน วาง 1 ที่ใดก็ได้เพื่อเริ่มห่วงโซ่

# Placement
numberchain-place-you = คุณวาง { $number } ที่แถว { $row } คอลัมน์ { $col }
numberchain-place-other = { $player } วาง { $number } ที่แถว { $row } คอลัมน์ { $col }

# Errors
numberchain-illegal-move = การเดินนี้ไม่ถูกต้อง

# Status / info
numberchain-status = ตา { $current } เลขถัดไป: { $required }
numberchain-inventory = ตัวเลขที่เหลือของคุณ: { $inventory }
numberchain-required = เลขที่จะวางต่อไป: { $required }

# Square labels
numberchain-sq-empty = แถว { $row } คอลัมน์ { $col } ว่าง
numberchain-sq-own = แถว { $row } คอลัมน์ { $col } { $number } ของคุณ
numberchain-sq-opponent = แถว { $row } คอลัมน์ { $col } { $number } { $owner }

# Action labels
numberchain-check-status = สถานะ
numberchain-check-inventory = คลัง
numberchain-check-required = เลขถัดไป

# Win
numberchain-wins = { $player } ชนะ! ฝ่ายตรงข้ามไม่มีการเดินที่ถูกต้องเหลืออยู่
numberchain-final = { $winner } ชนะ

# Options
numberchain-option-bot-difficulty = ระดับบอท: { $bot_difficulty }
numberchain-option-select-bot-difficulty = เลือกระดับบอท
numberchain-option-changed-bot-difficulty = ตั้งระดับบอทเป็น { $bot_difficulty }
numberchain-difficulty-random = สุ่ม
numberchain-difficulty-simple = ง่าย
