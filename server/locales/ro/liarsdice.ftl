# Liar's Dice — ro
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Fiecare jucător aruncă zarurile în secret sub cupă. Pe rând, faceți pariuri tot mai mari pe numărul total al unei fețe la nivelul mesei — sau strigați "Mincinos!" dacă nu credeți ultimul pariu. Greșit înseamnă pierderea unui zar. Câștigă ultimul cu zaruri.

liarsdice-rules =
    Liar's Dice este un joc de cacealma cu zaruri pentru 2 până la 6 jucători.
    Fiecare jucător începe cu 5 zaruri în cupă. La începutul fiecărei runde toți aruncă în secret.
    Pe rând pariați pe numărul total al unei fețe pe toate zarurile — de exemplu "trei 4" înseamnă că la dezvăluirea tuturor cupelor sunt cel puțin trei 4.
    Fiecare pariu nou trebuie să fie mai mare: aceeași față cu cantitate mai mare, sau față mai mare cu cantitate egală sau mai mare.
    1-urile sunt jokere — se numără la orice pariu cu excepția pariurilor pe 1.
    Trecerea la un pariu pe 1 înjumătățește cantitatea (rotunjire în sus). Întoarcerea de la 1 la o față normală cere mai mult decât dublul cantității precedente.
    În loc să pariezi poți striga "Mincinos!" pentru a contesta ultimul pariu. Cupele se dezvăluie: dacă pariul era corect, cel care contestă pierde un zar; altfel pierde cel care a pariat.
    Cu Spot On activat poți striga "Spot On" pariind că pariul este exact corect. Dacă ai dreptate, fiecare alt jucător pierde un zar; dacă nu, tu pierzi două.
    Eliminat când ajungi la zero zaruri. Câștigă ultimul cu zaruri.
    Apasă S pentru a verifica masa.

ld-set-starting-dice = Zaruri de pornire per jucător: { $dice }
ld-desc-starting-dice = Cu câte zaruri începe fiecare jucător. Implicit 5. Mai multe zaruri = jocuri mai lungi și mai mult spațiu pentru cacealma.
ld-prompt-starting-dice = Introdu zarurile de pornire (3 până la 8)
ld-option-changed-starting-dice = Zaruri de pornire setate la { $dice }.

ld-toggle-wild-ones = 1-urile sunt jokere: { $enabled }
ld-desc-wild-ones = Pornit: 1-urile se numără la orice pariu care nu este pe 1. Pariul pe 1 dezactivează jokerele pentru acel pariu. Oprit — jocul este pură probabilitate fără joker.
ld-option-changed-wild-ones = Joker 1 { $enabled }.

ld-toggle-spot-on = Strigare Spot On activată: { $enabled }
ld-desc-spot-on = Pornit: pe lângă "Mincinos" poți striga "Spot On" pariind că pariul este exact. Dacă ai dreptate, ceilalți pierd un zar fiecare. Dacă nu, tu pierzi două. Risc mare, recompensă mare.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Runda { $round } începe. Total zaruri pe masă: { $total }. Toți aruncă.
ld-your-roll = Zarurile tale în această rundă: { $dice }.
ld-your-counts = Numărările tale: { $counts }.
ld-turn-start = Rândul lui { $player }. { $bid_state }
ld-no-bid-yet = Niciun pariu încă — deschide runda.
ld-current-bid = Pariu curent: { $quantity } { $face }.

ld-action-bid = Pariază
ld-action-call-liar = Strigă Mincinos
ld-action-call-spot-on = Strigă Spot On
ld-bid-prompt = Alege pariul tău.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Pariezi { $quantity } { $face }.
    *[player] { $player } pariază { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Strigi Mincinos la pariul lui { $target } de { $quantity } { $face }.
    *[player] { $player } strigă Mincinos la pariul lui { $target } de { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Strigi Spot On la pariul lui { $target } de { $quantity } { $face }.
    *[player] { $player } strigă Spot On la pariul lui { $target } de { $quantity } { $face }.
}
ld-reveal-header = Cupele sus! Numărăm { $face } pe masă.
ld-reveal-line = { $player } a aruncat: { $dice }.
ld-actual-count = Numărul real de { $face } (cu 1 joker): { $count }. Pariul era { $quantity }.
ld-actual-count-no-wild = Numărul real de { $face } (fără jokere): { $count }. Pariul era { $quantity }.

ld-liar-bidder-loses = { $bidder } a pariat prea mult — pierde un zar.
ld-liar-caller-loses = Pariul a fost cinstit — { $caller } pierde un zar.
ld-spot-on-correct = Spot on! { $caller } a nimerit exact — ceilalți pierd un zar fiecare.
ld-spot-on-wrong = Nu e spot on. { $caller } pierde două zaruri.

ld-lost-die = { $who ->
    [you] Ai pierdut un zar. Ai acum { $remaining } { $remaining ->
        [one] zar
        *[other] zaruri
    }.
    *[player] { $player } a pierdut un zar. Are acum { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Ai pierdut { $count } zaruri. Ai acum { $remaining } { $remaining ->
        [one] zar
        *[other] zaruri
    }.
    *[player] { $player } a pierdut { $count } zaruri. Are acum { $remaining }.
}
ld-eliminated = { $player } a rămas fără zaruri și este eliminat! Au mai rămas { $remaining } { $remaining ->
    [one] jucător
    *[other] jucători
}.
ld-winner = { $player } este ultimul cu zaruri — câștigă!

ld-status-round = Runda { $round }.
ld-status-your-dice = Zarurile tale: { $dice }.
ld-status-your-counts = Numărările tale: { $counts }.
ld-status-no-dice = Nu ai zaruri — ai fost eliminat.
ld-status-current-bid = Pariu curent: { $quantity } { $face }.
ld-status-no-bid = Niciun pariu în această rundă.
ld-status-table-total = Total zaruri pe masă: { $total }.
ld-status-detailed-header = Stare detaliată — au mai rămas { $count } jucători.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] zar
    *[other] zaruri
}.
ld-status-detailed-out = { $player }: eliminat.
ld-status-detailed-self-suffix = {" "}(tu)

ld-face-1 = unu
ld-face-2 = doi
ld-face-3 = trei
ld-face-4 = patru
ld-face-5 = cinci
ld-face-6 = șase

ld-action-not-your-turn = Nu este rândul tău.
ld-action-not-playing = Jocul nu este în desfășurare.
ld-action-no-bid-to-call = Nu există încă un pariu de contestat.
ld-action-eliminated = Ești eliminat.
