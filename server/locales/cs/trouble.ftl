# Trouble — cs
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble je závodní hra z rodiny Parcheesi.
    Každý hráč začíná s kameny ve své Domácí oblasti.
    Při svém tahu zmáčkneš kostku a posuneš jeden ze svých kamenů.
    Ve výchozím nastavení musíš hodit 6, aby ses dostal z Domu na dráhu.
    Ve výchozím nastavení dává 6 také tah navíc.
    Kameny se pohybují po směru hodinových ručiček po sdílené dráze k cílové zóně.
    Přistání na soupeřově kameni ho pošle zpět do jeho Domu, pokud není pole chráněno.
    Když všechny tvé kameny dorazí do cíle, vyhráváš.
    V týmovém režimu vyhrává tým, jakmile všichni spoluhráči dokončí.
    Tlačítka 1-6 vybírají kámen, R hází.
    E kdykoliv přečte plný stav desky.

trouble-action-roll = Zmáčknout kostku
trouble-action-move-token = Posunout kámen { $token }
trouble-action-check-board = Zkontrolovat desku

trouble-token-label-home = Kámen { $token }: v Domě
trouble-token-label-track = Kámen { $token }: pole { $position } na dráze
trouble-token-label-finish-lane = Kámen { $token }: cílový pruh { $position } z { $total }
trouble-token-label-finished = Kámen { $token }: v cíli

trouble-rolled = { $player } hodil { $roll }.
trouble-leave-home = { $player } pouští kámen { $token } na dráhu.
trouble-advance-track = { $player } posouvá kámen { $token } na pole { $position }.
trouble-enter-finish-lane = { $player } vede kámen { $token } do cílového pruhu.
trouble-advance-finish-lane =
    { $player } posouvá kámen { $token } na pole { $position } z { $total } v cílovém pruhu.
trouble-token-finished = Kámen { $token } hráče { $player } dosáhl cíle.
trouble-bump =
    Kámen { $token } hráče { $player } posílá kámen { $opp_token } hráče { $opponent } zpět domů.
trouble-no-legal-move = { $player } nemá legální tah. Tah pokračuje dál.
trouble-extra-turn = { $player } dostává tah navíc za 6.

trouble-winner = { $player } vyhrává! Všechny kameny v cíli.
trouble-team-winner = Tým { $team } vyhrává! Všichni spoluhráči dokončili.
trouble-final-standing = { $player }: { $finished } z { $total } kamenů dokončilo.

trouble-turn-summary =
    Máš { $own_home } doma, { $own_track } na dráze, { $own_finished } v cíli.
    Soupeři: { $opponents }.
trouble-opponent-summary = { $name }: { $home } domů, { $track } dráha, { $finished } cíl

trouble-board-status =
    Tvoje kameny: { $own_tokens }.
    Soupeřovy kameny: { $opp_tokens }.

trouble-reason-not-rolled = Nejdřív zmáčkni kostku.
trouble-reason-already-rolled = Už jsi zmáčkl. Vyber kámen k pohybu.
trouble-reason-no-legal-moves = Pro tento hod nejsou legální tahy.
trouble-reason-token-home-needs-six = Tento kámen je doma. K uvolnění potřebuješ 6.
trouble-reason-token-home-needs-any = Tento kámen je doma. Jakýkoli hod ho uvolní.
trouble-reason-token-home-no-qualifying-roll =
    Tento kámen je doma a tvůj hod nestačí k uvolnění.
trouble-reason-token-finished = Tento kámen už je v cíli.
trouble-reason-overshoot-wastes = Tento kámen nemůže projít { $roll } polí, aniž by přesáhl cíl.
trouble-reason-blocked = Tento tah je zablokovaný.

trouble-option-track-size = Délka dráhy: { $track_size } polí
trouble-option-select-track-size = Vyber počet polí na dráze.
trouble-option-changed-track-size = Dráha nastavena na { $track_size } polí.
trouble-option-desc-track-size = Počet polí na sdílené dráze.

trouble-option-tokens-per-player = Kameny na hráče: { $tokens }
trouble-option-enter-tokens-per-player = Zadej počet kamenů na hráče (2-6):
trouble-option-changed-tokens-per-player = Kameny na hráče nastaveny na { $tokens }.
trouble-option-desc-tokens-per-player = Kolik kamenů každý hráč vede do cíle.

trouble-option-extra-turn-on-six = Tah navíc při 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Tah navíc při 6 { $enabled ->
    [on] zapnut.
    [off] vypnut.
   *[other] aktualizován.
}
trouble-option-desc-extra-turn-on-six =
    Zapnuto: 6 dává tah navíc (klasické Hasbro pravidlo).

trouble-option-six-to-leave-home = Vyžadovat 6 k opuštění Domu: { $enabled }
trouble-option-changed-six-to-leave-home = Šestka k opuštění Domu { $enabled ->
    [on] zapnuto.
    [off] vypnuto.
   *[other] aktualizováno.
}
trouble-option-desc-six-to-leave-home =
    Zapnuto: hráč potřebuje 6 k uvolnění kamene z Domu. Vypnuto: jakýkoli hod uvolňuje.

trouble-option-safe-spaces = Bezpečná pole: { $mode }
trouble-option-select-safe-spaces = Vyber režim bezpečných polí.
trouble-option-changed-safe-spaces = Bezpečná pole nastavena na { $mode }.
trouble-option-desc-safe-spaces = Rozhodni, zda kameny mohou být chráněny před nárazy.

trouble-safe-mode-none = Žádné
trouble-safe-mode-home-stretch = Pouze cílová rovinka
trouble-safe-mode-every-seventh = Každé 7. pole

trouble-option-finish-behavior = Cíl: { $mode }
trouble-option-select-finish-behavior = Vyber chování v cíli.
trouble-option-changed-finish-behavior = Chování cíle nastaveno na { $mode }.
trouble-option-desc-finish-behavior = Jak řešit hod, který přesáhne cíl.

trouble-finish-mode-exact = Vyžadován přesný hod
trouble-finish-mode-bounce = Přesah se odráží
trouble-finish-mode-allow = Přesah povolen

trouble-option-bot-difficulty = Obtížnost bota: { $level }
trouble-option-select-bot-difficulty = Vyber obtížnost bota.
trouble-option-changed-bot-difficulty = Obtížnost bota nastavena na { $level }.
trouble-option-desc-bot-difficulty = Síla vestavěných botů.

trouble-bot-difficulty-naive = Naivní
trouble-bot-difficulty-greedy = Lakomý

trouble-option-preset = Předvolba: { $preset }
trouble-option-select-preset = Vyber variantu. Hostitel může později upravit jednotlivá pravidla.
trouble-option-changed-preset = Předvolba aplikována: { $preset }.
trouble-option-desc-preset = Předpřipravené sady možností pro běžné varianty.

trouble-preset-classic = Klasický Hasbro
trouble-preset-fast = Rychlý
trouble-preset-brutal = Brutální
trouble-preset-custom = Vlastní
