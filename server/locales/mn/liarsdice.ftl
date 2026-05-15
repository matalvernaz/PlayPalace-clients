# Liar's Dice — mn
# AI-translated with limited fluency, native review strongly recommended.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Тоглогч бүр аяганы доор шооноо нууцаар хаяна. Ээлжээр ширээний нийт нэг талын тоонд илүү өндөр санал тавьдаг, эсвэл сүүлчийн саналд итгэхгүй бол "Худалч!" гэж хашгирдаг. Алдах нь нэг шоо алддаг. Шоотой сүүлчийн хүн ялна.

liarsdice-rules =
    Liar's Dice бол 2-6 тоглогчтой шоо бамбайн тоглоом.
    Тоглогч бүр аяганы дотор 5 шоотой эхэлнэ. Туршилт бүрийн эхэнд бүгд нууцаар хаяна.
    Ээлжээр бүх шоо дээрх нэг талын нийт тоонд санал тавьдаг — жишээ нь "гурван 4" гэдэг нь бүх аяга нээгдсэн үед дор хаяж гурван 4 байна гэсэн үг.
    Шинэ санал өмнөхөөс өндөр байх ёстой: ижил тал илүү тоотой, эсвэл өндөр тал ижил эсвэл илүү тоотой.
    1-үүд жокер — 1 өөрөө биш бүх санал руу тоологдоно.
    1 рүү шилжихэд тоо тал хувь хуваагдана (дээш бөөрөнхийлсөн). 1-ээс ердийн тал руу буцахад өмнөх тооноос хоёр дахин их тоо хэрэгтэй.
    Санал тавихын оронд та "Худалч!" гэж хашгирч сүүлчийн саналыг эсэргүүцэж болно. Бүх аяганууд дээш: санал зөв байсан бол эсэргүүцэгч нэг шоо алдана; үгүй бол санал тавигч нэг шоо алдана.
    Spot On идэвхтэй үед та "Spot On" гэж хашгирч санал яг зөв гэдэгт мөрийцөж болно. Зөв — бусад бүгд нэг шоо алдана; буруу — та хоёр шоо алдана.
    Шоо тэг болсон үед таныг хасна. Шоотой сүүлчийн хүн ялна.
    Ширээг шалгахын тулд S дар.

ld-set-starting-dice = Тоглогч тус бүрийн эхлэлийн шоо: { $dice }
ld-desc-starting-dice = Тоглогч бүр хэдэн шоотой эхлэх. Анхдагч 5. Илүү олон шоо = илүү урт тоглоомууд, илүү бамбайн зай.
ld-prompt-starting-dice = Эхлэлийн шоог оруул (3-аас 8)
ld-option-changed-starting-dice = Эхлэлийн шоог { $dice } болгов.

ld-toggle-wild-ones = 1-үүд жокер: { $enabled }
ld-desc-wild-ones = Идэвхтэй: 1-үүд 1 биш бүх санал руу тоологдоно. 1 дээрх санал тэр санлын хувьд жокерийг идэвхгүй болгоно. Идэвхгүй — тоглоом жокергүй цэвэр магадлал болно.
ld-option-changed-wild-ones = Жокер 1-үүд { $enabled }.

ld-toggle-spot-on = Spot On дуудлага идэвхтэй: { $enabled }
ld-desc-spot-on = Идэвхтэй: "Худалч"-аас гадна "Spot On" гэж хашгирч санал яг зөв гэдэгт мөрийцөж болно. Зөв — бусад тус бүр нэг шоо алдана. Буруу — та хоёр алдана. Өндөр эрсдэл, өндөр шагнал.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = { $round } дугаар тойрог эхлэв. Ширээ дээрх нийт шоо: { $total }. Бүгд хаяна.
ld-your-roll = Энэ тойрог дэх таны шоо: { $dice }.
ld-your-counts = Таны тоо: { $counts }.
ld-turn-start = { $player }-н ээлж. { $bid_state }
ld-no-bid-yet = Одоо хэр санал байхгүй — тойргийг нээ.
ld-current-bid = Одоогийн санал: { $quantity } { $face }.

ld-action-bid = Санал тавь
ld-action-call-liar = Худалч хашгир
ld-action-call-spot-on = Spot On хашгир
ld-bid-prompt = Саналаа сонго.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Та { $quantity } { $face }-д санал тавьна.
    *[player] { $player } { $quantity } { $face }-д санал тавьна.
}

ld-call-liar = { $who ->
    [you] Та { $target }-н { $quantity } { $face } саналд Худалч гэж хашгирна.
    *[player] { $player } { $target }-н { $quantity } { $face } саналд Худалч гэж хашгирна.
}
ld-call-spot-on = { $who ->
    [you] Та { $target }-н { $quantity } { $face } саналд Spot On гэж хашгирна.
    *[player] { $player } { $target }-н { $quantity } { $face } саналд Spot On гэж хашгирна.
}
ld-reveal-header = Аяганууд дээш! Ширээ дээрх { $face }-г тоолно.
ld-reveal-line = { $player } хаяв: { $dice }.
ld-actual-count = { $face }-н бодит тоо (жокер 1-тэй): { $count }. Санал { $quantity } байсан.
ld-actual-count-no-wild = { $face }-н бодит тоо (жокергүй): { $count }. Санал { $quantity } байсан.

ld-liar-bidder-loses = { $bidder } хэт өндөр санал тавив — нэг шоо алдана.
ld-liar-caller-loses = Санал шударга байсан — { $caller } нэг шоо алдана.
ld-spot-on-correct = Spot on! { $caller } яг таамаглав — бусад тус бүр нэг шоо алдана.
ld-spot-on-wrong = Spot on биш. { $caller } хоёр шоо алдана.

ld-lost-die = { $who ->
    [you] Та нэг шоо алдлаа. Одоо { $remaining } { $remaining ->
        [one] шоо
        *[other] шоо
    } байна.
    *[player] { $player } нэг шоо алдав. Одоо { $remaining } байна.
}
ld-lost-dice-multi = { $who ->
    [you] Та { $count } шоо алдлаа. Одоо { $remaining } { $remaining ->
        [one] шоо
        *[other] шоо
    } байна.
    *[player] { $player } { $count } шоо алдав. Одоо { $remaining } байна.
}
ld-eliminated = { $player } шоо дуусаж хасагдав! { $remaining } { $remaining ->
    [one] тоглогч
    *[other] тоглогч
} үлдэв.
ld-winner = { $player } шоотой сүүлчийн хүн — ялав!

ld-status-round = Тойрог { $round }.
ld-status-your-dice = Таны шоо: { $dice }.
ld-status-your-counts = Таны тоо: { $counts }.
ld-status-no-dice = Танд шоо байхгүй — таныг хассан.
ld-status-current-bid = Одоогийн санал: { $quantity } { $face }.
ld-status-no-bid = Энэ тойрогт санал алга.
ld-status-table-total = Ширээ дээрх нийт шоо: { $total }.
ld-status-detailed-header = Дэлгэрэнгүй төлөв — { $count } тоглогч үлдэв.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] шоо
    *[other] шоо
}.
ld-status-detailed-out = { $player }: хасагдсан.
ld-status-detailed-self-suffix = {" "}(чи)

ld-face-1 = нэгүүд
ld-face-2 = хоёрууд
ld-face-3 = гуравууд
ld-face-4 = дөрөвүүд
ld-face-5 = тавууд
ld-face-6 = зургаауд

ld-action-not-your-turn = Таны ээлж биш.
ld-action-not-playing = Тоглоом явагдаагүй байна.
ld-action-no-bid-to-call = Эсэргүүцэх санал хараахан алга.
ld-action-eliminated = Таныг хассан.
