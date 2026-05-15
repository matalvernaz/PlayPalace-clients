# Crazy Eights

game-name-crazyeights = Crazy Eights

crazyeights-set-winning-score = Winning score: { $score }
crazyeights-enter-winning-score = Enter winning score
crazyeights-option-changed-winning-score = Winning score set to { $score }.

crazyeights-set-turn-timer = Turn timer: { $mode }
crazyeights-select-turn-timer = Select turn timer
crazyeights-option-changed-turn-timer = Turn timer set to { $mode }.

crazyeights-draw = Draw
crazyeights-pass = Pass
crazyeights-read-top = Read top card
crazyeights-read-counts = Read card counts
crazyeights-deck-count =
    { $count ->
        [one] Deck: 1 card.
       *[other] Deck: { $count } cards.
    }

crazyeights-new-hand = Round { $round }.
crazyeights-start-card = { $player } turns up { $card }.
crazyeights-you-turn-up = You turn up { $card }.
crazyeights-wild-played = { $player } played a Wild Eight.

crazyeights-no-players = No players.
crazyeights-no-hands = No hand in progress.
crazyeights-no-top = No top card.

# Card display names. The game's own name is "Crazy Eights" with a word,
# so the wild card uses the word too (style guide §7).
crazyeights-wild = Wild Eight
crazyeights-wild-suit = Wild Eight, { $suit }
crazyeights-reverse = Reverse, { $suit }
crazyeights-skip = Skip, { $suit }
crazyeights-draw-two = Draw Two, { $suit }

crazyeights-suit-chosen = { $suit }

crazyeights-round-summary = { $player } wins the round. { $details }. { $player } gains { $total } points.
crazyeights-you-win-round = You win the round. { $details }. You gain { $total } points.
crazyeights-round-details-none = No points were taken from opponents.
crazyeights-round-winner = { $player } wins { $points } points. { $detail }
crazyeights-round-points-from = { $points } from { $player }
crazyeights-dealt-cards = Everyone is dealt in with { $cards } cards.
crazyeights-one-card = 1 card.

crazyeights-game-winner = { $player } wins with { $score } points!
crazyeights-you-win-game = You win with { $score } points!

crazyeights-player-plays = { $player } plays { $card }.
crazyeights-you-play = You play { $card }.
crazyeights-player-draws-one = { $player } draws a card.
crazyeights-you-draw-one = You draw a card.
crazyeights-player-draws-many = { $player } draws { $count } cards.
crazyeights-you-draw-many = You draw { $count } cards.
crazyeights-player-passes = { $player } passes.
crazyeights-you-pass = You pass.

crazyeights-player-skipped = Skipping { $player }.
crazyeights-you-are-skipped = Skipping you.
