# PlayPalace için paylaşılan oyun mesajları
# Bu mesajlar birden fazla oyunda ortak kullanılır

# Oyun adları
game-name-ninetynine = Ninety Nine

# Raund ve tur akışı
game-round-start = Raund { $round }.
game-round-end = Raund { $round } tamamlandı.
game-turn-start = { $player }'ın turu.
game-your-turn = Senin turun.
game-no-turn = Şu anda kimsenin turu değil.

# Skor gösterimi
game-scores-header = Güncel Skorlar:
game-score-line = { $player }: { $score } puan
game-final-scores-header = Final Skorları:

# Kazanma/kaybetme
game-winner = { $player } kazandı!
game-winner-score = { $player } { $score } puan ile kazandı!
game-tiebreaker = Berabere! Beraberlik turu!
game-tiebreaker-players = { $players } arasında berabere! Beraberlik turu!
game-eliminated = { $player } { $score } puan ile elendi.

# Ortak seçenekler
game-set-target-score = Hedef skor: { $score }
game-enter-target-score = Hedef skoru girin:
game-option-changed-target = Hedef skor { $score } olarak ayarlandı.

game-set-team-mode = Takım modu: { $mode }
game-select-team-mode = Takım modunu seç
game-option-changed-team = Takım modu { $mode } olarak ayarlandı.
game-team-mode-individual = Bireysel
game-team-mode-x-teams-of-y = { $team_size } kişilik { $num_teams } takım

# Boolean seçenek değerleri
option-on = açık
option-off = kapalı

# Durum kutusu

# Oyun sonu
game-leave = Oyundan ayrıl

# Raund zamanlayıcısı
round-timer-paused = { $player } oyunu duraklattı (sonraki raunda başlamak için p'ye basın).
round-timer-resumed = Raund zamanlayıcısı devam etti.
round-timer-countdown = Sonraki raund { $seconds } içinde...

# Zar oyunları - zarları tutma/bırakma
dice-keeping = { $value } tutulyor.
dice-rerolling = { $value } tekrar atılıyor.
dice-locked = Bu zar kilitli ve değiştirilemez.
dice-status-locked = locked
dice-status-kept = kept

# Dağıtma (kart oyunları)
game-deal-counter = Dağıtım { $current }/{ $total }.
game-you-deal = Kartları dağıtıyorsun.
game-player-deals = { $player } kartları dağıtıyor.

# Kart adları
card-name = { $suit } { $rank }
no-cards = Kart yok

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = siyah
color-black-m = siyah
color-black-f = siyah
color-blue = mavi
color-blue-m = mavi
color-blue-f = mavi
color-brown = kahverengi
color-brown-m = kahverengi
color-brown-f = kahverengi
color-gray = gri
color-gray-m = gri
color-gray-f = gri
color-green = yeşil
color-green-m = yeşil
color-green-f = yeşil
color-indigo = çivit
color-indigo-m = çivit
color-indigo-f = çivit
color-orange = turuncu
color-orange-m = turuncu
color-orange-f = turuncu
color-pink = pembe
color-pink-m = pembe
color-pink-f = pembe
color-purple = mor
color-purple-m = mor
color-purple-f = mor
color-red = kırmızı
color-red-m = kırmızı
color-red-f = kırmızı
color-violet = menekşe
color-violet-m = menekşe
color-violet-f = menekşe
color-white = beyaz
color-white-m = beyaz
color-white-f = beyaz
color-yellow = sarı
color-yellow-m = sarı
color-yellow-f = sarı

# Takım adları
suit-diamonds = karo
suit-clubs = sinek
suit-hearts = kupa
suit-spades = maça

# Değer adları
rank-ace = as
rank-ace-plural = aslar
rank-two = 2
rank-two-plural = 2'ler
rank-three = 3
rank-three-plural = 3'ler
rank-four = 4
rank-four-plural = 4'ler
rank-five = 5
rank-five-plural = 5'ler
rank-six = 6
rank-six-plural = 6'ler
rank-seven = 7
rank-seven-plural = 7'ler
rank-eight = 8
rank-eight-plural = 8'ler
rank-nine = 9
rank-nine-plural = 9'lar
rank-ten = 10
rank-ten-plural = 10'lar
rank-jack = vale
rank-jack-plural = valeler
rank-queen = kız
rank-queen-plural = kızlar
rank-king = papaz
rank-king-plural = papazlar

# Poker el açıklamaları
poker-high-card-with = { $high } yüksek, { $rest } ile
poker-high-card = { $high } yüksek
poker-pair-with = { $pair } çifti, { $rest } ile
poker-pair = { $pair } çifti
poker-two-pair-with = İki Çift, { $high } ve { $low }, { $kicker } ile
poker-two-pair = İki Çift, { $high } ve { $low }
poker-trips-with = Üçlü, { $trips }, { $rest } ile
poker-trips = Üçlü, { $trips }
poker-straight-high = { $high } yüksek Sıra
poker-flush-high-with = { $high } yüksek Renk, { $rest } ile
poker-full-house = Full House, { $trips } üzerinde { $pair }
poker-quads-with = Dörtlü, { $quads }, { $kicker } ile
poker-quads = Dörtlü, { $quads }
poker-straight-flush-high = { $high } yüksek Sıralı Renk
poker-unknown-hand = Bilinmeyen el

# Doğrulama hataları (oyunlar arası ortak)
game-error-invalid-team-mode = Seçilen takım modu mevcut oyuncu sayısı için geçerli değil.

game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] point
   *[other] points
}
game-score-unit-chips = { $count ->
    [one] chip
   *[other] chips
}
game-score-unit-coins = { $count ->
    [one] coin
   *[other] coins
}
game-score-unit-health = health
game-score-unit-ninetynine-tokens = { $count ->
    [one] token
   *[other] tokens
}
game-score-unit-tokens-home = { $count ->
    [one] token home
   *[other] tokens home
}
game-score-unit-pawns-home = { $count ->
    [one] pawn home
   *[other] pawns home
}
game-score-unit-hand-wins = { $count ->
    [one] hand win
   *[other] hand wins
}
game-score-unit-light = light
game-winner-you = You win!
game-team-name = Team { $index }
team-arrangement-started = Team arrangement started. Review the teams, swap members if needed, then confirm to start.
team-arrangement-confirm = Confirm teams and start
team-arrangement-read = Read teams
team-arrangement-select-member-action = Select team member
team-arrangement-select-member = Select a team member
team-arrangement-select-swap-target = Select a player to swap with
team-arrangement-swap-member = Choose swap target
team-arrangement-swap-member-selected = Swap { $player } with...
team-arrangement-cancel = Cancel team arrangement
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Turn order: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selected
team-arrangement-not-selected = not selected
team-arrangement-member-selected = { $player } from { $team } selected. Choose a player from another team to swap with.
team-arrangement-swapped = { $first } and { $second } have swapped teams.
team-arrangement-cancelled = Team arrangement cancelled.
team-arrangement-cancelled-roster = Team arrangement cancelled because the player list changed.
team-arrangement-refreshed = The player list changed. Team arrangement has been refreshed.
team-arrangement-in-progress = Finish or cancel team arrangement first.
team-arrangement-not-active = Team arrangement is not active.
team-arrangement-select-first = Select a team member first.
team-arrangement-player-missing = That player is no longer available for team arrangement.
team-arrangement-same-team = Choose someone from a different team.
team-arrangement-swap-failed = Could not swap those team members.

status-box-closed = Status information closed.

dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)

poker-royal-flush = Royal Flush
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
contact = Contact
document-not-found = Document not found.
help = Help

# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: {$game}
game-info-players = Players: {$count}
game-info-host = Host: {$host}
game-info-status = Status: {$status}
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.

# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for {$game} are not available yet.
