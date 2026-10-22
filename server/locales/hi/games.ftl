# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = नाइंटी नाइन

# Round and turn flow
game-round-start = राउंड { $round }।
game-round-end = राउंड { $round } पूरा।
game-turn-start = { $player } की बारी।
game-your-turn = आपकी बारी।
game-no-turn = अभी किसी की बारी नहीं।

# Score display
game-scores-header = वर्तमान स्कोर:
game-score-line = { $player }: { $score } अंक
game-final-scores-header = अंतिम स्कोर:

# Win/loss
game-winner = { $player } जीतते हैं!
game-winner-score = { $player } { $score } अंकों के साथ जीतते हैं!
game-tiebreaker = बराबरी है! टाइब्रेकर राउंड!
game-tiebreaker-players = { $players } के बीच बराबरी है! टाइब्रेकर राउंड!
game-eliminated = { $player } { $score } अंकों के साथ बाहर हो गए हैं।

# Common options
game-set-target-score = लक्ष्य स्कोर: { $score }
game-enter-target-score = लक्ष्य स्कोर दर्ज करें:
game-option-changed-target = लक्ष्य स्कोर { $score } पर सेट किया गया।

game-set-team-mode = टीम मोड: { $mode }
game-select-team-mode = टीम मोड चुनें
game-option-changed-team = टीम मोड { $mode } पर सेट किया गया।
game-team-mode-individual = व्यक्तिगत
game-team-mode-x-teams-of-y = { $team_size } की { $num_teams } टीमें

# Boolean option values
option-on = चालू
option-off = बंद

# Status box

# Game end
game-leave = खेल छोड़ें

# Round timer
round-timer-paused = { $player } ने खेल को रोक दिया है (अगला राउंड शुरू करने के लिए p दबाएं)।
round-timer-resumed = राउंड टाइमर फिर से शुरू हुआ।
round-timer-countdown = अगला राउंड { $seconds } में...

# Dice games - keeping/releasing dice
dice-keeping = { $value } को रख रहे हैं।
dice-rerolling = { $value } को फिर से रोल कर रहे हैं।
dice-locked = वह पासा बंद है और बदला नहीं जा सकता।
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = बांटें { $current }/{ $total }।
game-you-deal = आप पत्ते बांटते हैं।
game-player-deals = { $player } पत्ते बांटते हैं।

# Card names
card-name = { $suit } का { $rank }
no-cards = कोई पत्ते नहीं

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = काला
color-black-m = काला
color-black-f = काली
color-blue = नीला
color-blue-m = नीला
color-blue-f = नीली
color-brown = भूरा
color-brown-m = भूरा
color-brown-f = भूरी
color-gray = धूसर
color-gray-m = धूसर
color-gray-f = धूसर
color-green = हरा
color-green-m = हरा
color-green-f = हरी
color-indigo = नील
color-indigo-m = नील
color-indigo-f = नील
color-orange = नारंगी
color-orange-m = नारंगी
color-orange-f = नारंगी
color-pink = गुलाबी
color-pink-m = गुलाबी
color-pink-f = गुलाबी
color-purple = बैंगनी
color-purple-m = बैंगनी
color-purple-f = बैंगनी
color-red = लाल
color-red-m = लाल
color-red-f = लाल
color-violet = बैंगनी
color-violet-m = बैंगनी
color-violet-f = बैंगनी
color-white = सफ़ेद
color-white-m = सफ़ेद
color-white-f = सफ़ेद
color-yellow = पीला
color-yellow-m = पीला
color-yellow-f = पीली

# Suit names
suit-diamonds = हीरा
suit-clubs = चिड़ी
suit-hearts = पान
suit-spades = हुकुम

# Rank names
rank-ace = इक्का
rank-ace-plural = इक्के
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
rank-jack = गुलाम
rank-jack-plural = गुलाम
rank-queen = बेगम
rank-queen-plural = बेगम
rank-king = बादशाह
rank-king-plural = बादशाह

# Poker hand descriptions
poker-high-card-with = { $high } हाई, { $rest } के साथ
poker-high-card = { $high } हाई
poker-pair-with = { $pair } की जोड़ी, { $rest } के साथ
poker-pair = { $pair } की जोड़ी
poker-two-pair-with = दो जोड़ी, { $high } और { $low }, { $kicker } के साथ
poker-two-pair = दो जोड़ी, { $high } और { $low }
poker-trips-with = तीन एक तरह के, { $trips }, { $rest } के साथ
poker-trips = तीन एक तरह के, { $trips }
poker-straight-high = { $high } हाई स्ट्रेट
poker-flush-high-with = { $high } हाई फ्लश, { $rest } के साथ
poker-full-house = फुल हाउस, { $trips } { $pair } के ऊपर
poker-quads-with = चार एक तरह के, { $quads }, { $kicker } के साथ
poker-quads = चार एक तरह के, { $quads }
poker-straight-flush-high = { $high } हाई स्ट्रेट फ्लश
poker-unknown-hand = अज्ञात हाथ

# Validation errors (common across games)
game-error-invalid-team-mode = चयनित टीम मोड वर्तमान खिलाड़ियों की संख्या के लिए मान्य नहीं है।

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
