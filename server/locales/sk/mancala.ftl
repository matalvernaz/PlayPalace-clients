# Mancala game messages — sk
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = Jamka { $pit }: { $stones } kameňov

# Game events
mancala-sow = { $player } seje { $stones } kameňov z jamky { $pit }
mancala-capture = { $player } zajíma { $captured } kameňov!
mancala-extra-turn = Posledný kameň v zásobníku! { $player } hrá znova.
mancala-winner = { $player } vyhráva s { $score } kameňmi!
mancala-draw = Remíza! Obaja hráči majú { $score } kameňov.

# Board status
mancala-board-status =
    Vaše jamky: { $own_pits }. Váš zásobník: { $own_store }. Jamky súpera: { $opp_pits }. Zásobník súpera: { $opp_store }.

# Options
mancala-set-stones = Kameňov na jamku: { $stones }
mancala-desc-stones = Počet kameňov v každej jamke na začiatku
mancala-enter-stones = Zadajte počet počiatočných kameňov na jamku:
mancala-option-changed-stones = Počiatočné kamene zmenené na { $stones }

# Disabled reasons
mancala-pit-empty = Táto jamka je prázdna.

# Rules
mancala-rules =
    Mankala je hra pre dvoch hráčov s jamkami a kameňmi.
    Každý hráč má 6 jamiek a zásobník.
    Na ťahu si vyberte jednu zo svojich jamiek.
    Kamene sa rozkladajú po jednom do každej jamky okolo dosky, vrátane vášho zásobníka, ale preskakujete zásobník súpera.
    Ak váš posledný kameň padne do vášho zásobníka, hráte znova.
    Ak váš posledný kameň padne do prázdnej jamky na vašej strane, zajmete tento kameň a všetky kamene v protiľahlej jamke.
    Hra končí, keď je jedna strana úplne prázdna.
    Hráč s najviac kameňmi vyhráva.
    Použite klávesy 1-6 na výber jamky. Stlačte E na kontrolu dosky.

# End screen
mancala-final-score = { $player }: { $score } kameňov
mancala-check-board = Check board
