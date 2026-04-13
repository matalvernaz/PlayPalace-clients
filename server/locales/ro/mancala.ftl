# Mancala game messages — ro
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Groapă { $pit }: { $stones } pietre

# Game events
mancala-sow = { $player } seamănă { $stones } pietre din groapa { $pit }
mancala-capture = { $player } capturează { $captured } pietre!
mancala-extra-turn = Ultima piatră în depozit! { $player } joacă din nou.
mancala-winner = { $player } câștigă cu { $score } pietre!
mancala-draw = Egalitate! Ambii jucători au { $score } pietre.

# Board status
mancala-board-status =
    Gropile tale: { $own_pits }. Depozitul tău: { $own_store }. Gropile adversarului: { $opp_pits }. Depozitul adversarului: { $opp_store }.

# Options
mancala-set-stones = Pietre pe groapă: { $stones }
mancala-desc-stones = Numărul de pietre în fiecare groapă la început
mancala-enter-stones = Introduceți numărul de pietre inițiale pe groapă:
mancala-option-changed-stones = Pietrele inițiale schimbate la { $stones }

# Disabled reasons
mancala-pit-empty = Acea groapă este goală.

# Rules
mancala-rules =
    Mancala este un joc de gropi și pietre pentru doi jucători.
    Fiecare jucător are 6 gropi și un depozit.
    La rândul tău, alege una din gropile tale pentru a semăna.
    Pietrele sunt plasate câte una în fiecare groapă din jurul tablei, inclusiv depozitul tău dar sărind depozitul adversarului.
    Dacă ultima piatră cade în depozitul tău, joci din nou.
    Dacă ultima piatră cade într-o groapă goală de partea ta, capturezi acea piatră și toate pietrele din groapa opusă.
    Jocul se termină când o parte este complet goală.
    Jucătorul cu cele mai multe pietre câștigă.
    Folosește tastele 1-6 pentru a alege o groapă. Apasă E pentru a verifica tabla.

# End screen
mancala-final-score = { $player }: { $score } pietre
