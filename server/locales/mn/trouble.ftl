# Trouble — mn
# AI-translated with limited fluency, native review strongly recommended.
game-name-trouble = Trouble

trouble-rules =
    Trouble нь Parcheesi гэр бүлийн уралдааны тоглоом.
    Тоглогч бүр өөрийн хүүхдүүдийг Гэр талбайд эхлүүлнэ.
    Ээлжид шооноо дарж, хүүхдүүдийн нэгийг хөдөлгөнө.
    Анхдагч байдлаар хүүхдийг Гэрээс зам руу гаргахын тулд 6 буулгах ёстой.
    Анхдагч байдлаар 6 буулгахад нэмэлт ээлж бас өгнө.
    Хүүхдүүд хуваалцсан зам дээр цагийн зүүний дагуу финиш руу хөдөлнө.
    Өрсөлдөгчийн хүүхдэн дээр буух нь түүнийг Гэрт нь буцаана, талбай хамгаалагдсан биш бол.
    Бүх хүүхдүүд чинь финишид хүрэхэд та ялна.
    Багийн горимд бүх багийн гишүүд дуусахад таны баг ялна.
    1-6 товчоор хүүхэд сонгож, R-р шоо буулгана.
    Хэдийд ч E дарж самбарын бүрэн төлөвийг сонсож болно.

trouble-action-roll = Шоо дарах
trouble-action-move-token = Хүүхэд { $token } хөдөлгөх
trouble-action-check-board = Самбар шалгах

trouble-token-label-home = Хүүхэд { $token }: Гэрт
trouble-token-label-track = Хүүхэд { $token }: замын { $position } байр
trouble-token-label-finish-lane = Хүүхэд { $token }: финиш зурвас { $position } / { $total }
trouble-token-label-finished = Хүүхэд { $token }: дуусчихсан

trouble-rolled = { $player } { $roll } буулгав.
trouble-leave-home = { $player } хүүхэд { $token } -г зам руу гаргалаа.
trouble-advance-track = { $player } хүүхэд { $token } -г { $position } байрт зөөв.
trouble-enter-finish-lane = { $player } хүүхэд { $token } -г финиш зурваст оруулав.
trouble-advance-finish-lane =
    { $player } хүүхэд { $token } -г финиш зурвасны { $position } / { $total } байрт ахиулав.
trouble-token-finished = { $player } -н хүүхэд { $token } финишид хүрэв.
trouble-bump =
    { $player } -н хүүхэд { $token } { $opponent } -н хүүхэд { $opp_token } -г Гэрт буцаалаа.
trouble-no-legal-move = { $player } -д хүчинтэй хөдөлгөөн алга. Ээлж дамжина.
trouble-extra-turn = { $player } 6 буулгасны нэмэлт ээлж авав.

trouble-winner = { $player } ялав! Бүх хүүхдүүд финишид.
trouble-team-winner = { $team } баг ялав! Бүх багийн гишүүд дуусав.
trouble-final-standing = { $player }: { $total } -аас { $finished } хүүхэд дуусав.

trouble-turn-summary =
    Гэрт { $own_home }, замд { $own_track }, финишид { $own_finished } байна.
    Өрсөлдөгчид: { $opponents }.
trouble-opponent-summary = { $name }: { $home } гэр, { $track } зам, { $finished } финиш

trouble-board-status =
    Таны хүүхдүүд: { $own_tokens }.
    Өрсөлдөгчийн хүүхдүүд: { $opp_tokens }.

trouble-reason-not-rolled = Эхлээд шоо дарах.
trouble-reason-already-rolled = Аль хэдийн дарсан. Хөдөлгөх хүүхэд сонго.
trouble-reason-no-legal-moves = Энэ буулгалтад хүчинтэй хөдөлгөөн алга.
trouble-reason-token-home-needs-six = Энэ хүүхэд Гэрт байна. Гаргахын тулд 6 хэрэгтэй.
trouble-reason-token-home-needs-any = Энэ хүүхэд Гэрт байна. Аливаа буулгалт гаргана.
trouble-reason-token-home-no-qualifying-roll =
    Энэ хүүхэд Гэрт байгаа бөгөөд таны буулгалт гаргах нөхцлийг хангаагүй.
trouble-reason-token-finished = Энэ хүүхэд аль хэдийн дууссан.
trouble-reason-overshoot-wastes = Энэ хүүхэд финишийг өнгөрөхгүйгээр { $roll } байр явж чадахгүй.
trouble-reason-blocked = Энэ хөдөлгөөн хаалттай.

trouble-option-track-size = Замын урт: { $track_size } байр
trouble-option-select-track-size = Замын байрны тоог сонгох.
trouble-option-changed-track-size = Зам { $track_size } байр болов.
trouble-option-desc-track-size = Хуваалцсан зам дээрх байрны тоо.

trouble-option-tokens-per-player = Тоглогч тутамд хүүхэд: { $tokens }
trouble-option-enter-tokens-per-player = Тоглогч тутамд хүүхэд оруулах (2-6):
trouble-option-changed-tokens-per-player = Тоглогч тутамд хүүхэд { $tokens } болов.
trouble-option-desc-tokens-per-player = Тоглогч бүр хичнээн хүүхдийг финишид аваачих.

trouble-option-extra-turn-on-six = 6-д нэмэлт ээлж: { $enabled }
trouble-option-changed-extra-turn-on-six = 6-д нэмэлт ээлжийг { $enabled ->
    [on] идэвхжүүлэв.
    [off] идэвхгүй болгов.
   *[other] шинэчлэв.
}
trouble-option-desc-extra-turn-on-six =
    Идэвхтэй: 6 нэмэлт ээлж өгнө (Hasbro сонгодог дүрэм).

trouble-option-six-to-leave-home = Гэрээс гарахад 6 шаардлагатай: { $enabled }
trouble-option-changed-six-to-leave-home = Гэрээс гарах зургааг { $enabled ->
    [on] идэвхжүүлэв.
    [off] идэвхгүй болгов.
   *[other] шинэчлэв.
}
trouble-option-desc-six-to-leave-home =
    Идэвхтэй: хүүхэд Гэрээс гаргахын тулд 6 хэрэгтэй. Идэвхгүй: аливаа буулгалт гаргана.

trouble-option-safe-spaces = Аюулгүй байрууд: { $mode }
trouble-option-select-safe-spaces = Аюулгүй байрны горимыг сонгох.
trouble-option-changed-safe-spaces = Аюулгүй байруудыг { $mode } болгов.
trouble-option-desc-safe-spaces = Хүүхдүүд мөргөлдөөнөөс хамгаалагдах эсэхийг сонгох.

trouble-safe-mode-none = Алга
trouble-safe-mode-home-stretch = Зөвхөн финиш шулуун
trouble-safe-mode-every-seventh = Тус бүр 7 байр

trouble-option-finish-behavior = Финиш: { $mode }
trouble-option-select-finish-behavior = Финишийн зан үйлийг сонгох.
trouble-option-changed-finish-behavior = Финишийн зан үйл { $mode } болов.
trouble-option-desc-finish-behavior = Финишийг хэтэрсэн буулгалтыг хэрхэн зохицуулах.

trouble-finish-mode-exact = Яг буулгалт хэрэгтэй
trouble-finish-mode-bounce = Хэтэрхийтэй буулгалт буцна
trouble-finish-mode-allow = Хэтэрхий зөвшөөрнө

trouble-option-bot-difficulty = Ботын түвшин: { $level }
trouble-option-select-bot-difficulty = Ботын түвшинг сонгох.
trouble-option-changed-bot-difficulty = Ботын түвшин { $level } болов.
trouble-option-desc-bot-difficulty = Дотоод ботын хүч.

trouble-bot-difficulty-naive = Энгийн
trouble-bot-difficulty-greedy = Шуналт

trouble-option-preset = Урьдчилан тохиргоо: { $preset }
trouble-option-select-preset = Хувилбар сонгох. Хост дараа нь дүрмийг тус бүрчлэн тохируулна.
trouble-option-changed-preset = Тохиргоо хэрэглэгдэв: { $preset }.
trouble-option-desc-preset = Түгээмэл хувилбаруудад зориулсан сонголтуудын багц.

trouble-preset-classic = Сонгодог Hasbro
trouble-preset-fast = Хурдан
trouble-preset-brutal = Хатуу
trouble-preset-custom = Захиалгат
