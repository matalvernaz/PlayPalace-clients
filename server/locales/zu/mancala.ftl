# Mancala game messages — zu
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Umgodi { $pit }: amatshe angu-{ $stones }

# Game events
mancala-sow = { $player } uhlwanyela amatshe angu-{ $stones } emgodini { $pit }
mancala-capture = { $player } ubamba amatshe angu-{ $captured }!
mancala-extra-turn = Itshe lokugcina esitolo! { $player } uthola elinye ithuba.
mancala-winner = { $player } unqoba ngamatshe angu-{ $score }!
mancala-draw = Kulingana! Bobabili abadlali banamatshe angu-{ $score }.

# Board status
mancala-board-status =
    Imigodi yakho: { $own_pits }. Isitolo sakho: { $own_store }. Imigodi yomphikisi: { $opp_pits }. Isitolo somphikisi: { $opp_store }.

# Options
mancala-set-stones = Amatshe ngomgodi: { $stones }
mancala-desc-stones = Inani lamatshe kumgodi ngamunye ekuqaleni
mancala-enter-stones = Faka inani lamatshe okuqala ngomgodi:
mancala-option-changed-stones = Amatshe okuqala ashintshwe aba ngu-{ $stones }

# Disabled reasons
mancala-pit-empty = Lo mgodi awunalutho.

# Rules
mancala-rules =
    I-Mancala umdlalo wemigodi namatshe wabadlali ababili.
    Umdlali ngamunye unemigodi eyi-6 nesitolo esisodwa.
    Ngethuba lakho, khetha umgodi owodwa ukuze uhlwanyele.
    Amatshe afakwa ngalinye kumgodi ngamunye ebhodini, kufaka isitolo sakho kodwa weqa isitolo somphikisi.
    Uma itshe lokugcina liwela esitolo sakho, udlala futhi.
    Uma itshe lokugcina liwela emgodini ongenalutho ohlangothini lwakho, ubamba lelo tshe nawo wonke amatshe emgodini obhekene nawo.
    Umdlalo uphela uma uhlangothi olulodwa lungenalutho ngokuphelele.
    Umdlali onamatshe amaningi uyaphumelela.
    Sebenzisa izinkinobho 1-6 ukukhetha umgodi. Cindezela u-E ukuhlola ibhodi.

# End screen
mancala-final-score = { $player }: amatshe angu-{ $score }
