# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Ninety Nine

# Round and turn flow
game-round-start = Ronde { $round }.
game-round-end = Ronde { $round } selesai.
game-turn-start = Giliran { $player }.
game-your-turn = Giliran Anda.
game-no-turn = Tidak ada giliran sekarang.

# Score display
game-scores-header = Skor Saat Ini:
game-score-line = { $player }: { $score } poin
game-final-scores-header = Skor Akhir:

# Win/loss
game-winner = { $player } menang!
game-winner-score = { $player } menang dengan { $score } poin!
game-tiebreaker = Seri! Ronde tiebreaker!
game-tiebreaker-players = Seri antara { $players }! Ronde tiebreaker!
game-eliminated = { $player } telah dieliminasi dengan { $score } poin.

# Common options
game-set-target-score = Skor target: { $score }
game-enter-target-score = Masukkan skor target:
game-option-changed-target = Skor target diatur ke { $score }.

game-set-team-mode = Mode tim: { $mode }
game-select-team-mode = Pilih mode tim
game-option-changed-team = Mode tim diatur ke { $mode }.
game-team-mode-individual = Individual
game-team-mode-x-teams-of-y = { $num_teams } tim dari { $team_size }

# Boolean option values
option-on = aktif
option-off = nonaktif

# Status box

# Game end
game-leave = Tinggalkan permainan

# Round timer
round-timer-paused = { $player } telah menjeda permainan (tekan p untuk memulai ronde berikutnya).
round-timer-resumed = Timer ronde dilanjutkan.
round-timer-countdown = Ronde berikutnya dalam { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Menyimpan { $value }.
dice-rerolling = Melempar ulang { $value }.
dice-locked = Dadu itu terkunci dan tidak dapat diubah.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Bagikan { $current }/{ $total }.
game-you-deal = Anda membagikan kartu.
game-player-deals = { $player } membagikan kartu.

# Card names
card-name = { $rank } { $suit }
no-cards = Tidak ada kartu

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = hitam
color-black-m = hitam
color-black-f = hitam
color-blue = biru
color-blue-m = biru
color-blue-f = biru
color-brown = cokelat
color-brown-m = cokelat
color-brown-f = cokelat
color-gray = abu-abu
color-gray-m = abu-abu
color-gray-f = abu-abu
color-green = hijau
color-green-m = hijau
color-green-f = hijau
color-indigo = nila
color-indigo-m = nila
color-indigo-f = nila
color-orange = oranye
color-orange-m = oranye
color-orange-f = oranye
color-pink = merah muda
color-pink-m = merah muda
color-pink-f = merah muda
color-purple = ungu
color-purple-m = ungu
color-purple-f = ungu
color-red = merah
color-red-m = merah
color-red-f = merah
color-violet = violet
color-violet-m = violet
color-violet-f = violet
color-white = putih
color-white-m = putih
color-white-f = putih
color-yellow = kuning
color-yellow-m = kuning
color-yellow-f = kuning

# Suit names
suit-diamonds = wajik
suit-clubs = keriting
suit-hearts = hati
suit-spades = sekop

# Rank names
rank-ace = as
rank-ace-plural = as
rank-two = 2
rank-two-plural = 2
rank-three = 3
rank-three-plural = 3
rank-four = 4
rank-four-plural = 4
rank-five = 5
rank-five-plural = 5
rank-six = 6
rank-six-plural = 6
rank-seven = 7
rank-seven-plural = 7
rank-eight = 8
rank-eight-plural = 8
rank-nine = 9
rank-nine-plural = 9
rank-ten = 10
rank-ten-plural = 10
rank-jack = jack
rank-jack-plural = jack
rank-queen = queen
rank-queen-plural = queen
rank-king = king
rank-king-plural = king

# Poker hand descriptions
poker-high-card-with = { $high } tinggi, dengan { $rest }
poker-high-card = { $high } tinggi
poker-pair-with = Pasangan { $pair }, dengan { $rest }
poker-pair = Pasangan { $pair }
poker-two-pair-with = Dua Pasangan, { $high } dan { $low }, dengan { $kicker }
poker-two-pair = Dua Pasangan, { $high } dan { $low }
poker-trips-with = Three of a Kind, { $trips }, dengan { $rest }
poker-trips = Three of a Kind, { $trips }
poker-straight-high = Straight { $high } tinggi
poker-flush-high-with = Flush { $high } tinggi, dengan { $rest }
poker-full-house = Full House, { $trips } over { $pair }
poker-quads-with = Four of a Kind, { $quads }, dengan { $kicker }
poker-quads = Four of a Kind, { $quads }
poker-straight-flush-high = Straight Flush { $high } tinggi
poker-unknown-hand = Tangan tidak diketahui

# Validation errors (common across games)
game-error-invalid-team-mode = Mode tim yang dipilih tidak valid untuk jumlah pemain saat ini.

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
