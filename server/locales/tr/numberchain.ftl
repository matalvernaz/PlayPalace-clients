# Number Chain — tr
# AI-translated, native review pending — corrections welcome.

game-name-numberchain = Number Chain

# Game start
numberchain-game-started = { $p1 } oyuncu 1, { $p2 } oyuncu 2. { $first } başlıyor. Zinciri başlatmak için herhangi bir yere 1 yerleştirin.

# Placement
numberchain-place-you = { $number } sayısını satır { $row }, sütun { $col } konumuna yerleştiriyorsun.
numberchain-place-other = { $player } { $number } sayısını satır { $row }, sütun { $col } konumuna yerleştiriyor.

# Errors
numberchain-illegal-move = Bu hamle geçersiz.

# Status / info
numberchain-status = Sıra { $current } üzerinde. Sıradaki sayı: { $required }.
numberchain-inventory = Kalan taşların: { $inventory }.
numberchain-required = Yerleştirilecek sıradaki sayı: { $required }.

# Square labels
numberchain-sq-empty = Satır { $row }, sütun { $col }, boş
numberchain-sq-own = Satır { $row }, sütun { $col }, { $number }, senin
numberchain-sq-opponent = Satır { $row }, sütun { $col }, { $number }, { $owner }

# Action labels
numberchain-check-status = Durum
numberchain-check-inventory = Envanter
numberchain-check-required = Sıradaki sayı

# Win
numberchain-wins = { $player } kazandı! Rakibin geçerli hamlesi kalmadı.
numberchain-final = { $winner } kazandı.

# Options
numberchain-option-bot-difficulty = Bot zorluğu: { $bot_difficulty }
numberchain-option-select-bot-difficulty = Bot zorluğunu seç
numberchain-option-changed-bot-difficulty = Bot zorluğu { $bot_difficulty } olarak ayarlandı.
numberchain-difficulty-random = Rastgele
numberchain-difficulty-simple = Basit
