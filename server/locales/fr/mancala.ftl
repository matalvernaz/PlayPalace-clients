# Mancala game messages — fr
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Trou { $pit } : { $stones } graines

# Game events
mancala-sow = { $player } sème { $stones } graines du trou { $pit }
mancala-capture = { $player } capture { $captured } graines !
mancala-extra-turn = Dernière graine dans le grenier ! { $player } rejoue.
mancala-winner = { $player } gagne avec { $score } graines !
mancala-draw = Égalité ! Les deux joueurs ont { $score } graines.

# Board status
mancala-board-status =
    Vos trous : { $own_pits }. Votre grenier : { $own_store }. Trous adverses : { $opp_pits }. Grenier adverse : { $opp_store }.

# Options
mancala-set-stones = Graines par trou : { $stones }
mancala-desc-stones = Nombre de graines dans chaque trou au début
mancala-enter-stones = Entrez le nombre de graines de départ par trou :
mancala-option-changed-stones = Graines de départ changées à { $stones }

# Disabled reasons
mancala-pit-empty = Ce trou est vide.

# Rules
mancala-rules =
    Le Mancala est un jeu de trous et de graines pour deux joueurs.
    Chaque joueur a 6 trous et un grenier.
    À votre tour, choisissez un de vos trous pour semer.
    Les graines sont déposées une par une dans chaque trou autour du plateau, y compris votre grenier mais en sautant celui de l'adversaire.
    Si votre dernière graine tombe dans votre grenier, vous rejouez.
    Si votre dernière graine tombe dans un trou vide de votre côté, vous capturez cette graine et toutes celles du trou opposé.
    La partie se termine quand un côté est complètement vide. Les graines restantes vont dans le grenier du joueur correspondant.
    Le joueur avec le plus de graines gagne.
    Utilisez les touches 1 à 6 pour choisir un trou. Appuyez sur E pour vérifier le plateau.

# End screen
mancala-final-score = { $player } : { $score } graines
mancala-check-board = Check board
