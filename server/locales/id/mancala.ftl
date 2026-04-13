# Mancala game messages — id
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Congklak

# Actions
mancala-pit-label = Lubang { $pit }: { $stones } biji

# Game events
mancala-sow = { $player } menabur { $stones } biji dari lubang { $pit }
mancala-capture = { $player } menangkap { $captured } biji!
mancala-extra-turn = Biji terakhir di lumbung! { $player } mendapat giliran tambahan.
mancala-winner = { $player } menang dengan { $score } biji!
mancala-draw = Seri! Kedua pemain memiliki { $score } biji.

# Board status
mancala-board-status =
    Lubang Anda: { $own_pits }. Lumbung Anda: { $own_store }. Lubang lawan: { $opp_pits }. Lumbung lawan: { $opp_store }.

# Options
mancala-set-stones = Biji per lubang: { $stones }
mancala-desc-stones = Jumlah biji di setiap lubang saat mulai
mancala-enter-stones = Masukkan jumlah biji awal per lubang:
mancala-option-changed-stones = Biji awal diubah menjadi { $stones }

# Disabled reasons
mancala-pit-empty = Lubang itu kosong.

# Rules
mancala-rules =
    Congklak adalah permainan lubang dan biji untuk dua pemain.
    Setiap pemain memiliki 6 lubang dan satu lumbung.
    Pada giliran Anda, pilih salah satu lubang untuk menabur.
    Biji dijatuhkan satu per satu ke setiap lubang di sekeliling papan, termasuk lumbung Anda tapi melewati lumbung lawan.
    Jika biji terakhir jatuh di lumbung Anda, Anda mendapat giliran tambahan.
    Jika biji terakhir jatuh di lubang kosong di sisi Anda, Anda menangkap biji itu dan semua biji di lubang seberang.
    Permainan berakhir ketika satu sisi benar-benar kosong.
    Pemain dengan biji terbanyak menang.
    Gunakan tombol 1 sampai 6 untuk memilih lubang. Tekan E untuk memeriksa papan.

# End screen
mancala-final-score = { $player }: { $score } biji
