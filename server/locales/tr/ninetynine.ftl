# ninetynine.ftl for locale tr. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Oyun adları
game-name-ninetynine = Ninety Nine
# Raund
ninetynine-round = Raund { $round }.
# Kart oynama - v10 ile tam eşleşiyor
ninetynine-you-play = { $card } oynuyorsun. Sayaç şimdi { $count }.
ninetynine-player-plays = { $player } { $card } oynuyor. Sayaç şimdi { $count }.
# Yön tersine çevirme
ninetynine-direction-reverses = Oyun yönü tersine çevriliyor!
# Atlama
ninetynine-player-skipped = { $player } atlanıyor.
# Jeton kaybı - v10 ile tam eşleşiyor
ninetynine-you-lose-tokens =
    { $amount } { $amount ->
        [one] jeton
       *[other] jeton
    } kaybediyorsun.
ninetynine-player-loses-tokens =
    { $player } { $amount } { $amount ->
        [one] jeton
       *[other] jeton
    } kaybediyor.
# Eleme
ninetynine-player-eliminated = { $player } elendi!
# Oyun sonu
ninetynine-player-wins = { $player } oyunu kazandı!
# Kart çekme
ninetynine-you-draw = { $card } çekiyorsun.
ninetynine-player-draws = { $player } bir kart çekiyor.
# Geçerli kart yok
ninetynine-no-valid-cards = { $player }'ın 99'u aşmayacak kartı yok!
# Durum - C tuşu için
ninetynine-current-count = Sayaç { $count }.
# As seçimi
ninetynine-ace-choice = As'ı +1 veya +11 olarak oyna?
ninetynine-ace-add-eleven = 11 ekle
ninetynine-ace-add-one = 1 ekle
# On seçimi
ninetynine-ten-choice = 10'u +10 veya -10 olarak oyna?
ninetynine-ten-add = 10 ekle
ninetynine-ten-subtract = 10 çıkar
# Manuel çekme
ninetynine-draw-card = Kart çek
ninetynine-draw-prompt = Kart çekmek için Boşluk veya D'ye basın.
# Seçenekler
ninetynine-set-tokens = Başlangıç jetonları: { $tokens }
ninetynine-enter-tokens = Başlangıç jeton sayısını girin:
ninetynine-option-changed-tokens = Başlangıç jetonları { $tokens } olarak ayarlandı.
ninetynine-set-rules = Kural varyantı: { $rules }
ninetynine-select-rules = Kural varyantını seç
ninetynine-option-changed-rules = Kural varyantı { $rules } olarak ayarlandı.
ninetynine-set-hand-size = El boyutu: { $size }
ninetynine-enter-hand-size = El boyutunu girin:
ninetynine-option-changed-hand-size = El boyutu { $size } olarak ayarlandı.
ninetynine-set-autodraw = Otomatik çekme: { $enabled }
ninetynine-option-changed-autodraw = Otomatik çekme { $enabled } olarak ayarlandı.
# Devre dışı eylem nedenleri
ninetynine-choose-first = Önce bir seçim yapmalısın.
