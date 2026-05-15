# Liar's Dice — th
# AI-translated with limited fluency, native review strongly recommended.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = ผู้เล่นแต่ละคนทอยลูกเต๋าใต้ถ้วยอย่างลับ ๆ สลับกันเสนอเดิมพันสูงขึ้นเรื่อย ๆ บนจำนวนรวมของหน้าหนึ่งทั่วโต๊ะ หรือร้อง "โกหก!" ถ้าไม่เชื่อเดิมพันล่าสุด ผิดจะเสียลูกเต๋า ผู้เหลือลูกเต๋าคนสุดท้ายชนะ

liarsdice-rules =
    Liar's Dice เป็นเกมลูกเต๋าบลัฟสำหรับ 2 ถึง 6 ผู้เล่น
    ผู้เล่นแต่ละคนเริ่มด้วยลูกเต๋า 5 ลูกในถ้วย ต้นรอบทุกคนทอยอย่างลับ ๆ
    สลับกันเดิมพันบนจำนวนรวมของหน้าหนึ่งบนลูกเต๋าทุกลูก เช่น "สาม 4" คือเมื่อเปิดถ้วยทั้งหมดมีอย่างน้อยสาม 4
    เดิมพันใหม่ต้องสูงกว่าเดิม: หน้าเดียวกันจำนวนมากกว่า หรือหน้าสูงกว่าจำนวนเท่ากันหรือมากกว่า
    1 เป็นไวลด์ นับในทุกเดิมพันยกเว้นเดิมพันที่ 1
    เปลี่ยนเป็นเดิมพันที่ 1 จะลดจำนวนเป็นครึ่ง (ปัดขึ้น) กลับจาก 1 ไปหน้าปกติต้องใช้มากกว่าสองเท่าของจำนวนก่อนหน้า
    แทนที่จะเดิมพันคุณสามารถร้อง "โกหก!" เพื่อท้าทายเดิมพันล่าสุด เปิดถ้วยทั้งหมด: ถ้าเดิมพันถูก ผู้ท้าทายเสียลูกเต๋า; ถ้าไม่ ผู้เดิมพันเสียลูกเต๋า
    เมื่อ Spot On เปิดอยู่ คุณสามารถร้อง "Spot On" เดิมพันว่าจำนวนตรงเป๊ะ ถูก คนอื่นทุกคนเสียลูกเต๋าหนึ่งลูก; ผิด คุณเสียสองลูก
    ตกรอบเมื่อลูกเต๋าเหลือศูนย์ ผู้เหลือลูกเต๋าคนสุดท้ายชนะ
    กด S เพื่อตรวจสอบโต๊ะ

ld-set-starting-dice = ลูกเต๋าเริ่มต้นต่อผู้เล่น: { $dice }
ld-desc-starting-dice = ผู้เล่นแต่ละคนเริ่มด้วยลูกเต๋าเท่าไหร่ ค่าเริ่มต้น 5 ลูกเต๋ามากขึ้น = เกมยาวขึ้น พื้นที่บลัฟมากขึ้น
ld-prompt-starting-dice = ป้อนลูกเต๋าเริ่มต้น (3 ถึง 8)
ld-option-changed-starting-dice = ตั้งลูกเต๋าเริ่มต้นเป็น { $dice }

ld-toggle-wild-ones = 1 เป็นไวลด์: { $enabled }
ld-desc-wild-ones = เปิด: 1 นับในเดิมพันทุกอย่างที่ไม่ใช่ที่ 1 เดิมพันที่ 1 ปิดไวลด์สำหรับเดิมพันนั้น ปิด เกมเป็นความน่าจะเป็นล้วน ไม่มีไวลด์
ld-option-changed-wild-ones = ไวลด์ 1 { $enabled }

ld-toggle-spot-on = การร้อง Spot On เปิด: { $enabled }
ld-desc-spot-on = เปิด: นอกจาก "โกหก" สามารถร้อง "Spot On" เดิมพันว่าจำนวนตรงเป๊ะ ถูก คนอื่นเสียลูกเต๋าหนึ่งคนละลูก ผิด คุณเสียสอง เสี่ยงสูง รางวัลสูง
ld-option-changed-spot-on = Spot On { $enabled }

ld-round-start = รอบ { $round } เริ่ม รวมลูกเต๋าบนโต๊ะ: { $total } ทุกคนทอย
ld-your-roll = ลูกเต๋าของคุณรอบนี้: { $dice }
ld-your-counts = การนับของคุณ: { $counts }
ld-turn-start = ตา { $player } { $bid_state }
ld-no-bid-yet = ยังไม่มีเดิมพัน เปิดรอบ
ld-current-bid = เดิมพันปัจจุบัน: { $quantity } { $face }

ld-action-bid = เดิมพัน
ld-action-call-liar = ร้องโกหก
ld-action-call-spot-on = ร้อง Spot On
ld-bid-prompt = เลือกเดิมพันของคุณ
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] คุณเดิมพัน { $quantity } { $face }
    *[player] { $player } เดิมพัน { $quantity } { $face }
}

ld-call-liar = { $who ->
    [you] คุณร้องโกหกต่อเดิมพันของ { $target } { $quantity } { $face }
    *[player] { $player } ร้องโกหกต่อเดิมพันของ { $target } { $quantity } { $face }
}
ld-call-spot-on = { $who ->
    [you] คุณร้อง Spot On ต่อเดิมพันของ { $target } { $quantity } { $face }
    *[player] { $player } ร้อง Spot On ต่อเดิมพันของ { $target } { $quantity } { $face }
}
ld-reveal-header = เปิดถ้วย! กำลังนับ { $face } บนโต๊ะ
ld-reveal-line = { $player } ทอย: { $dice }
ld-actual-count = จำนวนจริงของ { $face } (รวมไวลด์ 1): { $count } เดิมพันคือ { $quantity }
ld-actual-count-no-wild = จำนวนจริงของ { $face } (ไม่มีไวลด์): { $count } เดิมพันคือ { $quantity }

ld-liar-bidder-loses = { $bidder } เดิมพันสูงเกิน เสียลูกเต๋าหนึ่งลูก
ld-liar-caller-loses = เดิมพันซื่อสัตย์ { $caller } เสียลูกเต๋าหนึ่งลูก
ld-spot-on-correct = Spot on! { $caller } ทายตรงเป๊ะ คนอื่นเสียลูกเต๋าหนึ่งคนละลูก
ld-spot-on-wrong = ไม่ใช่ spot on { $caller } เสียลูกเต๋าสองลูก

ld-lost-die = { $who ->
    [you] คุณเสียลูกเต๋าหนึ่งลูก ตอนนี้มี { $remaining } { $remaining ->
        [one] ลูก
        *[other] ลูก
    }
    *[player] { $player } เสียลูกเต๋าหนึ่งลูก ตอนนี้มี { $remaining }
}
ld-lost-dice-multi = { $who ->
    [you] คุณเสียลูกเต๋า { $count } ลูก ตอนนี้มี { $remaining } { $remaining ->
        [one] ลูก
        *[other] ลูก
    }
    *[player] { $player } เสียลูกเต๋า { $count } ลูก ตอนนี้มี { $remaining }
}
ld-eliminated = { $player } ลูกเต๋าหมดและตกรอบ! เหลือ { $remaining } { $remaining ->
    [one] คน
    *[other] คน
}
ld-winner = { $player } เป็นคนสุดท้ายที่มีลูกเต๋า ชนะ!

ld-status-round = รอบ { $round }
ld-status-your-dice = ลูกเต๋าของคุณ: { $dice }
ld-status-your-counts = การนับของคุณ: { $counts }
ld-status-no-dice = ไม่มีลูกเต๋า ตกรอบแล้ว
ld-status-current-bid = เดิมพันปัจจุบัน: { $quantity } { $face }
ld-status-no-bid = ไม่มีเดิมพันในรอบนี้
ld-status-table-total = รวมลูกเต๋าบนโต๊ะ: { $total }
ld-status-detailed-header = สถานะละเอียด เหลือ { $count } คน
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] ลูก
    *[other] ลูก
}
ld-status-detailed-out = { $player }: ตกรอบ
ld-status-detailed-self-suffix = {" "}(คุณ)

ld-face-1 = หนึ่ง
ld-face-2 = สอง
ld-face-3 = สาม
ld-face-4 = สี่
ld-face-5 = ห้า
ld-face-6 = หก

ld-action-not-your-turn = ยังไม่ใช่ตาคุณ
ld-action-not-playing = เกมไม่ได้ดำเนินอยู่
ld-action-no-bid-to-call = ยังไม่มีเดิมพันให้ท้าทาย
ld-action-eliminated = คุณตกรอบแล้ว
