# Liar's Dice — cs
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Každý hráč hází kostkami pod kelímkem v utajení. Postupně zvyšujete sázky na celkový počet jedné strany na celém stole — nebo zakřičíte "Lhář!", když nevěříte poslední sázce. Špatný odhad stojí jednu kostku. Vyhrává poslední, kdo má kostky.

liarsdice-rules =
    Liar's Dice je blafovací hra v kostky pro 2 až 6 hráčů.
    Každý hráč začíná s 5 kostkami v kelímku. Na začátku každého kola všichni v utajení hází.
    Postupně sázíte na celkový počet jedné strany na všech kostkách — například "tři 4" znamená, že po odkrytí všech kelímků je na stole alespoň tři 4.
    Každá nová sázka musí být vyšší: stejná strana s vyšším počtem, nebo vyšší strana se stejným či vyšším počtem.
    Jedničky jsou žolíky — počítají se do každé sázky kromě sázek na jedničky.
    Přepnutí na sázku na jedničky půlí množství (zaokrouhleno nahoru). Návrat z jedniček na běžnou stranu vyžaduje více než dvojnásobek předchozího množství.
    Místo sázky můžeš zakřičet "Lhář!" a zpochybnit poslední sázku. Všechny kelímky vzhůru: pokud byla sázka správná, hráč zpochybňující ztrácí kostku; jinak hráč sázející.
    Při zapnutém Spot On můžeš místo toho zakřičet "Spot On" a vsadit, že je sázka přesně správná. Pokud máš pravdu, každý jiný hráč ztrácí kostku; pokud ne, ty ztrácíš dvě.
    Vyřazen jsi při nule kostek. Vyhrává poslední, kdo má kostky.
    Stiskni S pro kontrolu stolu.

ld-set-starting-dice = Počáteční kostky na hráče: { $dice }
ld-desc-starting-dice = S kolika kostkami každý hráč začíná. Výchozí 5. Více kostek = delší hry a více prostoru pro blafování.
ld-prompt-starting-dice = Zadej počáteční kostky (3 až 8)
ld-option-changed-starting-dice = Počáteční kostky nastaveny na { $dice }.

ld-toggle-wild-ones = Jedničky jsou žolíky: { $enabled }
ld-desc-wild-ones = Zapnuto: jedničky se počítají do každé sázky, která není na jedničky. Sázka na jedničky pro tu sázku žolíky vypíná. Vypnuto — hra je čistá pravděpodobnost bez žolíku.
ld-option-changed-wild-ones = Žolík jedničky { $enabled }.

ld-toggle-spot-on = Volání Spot On povoleno: { $enabled }
ld-desc-spot-on = Zapnuto: kromě "Lháře" můžeš zakřičet "Spot On" a vsadit, že je sázka přesně správná. Když máš pravdu, ostatní ztrácejí po kostce. Když ne, ty ztrácíš dvě. Vysoké riziko, vysoká odměna.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Začíná kolo { $round }. Celkem kostek na stole: { $total }. Všichni hází.
ld-your-roll = Tvoje kostky v tomto kole: { $dice }.
ld-your-counts = Tvoje počty: { $counts }.
ld-turn-start = Na řadě je { $player }. { $bid_state }
ld-no-bid-yet = Zatím bez sázky — otevři kolo.
ld-current-bid = Současná sázka: { $quantity } { $face }.

ld-action-bid = Sázej
ld-action-call-liar = Zakřič Lháře
ld-action-call-spot-on = Zakřič Spot On
ld-bid-prompt = Vyber svou sázku.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Sázíš { $quantity } { $face }.
    *[player] { $player } sází { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Křičíš Lhář na sázku { $target } { $quantity } { $face }.
    *[player] { $player } křičí Lhář na sázku { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Křičíš Spot On na sázku { $target } { $quantity } { $face }.
    *[player] { $player } křičí Spot On na sázku { $target } { $quantity } { $face }.
}
ld-reveal-header = Kelímky vzhůru! Počítáme { $face } na stole.
ld-reveal-line = { $player } hodil: { $dice }.
ld-actual-count = Skutečný počet { $face } (včetně žolíkových 1): { $count }. Sázka byla { $quantity }.
ld-actual-count-no-wild = Skutečný počet { $face } (bez žolíků): { $count }. Sázka byla { $quantity }.

ld-liar-bidder-loses = { $bidder } přesázel — ztrácí kostku.
ld-liar-caller-loses = Sázka byla pravdivá — { $caller } ztrácí kostku.
ld-spot-on-correct = Spot on! { $caller } trefil přesně — ostatní ztrácejí po kostce.
ld-spot-on-wrong = Není spot on. { $caller } ztrácí dvě kostky.

ld-lost-die = { $who ->
    [you] Ztratil jsi kostku. Máš nyní { $remaining } { $remaining ->
        [one] kostku
        [few] kostky
        *[other] kostek
    }.
    *[player] { $player } ztratil kostku. Má nyní { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Ztratil jsi { $count } kostek. Máš nyní { $remaining } { $remaining ->
        [one] kostku
        [few] kostky
        *[other] kostek
    }.
    *[player] { $player } ztratil { $count } kostek. Má nyní { $remaining }.
}
ld-eliminated = { $player } už nemá kostky a je vyřazen! Zbývá { $remaining } { $remaining ->
    [one] hráč
    [few] hráči
    *[other] hráčů
}.
ld-winner = { $player } je poslední s kostkami — vyhrává!

ld-status-round = Kolo { $round }.
ld-status-your-dice = Tvoje kostky: { $dice }.
ld-status-your-counts = Tvoje počty: { $counts }.
ld-status-no-dice = Nemáš kostky — jsi vyřazen.
ld-status-current-bid = Současná sázka: { $quantity } { $face }.
ld-status-no-bid = Zatím v tomto kole bez sázky.
ld-status-table-total = Celkem kostek na stole: { $total }.
ld-status-detailed-header = Podrobný stav — zbývá { $count } hráčů.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kostka
    [few] kostky
    *[other] kostek
}.
ld-status-detailed-out = { $player }: vyřazen.
ld-status-detailed-self-suffix = {" "}(ty)

ld-face-1 = jedničky
ld-face-2 = dvojky
ld-face-3 = trojky
ld-face-4 = čtyřky
ld-face-5 = pětky
ld-face-6 = šestky

ld-action-not-your-turn = Nejsi na řadě.
ld-action-not-playing = Hra neběží.
ld-action-no-bid-to-call = Zatím není sázka k zpochybnění.
ld-action-eliminated = Jsi vyřazen.
