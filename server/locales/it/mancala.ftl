# Mancala game messages — it
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Buca { $pit }: { $stones } semi

# Game events
mancala-sow = { $player } semina { $stones } semi dalla buca { $pit }
mancala-capture = { $player } cattura { $captured } semi!
mancala-extra-turn = Ultimo seme nel deposito! { $player } ha un altro turno.
mancala-winner = { $player } vince con { $score } semi!
mancala-draw = Pareggio! Entrambi i giocatori hanno { $score } semi.

# Board status
mancala-board-status =
    Le tue buche: { $own_pits }. Il tuo deposito: { $own_store }. Buche avversarie: { $opp_pits }. Deposito avversario: { $opp_store }.

# Options
mancala-set-stones = Semi per buca: { $stones }
mancala-desc-stones = Numero di semi in ogni buca all'inizio
mancala-enter-stones = Inserisci il numero di semi iniziali per buca:
mancala-option-changed-stones = Semi iniziali cambiati a { $stones }

# Disabled reasons
mancala-pit-empty = Quella buca è vuota.

# Rules
mancala-rules =
    Il Mancala è un gioco di buche e semi per due giocatori.
    Ogni giocatore ha 6 buche e un deposito.
    Nel tuo turno, scegli una delle tue buche per seminare.
    I semi vengono depositati uno per uno in ogni buca intorno al tavoliere, incluso il tuo deposito ma saltando quello dell'avversario.
    Se l'ultimo seme cade nel tuo deposito, hai un altro turno.
    Se l'ultimo seme cade in una buca vuota dalla tua parte, catturi quel seme e tutti i semi nella buca opposta.
    Il gioco finisce quando un lato è completamente vuoto.
    Il giocatore con più semi vince.
    Usa i tasti da 1 a 6 per scegliere una buca. Premi E per controllare il tavoliere.

# End screen
mancala-final-score = { $player }: { $score } semi
mancala-check-board = Check board
