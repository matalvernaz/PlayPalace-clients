# Liar's Dice — sk
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Každý hráč hádže kockami pod pohárikom v utajení. Postupne zvyšujete stávky na celkový počet jednej strany na celom stole — alebo zakričíte "Klamár!", keď neveríte poslednej stávke. Zlý odhad stojí jednu kocku. Vyhráva posledný, kto má kocky.

liarsdice-rules =
    Liar's Dice je blafovacia hra v kocky pre 2 až 6 hráčov.
    Každý hráč začína s 5 kockami v poháriku. Na začiatku každého kola všetci v utajení hádžu.
    Postupne stávkujete na celkový počet jednej strany na všetkých kockách — napríklad "tri 4" znamená, že po odhalení všetkých pohárikov je na stole aspoň tri 4.
    Každá nová stávka musí byť vyššia: rovnaká strana s vyšším počtom, alebo vyššia strana s rovnakým či vyšším počtom.
    Jednotky sú žolíky — počítajú sa do každej stávky okrem stávok na jednotky.
    Prepnutie na stávku na jednotky polovičí množstvo (zaokrúhlené nahor). Návrat z jednotiek na bežnú stranu vyžaduje viac ako dvojnásobok predchádzajúceho množstva.
    Namiesto stávky môžeš zakričať "Klamár!" a spochybniť poslednú stávku. Všetky pohárike hore: ak bola stávka správna, spochybňujúci hráč stráca kocku; inak hráč stávkujúci.
    Pri zapnutom Spot On môžeš zakričať "Spot On" a vsadiť, že je stávka presne správna. Ak máš pravdu, ostatní hráči strácajú po kocke; ak nie, ty strácaš dve.
    Vyradený si pri nule kociek. Vyhráva posledný, kto má kocky.
    Stlač S pre kontrolu stola.

ld-set-starting-dice = Počiatočné kocky na hráča: { $dice }
ld-desc-starting-dice = S koľkými kockami každý hráč začína. Predvolené 5. Viac kociek = dlhšie hry a viac priestoru na blafovanie.
ld-prompt-starting-dice = Zadaj počiatočné kocky (3 až 8)
ld-option-changed-starting-dice = Počiatočné kocky nastavené na { $dice }.

ld-toggle-wild-ones = Jednotky sú žolíky: { $enabled }
ld-desc-wild-ones = Zapnuté: jednotky sa počítajú do každej stávky, ktorá nie je na jednotky. Stávka na jednotky pre túto stávku žolíky vypína. Vypnuté — hra je čistá pravdepodobnosť bez žolíku.
ld-option-changed-wild-ones = Žolík jednotky { $enabled }.

ld-toggle-spot-on = Volanie Spot On povolené: { $enabled }
ld-desc-spot-on = Zapnuté: okrem "Klamára" môžeš zakričať "Spot On" a vsadiť, že je stávka presne správna. Ak máš pravdu, ostatní strácajú po kocke. Ak nie, ty strácaš dve. Vysoké riziko, vysoká odmena.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Začína kolo { $round }. Spolu kociek na stole: { $total }. Všetci hádžu.
ld-your-roll = Tvoje kocky v tomto kole: { $dice }.
ld-your-counts = Tvoje počty: { $counts }.
ld-turn-start = Na rade je { $player }. { $bid_state }
ld-no-bid-yet = Zatiaľ bez stávky — otvor kolo.
ld-current-bid = Aktuálna stávka: { $quantity } { $face }.

ld-action-bid = Stávkuj
ld-action-call-liar = Zakrič Klamár
ld-action-call-spot-on = Zakrič Spot On
ld-bid-prompt = Vyber svoju stávku.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Stávkuješ { $quantity } { $face }.
    *[player] { $player } stávkuje { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Kričíš Klamár na stávku { $target } { $quantity } { $face }.
    *[player] { $player } kričí Klamár na stávku { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Kričíš Spot On na stávku { $target } { $quantity } { $face }.
    *[player] { $player } kričí Spot On na stávku { $target } { $quantity } { $face }.
}
ld-reveal-header = Pohárike hore! Počítame { $face } na stole.
ld-reveal-line = { $player } hodil: { $dice }.
ld-actual-count = Skutočný počet { $face } (vrátane žolíkových 1): { $count }. Stávka bola { $quantity }.
ld-actual-count-no-wild = Skutočný počet { $face } (bez žolíkov): { $count }. Stávka bola { $quantity }.

ld-liar-bidder-loses = { $bidder } preplatil — stráca kocku.
ld-liar-caller-loses = Stávka bola pravdivá — { $caller } stráca kocku.
ld-spot-on-correct = Spot on! { $caller } trafil presne — ostatní strácajú po kocke.
ld-spot-on-wrong = Nie je spot on. { $caller } stráca dve kocky.

ld-lost-die = { $who ->
    [you] Stratil si kocku. Máš teraz { $remaining } { $remaining ->
        [one] kocku
        [few] kocky
        *[other] kociek
    }.
    *[player] { $player } stratil kocku. Má teraz { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Stratil si { $count } kociek. Máš teraz { $remaining } { $remaining ->
        [one] kocku
        [few] kocky
        *[other] kociek
    }.
    *[player] { $player } stratil { $count } kociek. Má teraz { $remaining }.
}
ld-eliminated = { $player } už nemá kocky a je vyradený! Zostáva { $remaining } { $remaining ->
    [one] hráč
    [few] hráči
    *[other] hráčov
}.
ld-winner = { $player } je posledný s kockami — vyhráva!

ld-status-round = Kolo { $round }.
ld-status-your-dice = Tvoje kocky: { $dice }.
ld-status-your-counts = Tvoje počty: { $counts }.
ld-status-no-dice = Nemáš kocky — si vyradený.
ld-status-current-bid = Aktuálna stávka: { $quantity } { $face }.
ld-status-no-bid = V tomto kole bez stávky.
ld-status-table-total = Spolu kociek na stole: { $total }.
ld-status-detailed-header = Podrobný stav — zostáva { $count } hráčov.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kocka
    [few] kocky
    *[other] kociek
}.
ld-status-detailed-out = { $player }: vyradený.
ld-status-detailed-self-suffix = {" "}(ty)

ld-face-1 = jednotky
ld-face-2 = dvojky
ld-face-3 = trojky
ld-face-4 = štvorky
ld-face-5 = päťky
ld-face-6 = šestky

ld-action-not-your-turn = Nie si na rade.
ld-action-not-playing = Hra neprebieha.
ld-action-no-bid-to-call = Zatiaľ nie je stávka na spochybnenie.
ld-action-eliminated = Si vyradený.
