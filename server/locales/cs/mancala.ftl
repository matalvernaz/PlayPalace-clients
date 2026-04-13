# Mancala game messages — cs
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = Jamka { $pit }: { $stones } kamenů

# Game events
mancala-sow = { $player } rozsévá { $stones } kamenů z jamky { $pit }
mancala-capture = { $player } zajímá { $captured } kamenů!
mancala-extra-turn = Poslední kámen v zásobníku! { $player } hraje znovu.
mancala-winner = { $player } vyhrává s { $score } kameny!
mancala-draw = Remíza! Oba hráči mají { $score } kamenů.

# Board status
mancala-board-status =
    Vaše jamky: { $own_pits }. Váš zásobník: { $own_store }. Jamky soupeře: { $opp_pits }. Zásobník soupeře: { $opp_store }.

# Options
mancala-set-stones = Kamenů na jamku: { $stones }
mancala-desc-stones = Počet kamenů v každé jamce na začátku
mancala-enter-stones = Zadejte počet počátečních kamenů na jamku:
mancala-option-changed-stones = Počáteční kameny změněny na { $stones }

# Disabled reasons
mancala-pit-empty = Tato jamka je prázdná.

# Rules
mancala-rules =
    Mankala je hra pro dva hráče s jamkami a kameny.
    Každý hráč má 6 jamek a zásobník.
    Na tahu si vyberte jednu ze svých jamek.
    Kameny se rozkládají po jednom do každé jamky kolem desky, včetně vašeho zásobníku, ale přeskakujete zásobník soupeře.
    Pokud váš poslední kámen padne do vašeho zásobníku, hrajete znovu.
    Pokud váš poslední kámen padne do prázdné jamky na vaší straně, zajmete tento kámen a všechny kameny v protější jamce.
    Hra končí, když je jedna strana zcela prázdná. Zbývající kameny jdou do zásobníku toho hráče.
    Hráč s nejvíce kameny vyhrává.
    Použijte klávesy 1 až 6 pro výběr jamky. Stiskněte E pro kontrolu desky.

# End screen
mancala-final-score = { $player }: { $score } kamenů
mancala-check-board = Check board
