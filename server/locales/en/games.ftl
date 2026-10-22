# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Ninety Nine
game-name-humanitycards = Cards Against Humanity

# Game categories (shared)
category-party-games = Party Games

# Round and turn flow
game-round-start = Round { $round }.
game-round-end = Round { $round } complete.
game-turn-start = { $player }'s turn.
game-your-turn = Your turn.
game-no-turn = No one's turn right now.

# Score display
game-scores-header = Current Scores:
game-score-line = { $player }: { $score } points
game-final-scores-header = Final Scores:

# Win/loss
game-winner = { $player } wins!
game-winner-score = { $player } wins with { $score } points!
game-tiebreaker = It's a tie! Tiebreaker round!
game-tiebreaker-players = It's a tie between { $players }! Tiebreaker round!
game-eliminated = { $player } has been eliminated with { $score } points.

# Common options
game-set-target-score = Target score: { $score }
game-enter-target-score = Enter target score:
game-option-changed-target = Target score set to { $score }.

game-set-team-mode = Team mode: { $mode }
game-select-team-mode = Select team mode
game-option-changed-team = Team mode set to { $mode }.
game-team-mode-individual = Individual
game-team-mode-x-teams-of-y = { $num_teams } teams of { $team_size }

# Boolean option values
option-on = on
option-off = off

# Option navigation
option-back = Back
option-min-selected = At least { $count } { $count ->
    [one] item
   *[other] items
} must be selected.
option-max-selected = At most { $count } { $count ->
    [one] item
   *[other] items
} can be selected.
option-select-all = Select all
option-deselect-all = Deselect all
option-selected-count = { $count } { $count ->
    [one] item
   *[other] items
} selected.
option-deselected-count = { $count } { $count ->
    [one] item
   *[other] items
} deselected.

# Status box

# Game end
game-leave = Leave game

# Round timer
round-timer-paused = { $player } has paused the game (press p to start the next round).
round-timer-resumed = Round timer resumed.
round-timer-countdown = Next round in { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Keeping { $value }.
dice-rerolling = Rerolling { $value }.
dice-locked = That die is locked and cannot be changed.
dice-status-locked = locked
dice-status-kept = kept

# Dice games — shared roll-event keys.
# Use these from broadcast_personal_l so the active player hears "You..."
# and everyone else hears "{ $player }...". Both forms include the result
# and the running total so a player who just heard one announcement has
# all the context they need.
dice-you-rolled = You rolled { $roll }. Round total: { $total }.
dice-player-rolled = { $player } rolled { $roll }. Round total: { $total }.
dice-rolls-remaining = Rolls remaining: { $remaining }.

# Dealing (card games)
game-deal-counter = Deal { $current }/{ $total }.
game-you-deal = You deal out the cards.
game-player-deals = { $player } deals out the cards.

# Card names
card-name = { $rank } of { $suit }
no-cards = No cards

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = black
color-black-m = black
color-black-f = black
color-blue = blue
color-blue-m = blue
color-blue-f = blue
color-brown = brown
color-brown-m = brown
color-brown-f = brown
color-gray = gray
color-gray-m = gray
color-gray-f = gray
color-green = green
color-green-m = green
color-green-f = green
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = orange
color-orange-m = orange
color-orange-f = orange
color-pink = pink
color-pink-m = pink
color-pink-f = pink
color-purple = purple
color-purple-m = purple
color-purple-f = purple
color-red = red
color-red-m = red
color-red-f = red
color-violet = violet
color-violet-m = violet
color-violet-f = violet
color-white = white
color-white-m = white
color-white-f = white
color-yellow = yellow
color-yellow-m = yellow
color-yellow-f = yellow

# Suit names
suit-diamonds = diamonds
suit-clubs = clubs
suit-hearts = hearts
suit-spades = spades

# Rank names
rank-ace = ace
rank-ace-plural = aces
rank-two = 2
rank-two-plural = 2s
rank-three = 3
rank-three-plural = 3s
rank-four = 4
rank-four-plural = 4s
rank-five = 5
rank-five-plural = 5s
rank-six = 6
rank-six-plural = 6s
rank-seven = 7
rank-seven-plural = 7s
rank-eight = 8
rank-eight-plural = 8s
rank-nine = 9
rank-nine-plural = 9s
rank-ten = 10
rank-ten-plural = 10s
rank-jack = jack
rank-jack-plural = jacks
rank-queen = queen
rank-queen-plural = queens
rank-king = king
rank-king-plural = kings
rank-joker = joker
rank-joker-plural = jokers

# Shapes
shape-circle = circle
shape-cone = cone
shape-cylinder = cylinder
shape-hexagon = hexagon
shape-oval = oval
shape-pentagon = pentagon
shape-prism = prism
shape-rectangle = rectangle
shape-square = square
shape-triangle = triangle

# Poker hand descriptions
poker-high-card-with = { $high } high, with { $rest }
poker-high-card = { $high } high
poker-pair-with = Pair of { $pair }, with { $rest }
poker-pair = Pair of { $pair }
poker-two-pair-with = Two Pair, { $high } and { $low }, with { $kicker }
poker-two-pair = Two Pair, { $high } and { $low }
poker-trips-with = Three of a Kind, { $trips }, with { $rest }
poker-trips = Three of a Kind, { $trips }
poker-straight-high = { $high } high Straight
poker-flush-high-with = { $high } high Flush, with { $rest }
poker-full-house = Full House, { $trips } over { $pair }
poker-quads-with = Four of a Kind, { $quads }, with { $kicker }
poker-quads = Four of a Kind, { $quads }
poker-straight-flush-high = { $high } high Straight Flush
poker-unknown-hand = Unknown hand

# Validation errors (common across games)
game-error-invalid-team-mode = The selected team mode is not valid for the current number of players.

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
