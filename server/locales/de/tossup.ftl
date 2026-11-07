# tossup.ftl for locale de. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Spielinformationen
game-name-tossup = Toss Up
# Aktionen
tossup-roll-first = { $count } Würfel würfeln
tossup-roll-remaining = { $count } verbleibende Würfel würfeln
tossup-bank = { $points } Punkte sichern
tossup-you-roll = Sie würfelten: { $results }.
tossup-player-rolls = { $player } würfelte: { $results }.
# Zugstatus
tossup-you-have-points = Zugpunkte: { $turn_points }. Verbleibende Würfel: { $dice_count }.
tossup-player-has-points = { $player } hat { $turn_points } Zugpunkte. { $dice_count } Würfel verbleiben.
# Frische Würfel
tossup-you-get-fresh = Keine Würfel mehr! Erhalte { $count } frische Würfel.
tossup-player-gets-fresh = { $player } erhält { $count } frische Würfel.
# Fehlschlag
tossup-you-bust = Fehlschlag! Sie verlieren { $points } Punkte für diesen Zug.
tossup-player-busts = { $player } schlägt fehl und verliert { $points } Punkte!
# Sichern
tossup-you-bank = Sie sichern { $points } Punkte. Gesamtpunktzahl: { $total }.
tossup-player-banks = { $player } sichert { $points } Punkte. Gesamtpunktzahl: { $total }.
# Gewinner
tossup-winner = { $player } gewinnt mit { $score } Punkten!
tossup-tie-tiebreaker = Es ist ein Unentschieden zwischen { $players }! Entscheidungsrunde!
# Optionen
tossup-set-rules-variant = Regelvariante: { $variant }
tossup-select-rules-variant = Regelvariante auswählen:
tossup-option-changed-rules = Regelvariante auf { $variant } geändert
tossup-set-starting-dice = Startwürfel: { $count }
tossup-enter-starting-dice = Anzahl der Startwürfel eingeben:
tossup-option-changed-dice = Startwürfel auf { $count } geändert
# Regelvarianten
tossup-rules-standard = Standard
# Regelerklärungen
tossup-rules-standard-desc = 3 grün, 2 gelb, 1 rot pro Würfel. Fehlschlag, wenn keine Grünen und mindestens ein Roter.
