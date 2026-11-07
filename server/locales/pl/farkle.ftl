# farkle.ftl for locale pl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-farkle = Farkle
# Actions - Roll and Bank
farkle-roll =
    Rzuć { $count } { $count ->
        [one] kostką
       *[other] kostkami
    }
farkle-bank = Bankuj { $points } punktów
# Scoring combination actions (matching v10 exactly)
farkle-take-single-one = Single 1 for { $points } points
farkle-take-single-five = Single 5 for { $points } points
farkle-take-three-kind = Three { $number }s for { $points } points
farkle-take-four-kind = Four { $number }s for { $points } points
farkle-take-five-kind = Five { $number }s for { $points } points
farkle-take-six-kind = Six { $number }s for { $points } points
farkle-take-small-straight = Small Straight for { $points } points
farkle-take-large-straight = Large Straight for { $points } points
farkle-take-three-pairs = Three pairs for { $points } points
farkle-take-double-triplets = Double triplets for { $points } points
farkle-take-full-house = Full house for { $points } points
farkle-you-roll =
    Rzucasz { $count } { $count ->
        [one] kostką
       *[other] kostkami
    }...
farkle-roll-result = { $dice }
farkle-you-farkle = FARKLE! Tracisz { $points } punktów
farkle-you-take-combo = Bierzesz { $combo } za { $points } punktów
farkle-you-bank = Bankujesz { $points } punktów, łącznie masz { $total }
farkle-you-win = Wygrywasz z wynikiem { $score } punktów!
farkle-winner = { $player } wygrywa z wynikiem { $score } punktów!
farkle-winners-tie = Mamy remis! Wygrywają: { $players }
# Check turn score action
farkle-turn-score = { $player } ma { $points } punktów w tej turze.
farkle-no-turn = Obecnie nikt nie ma tury.
# Farkle-specific options
farkle-set-target-score = Maksymalna liczba punktów: { $score }
farkle-enter-target-score = Podaj maksymalną liczbę punktów (między 500 a 5000):
farkle-option-changed-target = Maksymalna liczba punktów została ustawiona na { $score }.
# Disabled action reasons
farkle-must-take-combo = Najpierw musisz wybrać punktującą kombinację.
farkle-cannot-bank = Nie możesz teraz zabankować.
