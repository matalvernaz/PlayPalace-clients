# Trouble — sk
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble je pretekárska hra z rodiny Parcheesi.
    Každý hráč začína s figúrkami v Domácom území.
    V ťahu stlačíš kocku a posunieš jednu zo svojich figúrok.
    Predvolene musíš hodiť 6, aby si dostal figúrku z Domu na dráhu.
    Predvolene 6 dáva aj ťah navyše.
    Figúrky sa pohybujú po smere hodinových ručičiek po zdieľanej dráhe k cieľovej zóne.
    Pristátie na súperovej figúrke ju pošle späť do jeho Domu, pokiaľ pole nie je chránené.
    Keď všetky tvoje figúrky dorazia do cieľa, vyhrávaš.
    V tímovom režime vyhráva tím, keď všetci členovia dokončia.
    Klávesy 1-6 vyberajú figúrku, R hádže.
    E kedykoľvek prečíta plný stav dosky.

trouble-action-roll = Stlač kocku
trouble-action-move-token = Posunúť figúrku { $token }
trouble-action-check-board = Skontrolovať dosku

trouble-token-label-home = Figúrka { $token }: v Dome
trouble-token-label-track = Figúrka { $token }: pole { $position } na dráhe
trouble-token-label-finish-lane = Figúrka { $token }: cieľový pruh { $position } z { $total }
trouble-token-label-finished = Figúrka { $token }: v cieli

trouble-rolled = { $player } hodil { $roll }.
trouble-leave-home = { $player } púšťa figúrku { $token } na dráhu.
trouble-advance-track = { $player } posúva figúrku { $token } na pole { $position }.
trouble-enter-finish-lane = { $player } vedie figúrku { $token } do cieľového pruhu.
trouble-advance-finish-lane =
    { $player } posúva figúrku { $token } na pole { $position } z { $total } v cieľovom pruhu.
trouble-token-finished = Figúrka { $token } hráča { $player } dosiahla cieľ.
trouble-bump =
    Figúrka { $token } hráča { $player } posiela figúrku { $opp_token } hráča { $opponent } späť domov.
trouble-no-legal-move = { $player } nemá legálny ťah. Ťah pokračuje ďalej.
trouble-extra-turn = { $player } dostáva ťah navyše za 6.

trouble-winner = { $player } vyhráva! Všetky figúrky v cieli.
trouble-team-winner = Tím { $team } vyhráva! Všetci členovia dokončili.
trouble-final-standing = { $player }: { $finished } z { $total } figúrok dokončilo.

trouble-turn-summary =
    Máš { $own_home } doma, { $own_track } na dráhe, { $own_finished } v cieli.
    Súperi: { $opponents }.
trouble-opponent-summary = { $name }: { $home } dom, { $track } dráha, { $finished } cieľ

trouble-board-status =
    Tvoje figúrky: { $own_tokens }.
    Súperove figúrky: { $opp_tokens }.

trouble-reason-not-rolled = Najprv stlač kocku.
trouble-reason-already-rolled = Už si stlačil. Vyber figúrku na pohyb.
trouble-reason-no-legal-moves = Pre tento hod nie sú legálne ťahy.
trouble-reason-token-home-needs-six = Táto figúrka je doma. Na uvoľnenie potrebuješ 6.
trouble-reason-token-home-needs-any = Táto figúrka je doma. Hocijaký hod ju uvoľní.
trouble-reason-token-home-no-qualifying-roll =
    Táto figúrka je doma a tvoj hod nestačí na uvoľnenie.
trouble-reason-token-finished = Táto figúrka je už v cieli.
trouble-reason-overshoot-wastes = Táto figúrka nemôže prejsť { $roll } polí bez prekročenia cieľa.
trouble-reason-blocked = Tento ťah je blokovaný.

trouble-option-track-size = Dĺžka dráhy: { $track_size } polí
trouble-option-select-track-size = Vyber počet polí na dráhe.
trouble-option-changed-track-size = Dráha nastavená na { $track_size } polí.
trouble-option-desc-track-size = Počet polí na zdieľanej dráhe.

trouble-option-tokens-per-player = Figúrky na hráča: { $tokens }
trouble-option-enter-tokens-per-player = Zadaj figúrky na hráča (2-6):
trouble-option-changed-tokens-per-player = Figúrky na hráča nastavené na { $tokens }.
trouble-option-desc-tokens-per-player = Koľko figúrok každý hráč vedie do cieľa.

trouble-option-extra-turn-on-six = Ťah navyše pri 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Ťah navyše pri 6 { $enabled ->
    [on] zapnutý.
    [off] vypnutý.
   *[other] aktualizovaný.
}
trouble-option-desc-extra-turn-on-six =
    Zapnuté: 6 dáva ťah navyše (klasické Hasbro pravidlo).

trouble-option-six-to-leave-home = Vyžadovať 6 na opustenie Domu: { $enabled }
trouble-option-changed-six-to-leave-home = Šestka na opustenie Domu { $enabled ->
    [on] zapnuté.
    [off] vypnuté.
   *[other] aktualizované.
}
trouble-option-desc-six-to-leave-home =
    Zapnuté: hráč potrebuje 6 na uvoľnenie figúrky z Domu. Vypnuté: hocijaký hod uvoľňuje.

trouble-option-safe-spaces = Bezpečné polia: { $mode }
trouble-option-select-safe-spaces = Vyber režim bezpečných polí.
trouble-option-changed-safe-spaces = Bezpečné polia nastavené na { $mode }.
trouble-option-desc-safe-spaces = Rozhodni, či figúrky môžu byť chránené pred zrážkami.

trouble-safe-mode-none = Žiadne
trouble-safe-mode-home-stretch = Iba cieľová rovinka
trouble-safe-mode-every-seventh = Každé 7. pole

trouble-option-finish-behavior = Cieľ: { $mode }
trouble-option-select-finish-behavior = Vyber správanie v cieli.
trouble-option-changed-finish-behavior = Správanie cieľa nastavené na { $mode }.
trouble-option-desc-finish-behavior = Ako riešiť hod, ktorý prekračuje cieľ.

trouble-finish-mode-exact = Vyžadovaný presný hod
trouble-finish-mode-bounce = Presah sa odráža
trouble-finish-mode-allow = Presah povolený

trouble-option-bot-difficulty = Obtiažnosť bota: { $level }
trouble-option-select-bot-difficulty = Vyber obtiažnosť bota.
trouble-option-changed-bot-difficulty = Obtiažnosť bota nastavená na { $level }.
trouble-option-desc-bot-difficulty = Sila vstavaných botov.

trouble-bot-difficulty-naive = Naivný
trouble-bot-difficulty-greedy = Lakomý

trouble-option-preset = Predvoľba: { $preset }
trouble-option-select-preset = Vyber variant. Hostiteľ môže neskôr upraviť jednotlivé pravidlá.
trouble-option-changed-preset = Predvoľba aplikovaná: { $preset }.
trouble-option-desc-preset = Vopred pripravené sady možností pre bežné varianty.

trouble-preset-classic = Klasický Hasbro
trouble-preset-fast = Rýchly
trouble-preset-brutal = Brutálny
trouble-preset-custom = Vlastný
