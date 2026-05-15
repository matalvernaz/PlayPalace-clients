# Liar's Dice — id
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Setiap pemain melempar dadunya secara diam-diam di bawah cangkir. Bergantian, kalian membuat taruhan makin tinggi atas jumlah total satu nilai di seluruh meja — atau berteriak "Bohong!" jika tidak percaya pada taruhan terakhir. Salah tebak = kehilangan satu dadu. Pemain terakhir dengan dadu menang.

liarsdice-rules =
    Liar's Dice adalah permainan dadu blasi untuk 2 hingga 6 pemain.
    Setiap pemain mulai dengan 5 dadu di cangkir. Di awal setiap ronde semua melempar diam-diam.
    Bergantian membuat taruhan atas jumlah total satu nilai pada semua dadu — misalnya "tiga 4" berarti ada paling tidak tiga 4 saat semua cangkir dibuka.
    Setiap taruhan baru harus lebih tinggi: nilai sama dengan jumlah lebih banyak, atau nilai lebih tinggi dengan jumlah sama atau lebih banyak.
    1 adalah joker — terhitung di setiap taruhan kecuali taruhan pada 1.
    Beralih ke taruhan pada 1 membagi dua jumlah (dibulatkan ke atas). Kembali dari 1 ke nilai biasa butuh lebih dari dua kali lipat jumlah sebelumnya.
    Daripada bertaruh, kamu bisa berteriak "Bohong!" untuk menantang taruhan terakhir. Semua cangkir dibuka: jika taruhan benar, penantang kehilangan dadu; jika tidak, pemain yang bertaruh kehilangan dadu.
    Dengan Spot On aktif, kamu bisa berteriak "Spot On" bertaruh bahwa taruhannya tepat. Benar — semua pemain lain kehilangan satu dadu; salah — kamu kehilangan dua.
    Tereliminasi saat dadu habis. Pemain terakhir dengan dadu menang.
    Tekan S untuk memeriksa meja.

ld-set-starting-dice = Dadu awal per pemain: { $dice }
ld-desc-starting-dice = Berapa dadu setiap pemain dimulai. Bawaan 5. Lebih banyak dadu = permainan lebih lama dan ruang lebih untuk blasi.
ld-prompt-starting-dice = Masukkan dadu awal (3 sampai 8)
ld-option-changed-starting-dice = Dadu awal diatur ke { $dice }.

ld-toggle-wild-ones = 1 adalah joker: { $enabled }
ld-desc-wild-ones = Aktif: 1 terhitung di setiap taruhan yang bukan pada 1. Taruhan pada 1 menonaktifkan joker untuk taruhan tersebut. Nonaktif — permainan murni probabilitas tanpa joker.
ld-option-changed-wild-ones = Joker 1 { $enabled }.

ld-toggle-spot-on = Panggilan Spot On aktif: { $enabled }
ld-desc-spot-on = Aktif: selain "Bohong" kamu bisa panggil "Spot On" bertaruh taruhannya tepat. Benar — yang lain kehilangan satu dadu masing-masing. Salah — kamu kehilangan dua. Risiko tinggi, imbalan tinggi.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Ronde { $round } dimulai. Total dadu di meja: { $total }. Semua melempar.
ld-your-roll = Dadu kamu ronde ini: { $dice }.
ld-your-counts = Jumlah kamu: { $counts }.
ld-turn-start = Giliran { $player }. { $bid_state }
ld-no-bid-yet = Belum ada taruhan — buka ronde.
ld-current-bid = Taruhan saat ini: { $quantity } { $face }.

ld-action-bid = Bertaruh
ld-action-call-liar = Panggil Bohong
ld-action-call-spot-on = Panggil Spot On
ld-bid-prompt = Pilih taruhanmu.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Kamu bertaruh { $quantity } { $face }.
    *[player] { $player } bertaruh { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Kamu panggil Bohong atas taruhan { $target } { $quantity } { $face }.
    *[player] { $player } panggil Bohong atas taruhan { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Kamu panggil Spot On atas taruhan { $target } { $quantity } { $face }.
    *[player] { $player } panggil Spot On atas taruhan { $target } { $quantity } { $face }.
}
ld-reveal-header = Buka cangkir! Hitung { $face } di meja.
ld-reveal-line = { $player } melempar: { $dice }.
ld-actual-count = Jumlah sebenarnya { $face } (termasuk joker 1): { $count }. Taruhan adalah { $quantity }.
ld-actual-count-no-wild = Jumlah sebenarnya { $face } (tanpa joker): { $count }. Taruhan adalah { $quantity }.

ld-liar-bidder-loses = { $bidder } bertaruh terlalu tinggi — kehilangan satu dadu.
ld-liar-caller-loses = Taruhannya jujur — { $caller } kehilangan satu dadu.
ld-spot-on-correct = Spot on! { $caller } tepat — yang lain kehilangan satu dadu masing-masing.
ld-spot-on-wrong = Bukan spot on. { $caller } kehilangan dua dadu.

ld-lost-die = { $who ->
    [you] Kamu kehilangan satu dadu. Sekarang punya { $remaining } { $remaining ->
        [one] dadu
        *[other] dadu
    }.
    *[player] { $player } kehilangan satu dadu. Sekarang punya { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Kamu kehilangan { $count } dadu. Sekarang punya { $remaining } { $remaining ->
        [one] dadu
        *[other] dadu
    }.
    *[player] { $player } kehilangan { $count } dadu. Sekarang punya { $remaining }.
}
ld-eliminated = { $player } kehabisan dadu dan tereliminasi! Tersisa { $remaining } { $remaining ->
    [one] pemain
    *[other] pemain
}.
ld-winner = { $player } pemain terakhir dengan dadu — menang!

ld-status-round = Ronde { $round }.
ld-status-your-dice = Dadu kamu: { $dice }.
ld-status-your-counts = Jumlah kamu: { $counts }.
ld-status-no-dice = Tidak ada dadu — kamu tereliminasi.
ld-status-current-bid = Taruhan saat ini: { $quantity } { $face }.
ld-status-no-bid = Tidak ada taruhan ronde ini.
ld-status-table-total = Total dadu di meja: { $total }.
ld-status-detailed-header = Status detail — tersisa { $count } pemain.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] dadu
    *[other] dadu
}.
ld-status-detailed-out = { $player }: tereliminasi.
ld-status-detailed-self-suffix = {" "}(kamu)

ld-face-1 = satu
ld-face-2 = dua
ld-face-3 = tiga
ld-face-4 = empat
ld-face-5 = lima
ld-face-6 = enam

ld-action-not-your-turn = Bukan giliranmu.
ld-action-not-playing = Permainan tidak sedang berjalan.
ld-action-no-bid-to-call = Belum ada taruhan untuk ditantang.
ld-action-eliminated = Kamu sudah tereliminasi.
