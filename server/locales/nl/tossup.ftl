# tossup.ftl for locale nl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-tossup = Toss Up
# Actions
tossup-roll-first = Gooi { $count } dobbelstenen
tossup-roll-remaining = Gooi { $count } overgebleven dobbelstenen
tossup-bank = Bank { $points } punten
tossup-you-roll = Je gooide: { $results }.
tossup-player-rolls = { $player } gooide: { $results }.
# Turn status
tossup-you-have-points = Beurtpunten: { $turn_points }. Dobbelstenen over: { $dice_count }.
tossup-player-has-points = { $player } heeft { $turn_points } beurtpunten. { $dice_count } dobbelstenen over.
# Fresh dice
tossup-you-get-fresh = Geen dobbelstenen meer! Je krijgt { $count } verse dobbelstenen.
tossup-player-gets-fresh = { $player } krijgt { $count } verse dobbelstenen.
# Bust
tossup-you-bust = Bust! Je verliest { $points } punten voor deze beurt.
tossup-player-busts = { $player } bust en verliest { $points } punten!
# Bank
tossup-you-bank = Je bankt { $points } punten. Totale score: { $total }.
tossup-player-banks = { $player } bankt { $points } punten. Totale score: { $total }.
# Winner
tossup-winner = { $player } wint met { $score } punten!
tossup-tie-tiebreaker = Het is gelijk tussen { $players }! Tie-breaker ronde!
# Options
tossup-set-rules-variant = Regelsvariant: { $variant }
tossup-select-rules-variant = Selecteer regelsvariant:
tossup-option-changed-rules = Regelsvariant gewijzigd naar { $variant }
tossup-set-starting-dice = Startdobbelstenen: { $count }
tossup-enter-starting-dice = Voer het aantal startdobbelstenen in:
tossup-option-changed-dice = Startdobbelstenen gewijzigd naar { $count }
# Rules variants
tossup-rules-standard = Standaard
# Rules explanations
tossup-rules-standard-desc = 3 groen, 2 geel, 1 rood per dobbelsteen. Bust als geen groenen en tenminste één rood.
