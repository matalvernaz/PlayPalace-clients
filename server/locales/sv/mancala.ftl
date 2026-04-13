# Mancala game messages — sv
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Grop { $pit }: { $stones } stenar

# Game events
mancala-sow = { $player } sår { $stones } stenar från grop { $pit }
mancala-capture = { $player } fångar { $captured } stenar!
mancala-extra-turn = Sista stenen i magasinet! { $player } spelar igen.
mancala-winner = { $player } vinner med { $score } stenar!
mancala-draw = Oavgjort! Båda spelarna har { $score } stenar.

# Board status
mancala-board-status =
    Dina gropar: { $own_pits }. Ditt magasin: { $own_store }. Motståndarens gropar: { $opp_pits }. Motståndarens magasin: { $opp_store }.

# Options
mancala-set-stones = Stenar per grop: { $stones }
mancala-desc-stones = Antal stenar i varje grop vid start
mancala-enter-stones = Ange antal startstenar per grop:
mancala-option-changed-stones = Startstenar ändrade till { $stones }

# Disabled reasons
mancala-pit-empty = Den gropen är tom.

# Rules
mancala-rules =
    Mancala är ett grop- och stenspel för två spelare.
    Varje spelare har 6 gropar och ett magasin.
    På din tur, välj en av dina gropar att så från.
    Stenar läggs en och en i varje grop runt brädet, inklusive ditt magasin men hoppa över motståndarens.
    Om din sista sten hamnar i ditt magasin får du spela igen.
    Om din sista sten hamnar i en tom grop på din sida fångar du den stenen och alla stenar i den motsatta gropen.
    Spelet slutar när en sida är helt tom.
    Spelaren med flest stenar vinner.
    Använd tangenterna 1-6 för att välja grop. Tryck E för att kontrollera brädet.

# End screen
mancala-final-score = { $player }: { $score } stenar
mancala-check-board = Check board
