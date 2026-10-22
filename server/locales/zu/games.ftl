# Shared game messages for PlayPalace (isiZulu)
# Imiyalezo ejwayelekile emidlalweni eminingi

# Game names
game-name-ninetynine = Ninety Nine

# Round and turn flow
game-round-start = Umjikelezo { $round }.
game-round-end = Umjikelezo { $round } uphelile.
game-turn-start = Ishintshi lika-{ $player }.
game-your-turn = Ishintshi lakho.
game-no-turn = Ayikho ishintshi lamuntu njengamanje.

# Score display
game-scores-header = Amaphuzu Amanje:
game-score-line = { $player }: { $score } amaphuzu
game-final-scores-header = Amaphuzu Okugcina:

# Win/loss
game-winner = U-{ $player } uyawina!
game-winner-score = U-{ $player } uyawina ngamaphuzu angu-{ $score }!
game-tiebreaker = Kuyalinganiswa! Umjikelezo wokuphula ukulinganiswa!
game-tiebreaker-players = Kuyalinganiswa phakathi kuka-{ $players }! Umjikelezo wokuphula ukulinganiswa!
game-eliminated = U-{ $player } ukhishiwe ngamaphuzu angu-{ $score }.

# Common options
game-set-target-score = Amaphuzu ahlosiwe: { $score }
game-enter-target-score = Faka amaphuzu ahlosiwe:
game-option-changed-target = Amaphuzu ahlosiwe asetelwe ku-{ $score }.

game-set-team-mode = Imodi yethimba: { $mode }
game-select-team-mode = Khetha imodi yethimba
game-option-changed-team = Imodi yethimba isetelwe ku-{ $mode }.
game-team-mode-individual = Ngamunye
game-team-mode-x-teams-of-y = Amathimba angu-{ $num_teams } obu-{ $team_size }

# Boolean option values
option-on = ivuliwe
option-off = ivaliwe

# Status box

# Game end
game-leave = Shiya umdlalo

# Round timer
round-timer-paused = U-{ $player } umise umdlalo (cindezela i-p ukuze uqale umjikelezo olandelayo).
round-timer-resumed = Isikhathi somjikelezo siqhubekile.
round-timer-countdown = Umjikelezo olandelayo kumasekhondi angu-{ $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Kugcinwa { $value }.
dice-rerolling = Kuphonswa kabusha { $value }.
dice-locked = Lelo dayisi livalwe futhi alikwazi ukushintshwa.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Ukwabela { $current }/{ $total }.
game-you-deal = Wena wabela amakhadi.
game-player-deals = U-{ $player } wabela amakhadi.

# Card names
card-name = { $rank } we-{ $suit }
no-cards = Awekho amakhadi

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = mnyama
color-black-m = mnyama
color-black-f = mnyama
color-blue = luhlaza okwesibhakabhaka
color-blue-m = luhlaza okwesibhakabhaka
color-blue-f = luhlaza okwesibhakabhaka
color-brown = nsundu
color-brown-m = nsundu
color-brown-f = nsundu
color-gray = mpunga
color-gray-m = mpunga
color-gray-f = mpunga
color-green = luhlaza
color-green-m = luhlaza
color-green-f = luhlaza
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = orenji
color-orange-m = orenji
color-orange-f = orenji
color-pink = pinki
color-pink-m = pinki
color-pink-f = pinki
color-purple = mfusa
color-purple-m = mfusa
color-purple-f = mfusa
color-red = bomvu
color-red-m = bomvu
color-red-f = bomvu
color-violet = violethi
color-violet-m = violethi
color-violet-f = violethi
color-white = mhlophe
color-white-m = mhlophe
color-white-f = mhlophe
color-yellow = phuzi
color-yellow-m = phuzi
color-yellow-f = phuzi

# Suit names
suit-diamonds = amadayimane
suit-clubs = amaklabhu
suit-hearts = izinhliziyo
suit-spades = amaspeyidi

# Rank names
rank-ace = i-ace
rank-ace-plural = ama-aces
rank-two = u-2
rank-two-plural = ama-2
rank-three = u-3
rank-three-plural = ama-3
rank-four = u-4
rank-four-plural = ama-4
rank-five = u-5
rank-five-plural = ama-5
rank-six = u-6
rank-six-plural = ama-6
rank-seven = u-7
rank-seven-plural = ama-7
rank-eight = u-8
rank-eight-plural = ama-8
rank-nine = u-9
rank-nine-plural = ama-9
rank-ten = u-10
rank-ten-plural = ama-10
rank-jack = i-jack
rank-jack-plural = ama-jacks
rank-queen = i-queen
rank-queen-plural = ama-queens
rank-king = i-king
rank-king-plural = ama-kings

# Poker hand descriptions
poker-high-card-with = { $high } ephezulu, no-{ $rest }
poker-high-card = { $high } ephezulu
poker-pair-with = Ipheya le-{ $pair }, no-{ $rest }
poker-pair = Ipheya le-{ $pair }
poker-two-pair-with = Amapheya Amabili, { $high } no-{ $low }, no-{ $kicker }
poker-two-pair = Amapheya Amabili, { $high } no-{ $low }
poker-trips-with = Amathathu Ohlobo Olulodwa, { $trips }, no-{ $rest }
poker-trips = Amathathu Ohlobo Olulodwa, { $trips }
poker-straight-high = Ukulandelana okuphezulu kwe-{ $high }
poker-flush-high-with = Ukugcwala okuphezulu kwe-{ $high }, no-{ $rest }
poker-full-house = Indlu Egcwele, { $trips } phezu kwe-{ $pair }
poker-quads-with = Amane Ohlobo Olulodwa, { $quads }, no-{ $kicker }
poker-quads = Amane Ohlobo Olulodwa, { $quads }
poker-straight-flush-high = Ukugcwala Nokulandelana okuphezulu kwe-{ $high }
poker-unknown-hand = Isandla esingaziwa

# Validation errors (common across games)
game-error-invalid-team-mode = Imodi yethimba ekhethiwe ayivumelekile ngenani labadlali lamanje.

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
