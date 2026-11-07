# farkle.ftl for locale it. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-farkle = Farkle
# Actions - Roll and Bank
farkle-roll =
    Tira { $count } { $count ->
        [one] dado
       *[other] dadi
    }
farkle-bank = Banca { $points } punti
# Scoring combination actions (matching v10 exactly)
farkle-take-single-one = Singolo 1 per { $points } punti
farkle-take-single-five = Singolo 5 per { $points } punti
farkle-take-three-kind = Tre { $number } per { $points } punti
farkle-take-four-kind = Quattro { $number } per { $points } punti
farkle-take-five-kind = Cinque { $number } per { $points } punti
farkle-take-six-kind = Sei { $number } per { $points } punti
farkle-take-small-straight = Scala piccola per { $points } punti
farkle-take-large-straight = Scala grande per { $points } punti
farkle-take-three-pairs = Tre coppie per { $points } punti
farkle-take-double-triplets = Doppia tris per { $points } punti
farkle-take-full-house = Full house per { $points } punti
farkle-you-roll =
    Tiri { $count } { $count ->
        [one] dado
       *[other] dadi
    }...
farkle-roll-result = { $dice }
farkle-you-farkle = FARKLE! Perdi { $points } punti
farkle-you-take-combo = Prendi { $combo } per { $points } punti
farkle-you-bank = Banchi { $points } punti per un totale di { $total }
farkle-you-win = Vinci con { $score } punti!
farkle-winner = { $player } vince con { $score } punti!
farkle-winners-tie = Abbiamo un pareggio! Vincitori: { $players }
# Check turn score action
farkle-turn-score = { $player } ha { $points } punti in questo turno.
farkle-no-turn = Nessuno sta attualmente facendo un turno.
# Farkle-specific options
farkle-set-target-score = Punteggio obiettivo: { $score }
farkle-enter-target-score = Inserisci punteggio obiettivo (500-5000):
farkle-option-changed-target = Punteggio obiettivo impostato a { $score }.
# Disabled action reasons
farkle-must-take-combo = Devi prima prendere una combinazione di punteggio.
farkle-cannot-bank = Non puoi bancare ora.
