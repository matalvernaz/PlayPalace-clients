# Shared game messages for PlayPalace
# These messages are common across multiple games

# Game names
game-name-ninetynine = Kilencvenkilenc

# Round and turn flow
game-round-start = { $round }. kör.
game-round-end = { $round }. kör befejezve.
game-turn-start = { $player } következik.
game-your-turn = Te következel.
game-no-turn = Most senki sem következik.

# Score display
game-scores-header = Jelenlegi pontszámok:
game-score-line = { $player }: { $score } pont
game-final-scores-header = Végső pontszámok:

# Win/loss
game-winner = { $player } nyert!
game-winner-score = { $player } nyert { $score } ponttal!
game-tiebreaker = Döntetlen! Döntő kör!
game-tiebreaker-players = Döntetlen { $players } között! Döntő kör!
game-eliminated = { $player } kiesett { $score } ponttal.

# Common options
game-set-target-score = Célpontszám: { $score }
game-enter-target-score = Add meg a célpontszámot:
game-option-changed-target = Célpontszám beállítva: { $score }.

game-set-team-mode = Csapat mód: { $mode }
game-select-team-mode = Válaszd ki a csapat módot
game-option-changed-team = Csapat mód beállítva: { $mode }.
game-team-mode-individual = Egyéni
game-team-mode-x-teams-of-y = { $num_teams } csapat, egyenként { $team_size } fővel

# Boolean option values
option-on = be
option-off = ki

# Status box

# Game end
game-leave = Játék elhagyása

# Round timer
round-timer-paused = { $player } szüneteltette a játékot (nyomd meg a p-t a következő kör indításához).
round-timer-resumed = Kör időzítő folytatva.
round-timer-countdown = Következő kör { $seconds } másodperc múlva...

# Dice games - keeping/releasing dice
dice-keeping = { $value } megtartása.
dice-rerolling = { $value } újradobása.
dice-locked = Ez a kocka zárolva van és nem változtatható meg.
dice-status-locked = locked
dice-status-kept = kept

# Dealing (card games)
game-deal-counter = Osztás { $current }/{ $total }.
game-you-deal = Te osztasz.
game-player-deals = { $player } oszt.

# Card names
card-name = { $suit } { $rank }
no-cards = Nincsenek kártyák

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = fekete
color-black-m = fekete
color-black-f = fekete
color-blue = kék
color-blue-m = kék
color-blue-f = kék
color-brown = barna
color-brown-m = barna
color-brown-f = barna
color-gray = szürke
color-gray-m = szürke
color-gray-f = szürke
color-green = zöld
color-green-m = zöld
color-green-f = zöld
color-indigo = indigó
color-indigo-m = indigó
color-indigo-f = indigó
color-orange = narancssárga
color-orange-m = narancssárga
color-orange-f = narancssárga
color-pink = rózsaszín
color-pink-m = rózsaszín
color-pink-f = rózsaszín
color-purple = lila
color-purple-m = lila
color-purple-f = lila
color-red = piros
color-red-m = piros
color-red-f = piros
color-violet = ibolya
color-violet-m = ibolya
color-violet-f = ibolya
color-white = fehér
color-white-m = fehér
color-white-f = fehér
color-yellow = sárga
color-yellow-m = sárga
color-yellow-f = sárga

# Suit names
suit-diamonds = káró
suit-clubs = treff
suit-hearts = kőr
suit-spades = pikk

# Rank names
rank-ace = ász
rank-ace-plural = ászok
rank-two = 2
rank-two-plural = ketesek
rank-three = 3
rank-three-plural = hármasok
rank-four = 4
rank-four-plural = négyesek
rank-five = 5
rank-five-plural = ötösök
rank-six = 6
rank-six-plural = hatosok
rank-seven = 7
rank-seven-plural = hetesek
rank-eight = 8
rank-eight-plural = nyolcasok
rank-nine = 9
rank-nine-plural = kilencesek
rank-ten = 10
rank-ten-plural = tízesek
rank-jack = bubi
rank-jack-plural = bubik
rank-queen = dáma
rank-queen-plural = dámák
rank-king = király
rank-king-plural = királyok

# Poker hand descriptions
poker-high-card-with = { $high } magas, { $rest }-val
poker-high-card = { $high } magas
poker-pair-with = Pár { $pair }, { $rest }-val
poker-pair = Pár { $pair }
poker-two-pair-with = Két pár, { $high } és { $low }, { $kicker }-val
poker-two-pair = Két pár, { $high } és { $low }
poker-trips-with = Drill, { $trips }, { $rest }-val
poker-trips = Drill, { $trips }
poker-straight-high = { $high } magas sor
poker-flush-high-with = { $high } magas flush, { $rest }-val
poker-full-house = Full house, { $trips } és { $pair }
poker-quads-with = Póker, { $quads }, { $kicker }-val
poker-quads = Póker, { $quads }
poker-straight-flush-high = { $high } magas színsor
poker-unknown-hand = Ismeretlen lap

# Validation errors (common across games)
game-error-invalid-team-mode = A kiválasztott csapat mód nem érvényes a jelenlegi játékosszám mellett.

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
