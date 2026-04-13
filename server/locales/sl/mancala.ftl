# Mancala game messages — sl
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = Luknja { $pit }: { $stones } kamnov

# Game events
mancala-sow = { $player } seje { $stones } kamnov iz luknje { $pit }
mancala-capture = { $player } zajame { $captured } kamnov!
mancala-extra-turn = Zadnji kamen v shrambi! { $player } igra še enkrat.
mancala-winner = { $player } zmaga s { $score } kamni!
mancala-draw = Izenačenje! Oba igralca imata { $score } kamnov.

# Board status
mancala-board-status =
    Vaše luknje: { $own_pits }. Vaša shramba: { $own_store }. Nasprotnikove luknje: { $opp_pits }. Nasprotnikova shramba: { $opp_store }.

# Options
mancala-set-stones = Kamnov na luknjo: { $stones }
mancala-desc-stones = Število kamnov v vsaki luknji na začetku
mancala-enter-stones = Vnesite število začetnih kamnov na luknjo:
mancala-option-changed-stones = Začetni kamni spremenjeni na { $stones }

# Disabled reasons
mancala-pit-empty = Ta luknja je prazna.

# Rules
mancala-rules =
    Mankala je igra za dva igralca z luknjami in kamni.
    Vsak igralec ima 6 lukenj in shrambo.
    Na svoji potezi izberite eno od svojih lukenj za sejanje.
    Kamni se polagajo enega za drugim v vsako luknjo okrog plošče, vključno z vašo shrambo, vendar preskočite nasprotnikovo.
    Če zadnji kamen pade v vašo shrambo, igrate še enkrat.
    Če zadnji kamen pade v prazno luknjo na vaši strani, zajamete ta kamen in vse kamne v nasprotni luknji.
    Igra se konča, ko je ena stran popolnoma prazna.
    Igralec z največ kamni zmaga.
    Uporabite tipke 1-6 za izbiro luknje. Pritisnite E za pregled plošče.

# End screen
mancala-final-score = { $player }: { $score } kamnov
mancala-check-board = Check board
