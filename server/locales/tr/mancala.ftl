# Mancala game messages — tr
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mangala

# Actions
mancala-pit-label = Çukur { $pit }: { $stones } taş

# Game events
mancala-sow = { $player } çukur { $pit }'den { $stones } taş eker
mancala-capture = { $player } { $captured } taş yakalar!
mancala-extra-turn = Son taş hazinede! { $player } tekrar oynuyor.
mancala-winner = { $player } { $score } taşla kazandı!
mancala-draw = Berabere! İki oyuncunun da { $score } taşı var.

# Board status
mancala-board-status =
    Çukurlarınız: { $own_pits }. Hazineniz: { $own_store }. Rakibin çukurları: { $opp_pits }. Rakibin hazinesi: { $opp_store }.

# Options
mancala-set-stones = Çukur başına taş: { $stones }
mancala-desc-stones = Başlangıçta her çukurdaki taş sayısı
mancala-enter-stones = Çukur başına başlangıç taş sayısını girin:
mancala-option-changed-stones = Başlangıç taşları { $stones } olarak değiştirildi

# Disabled reasons
mancala-pit-empty = O çukur boş.

# Rules
mancala-rules =
    Mangala iki kişilik bir çukur ve taş oyunudur.
    Her oyuncunun 6 çukuru ve bir hazinesi vardır.
    Sıranızda ekmek için çukurlarınızdan birini seçin.
    Taşlar tahtanın etrafında her çukura birer birer konulur, hazineniz dahil ama rakibin hazinesi atlanır.
    Son taşınız hazinenize düşerse tekrar oynarsınız.
    Son taşınız kendi tarafınızdaki boş bir çukura düşerse, o taşı ve karşı çukurdaki tüm taşları yakalarsınız.
    Bir taraf tamamen boşaldığında oyun biter.
    En çok taşı olan oyuncu kazanır.
    Çukur seçmek için 1-6 tuşlarını kullanın. Tahtayı kontrol etmek için E'ye basın.

# End screen
mancala-final-score = { $player }: { $score } taş
