# Sdílené herní zprávy pro PlayPalace
# Tyto zprávy jsou společné pro více her

# Názvy her
game-name-ninetynine = Devadesát devět

# Průběh kol a tahů
game-round-start = Kolo { $round }.
game-round-end = Kolo { $round } dokončeno.
game-turn-start = Tah hráče { $player }.
game-your-turn = Váš tah.
game-no-turn = Momentálně není tah nikoho.

# Zobrazení skóre
game-scores-header = Aktuální skóre:
game-score-line = { $player }: { $score } bodů
game-final-scores-header = Konečné skóre:

# Výhra/prohra
game-winner = { $player } vyhrává!
game-winner-score = { $player } vyhrává s { $score } body!
game-tiebreaker = Remíza! Rozhodující kolo!
game-tiebreaker-players = Remíza mezi { $players }! Rozhodující kolo!
game-eliminated = { $player } byl vyřazen s { $score } body.

# Běžné možnosti
game-set-target-score = Cílové skóre: { $score }
game-enter-target-score = Zadejte cílové skóre:
game-option-changed-target = Cílové skóre nastaveno na { $score }.

game-set-team-mode = Týmový režim: { $mode }
game-select-team-mode = Vyberte týmový režim
game-option-changed-team = Týmový režim nastaven na { $mode }.
game-team-mode-individual = Individuální
game-team-mode-x-teams-of-y = { $num_teams } týmů po { $team_size }

# Hodnoty booleovských možností
option-on = zapnuto
option-off = vypnuto

# Stavové okno

# Konec hry
game-leave = Opustit hru

# Časovač kola
round-timer-paused = { $player } pozastavil hru (stiskněte p pro start dalšího kola).
round-timer-resumed = Časovač kola obnoven.
round-timer-countdown = Další kolo za { $seconds }...

# Kostky - držení/uvolňování kostek
dice-keeping = Držení { $value }.
dice-rerolling = Přehození { $value }.
dice-locked = Tato kostka je uzamčena a nelze ji změnit.
dice-status-locked = locked
dice-status-kept = kept

# Rozdávání (karetní hry)
game-deal-counter = Rozdání { $current }/{ $total }.
game-you-deal = Rozdáváte karty.
game-player-deals = { $player } rozdává karty.

# Názvy karet
card-name = { $rank } { $suit }
no-cards = Žádné karty

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = černá
color-black-m = černý
color-black-f = černá
color-blue = modrá
color-blue-m = modrý
color-blue-f = modrá
color-brown = hnědá
color-brown-m = hnědý
color-brown-f = hnědá
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
color-pink = růžová
color-pink-m = růžový
color-pink-f = růžová
color-purple = purpurová
color-purple-m = purpurový
color-purple-f = purpurová
color-red = červená
color-red-m = červený
color-red-f = červená
color-violet = fialová
color-violet-m = fialový
color-violet-f = fialová
color-white = bílá
color-white-m = bílý
color-white-f = bílá
color-yellow = žlutá
color-yellow-m = žlutý
color-yellow-f = žlutá

# Názvy barev
suit-diamonds = kárové
suit-clubs = křížové
suit-hearts = srdcové
suit-spades = pikové

# Názvy hodnot
rank-ace = eso
rank-ace-plural = esa
rank-two = 2
rank-two-plural = dvojky
rank-three = 3
rank-three-plural = trojky
rank-four = 4
rank-four-plural = čtyřky
rank-five = 5
rank-five-plural = pětky
rank-six = 6
rank-six-plural = šestky
rank-seven = 7
rank-seven-plural = sedmičky
rank-eight = 8
rank-eight-plural = osmičky
rank-nine = 9
rank-nine-plural = devítky
rank-ten = 10
rank-ten-plural = desítky
rank-jack = spodek
rank-jack-plural = spodky
rank-queen = dáma
rank-queen-plural = dámy
rank-king = král
rank-king-plural = králové

# Popisy pokerových rukou
poker-high-card-with = { $high } nejvyšší, s { $rest }
poker-high-card = { $high } nejvyšší
poker-pair-with = Pár { $pair }, s { $rest }
poker-pair = Pár { $pair }
poker-two-pair-with = Dva páry, { $high } a { $low }, s { $kicker }
poker-two-pair = Dva páry, { $high } a { $low }
poker-trips-with = Trojice, { $trips }, s { $rest }
poker-trips = Trojice, { $trips }
poker-straight-high = { $high } vysoká postupka
poker-flush-high-with = { $high } vysoký flush, s { $rest }
poker-full-house = Full house, { $trips } nad { $pair }
poker-quads-with = Čtyřice, { $quads }, s { $kicker }
poker-quads = Čtyřice, { $quads }
poker-straight-flush-high = { $high } vysoký straight flush
poker-unknown-hand = Neznámá ruka

# Chyby validace (společné pro hry)
game-error-invalid-team-mode = Vybraný týmový režim není platný pro aktuální počet hráčů.

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
