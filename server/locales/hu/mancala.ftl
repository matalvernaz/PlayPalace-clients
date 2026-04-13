# Mancala game messages — hu
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mankala

# Actions
mancala-pit-label = { $pit }. gödör: { $stones } kő

# Game events
mancala-sow = { $player } { $stones } követ vet a { $pit }. gödörből
mancala-capture = { $player } elfog { $captured } követ!
mancala-extra-turn = Utolsó kő a tárban! { $player } újra jön.
mancala-winner = { $player } nyer { $score } kővel!
mancala-draw = Döntetlen! Mindkét játékosnak { $score } köve van.

# Board status
mancala-board-status =
    Gödreid: { $own_pits }. Tárad: { $own_store }. Ellenfél gödrei: { $opp_pits }. Ellenfél tára: { $opp_store }.

# Options
mancala-set-stones = Kő gödrönként: { $stones }
mancala-desc-stones = Kövek száma minden gödörben az elején
mancala-enter-stones = Add meg a kezdő kövek számát gödrönként:
mancala-option-changed-stones = Kezdő kövek { $stones }-ra módosítva

# Disabled reasons
mancala-pit-empty = Ez a gödör üres.

# Rules
mancala-rules =
    A Mankala kétszemélyes gödör- és kőjáték.
    Minden játékosnak 6 gödre és egy tára van.
    A lépésedben válassz egy gödröt a vetéshez.
    A köveket egyenként helyezed el a gödrökbe a tábla körül, beleértve a táradat, de kihagyva az ellenfél tárát.
    Ha az utolsó köved a táradba esik, újra te jössz.
    Ha az utolsó köved a te oldaladon egy üres gödörbe esik, elfogod azt a követ és a szemben lévő gödör összes kövét.
    A játék véget ér, ha az egyik oldal teljesen üres.
    A legtöbb kővel rendelkező játékos nyer.
    Használd az 1-6 billentyűket a gödör kiválasztásához. Nyomd meg az E-t a tábla ellenőrzéséhez.

# End screen
mancala-final-score = { $player }: { $score } kő
