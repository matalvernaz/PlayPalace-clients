# Mancala game messages — pl
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = Dołek { $pit }: { $stones } kamieni

# Game events
mancala-sow = { $player } sieje { $stones } kamieni z dołka { $pit }
mancala-capture = { $player } przechwytuje { $captured } kamieni!
mancala-extra-turn = Ostatni kamień w magazynie! { $player } gra ponownie.
mancala-winner = { $player } wygrywa z { $score } kamieniami!
mancala-draw = Remis! Obaj gracze mają { $score } kamieni.

# Board status
mancala-board-status =
    Twoje dołki: { $own_pits }. Twój magazyn: { $own_store }. Dołki przeciwnika: { $opp_pits }. Magazyn przeciwnika: { $opp_store }.

# Options
mancala-set-stones = Kamieni na dołek: { $stones }
mancala-desc-stones = Liczba kamieni w każdym dołku na początku
mancala-enter-stones = Podaj liczbę początkowych kamieni na dołek:
mancala-option-changed-stones = Początkowe kamienie zmienione na { $stones }

# Disabled reasons
mancala-pit-empty = Ten dołek jest pusty.

# Rules
mancala-rules =
    Mankala to gra w dołki i kamienie dla dwóch graczy.
    Każdy gracz ma 6 dołków i magazyn.
    W swojej turze wybierz jeden z dołków do siania.
    Kamienie są kładzione po jednym w każdy dołek dookoła planszy, włącznie z twoim magazynem, ale pomijając magazyn przeciwnika.
    Jeśli ostatni kamień wpadnie do twojego magazynu, grasz ponownie.
    Jeśli ostatni kamień wpadnie do pustego dołka po twojej stronie, przechwytujesz ten kamień i wszystkie kamienie z przeciwległego dołka.
    Gra kończy się, gdy jedna strona jest całkowicie pusta.
    Gracz z największą liczbą kamieni wygrywa.
    Użyj klawiszy 1-6 aby wybrać dołek. Naciśnij E aby sprawdzić planszę.

# End screen
mancala-final-score = { $player }: { $score } kamieni
mancala-check-board = Check board
