# Liar's Dice — sv
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Varje spelare rullar tärningarna i hemlighet under sin bägare. I tur och ordning bjuder ni allt högre på det totala antalet av en valör runt hela bordet — eller ropar "Lögnare!" om ni inte tror på det senaste budet. Fel gissning kostar en tärning. Den sista med tärningar vinner.

liarsdice-rules =
    Liar's Dice är ett blufftärningsspel för 2 till 6 spelare.
    Varje spelare börjar med 5 tärningar i en bägare. Vid varje rondstart rullar alla i hemlighet.
    I tur och ordning bjuder ni på det totala antalet av en valör över alla tärningar — exempelvis "tre 4:or" betyder att det finns minst tre 4:or när alla bägare avslöjas.
    Varje nytt bud måste vara högre: samma valör med högre antal, eller högre valör med samma eller högre antal.
    Ettor är jokrar — de räknas med i alla bud utom bud på ettor.
    Att byta till bud på ettor halverar mängden (avrundas uppåt). Att gå tillbaka från ettor till en vanlig valör kräver mer än dubbla föregående mängd.
    I stället för bud kan du ropa "Lögnare!" för att utmana det senaste budet. Alla bägare upp: om budet var korrekt förlorar utmanaren en tärning; annars förlorar budgivaren en tärning.
    Med Spot On på kan du i stället ropa "Spot On" och satsa på att budet är exakt rätt. Om du har rätt förlorar alla andra en tärning; annars förlorar du två.
    Eliminerad när du når noll tärningar. Den sista med tärningar vinner.
    Tryck S för att kolla bordet.

ld-set-starting-dice = Starttärningar per spelare: { $dice }
ld-desc-starting-dice = Hur många tärningar varje spelare börjar med. Standard 5. Fler tärningar = längre spel och mer utrymme att bluffa.
ld-prompt-starting-dice = Ange starttärningar (3 till 8)
ld-option-changed-starting-dice = Starttärningar satta till { $dice }.

ld-toggle-wild-ones = Ettor är jokrar: { $enabled }
ld-desc-wild-ones = På: ettor räknas med i alla bud som inte är på ettor. Bud på ettor inaktiverar jokrarna för det budet. Av — spelet blir ren sannolikhet utan joker.
ld-option-changed-wild-ones = Joker-ettor { $enabled }.

ld-toggle-spot-on = Spot On-rop aktiverat: { $enabled }
ld-desc-spot-on = På: utöver "Lögnare" kan du ropa "Spot On" och satsa på att budet är exakt rätt. Om du har rätt förlorar de andra en tärning var. Om du har fel förlorar du två. Hög risk, hög belöning.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Rond { $round } börjar. Totalt antal tärningar på bordet: { $total }. Alla rullar.
ld-your-roll = Dina tärningar denna rond: { $dice }.
ld-your-counts = Dina antal: { $counts }.
ld-turn-start = Det är { $player }s tur. { $bid_state }
ld-no-bid-yet = Inget bud än — öppna ronden.
ld-current-bid = Aktuellt bud: { $quantity } { $face }.

ld-action-bid = Lägg ett bud
ld-action-call-liar = Ropa Lögnare
ld-action-call-spot-on = Ropa Spot On
ld-bid-prompt = Välj ditt bud.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Du bjuder { $quantity } { $face }.
    *[player] { $player } bjuder { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Du ropar Lögnare på { $target }s bud om { $quantity } { $face }.
    *[player] { $player } ropar Lögnare på { $target }s bud om { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Du ropar Spot On på { $target }s bud om { $quantity } { $face }.
    *[player] { $player } ropar Spot On på { $target }s bud om { $quantity } { $face }.
}
ld-reveal-header = Bägarna upp! Vi räknar { $face } runt bordet.
ld-reveal-line = { $player } rullade: { $dice }.
ld-actual-count = Verkligt antal { $face } (med joker-ettor): { $count }. Budet var { $quantity }.
ld-actual-count-no-wild = Verkligt antal { $face } (utan jokrar): { $count }. Budet var { $quantity }.

ld-liar-bidder-loses = { $bidder } bjöd för högt — förlorar en tärning.
ld-liar-caller-loses = Budet var ärligt — { $caller } förlorar en tärning.
ld-spot-on-correct = Spot on! { $caller } träffade exakt — alla andra förlorar en tärning var.
ld-spot-on-wrong = Inte spot on. { $caller } förlorar två tärningar.

ld-lost-die = { $who ->
    [you] Du förlorade en tärning. Du har nu { $remaining } { $remaining ->
        [one] tärning
        *[other] tärningar
    }.
    *[player] { $player } förlorade en tärning. Har nu { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Du förlorade { $count } tärningar. Du har nu { $remaining } { $remaining ->
        [one] tärning
        *[other] tärningar
    }.
    *[player] { $player } förlorade { $count } tärningar. Har nu { $remaining }.
}
ld-eliminated = { $player } är slut på tärningar och är ute! { $remaining } { $remaining ->
    [one] spelare
    *[other] spelare
} kvar.
ld-winner = { $player } är den sista med tärningar — vinner!

ld-status-round = Rond { $round }.
ld-status-your-dice = Dina tärningar: { $dice }.
ld-status-your-counts = Dina antal: { $counts }.
ld-status-no-dice = Du har inga tärningar — du är ute.
ld-status-current-bid = Aktuellt bud: { $quantity } { $face }.
ld-status-no-bid = Inget bud denna rond.
ld-status-table-total = Totalt antal tärningar på bordet: { $total }.
ld-status-detailed-header = Detaljerad status — { $count } spelare kvar.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] tärning
    *[other] tärningar
}.
ld-status-detailed-out = { $player }: ute.
ld-status-detailed-self-suffix = {" "}(du)

ld-face-1 = ettor
ld-face-2 = tvåor
ld-face-3 = treor
ld-face-4 = fyror
ld-face-5 = femmor
ld-face-6 = sexor

ld-action-not-your-turn = Det är inte din tur.
ld-action-not-playing = Spelet pågår inte.
ld-action-no-bid-to-call = Det finns inget bud att utmana.
ld-action-eliminated = Du är ute.
