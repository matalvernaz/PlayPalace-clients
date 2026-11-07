# tossup.ftl for locale tr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Oyun bilgisi
game-name-tossup = Toss Up
# Eylemler
tossup-roll-first = { $count } zar at
tossup-roll-remaining = Kalan { $count } zarı at
tossup-bank = { $points } puan bankaya yatır
tossup-you-roll = Attığın: { $results }.
tossup-player-rolls = { $player } attı: { $results }.
# Tur durumu
tossup-you-have-points = Tur puanı: { $turn_points }. Kalan zar: { $dice_count }.
tossup-player-has-points = { $player } { $turn_points } tur puanı var. { $dice_count } zar kaldı.
# Taze zarlar
tossup-you-get-fresh = Zar kalmadı! { $count } taze zar alıyorsun.
tossup-player-gets-fresh = { $player } { $count } taze zar alıyor.
# Yanma
tossup-you-bust = Yandın! Bu tur için { $points } puan kaybediyorsun.
tossup-player-busts = { $player } yanıyor ve { $points } puan kaybediyor!
# Bankaya yatırma
tossup-you-bank = { $points } puan bankaya yatırıyorsun. Toplam skor: { $total }.
tossup-player-banks = { $player } { $points } puan bankaya yatırıyor. Toplam skor: { $total }.
# Kazanan
tossup-winner = { $player } { $score } puan ile kazandı!
tossup-tie-tiebreaker = { $players } arasında berabere! Beraberlik raund!
# Seçenekler
tossup-set-rules-variant = Kural varyantı: { $variant }
tossup-select-rules-variant = Kural varyantını seç:
tossup-option-changed-rules = Kural varyantı { $variant } olarak değiştirildi
tossup-set-starting-dice = Başlangıç zarı: { $count }
tossup-enter-starting-dice = Başlangıç zar sayısını girin:
tossup-option-changed-dice = Başlangıç zarı { $count } olarak değiştirildi
# Kural varyantları
tossup-rules-standard = Standart
# Kural açıklamaları
tossup-rules-standard-desc = Zar başına 3 yeşil, 2 sarı, 1 kırmızı. Yeşil yoksa ve en az bir kırmızı varsa yan.
