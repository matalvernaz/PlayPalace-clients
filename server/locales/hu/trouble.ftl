# Trouble — hu
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    A Trouble a Parcheesi-család versengős táblajátéka.
    Minden játékos a Háznál kezdi a bábuival.
    A te körödben pop-old a kockát és mozgass egy bábut.
    Alapértelmezetten 6-ost kell dobnod, hogy egy bábu kijuthasson a Házból a pályára.
    Alapértelmezetten a 6-os egy extra kört is ad.
    A bábuk az óramutató járásával megegyezően haladnak a közös pályán a cél felé.
    Ellenfél bábujára érkezve az visszakerül a Házába, hacsak a mező nem védett.
    Ha minden bábud célba ér, nyersz.
    Csapat módban a csapatod nyer, ha minden csapattárs befejezte.
    1-6 a bábut választja, R dobás.
    Nyomd meg az E-t bármikor a tábla teljes állapotának meghallgatásához.

trouble-action-roll = Kocka popolása
trouble-action-move-token = { $token } bábu mozgatása
trouble-action-check-board = Tábla megtekintése

trouble-token-label-home = { $token }. bábu: a Házban
trouble-token-label-track = { $token }. bábu: pálya { $position }. mezője
trouble-token-label-finish-lane = { $token }. bábu: célsáv { $position } / { $total }
trouble-token-label-finished = { $token }. bábu: célba ért

trouble-rolled = { $player } dobott egy { $roll }-est.
trouble-leave-home = { $player } pályára engedi a { $token }. bábut.
trouble-advance-track = { $player } a { $token }. bábut a { $position }. mezőre lépteti.
trouble-enter-finish-lane = { $player } a { $token }. bábut a célsávba viszi.
trouble-advance-finish-lane =
    { $player } a { $token }. bábut a célsáv { $position }. / { $total } mezőjére lépteti.
trouble-token-finished = { $player } { $token }. bábuja célba ért.
trouble-bump =
    { $player } { $token }. bábuja visszaküldi { $opponent } { $opp_token }. bábuját a Házba.
trouble-no-legal-move = { $player }-nek nincs érvényes lépése. A kör tovább megy.
trouble-extra-turn = { $player } extra kört kap a 6-osért.

trouble-winner = { $player } nyer! Minden bábu célba ért.
trouble-team-winner = A { $team } csapat nyer! Minden csapattárs befejezte.
trouble-final-standing = { $player }: { $total } -ból { $finished } bábu célba ért.

trouble-turn-summary =
    Házban { $own_home }, pályán { $own_track }, célban { $own_finished } bábud van.
    Ellenfelek: { $opponents }.
trouble-opponent-summary = { $name }: { $home } ház, { $track } pálya, { $finished } cél

trouble-board-status =
    Bábuid: { $own_tokens }.
    Ellenfél bábui: { $opp_tokens }.

trouble-reason-not-rolled = Előbb pop-old a kockát.
trouble-reason-already-rolled = Már pop-oltad. Válassz bábut mozgatáshoz.
trouble-reason-no-legal-moves = Ehhez a dobáshoz nincs érvényes lépés.
trouble-reason-token-home-needs-six = Ez a bábu a Házban van. 6-os kell a kiengedéséhez.
trouble-reason-token-home-needs-any = Ez a bábu a Házban van. Bármilyen dobás kiengedi.
trouble-reason-token-home-no-qualifying-roll =
    Ez a bábu a Házban van, és a dobásod nem elég a kiengedéséhez.
trouble-reason-token-finished = Ez a bábu már célba ért.
trouble-reason-overshoot-wastes = Ez a bábu nem mozdíthat { $roll } mezőt anélkül, hogy túljutna a célon.
trouble-reason-blocked = Ez a lépés blokkolt.

trouble-option-track-size = Pálya mérete: { $track_size } mező
trouble-option-select-track-size = Válaszd ki a pálya mezőszámát.
trouble-option-changed-track-size = Pálya beállítva: { $track_size } mező.
trouble-option-desc-track-size = A közös pályán lévő mezők száma.

trouble-option-tokens-per-player = Bábuk játékosonként: { $tokens }
trouble-option-enter-tokens-per-player = Add meg a bábuk számát játékosonként (2-6):
trouble-option-changed-tokens-per-player = Bábuk játékosonként: { $tokens }.
trouble-option-desc-tokens-per-player = Hány bábut visz célba minden játékos.

trouble-option-extra-turn-on-six = Extra kör 6-osnál: { $enabled }
trouble-option-changed-extra-turn-on-six = Extra kör 6-osnál { $enabled ->
    [on] engedélyezve.
    [off] letiltva.
   *[other] frissítve.
}
trouble-option-desc-extra-turn-on-six =
    Be: 6-os extra kört ad (klasszikus Hasbro szabály).

trouble-option-six-to-leave-home = 6-os szükséges a Ház elhagyásához: { $enabled }
trouble-option-changed-six-to-leave-home = Hatos a Ház elhagyásához { $enabled ->
    [on] engedélyezve.
    [off] letiltva.
   *[other] frissítve.
}
trouble-option-desc-six-to-leave-home =
    Be: a játékosnak 6-ost kell dobnia, hogy bábut kiengedjen. Ki: bármilyen dobás kienged.

trouble-option-safe-spaces = Biztonságos mezők: { $mode }
trouble-option-select-safe-spaces = Válaszd ki a biztonságos mező módot.
trouble-option-changed-safe-spaces = Biztonságos mezők: { $mode }.
trouble-option-desc-safe-spaces = Határozd meg, hogy a bábuk védve lehetnek-e az ütésektől.

trouble-safe-mode-none = Nincs
trouble-safe-mode-home-stretch = Csak a célegyenes
trouble-safe-mode-every-seventh = Minden 7. mező

trouble-option-finish-behavior = Cél: { $mode }
trouble-option-select-finish-behavior = Válaszd ki a célviselkedést.
trouble-option-changed-finish-behavior = Cél viselkedés: { $mode }.
trouble-option-desc-finish-behavior = Hogyan kezeljük a célt túlhaladó dobást.

trouble-finish-mode-exact = Pontos dobás kell
trouble-finish-mode-bounce = Túlhaladás visszapattan
trouble-finish-mode-allow = Túlhaladás engedélyezett

trouble-option-bot-difficulty = Bot nehézsége: { $level }
trouble-option-select-bot-difficulty = Válaszd ki a bot nehézségét.
trouble-option-changed-bot-difficulty = Bot nehézsége: { $level }.
trouble-option-desc-bot-difficulty = A beépített botok erőssége.

trouble-bot-difficulty-naive = Naiv
trouble-bot-difficulty-greedy = Mohó

trouble-option-preset = Előbeállítás: { $preset }
trouble-option-select-preset = Válaszd ki a variánst. A házigazda később egyedi szabályokat módosíthat.
trouble-option-changed-preset = Előbeállítás alkalmazva: { $preset }.
trouble-option-desc-preset = Előcsomagolt opciókészletek a gyakori variánsokhoz.

trouble-preset-classic = Klasszikus Hasbro
trouble-preset-fast = Gyors
trouble-preset-brutal = Brutális
trouble-preset-custom = Egyedi
