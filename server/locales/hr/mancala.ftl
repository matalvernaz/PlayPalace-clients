# Mancala game messages — hr
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = Rupa { $pit }: { $stones } kamenčića

# Game events
mancala-sow = { $player } sije { $stones } kamenčića iz rupe { $pit }
mancala-capture = { $player } zarobljava { $captured } kamenčića!
mancala-extra-turn = Zadnji kamenčić u spremištu! { $player } igra ponovo.
mancala-winner = { $player } pobjeđuje s { $score } kamenčića!
mancala-draw = Neriješeno! Oba igrača imaju { $score } kamenčića.

# Board status
mancala-board-status =
    Vaše rupe: { $own_pits }. Vaše spremište: { $own_store }. Protivnikove rupe: { $opp_pits }. Protivnikovo spremište: { $opp_store }.

# Options
mancala-set-stones = Kamenčića po rupi: { $stones }
mancala-desc-stones = Broj kamenčića u svakoj rupi na početku
mancala-enter-stones = Unesite broj početnih kamenčića po rupi:
mancala-option-changed-stones = Početni kamenčići promijenjeni na { $stones }

# Disabled reasons
mancala-pit-empty = Ta rupa je prazna.

# Rules
mancala-rules =
    Mankala je igra za dva igrača s rupama i kamenčićima.
    Svaki igrač ima 6 rupa i spremište.
    Na svom potezu odaberite jednu od svojih rupa za sijanje.
    Kamenčići se stavljaju jedan po jedan u svaku rupu oko ploče, uključujući vaše spremište ali preskačući protivnikovo.
    Ako vaš zadnji kamenčić padne u vaše spremište, igrate ponovo.
    Ako vaš zadnji kamenčić padne u praznu rupu na vašoj strani, zarobljavate taj kamenčić i sve kamenčiće iz suprotne rupe.
    Igra završava kad je jedna strana potpuno prazna.
    Igrač s najviše kamenčića pobjeđuje.
    Koristite tipke 1 do 6 za odabir rupe. Pritisnite E za provjeru ploče.

# End screen
mancala-final-score = { $player }: { $score } kamenčića
