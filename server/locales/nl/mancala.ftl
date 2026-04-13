# Mancala game messages — nl
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Put { $pit }: { $stones } stenen

# Game events
mancala-sow = { $player } zaait { $stones } stenen uit put { $pit }
mancala-capture = { $player } vangt { $captured } stenen!
mancala-extra-turn = Laatste steen in de pot! { $player } is opnieuw aan de beurt.
mancala-winner = { $player } wint met { $score } stenen!
mancala-draw = Gelijkspel! Beide spelers hebben { $score } stenen.

# Board status
mancala-board-status =
    Jouw putten: { $own_pits }. Jouw pot: { $own_store }. Putten tegenstander: { $opp_pits }. Pot tegenstander: { $opp_store }.

# Options
mancala-set-stones = Stenen per put: { $stones }
mancala-desc-stones = Aantal stenen in elke put bij de start
mancala-enter-stones = Voer het aantal startstenen per put in:
mancala-option-changed-stones = Startstenen gewijzigd naar { $stones }

# Disabled reasons
mancala-pit-empty = Die put is leeg.

# Rules
mancala-rules =
    Mancala is een put-en-stenenspel voor twee spelers.
    Elke speler heeft 6 putten en een pot.
    Kies in je beurt een van je putten om te zaaien.
    Stenen worden één voor één in elke put rondom het bord gelegd, inclusief je pot maar de pot van de tegenstander wordt overgeslagen.
    Als je laatste steen in je pot valt, ben je opnieuw aan de beurt.
    Als je laatste steen in een lege put aan jouw kant valt, vang je die steen en alle stenen in de tegenoverliggende put.
    Het spel eindigt als één kant helemaal leeg is.
    De speler met de meeste stenen wint.
    Gebruik toetsen 1 tot 6 om een put te kiezen. Druk op E om het bord te bekijken.

# End screen
mancala-final-score = { $player }: { $score } stenen
