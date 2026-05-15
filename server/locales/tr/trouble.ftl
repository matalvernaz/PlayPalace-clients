# Trouble — tr
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble, Parcheesi ailesinden bir yarış oyunudur.
    Her oyuncu taşlarını Ev bölgesinde başlatır.
    Sırasında zar pop edip taşlardan birini hareket ettirirsin.
    Varsayılan olarak Ev'den taşı pistte serbest bırakmak için 6 atmalısın.
    Varsayılan olarak 6 atmak ekstra tur da verir.
    Taşlar paylaşılan pistte saat yönünde bitiş bölgesine doğru ilerler.
    Rakibin taşının üzerine düşmek onu Ev'ine geri yollar, kare korunaklı değilse.
    Tüm taşların bitişe ulaşınca kazanırsın.
    Takım modunda tüm takım arkadaşları bittiğinde takımın kazanır.
    1-6 tuşları taş seçimi, R zar pop.
    İstediğin an E ile tahta durumunu dinleyebilirsin.

trouble-action-roll = Zar pop et
trouble-action-move-token = Taş { $token } hareket
trouble-action-check-board = Tahtaya bak

trouble-token-label-home = Taş { $token }: Ev'de
trouble-token-label-track = Taş { $token }: pist { $position } karesi
trouble-token-label-finish-lane = Taş { $token }: bitiş şeridi { $position }/{ $total }
trouble-token-label-finished = Taş { $token }: bitti

trouble-rolled = { $player } { $roll } attı.
trouble-leave-home = { $player } taş { $token } 'i piste serbest bırakıyor.
trouble-advance-track = { $player } taş { $token } 'i pistin { $position }. karesine taşıyor.
trouble-enter-finish-lane = { $player } taş { $token } 'i bitiş şeridine sokuyor.
trouble-advance-finish-lane =
    { $player } taş { $token } 'i bitiş şeridinin { $position }/{ $total } konumuna ilerletiyor.
trouble-token-finished = { $player } 'nın taş { $token } 'i bitişe ulaştı.
trouble-bump =
    { $player } 'nın taş { $token } 'i { $opponent } 'nin taş { $opp_token } 'ini Ev'e gönderiyor.
trouble-no-legal-move = { $player } 'nın geçerli hamlesi yok. Sıra geçiyor.
trouble-extra-turn = { $player } 6 atarak ekstra tur kazandı.

trouble-winner = { $player } kazandı! Tüm taşlar bitişte.
trouble-team-winner = { $team } takımı kazandı! Tüm takım arkadaşları bitirdi.
trouble-final-standing = { $player }: { $total } taşın { $finished } 'i bitirdi.

trouble-turn-summary =
    Ev'de { $own_home }, pistte { $own_track }, bitişte { $own_finished } var.
    Rakipler: { $opponents }.
trouble-opponent-summary = { $name }: ev { $home }, pist { $track }, bitiş { $finished }

trouble-board-status =
    Senin taşların: { $own_tokens }.
    Rakip taşlar: { $opp_tokens }.

trouble-reason-not-rolled = Önce zarı pop et.
trouble-reason-already-rolled = Zaten pop ettin. Hareket ettirmek için bir taş seç.
trouble-reason-no-legal-moves = Bu atış için geçerli hamle yok.
trouble-reason-token-home-needs-six = Bu taş Ev'de. Serbest bırakmak için 6 gerek.
trouble-reason-token-home-needs-any = Bu taş Ev'de. Herhangi bir atış serbest bırakır.
trouble-reason-token-home-no-qualifying-roll =
    Bu taş Ev'de ve atışın serbest bırakmaya yetmez.
trouble-reason-token-finished = Bu taş zaten bitti.
trouble-reason-overshoot-wastes = Bu taş bitişi geçmeden { $roll } kare ilerleyemez.
trouble-reason-blocked = Bu hamle engelli.

trouble-option-track-size = Pist boyu: { $track_size } kare
trouble-option-select-track-size = Pist kare sayısını seç.
trouble-option-changed-track-size = Pist { $track_size } kareye ayarlandı.
trouble-option-desc-track-size = Paylaşılan pistteki kare sayısı.

trouble-option-tokens-per-player = Oyuncu başına taş: { $tokens }
trouble-option-enter-tokens-per-player = Oyuncu başına taş sayısını gir (2-6):
trouble-option-changed-tokens-per-player = Oyuncu başına taş { $tokens } 'e ayarlandı.
trouble-option-desc-tokens-per-player = Her oyuncunun bitirmek istediği taş sayısı.

trouble-option-extra-turn-on-six = 6'ta ekstra tur: { $enabled }
trouble-option-changed-extra-turn-on-six = 6'ta ekstra tur { $enabled ->
    [on] etkin.
    [off] kapalı.
   *[other] güncellendi.
}
trouble-option-desc-extra-turn-on-six =
    Açık: 6 ekstra tur verir (klasik Hasbro kuralı).

trouble-option-six-to-leave-home = Ev'den çıkmak için 6 gerekli: { $enabled }
trouble-option-changed-six-to-leave-home = Ev'den çıkmak için altı { $enabled ->
    [on] etkin.
    [off] kapalı.
   *[other] güncellendi.
}
trouble-option-desc-six-to-leave-home =
    Açık: Ev'den taş çıkarmak için 6 gerek. Kapalı: her atış çıkarır.

trouble-option-safe-spaces = Güvenli kareler: { $mode }
trouble-option-select-safe-spaces = Güvenli kare modunu seç.
trouble-option-changed-safe-spaces = Güvenli kareler { $mode } 'e ayarlandı.
trouble-option-desc-safe-spaces = Taşların çarpışmalardan korunup korunmadığını seç.

trouble-safe-mode-none = Yok
trouble-safe-mode-home-stretch = Sadece bitiş düzlüğü
trouble-safe-mode-every-seventh = Her 7. kare

trouble-option-finish-behavior = Bitiş: { $mode }
trouble-option-select-finish-behavior = Bitiş davranışını seç.
trouble-option-changed-finish-behavior = Bitiş davranışı { $mode } 'e ayarlandı.
trouble-option-desc-finish-behavior = Bitişi geçen atışın nasıl ele alınacağı.

trouble-finish-mode-exact = Tam atış gerekli
trouble-finish-mode-bounce = Aşma geri sekiyor
trouble-finish-mode-allow = Aşmaya izin

trouble-option-bot-difficulty = Bot zorluğu: { $level }
trouble-option-select-bot-difficulty = Bot zorluğunu seç.
trouble-option-changed-bot-difficulty = Bot zorluğu { $level } 'e ayarlandı.
trouble-option-desc-bot-difficulty = Dahili botların gücü.

trouble-bot-difficulty-naive = Naif
trouble-bot-difficulty-greedy = Açgözlü

trouble-option-preset = Hazır ayar: { $preset }
trouble-option-select-preset = Varyantı seç. Ev sahibi sonra kuralları ayarlayabilir.
trouble-option-changed-preset = Hazır ayar uygulandı: { $preset }.
trouble-option-desc-preset = Yaygın varyantlar için önceden paketlenmiş seçenekler.

trouble-preset-classic = Klasik Hasbro
trouble-preset-fast = Hızlı
trouble-preset-brutal = Acımasız
trouble-preset-custom = Özel
