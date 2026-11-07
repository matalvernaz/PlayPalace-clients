# pirates.ftl for locale mn. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = Алдагдсан тэнгисийн далайн дээрэмчид
# Game start and setup
pirates-welcome = Алдагдсан тэнгисийн далайн дээрэмчид тоглоомд тавтай морил! Далайгаар аялж, эрдэнийн чулуу цуглуулж, бусад далайн дээрэмчидтэй тулал!
pirates-oceans = Таны аялал: { $oceans }
pirates-gems-placed = { $total } эрдэнийн чулуу тэнгист тархсан. Бүгдийг нь ол!
pirates-golden-moon = Алтан сар мандав! Бүх туршлага гурав дахин өсөх болно!
# Turn announcements
pirates-turn = { $player }-ийн ээлж. Байрлал { $position }
# Movement actions
pirates-move-left = Зүүн тийш дарвуулах
pirates-move-right = Баруун тийш дарвуулах
pirates-move-2-left = 2 нүд зүүн тийш дарвуулах
pirates-move-2-right = 2 нүд баруун тийш дарвуулах
pirates-move-3-left = 3 нүд зүүн тийш дарвуулах
pirates-move-3-right = 3 нүд баруун тийш дарвуулах
# Movement messages
pirates-move-you = Та { $direction } тийш { $position } байрлал руу дарвуулав.
pirates-move = { $player } { $direction } тийш { $position } байрлал руу дарвуулав.
pirates-map-edge = Цааш дарвуулж чадахгүй. Та { $position } байрлалд байна.
pirates-your-position = Таны байрлал: { $ocean }-д { $position }
pirates-check-position = Байрлал шалгах
pirates-check-moon = Сарны гэрэлтэлт шалгах
# Position and status
pirates-check-status = Төлөв шалгах
pirates-all-gems-collected = Бүх эрдэнийн чулуу цуглуулагдлаа!
# Winner
pirates-winner = { $player } { $score } оноогоор ялав!
# Gem collection
pirates-gem-found-you = Та { $gem } оллоо! { $value } оноо өгнө.
pirates-gem-found = { $player } { $gem } оллоо! { $value } оноо өгнө.
pirates-level-up-you = Та { $level } түвшинд хүрлээ!
pirates-level-up = { $player } { $level } түвшинд хүрлээ!
pirates-level-up-multiple-you = Та { $levels } түвшин ахив! Одоо { $level } түвшин!
pirates-level-up-multiple = { $player } { $levels } түвшин ахив! Одоо { $level } түвшин!
pirates-skills-unlocked-you = Та шинэ ур чадвар нээлээ: { $skills }.
pirates-skills-unlocked = { $player } шинэ ур чадвар нээлээ: { $skills }.
# Combat - Attack initiation
pirates-cannonball = Их буу харвах
pirates-no-targets = { $range } нүдийн зайд бай байхгүй.
pirates-attack-you-fire = Та { $target } руу их буу харвав!
pirates-attack-incoming = { $attacker } танд их буу харвалаа!
pirates-attack-fired = { $attacker } { $defender } руу их буу харвав!
# Combat - Hit results
pirates-attack-hit-you = Шууд тусав! Та { $target }-г онолоо!
pirates-attack-hit-them = { $attacker } танд тусав!
pirates-attack-hit = { $attacker } { $defender }-д тусав!
# Combat - Miss results
pirates-attack-miss-you = Таны их буу { $target }-г алдлаа.
pirates-attack-miss-them = Их буу танд тусаагүй!
pirates-attack-miss = { $attacker }-ийн их буу { $defender }-г алдав.
pirates-push = { $attacker } { $defender }-г { $old_pos }-с { $new_pos } руу { $direction } тийш түлхэв.
pirates-steal-success-you = Та { $target }-с { $gem } хулгайллаа!
pirates-steal-success-them = { $attacker } таны { $gem }-г хулгайллаа!
pirates-steal-success = { $attacker } { $defender }-с { $gem } хулгайллаа!
pirates-steal-failed = Хулгайлалт амжилтгүй боллоо!
# Skills menu
pirates-use-skill = Ур чадвар хэрэглэх
pirates-select-skill = Хэрэглэх ур чадвар сонгох
# Skill activation
pirates-skill-activated = { $player } { $skill } идэвхжүүллээ!
pirates-buff-expired = { $player }-ийн { $skill } нэмэлт дууслаа.
# Portal skill
pirates-portal-no-ships = Портал нээх хөлөг байхгүй байна.
pirates-portal-fizzle = { $player }-ийн портал очих газаргүйгээс аль хэдийн алга болов.
pirates-portal-success = { $player } { $ocean }-д { $position } байрлал руу портал нээв!
# Gem Seeker skill
pirates-gem-seeker-reveal = Тэнгис { $position } байрлалд { $gem } байгааг шивнэв. ({ $uses } ашиглалт үлдсэн)
# Sword Fighter skill
pirates-sword-fighter-activated = Сэлэмчин идэвхжлээ! { $turns } ээлжид +4 довтолгооны нэмэлт.
# Push skill (defense buff)
pirates-push-activated = Түлхэлт идэвхжлээ! { $turns } ээлжид +3 хамгаалалтын нэмэлт.
# Skilled Captain skill
pirates-skilled-captain-activated = Чадварлаг ахмад идэвхжлээ! { $turns } ээлжид +2 довтолгоо ба +2 хамгаалалт.
# Battleship skill
pirates-battleship-activated = Байлдааны хөлөг идэвхжлээ! Энэ ээлжид хоёр удаа харвах боломжтой!
pirates-battleship-shot = { $shot } дахь харвалт хийж байна...
pirates-battleship-no-targets = { $shot } дахь харвалтад бай байхгүй.
# Double Devastation skill
pirates-double-devastation-activated = Давхар сүйрэл идэвхжлээ! { $turns } ээлжид довтолгооны зай 10 нүд болсон.
# XP Multiplier options
pirates-set-combat-xp-multiplier = тулааны туршлага үржүүлэгч: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = тулааны туршлага
pirates-set-find-gem-xp-multiplier = эрдэнийн чулуу олсон туршлага үржүүлэгч: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = эрдэнийн чулуу олсон туршлага
# Gem stealing options
pirates-set-gem-stealing = Эрдэнийн чулуу хулгайлах: { $mode }
pirates-select-gem-stealing = Эрдэнийн чулуу хулгайлах горим сонгох
pirates-option-changed-stealing = Эрдэнийн чулуу хулгайлах { $mode }-д тохируулагдлаа.
# Gem stealing mode choices
pirates-stealing-with-bonus = Шооны нэмэлттэй
pirates-stealing-no-bonus = Шооны нэмэлтгүй
pirates-stealing-disabled = Идэвхгүй
