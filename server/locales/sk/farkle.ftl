# farkle.ftl for locale sk. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-farkle = Farkle
# Actions - Roll and Bank
farkle-roll =
    Hodiť { $count } { $count ->
        [one] kockou
        [few] kockami
        [many] kockami
       *[other] kockami
    }
farkle-bank = Uložiť { $points } bodov
# Scoring combination actions (matching v10 exactly)
farkle-take-single-one = Jedno 1 za { $points } bodov
farkle-take-single-five = Jedno 5 za { $points } bodov
farkle-take-three-kind = Tri { $number } za { $points } bodov
farkle-take-four-kind = Štyri { $number } za { $points } bodov
farkle-take-five-kind = Päť { $number } za { $points } bodov
farkle-take-six-kind = Šesť { $number } za { $points } bodov
farkle-take-small-straight = Malý rad za { $points } bodov
farkle-take-large-straight = Veľký rad za { $points } bodov
farkle-take-three-pairs = Tri páry za { $points } bodov
farkle-take-double-triplets = Dvojité trojice za { $points } bodov
farkle-take-full-house = Plný dom za { $points } bodov
farkle-you-roll =
    Hodíte { $count } { $count ->
        [one] kockou
        [few] kockami
        [many] kockami
       *[other] kockami
    }...
farkle-roll-result = { $dice }
farkle-you-farkle = FARKLE! Strácate { $points } bodov
farkle-you-take-combo = Beriete { $combo } za { $points } bodov
farkle-you-bank = Ukladáte { $points } bodov pre celkom { $total }
farkle-you-win = Vyhrávate s { $score } bodmi!
farkle-winner = { $player } vyhráva s { $score } bodmi!
farkle-winners-tie = Máme remízu! Víťazi: { $players }
# Check turn score action
farkle-turn-score = { $player } má { $points } bodov v tomto ťahu.
farkle-no-turn = Momentálne nikto nie je na ťahu.
# Farkle-specific options
farkle-set-target-score = Cieľové skóre: { $score }
farkle-enter-target-score = Zadajte cieľové skóre (500-5000):
farkle-option-changed-target = Cieľové skóre nastavené na { $score }.
# Disabled action reasons
farkle-must-take-combo = Musíte najprv vziať bodovú kombináciu.
farkle-cannot-bank = Momentálne nemôžete uložiť.
