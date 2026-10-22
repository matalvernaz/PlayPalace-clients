# Gemeinsame Spielnachrichten für PlayPalace
# Diese Nachrichten sind über mehrere Spiele hinweg gebräuchlich

# Spielnamen
game-name-ninetynine = Ninety Nine

# Runden- und Zugablauf
game-round-start = Runde { $round }.
game-round-end = Runde { $round } abgeschlossen.
game-turn-start = { $player } ist am Zug.
game-your-turn = Sie sind am Zug.
game-no-turn = Momentan ist niemand am Zug.

# Punkteanzeige
game-scores-header = Aktuelle Punktzahlen:
game-score-line = { $player }: { $score } Punkte
game-final-scores-header = Endpunktzahlen:

# Sieg/Niederlage
game-winner = { $player } gewinnt!
game-winner-score = { $player } gewinnt mit { $score } Punkten!
game-tiebreaker = Es ist ein Unentschieden! Entscheidungsrunde!
game-tiebreaker-players = Es ist ein Unentschieden zwischen { $players }! Entscheidungsrunde!
game-eliminated = { $player } wurde mit { $score } Punkten eliminiert.

# Gemeinsame Optionen
game-set-target-score = Zielpunktzahl: { $score }
game-enter-target-score = Zielpunktzahl eingeben:
game-option-changed-target = Zielpunktzahl auf { $score } gesetzt.

game-set-team-mode = Teammodus: { $mode }
game-select-team-mode = Teammodus auswählen
game-option-changed-team = Teammodus auf { $mode } gesetzt.
game-team-mode-individual = Einzelspieler
game-team-mode-x-teams-of-y = { $num_teams } Teams à { $team_size }

# Boolesche Optionswerte
option-on = an
option-off = aus

# Statusbox

# Spielende
game-leave = Spiel verlassen

# Rundenzeitmesser
round-timer-paused = { $player } hat das Spiel pausiert (drücken Sie P, um die nächste Runde zu starten).
round-timer-resumed = Rundenzeitmesser fortgesetzt.
round-timer-countdown = Nächste Runde in { $seconds }...

# Würfelspiele - Würfel behalten/neu werfen
dice-keeping = { $value } behalten.
dice-rerolling = { $value } neu würfeln.
dice-locked = Dieser Würfel ist gesperrt und kann nicht geändert werden.
dice-status-locked = locked
dice-status-kept = kept

# Austeilen (Kartenspiele)
game-deal-counter = Ausgabe { $current }/{ $total }.
game-you-deal = Sie teilen die Karten aus.
game-player-deals = { $player } teilt die Karten aus.

# Kartennamen
card-name = { $rank } { $suit }
no-cards = Keine Karten

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = schwarz
color-black-m = schwarzer
color-black-f = schwarze
color-blue = blau
color-blue-m = blauer
color-blue-f = blaue
color-brown = braun
color-brown-m = brauner
color-brown-f = braune
color-gray = grau
color-gray-m = grauer
color-gray-f = graue
color-green = grün
color-green-m = grüner
color-green-f = grüne
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = orange
color-orange-m = orange
color-orange-f = orange
color-pink = pink
color-pink-m = pink
color-pink-f = pink
color-purple = lila
color-purple-m = lila
color-purple-f = lila
color-red = rot
color-red-m = roter
color-red-f = rote
color-violet = violett
color-violet-m = violetter
color-violet-f = violette
color-white = weiß
color-white-m = weißer
color-white-f = weiße
color-yellow = gelb
color-yellow-m = gelber
color-yellow-f = gelbe

# Farbennamen
suit-diamonds = Karo
suit-clubs = Kreuz
suit-hearts = Herz
suit-spades = Pik

# Rangbezeichnungen
rank-ace = Ass
rank-ace-plural = Asse
rank-two = 2
rank-two-plural = 2en
rank-three = 3
rank-three-plural = 3en
rank-four = 4
rank-four-plural = 4en
rank-five = 5
rank-five-plural = 5en
rank-six = 6
rank-six-plural = 6en
rank-seven = 7
rank-seven-plural = 7en
rank-eight = 8
rank-eight-plural = 8en
rank-nine = 9
rank-nine-plural = 9en
rank-ten = 10
rank-ten-plural = 10en
rank-jack = Bube
rank-jack-plural = Buben
rank-queen = Dame
rank-queen-plural = Damen
rank-king = König
rank-king-plural = Könige

# Poker-Blattbeschreibungen
poker-high-card-with = { $high } hoch, mit { $rest }
poker-high-card = { $high } hoch
poker-pair-with = Ein Paar { $pair }, mit { $rest }
poker-pair = Ein Paar { $pair }
poker-two-pair-with = Zwei Paare, { $high } und { $low }, mit { $kicker }
poker-two-pair = Zwei Paare, { $high } und { $low }
poker-trips-with = Drilling { $trips }, mit { $rest }
poker-trips = Drilling { $trips }
poker-straight-high = Straße bis { $high }
poker-flush-high-with = Flush bis { $high }, mit { $rest }
poker-full-house = Full House, { $trips } über { $pair }
poker-quads-with = Vierling { $quads }, mit { $kicker }
poker-quads = Vierling { $quads }
poker-straight-flush-high = Straight Flush bis { $high }
poker-unknown-hand = Unbekanntes Blatt

# Validierungsfehler (spielübergreifend)
game-error-invalid-team-mode = Der gewählte Teammodus ist für die aktuelle Spielerzahl nicht gültig.

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
