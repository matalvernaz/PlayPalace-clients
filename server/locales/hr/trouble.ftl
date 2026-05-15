# Trouble — hr
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble je trkaća igra iz Parcheesi obitelji.
    Svaki igrač počinje sa žetonima u svojoj Kući.
    U svom potezu pritisni kockicu i pomakni jedan žeton.
    Po zadanim postavkama moraš baciti 6 da bi pustio žeton iz Kuće na stazu.
    Po zadanim postavkama 6 daje i dodatni potez.
    Žetoni se kreću u smjeru kazaljke na satu po zajedničkoj stazi prema cilju.
    Slijetanje na protivnikov žeton vraća ga u njegovu Kuću, osim ako je polje zaštićeno.
    Kad svi tvoji žetoni dođu do cilja, pobjeđuješ.
    U timskom načinu tvoj tim pobjeđuje kad svi suigrači završe.
    Tipke 1-6 biraju žeton, R baca.
    Pritisni E za potpuni status ploče u bilo kojem trenutku.

trouble-action-roll = Pritisni kockicu
trouble-action-move-token = Pomakni žeton { $token }
trouble-action-check-board = Provjeri ploču

trouble-token-label-home = Žeton { $token }: u Kući
trouble-token-label-track = Žeton { $token }: polje { $position } na stazi
trouble-token-label-finish-lane = Žeton { $token }: cilj { $position } od { $total }
trouble-token-label-finished = Žeton { $token }: završio

trouble-rolled = { $player } je bacio { $roll }.
trouble-leave-home = { $player } pušta žeton { $token } na stazu.
trouble-advance-track = { $player } pomiče žeton { $token } na polje { $position }.
trouble-enter-finish-lane = { $player } uvodi žeton { $token } u cilj.
trouble-advance-finish-lane =
    { $player } pomiče žeton { $token } na polje { $position } od { $total } u cilju.
trouble-token-finished = Žeton { $token } igrača { $player } stigao u cilj.
trouble-bump =
    Žeton { $token } igrača { $player } šalje žeton { $opp_token } igrača { $opponent } natrag u Kuću.
trouble-no-legal-move = { $player } nema legalnih poteza. Red prelazi dalje.
trouble-extra-turn = { $player } dobiva dodatni potez za 6.

trouble-winner = { $player } pobjeđuje! Svi žetoni u cilju.
trouble-team-winner = Tim { $team } pobjeđuje! Svi suigrači završili.
trouble-final-standing = { $player }: { $finished } od { $total } žetona završeno.

trouble-turn-summary =
    Imaš { $own_home } u Kući, { $own_track } na stazi, { $own_finished } u cilju.
    Protivnici: { $opponents }.
trouble-opponent-summary = { $name }: { $home } kuća, { $track } staza, { $finished } cilj

trouble-board-status =
    Tvoji žetoni: { $own_tokens }.
    Protivnički žetoni: { $opp_tokens }.

trouble-reason-not-rolled = Prvo pritisni kockicu.
trouble-reason-already-rolled = Već si pritisnuo. Odaberi žeton za pomicanje.
trouble-reason-no-legal-moves = Nema legalnih poteza za ovaj bacanje.
trouble-reason-token-home-needs-six = Ovaj žeton je u Kući. Trebaš 6 za puštanje.
trouble-reason-token-home-needs-any = Ovaj žeton je u Kući. Bilo koje bacanje pušta.
trouble-reason-token-home-no-qualifying-roll =
    Ovaj žeton je u Kući i tvoje bacanje ne ispunjava uvjet.
trouble-reason-token-finished = Ovaj žeton je već završio.
trouble-reason-overshoot-wastes = Ovaj žeton ne može proći { $roll } polja bez prelaska cilja.
trouble-reason-blocked = Ovaj potez je blokiran.

trouble-option-track-size = Veličina staze: { $track_size } polja
trouble-option-select-track-size = Odaberi broj polja na stazi.
trouble-option-changed-track-size = Staza postavljena na { $track_size } polja.
trouble-option-desc-track-size = Broj polja na zajedničkoj stazi.

trouble-option-tokens-per-player = Žetoni po igraču: { $tokens }
trouble-option-enter-tokens-per-player = Unesi žetone po igraču (2-6):
trouble-option-changed-tokens-per-player = Žetoni po igraču postavljeni na { $tokens }.
trouble-option-desc-tokens-per-player = Koliko žetona svaki igrač vodi u cilj.

trouble-option-extra-turn-on-six = Dodatni potez na 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Dodatni potez na 6 { $enabled ->
    [on] omogućen.
    [off] onemogućen.
   *[other] ažuriran.
}
trouble-option-desc-extra-turn-on-six =
    Uključeno: 6 daje dodatni potez (klasično Hasbro pravilo).

trouble-option-six-to-leave-home = Trebaš 6 za napuštanje Kuće: { $enabled }
trouble-option-changed-six-to-leave-home = Šestica za napuštanje Kuće { $enabled ->
    [on] omogućeno.
    [off] onemogućeno.
   *[other] ažurirano.
}
trouble-option-desc-six-to-leave-home =
    Uključeno: igrač treba baciti 6 za puštanje žetona. Isključeno: bilo koje bacanje pušta.

trouble-option-safe-spaces = Sigurna polja: { $mode }
trouble-option-select-safe-spaces = Odaberi način sigurnih polja.
trouble-option-changed-safe-spaces = Sigurna polja postavljena na { $mode }.
trouble-option-desc-safe-spaces = Odredi mogu li žetoni biti zaštićeni od udaraca.

trouble-safe-mode-none = Nijedan
trouble-safe-mode-home-stretch = Samo završna ravnina
trouble-safe-mode-every-seventh = Svako 7. polje

trouble-option-finish-behavior = Cilj: { $mode }
trouble-option-select-finish-behavior = Odaberi ponašanje cilja.
trouble-option-changed-finish-behavior = Ponašanje cilja postavljeno na { $mode }.
trouble-option-desc-finish-behavior = Kako se obrađuje bacanje koje prelazi cilj.

trouble-finish-mode-exact = Točno bacanje potrebno
trouble-finish-mode-bounce = Prekoračenje se odbija
trouble-finish-mode-allow = Prekoračenje dopušteno

trouble-option-bot-difficulty = Težina bota: { $level }
trouble-option-select-bot-difficulty = Odaberi težinu bota.
trouble-option-changed-bot-difficulty = Težina bota postavljena na { $level }.
trouble-option-desc-bot-difficulty = Snaga ugrađenih botova.

trouble-bot-difficulty-naive = Naivan
trouble-bot-difficulty-greedy = Pohlepan

trouble-option-preset = Predložak: { $preset }
trouble-option-select-preset = Odaberi varijantu. Domaćin može kasnije promijeniti pojedine pravila.
trouble-option-changed-preset = Predložak primijenjen: { $preset }.
trouble-option-desc-preset = Unaprijed pripremljeni skupovi opcija za uobičajene varijante.

trouble-preset-classic = Klasični Hasbro
trouble-preset-fast = Brzi
trouble-preset-brutal = Brutalan
trouble-preset-custom = Prilagođen
