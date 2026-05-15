# Trouble — sl
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble je tekaška igra iz družine Parcheesi.
    Vsak igralec začne s figuricami v Domu.
    Na svoji potezi pritisni kocko in premakni eno svojih figuric.
    Privzeto moraš vreči 6, da figurico iz Doma sprostiš na stezo.
    Privzeto 6 prinese tudi dodatno potezo.
    Figurice se premikajo v smeri urinega kazalca po skupni stezi proti cilju.
    Pristanek na nasprotnikovi figurici jo pošlje nazaj v njegov Dom, razen če je polje zaščiteno.
    Ko vse tvoje figurice dosežejo cilj, zmagaš.
    V skupinskem načinu tvoja ekipa zmaga, ko vsi soigralci končajo.
    Tipke 1-6 izberejo figurico, R meče.
    Pritisni E za polno stanje plošče kadarkoli.

trouble-action-roll = Pritisni kocko
trouble-action-move-token = Premakni figurico { $token }
trouble-action-check-board = Preveri ploščo

trouble-token-label-home = Figurica { $token }: v Domu
trouble-token-label-track = Figurica { $token }: polje { $position } steze
trouble-token-label-finish-lane = Figurica { $token }: ciljna steza { $position } od { $total }
trouble-token-label-finished = Figurica { $token }: končala

trouble-rolled = { $player } je vrgel { $roll }.
trouble-leave-home = { $player } sprosti figurico { $token } na stezo.
trouble-advance-track = { $player } premakne figurico { $token } na polje { $position }.
trouble-enter-finish-lane = { $player } uvede figurico { $token } v ciljno stezo.
trouble-advance-finish-lane =
    { $player } premakne figurico { $token } na polje { $position } od { $total } v ciljni stezi.
trouble-token-finished = Figurica { $token } igralca { $player } dosegla cilj.
trouble-bump =
    Figurica { $token } igralca { $player } pošlje figurico { $opp_token } igralca { $opponent } nazaj v Dom.
trouble-no-legal-move = { $player } nima legalnih potez. Poteza preide.
trouble-extra-turn = { $player } dobi dodatno potezo za 6.

trouble-winner = { $player } zmaga! Vse figurice na cilju.
trouble-team-winner = Ekipa { $team } zmaga! Vsi soigralci so končali.
trouble-final-standing = { $player }: { $finished } od { $total } figuric končanih.

trouble-turn-summary =
    Imaš { $own_home } v Domu, { $own_track } na stezi, { $own_finished } na cilju.
    Nasprotniki: { $opponents }.
trouble-opponent-summary = { $name }: { $home } dom, { $track } steza, { $finished } cilj

trouble-board-status =
    Tvoje figurice: { $own_tokens }.
    Nasprotnikove figurice: { $opp_tokens }.

trouble-reason-not-rolled = Najprej pritisni kocko.
trouble-reason-already-rolled = Že si pritisnil. Izberi figurico za premik.
trouble-reason-no-legal-moves = Za to metanje ni legalnih potez.
trouble-reason-token-home-needs-six = Ta figurica je v Domu. Potrebuješ 6 za sprostitev.
trouble-reason-token-home-needs-any = Ta figurica je v Domu. Vsak met jo sprosti.
trouble-reason-token-home-no-qualifying-roll =
    Ta figurica je v Domu in tvoj met ne ustreza pogoju za sprostitev.
trouble-reason-token-finished = Ta figurica je že končala.
trouble-reason-overshoot-wastes = Ta figurica ne more iti { $roll } polj brez prečkanja cilja.
trouble-reason-blocked = Ta poteza je blokirana.

trouble-option-track-size = Velikost steze: { $track_size } polj
trouble-option-select-track-size = Izberi število polj steze.
trouble-option-changed-track-size = Steza nastavljena na { $track_size } polj.
trouble-option-desc-track-size = Število polj na skupni stezi.

trouble-option-tokens-per-player = Figuric na igralca: { $tokens }
trouble-option-enter-tokens-per-player = Vnesi figuric na igralca (2-6):
trouble-option-changed-tokens-per-player = Figuric na igralca nastavljeno na { $tokens }.
trouble-option-desc-tokens-per-player = Koliko figuric vsak igralec vodi v cilj.

trouble-option-extra-turn-on-six = Dodatna poteza pri 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Dodatna poteza pri 6 { $enabled ->
    [on] vključena.
    [off] izključena.
   *[other] posodobljena.
}
trouble-option-desc-extra-turn-on-six =
    Vklopljeno: 6 prinese dodatno potezo (klasično Hasbro pravilo).

trouble-option-six-to-leave-home = Zahteva 6 za zapustitev Doma: { $enabled }
trouble-option-changed-six-to-leave-home = Šestica za zapustitev Doma { $enabled ->
    [on] vključena.
    [off] izključena.
   *[other] posodobljena.
}
trouble-option-desc-six-to-leave-home =
    Vklopljeno: igralec mora vreči 6, da sprosti figurico iz Doma. Izklopljeno: kateri koli met sprosti.

trouble-option-safe-spaces = Varna polja: { $mode }
trouble-option-select-safe-spaces = Izberi način varnih polj.
trouble-option-changed-safe-spaces = Varna polja nastavljena na { $mode }.
trouble-option-desc-safe-spaces = Odloči, ali so figurice lahko zaščitene pred trki.

trouble-safe-mode-none = Brez
trouble-safe-mode-home-stretch = Samo ciljna ravnina
trouble-safe-mode-every-seventh = Vsako 7. polje

trouble-option-finish-behavior = Cilj: { $mode }
trouble-option-select-finish-behavior = Izberi vedenje cilja.
trouble-option-changed-finish-behavior = Vedenje cilja nastavljeno na { $mode }.
trouble-option-desc-finish-behavior = Kako obravnavati met, ki prečka cilj.

trouble-finish-mode-exact = Potreben točen met
trouble-finish-mode-bounce = Presežek se odbija
trouble-finish-mode-allow = Presežek dovoljen

trouble-option-bot-difficulty = Težavnost bota: { $level }
trouble-option-select-bot-difficulty = Izberi težavnost bota.
trouble-option-changed-bot-difficulty = Težavnost bota nastavljena na { $level }.
trouble-option-desc-bot-difficulty = Moč vgrajenih botov.

trouble-bot-difficulty-naive = Naiven
trouble-bot-difficulty-greedy = Pohlepen

trouble-option-preset = Prednastavitev: { $preset }
trouble-option-select-preset = Izberi varianto. Gostitelj lahko pozneje prilagodi posamezna pravila.
trouble-option-changed-preset = Prednastavitev uporabljena: { $preset }.
trouble-option-desc-preset = Vnaprej pripravljeni nabori možnosti za pogoste variante.

trouble-preset-classic = Klasični Hasbro
trouble-preset-fast = Hitri
trouble-preset-brutal = Brutalen
trouble-preset-custom = Po meri
