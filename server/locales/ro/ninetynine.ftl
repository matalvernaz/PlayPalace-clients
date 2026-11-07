# ninetynine.ftl for locale ro. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game names
game-name-ninetynine = Nouăzeci și nouă
# Round
ninetynine-round = Runda { $round }.
# Playing cards - match v10 exactly
ninetynine-you-play = Jucați { $card }. Contorul este acum { $count }.
ninetynine-player-plays = { $player } joacă { $card }. Contorul este acum { $count }.
# Direction reverse
ninetynine-direction-reverses = Direcția jocului se inversează!
# Skip
ninetynine-player-skipped = { $player } este sărit.
# Token loss - match v10 exactly
ninetynine-you-lose-tokens =
    Pierdeți { $amount } { $amount ->
        [one] jeton
        [few] jetoane
       *[other] de jetoane
    }.
ninetynine-player-loses-tokens =
    { $player } pierde { $amount } { $amount ->
        [one] jeton
        [few] jetoane
       *[other] de jetoane
    }.
# Elimination
ninetynine-player-eliminated = { $player } a fost eliminat!
# Game end
ninetynine-player-wins = { $player } câștigă jocul!
# Drawing cards
ninetynine-you-draw = Trageți { $card }.
ninetynine-player-draws = { $player } trage o carte.
# No valid cards
ninetynine-no-valid-cards = { $player } nu are cărți care să nu treacă de 99!
# Status - for C key
ninetynine-current-count = Contorul este { $count }.
# Ace choice
ninetynine-ace-choice = Jucați Asul ca +1 sau +11?
ninetynine-ace-add-eleven = Adăugați 11
ninetynine-ace-add-one = Adăugați 1
# Ten choice
ninetynine-ten-choice = Jucați 10 ca +10 sau -10?
ninetynine-ten-add = Adăugați 10
ninetynine-ten-subtract = Scădeți 10
# Manual draw
ninetynine-draw-card = Trageți carte
ninetynine-draw-prompt = Apăsați Spațiu sau D pentru a trage o carte.
# Options
ninetynine-set-tokens = Jetoane inițiale: { $tokens }
ninetynine-enter-tokens = Introduceți numărul de jetoane inițiale:
ninetynine-option-changed-tokens = Jetoane inițiale setate la { $tokens }.
ninetynine-set-rules = Varianta regulilor: { $rules }
ninetynine-select-rules = Selectați varianta regulilor
ninetynine-option-changed-rules = Varianta regulilor setată la { $rules }.
ninetynine-set-hand-size = Dimensiunea mâinii: { $size }
ninetynine-enter-hand-size = Introduceți dimensiunea mâinii:
ninetynine-option-changed-hand-size = Dimensiunea mâinii setată la { $size }.
ninetynine-set-autodraw = Tragere automată: { $enabled }
ninetynine-option-changed-autodraw = Tragere automată setată la { $enabled }.
# Disabled action reasons
ninetynine-choose-first = Trebuie să faceți o alegere mai întâi.
