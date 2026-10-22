# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Deväťdesiatdeväť

# Round and turn flow
game-round-start = Kolo { $round }.
game-round-end = Kolo { $round } dokončené.
game-turn-start = { $player } je na ťahu.
game-your-turn = Si na ťahu.
game-no-turn = Momentálne nie je nikto na ťahu.

# Score display
game-scores-header = Aktuálne skóre:
game-score-line = { $player }: { $score } bodov
game-final-scores-header = Konečné skóre:

# Win/loss
game-winner = { $player } vyhráva!
game-winner-score = { $player } vyhráva s { $score } bodmi!
game-tiebreaker = Je to remíza! Rozhodujúce kolo!
game-tiebreaker-players = Je to remíza medzi { $players }! Rozhodujúce kolo!
game-eliminated = { $player } bol/a vyradený/á s { $score } bodmi.

# Common options
game-set-target-score = Cieľové skóre: { $score }
game-enter-target-score = Zadajte cieľové skóre:
game-option-changed-target = Cieľové skóre nastavené na { $score }.

game-set-team-mode = Tímový režim: { $mode }
game-select-team-mode = Vyberte tímový režim
game-option-changed-team = Tímový režim nastavený na { $mode }.
game-team-mode-individual = Individuálny
game-team-mode-x-teams-of-y = { $num_teams } tímov po { $team_size }

# Boolean option values
option-on = zapnuté
option-off = vypnuté

# Status box

# Game end
game-leave = Opustiť hru

# Round timer
round-timer-paused = { $player } pozastavil/a hru (stlačte p pre spustenie ďalšieho kola).
round-timer-resumed = Časovač kola obnovený.
round-timer-countdown = Ďalšie kolo za { $seconds }...

# Dice games - keeping/releasing dice
dice-keeping = Ponechávam { $value }.
dice-rerolling = Prehodím { $value }.
dice-locked = Táto kocka je uzamknutá a nemožno ju zmeniť.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Rozdávanie { $current }/{ $total }.
game-you-deal = Ty rozdávaš karty.
game-player-deals = { $player } rozdáva karty.

# Card names
card-name = { $rank } { $suit }
no-cards = Žiadne karty

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = čierna
color-black-m = čierny
color-black-f = čierna
color-blue = modrá
color-blue-m = modrý
color-blue-f = modrá
color-brown = hnedá
color-brown-m = hnedý
color-brown-f = hnedá
color-gray = šedá
color-gray-m = šedý
color-gray-f = šedá
color-green = zelená
color-green-m = zelený
color-green-f = zelená
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = oranžová
color-orange-m = oranžový
color-orange-f = oranžová
color-pink = ružová
color-pink-m = ružový
color-pink-f = ružová
color-purple = purpurová
color-purple-m = purpurový
color-purple-f = purpurová
color-red = červená
color-red-m = červený
color-red-f = červená
color-violet = fialová
color-violet-m = fialový
color-violet-f = fialová
color-white = biela
color-white-m = biely
color-white-f = biela
color-yellow = žltá
color-yellow-m = žltý
color-yellow-f = žltá

# Suit names
suit-diamonds = káro
suit-clubs = krížiky
suit-hearts = srdcia
suit-spades = píky

# Rank names
rank-ace = eso
rank-ace-plural = esá
rank-two = 2
rank-two-plural = dvojky
rank-three = 3
rank-three-plural = trojky
rank-four = 4
rank-four-plural = štvorky
rank-five = 5
rank-five-plural = päťky
rank-six = 6
rank-six-plural = šestky
rank-seven = 7
rank-seven-plural = sedmičky
rank-eight = 8
rank-eight-plural = osmičky
rank-nine = 9
rank-nine-plural = deviatky
rank-ten = 10
rank-ten-plural = desiatky
rank-jack = dolník
rank-jack-plural = dolníky
rank-queen = dáma
rank-queen-plural = dámy
rank-king = kráľ
rank-king-plural = králi

# Poker hand descriptions
poker-high-card-with = { $high } vysoká, s { $rest }
poker-high-card = { $high } vysoká
poker-pair-with = Pár { $pair }, s { $rest }
poker-pair = Pár { $pair }
poker-two-pair-with = Dva páry, { $high } a { $low }, s { $kicker }
poker-two-pair = Dva páry, { $high } a { $low }
poker-trips-with = Trojica, { $trips }, s { $rest }
poker-trips = Trojica, { $trips }
poker-straight-high = { $high } vysoký pokerový postup
poker-flush-high-with = { $high } vysoký flush, s { $rest }
poker-full-house = Full house, { $trips } nad { $pair }
poker-quads-with = Štvorica, { $quads }, s { $kicker }
poker-quads = Štvorica, { $quads }
poker-straight-flush-high = { $high } vysoký pokerový postup v jednej farbe
poker-unknown-hand = Neznáme karty

# Validation errors (common across games)
game-error-invalid-team-mode = Vybraný tímový režim nie je platný pre aktuálny počet hráčov.

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
