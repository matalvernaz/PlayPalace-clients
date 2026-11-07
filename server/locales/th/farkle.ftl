# farkle.ftl for locale th. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-farkle = ฟาร์เคิล
# Actions - Roll and Bank
farkle-roll = ทอยลูกเต้า { $count } ลูก
farkle-bank = เก็บ { $points } คะแนน
# Scoring combination actions (matching v10 exactly)
farkle-take-single-one = เลข 1 หนึ่งลูกได้ { $points } คะแนน
farkle-take-single-five = เลข 5 หนึ่งลูกได้ { $points } คะแนน
farkle-take-three-kind = เลข { $number } สามลูกได้ { $points } คะแนน
farkle-take-four-kind = เลข { $number } สี่ลูกได้ { $points } คะแนน
farkle-take-five-kind = เลข { $number } ห้าลูกได้ { $points } คะแนน
farkle-take-six-kind = เลข { $number } หกลูกได้ { $points } คะแนน
farkle-take-small-straight = สเตรทเล็กได้ { $points } คะแนน
farkle-take-large-straight = สเตรทใหญ่ได้ { $points } คะแนน
farkle-take-three-pairs = สามคู่ได้ { $points } คะแนน
farkle-take-double-triplets = สองชุดสามเหมือนได้ { $points } คะแนน
farkle-take-full-house = ฟูลเฮาส์ได้ { $points } คะแนน
farkle-you-roll = คุณทอยลูกเต้า { $count } ลูก...
farkle-roll-result = { $dice }
farkle-you-farkle = ฟาร์เคิล! คุณเสีย { $points } คะแนน
farkle-you-take-combo = คุณเลือก { $combo } ได้ { $points } คะแนน
farkle-you-bank = คุณเก็บ { $points } คะแนน รวมเป็น { $total }
farkle-you-win = คุณชนะด้วย { $score } คะแนน!
farkle-winner = { $player } ชนะด้วย { $score } คะแนน!
farkle-winners-tie = เสมอกัน! ผู้ชนะ: { $players }
# Check turn score action
farkle-turn-score = { $player } มี { $points } คะแนนในรอบนี้
farkle-no-turn = ไม่มีใครกำลังเล่นอยู่
# Farkle-specific options
farkle-set-target-score = คะแนนเป้าหมาย: { $score }
farkle-enter-target-score = ป้อนคะแนนเป้าหมาย (500-5000):
farkle-option-changed-target = ตั้งคะแนนเป้าหมายเป็น { $score }
# Disabled action reasons
farkle-must-take-combo = คุณต้องเลือกคอมโบคะแนนก่อน
farkle-cannot-bank = คุณไม่สามารถเก็บคะแนนได้ตอนนี้
