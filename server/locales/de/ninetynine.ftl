# ninetynine.ftl for locale de. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Spielnamen
game-name-ninetynine = Ninety Nine
# Runde
ninetynine-round = Runde { $round }.
# Karten spielen - stimmt genau mit v10 überein
ninetynine-you-play = Sie spielen { $card }. Der Zähler steht jetzt auf { $count }.
ninetynine-player-plays = { $player } spielt { $card }. Der Zähler steht jetzt auf { $count }.
# Richtungsumkehr
ninetynine-direction-reverses = Die Spielrichtung wird umgekehrt!
# Überspringen
ninetynine-player-skipped = { $player } wird übersprungen.
# Token-Verlust - stimmt genau mit v10 überein
ninetynine-you-lose-tokens =
    Sie verlieren { $amount } { $amount ->
        [one] Token
       *[other] Token
    }.
ninetynine-player-loses-tokens =
    { $player } verliert { $amount } { $amount ->
        [one] Token
       *[other] Token
    }.
# Eliminierung
ninetynine-player-eliminated = { $player } wurde eliminiert!
# Spielende
ninetynine-player-wins = { $player } gewinnt das Spiel!
# Karten ziehen
ninetynine-you-draw = Sie ziehen { $card }.
ninetynine-player-draws = { $player } zieht eine Karte.
# Keine gültigen Karten
ninetynine-no-valid-cards = { $player } hat keine Karten, die nicht über 99 gehen würden!
# Status - für C-Taste
ninetynine-current-count = Der Zähler steht auf { $count }.
# Ass-Auswahl
ninetynine-ace-choice = Ass als +1 oder +11 spielen?
ninetynine-ace-add-eleven = 11 addieren
ninetynine-ace-add-one = 1 addieren
# 10er-Auswahl
ninetynine-ten-choice = 10 als +10 oder -10 spielen?
ninetynine-ten-add = 10 addieren
ninetynine-ten-subtract = 10 subtrahieren
# Manuelles Ziehen
ninetynine-draw-card = Karte ziehen
ninetynine-draw-prompt = Drücken Sie Leertaste oder D, um eine Karte zu ziehen.
# Optionen
ninetynine-set-tokens = Start-Token: { $tokens }
ninetynine-enter-tokens = Anzahl der Start-Token eingeben:
ninetynine-option-changed-tokens = Start-Token auf { $tokens } gesetzt.
ninetynine-set-rules = Regelvariante: { $rules }
ninetynine-select-rules = Regelvariante auswählen
ninetynine-option-changed-rules = Regelvariante auf { $rules } gesetzt.
ninetynine-set-hand-size = Handgröße: { $size }
ninetynine-enter-hand-size = Handgröße eingeben:
ninetynine-option-changed-hand-size = Handgröße auf { $size } gesetzt.
ninetynine-set-autodraw = Automatisches Ziehen: { $enabled }
ninetynine-option-changed-autodraw = Automatisches Ziehen auf { $enabled } gesetzt.
# Gründe für deaktivierte Aktionen
ninetynine-choose-first = Sie müssen zuerst eine Auswahl treffen.
