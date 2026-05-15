# Trouble — id
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble adalah game balap dari keluarga Parcheesi.
    Setiap pemain memulai dengan token di area Rumah.
    Pada giliranmu, tekan dadu dan gerakkan satu token.
    Secara default kamu harus melempar 6 untuk mengeluarkan token dari Rumah ke trek.
    Secara default melempar 6 juga memberikan giliran ekstra.
    Token bergerak searah jarum jam di trek bersama menuju area finis.
    Mendarat di token lawan mengirimnya kembali ke Rumah, kecuali ruang dilindungi.
    Saat semua tokenmu mencapai finis, kamu menang.
    Dalam mode tim, timmu menang saat semua rekan selesai.
    Tombol 1-6 memilih token, R melempar.
    Tekan E kapan saja untuk mendengar status papan penuh.

trouble-action-roll = Tekan dadu
trouble-action-move-token = Gerakkan token { $token }
trouble-action-check-board = Periksa papan

trouble-token-label-home = Token { $token }: di Rumah
trouble-token-label-track = Token { $token }: ruang { $position } di trek
trouble-token-label-finish-lane = Token { $token }: jalur finis { $position } dari { $total }
trouble-token-label-finished = Token { $token }: selesai

trouble-rolled = { $player } melempar { $roll }.
trouble-leave-home = { $player } mengeluarkan token { $token } ke trek.
trouble-advance-track = { $player } memindahkan token { $token } ke ruang { $position }.
trouble-enter-finish-lane = { $player } membawa token { $token } ke jalur finis.
trouble-advance-finish-lane =
    { $player } memajukan token { $token } ke ruang { $position } dari { $total } di jalur finis.
trouble-token-finished = Token { $token } { $player } mencapai finis.
trouble-bump =
    Token { $token } { $player } mengirim token { $opp_token } { $opponent } kembali ke Rumah.
trouble-no-legal-move = { $player } tidak punya gerakan sah. Giliran lewat.
trouble-extra-turn = { $player } dapat giliran ekstra karena 6.

trouble-winner = { $player } menang! Semua token di finis.
trouble-team-winner = Tim { $team } menang! Semua rekan selesai.
trouble-final-standing = { $player }: { $finished } dari { $total } token selesai.

trouble-turn-summary =
    Kamu punya { $own_home } di Rumah, { $own_track } di trek, { $own_finished } di finis.
    Lawan: { $opponents }.
trouble-opponent-summary = { $name }: { $home } rumah, { $track } trek, { $finished } finis

trouble-board-status =
    Token kamu: { $own_tokens }.
    Token lawan: { $opp_tokens }.

trouble-reason-not-rolled = Tekan dadu dulu.
trouble-reason-already-rolled = Sudah ditekan. Pilih token untuk digerakkan.
trouble-reason-no-legal-moves = Tidak ada gerakan sah untuk lemparan ini.
trouble-reason-token-home-needs-six = Token ini di Rumah. Butuh 6 untuk mengeluarkannya.
trouble-reason-token-home-needs-any = Token ini di Rumah. Lemparan apa saja mengeluarkannya.
trouble-reason-token-home-no-qualifying-roll =
    Token ini di Rumah dan lemparanmu tidak memenuhi syarat mengeluarkannya.
trouble-reason-token-finished = Token ini sudah selesai.
trouble-reason-overshoot-wastes = Token ini tidak bisa bergerak { $roll } ruang tanpa melewati finis.
trouble-reason-blocked = Gerakan ini diblokir.

trouble-option-track-size = Ukuran trek: { $track_size } ruang
trouble-option-select-track-size = Pilih jumlah ruang trek.
trouble-option-changed-track-size = Trek diatur ke { $track_size } ruang.
trouble-option-desc-track-size = Jumlah ruang pada trek bersama.

trouble-option-tokens-per-player = Token per pemain: { $tokens }
trouble-option-enter-tokens-per-player = Masukkan token per pemain (2-6):
trouble-option-changed-tokens-per-player = Token per pemain diatur ke { $tokens }.
trouble-option-desc-tokens-per-player = Berapa banyak token yang dilarikan setiap pemain ke finis.

trouble-option-extra-turn-on-six = Giliran ekstra pada 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Giliran ekstra pada 6 { $enabled ->
    [on] aktif.
    [off] nonaktif.
   *[other] diperbarui.
}
trouble-option-desc-extra-turn-on-six =
    Aktif: 6 memberi giliran ekstra (aturan klasik Hasbro).

trouble-option-six-to-leave-home = Butuh 6 untuk keluar Rumah: { $enabled }
trouble-option-changed-six-to-leave-home = Enam untuk keluar Rumah { $enabled ->
    [on] aktif.
    [off] nonaktif.
   *[other] diperbarui.
}
trouble-option-desc-six-to-leave-home =
    Aktif: pemain harus lempar 6 untuk mengeluarkan token dari Rumah. Nonaktif: lemparan apa saja keluar.

trouble-option-safe-spaces = Ruang aman: { $mode }
trouble-option-select-safe-spaces = Pilih mode ruang aman.
trouble-option-changed-safe-spaces = Ruang aman diatur ke { $mode }.
trouble-option-desc-safe-spaces = Tentukan apakah token bisa dilindungi dari tabrakan.

trouble-safe-mode-none = Tidak ada
trouble-safe-mode-home-stretch = Hanya garis finis
trouble-safe-mode-every-seventh = Setiap 7 ruang

trouble-option-finish-behavior = Finis: { $mode }
trouble-option-select-finish-behavior = Pilih perilaku finis.
trouble-option-changed-finish-behavior = Perilaku finis diatur ke { $mode }.
trouble-option-desc-finish-behavior = Cara menangani lemparan yang melewati finis.

trouble-finish-mode-exact = Lemparan tepat dibutuhkan
trouble-finish-mode-bounce = Kelebihan memantul
trouble-finish-mode-allow = Kelebihan diizinkan

trouble-option-bot-difficulty = Kesulitan bot: { $level }
trouble-option-select-bot-difficulty = Pilih kesulitan bot.
trouble-option-changed-bot-difficulty = Kesulitan bot diatur ke { $level }.
trouble-option-desc-bot-difficulty = Kekuatan bot bawaan.

trouble-bot-difficulty-naive = Naif
trouble-bot-difficulty-greedy = Serakah

trouble-option-preset = Preset: { $preset }
trouble-option-select-preset = Pilih varian. Tuan rumah bisa menyesuaikan aturan individual nanti.
trouble-option-changed-preset = Preset diterapkan: { $preset }.
trouble-option-desc-preset = Kumpulan opsi yang dikemas untuk varian umum.

trouble-preset-classic = Klasik Hasbro
trouble-preset-fast = Cepat
trouble-preset-brutal = Brutal
trouble-preset-custom = Kustom
