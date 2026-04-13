# Mancala game messages — de
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Mulde { $pit }: { $stones } Steine

# Game events
mancala-sow = { $player } sät { $stones } Steine aus Mulde { $pit }
mancala-capture = { $player } erbeutet { $captured } Steine!
mancala-extra-turn = Letzter Stein im Speicher! { $player } ist nochmal dran.
mancala-winner = { $player } gewinnt mit { $score } Steinen!
mancala-draw = Unentschieden! Beide Spieler haben { $score } Steine.

# Board status
mancala-board-status =
    Deine Mulden: { $own_pits }. Dein Speicher: { $own_store }. Mulden des Gegners: { $opp_pits }. Speicher des Gegners: { $opp_store }.

# Options
mancala-set-stones = Steine pro Mulde: { $stones }
mancala-desc-stones = Anzahl der Steine in jeder Mulde zu Beginn
mancala-enter-stones = Gib die Anzahl der Startsteine pro Mulde ein:
mancala-option-changed-stones = Startsteine auf { $stones } geändert

# Disabled reasons
mancala-pit-empty = Diese Mulde ist leer.

# Rules
mancala-rules =
    Mancala ist ein Mulden- und Steinspiel für zwei Spieler.
    Jeder Spieler hat 6 Mulden und einen Speicher.
    Wähle in deinem Zug eine deiner Mulden zum Säen.
    Steine werden einzeln in jede Mulde rund um das Brett gelegt, einschließlich deines Speichers, aber der Speicher des Gegners wird übersprungen.
    Landet dein letzter Stein in deinem Speicher, bist du nochmal dran.
    Landet dein letzter Stein in einer leeren Mulde auf deiner Seite, erbeutest du diesen Stein und alle Steine in der gegenüberliegenden Mulde.
    Das Spiel endet, wenn eine Seite komplett leer ist. Verbleibende Steine gehen in den Speicher des jeweiligen Spielers.
    Der Spieler mit den meisten Steinen gewinnt.
    Benutze die Tasten 1 bis 6 um eine Mulde zu wählen. Drücke E um das Brett zu prüfen.

# End screen
mancala-final-score = { $player }: { $score } Steine
mancala-check-board = Check board
