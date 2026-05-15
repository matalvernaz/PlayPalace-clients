# Liar's Dice — hr
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Svaki igrač baca svoje kocke tajno pod čašom. Naizmjence povisujete oklade na ukupan broj jedne strane na cijelom stolu — ili viknete "Lažljivac!" ako ne vjerujete zadnjoj okladi. Pogrešno = gubitak kocke. Posljednji s kockama pobjeđuje.

liarsdice-rules =
    Liar's Dice je blefersko igra kockama za 2 do 6 igrača.
    Svaki igrač počinje s 5 kocki u čaši. Na početku svake runde svi tajno bacaju.
    Naizmjence postavljate oklade na ukupan broj jedne strane preko svih kocki — npr. "tri 4" znači da je nakon otkrivanja čaša najmanje tri 4.
    Svaka nova oklada mora biti veća: ista strana s većom količinom, ili veća strana s istom ili većom količinom.
    Jedinice su jokeri — broje se u svakoj okladi osim okladi na jedinice.
    Prelazak na okladu na jedinice prepolovljuje količinu (zaokruženo gore). Povratak iz jedinica na običnu stranu zahtijeva više od dvostruke prethodne količine.
    Umjesto oklade možeš viknuti "Lažljivac!" da osporiš zadnju okladu. Sve čaše gore: ako je oklada bila točna, izazivač gubi kocku; inače gubi onaj tko je položio okladu.
    Sa Spot On uključenim možeš viknuti "Spot On" okladivši se da je oklada točno točna. Ako si u pravu, svi drugi gube po kocku; ako ne, ti gubiš dvije.
    Eliminiran kad imaš nula kocki. Posljednji s kockama pobjeđuje.
    Pritisni S za pregled stola.

ld-set-starting-dice = Početne kocke po igraču: { $dice }
ld-desc-starting-dice = S koliko kocki svaki igrač počinje. Zadano 5. Više kocki = duže igre i više prostora za blefiranje.
ld-prompt-starting-dice = Unesi početne kocke (3 do 8)
ld-option-changed-starting-dice = Početne kocke postavljene na { $dice }.

ld-toggle-wild-ones = Jedinice su jokeri: { $enabled }
ld-desc-wild-ones = Uključeno: jedinice se broje u svakoj okladi koja nije na jedinice. Oklada na jedinice isključuje jokere za tu okladu. Isključeno — igra je čista vjerojatnost bez jokera.
ld-option-changed-wild-ones = Joker jedinice { $enabled }.

ld-toggle-spot-on = Poziv Spot On omogućen: { $enabled }
ld-desc-spot-on = Uključeno: uz "Lažljivac" možeš viknuti "Spot On" okladivši se da je oklada točno točna. Točno — drugi gube po kocku. Pogrešno — ti gubiš dvije. Visoki rizik, visoka nagrada.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Runda { $round } počinje. Ukupno kocki na stolu: { $total }. Svi bacaju.
ld-your-roll = Tvoje kocke u ovoj rundi: { $dice }.
ld-your-counts = Tvoji brojevi: { $counts }.
ld-turn-start = Red je na { $player }. { $bid_state }
ld-no-bid-yet = Još nema oklade — otvori rundu.
ld-current-bid = Trenutna oklada: { $quantity } { $face }.

ld-action-bid = Okladi se
ld-action-call-liar = Vikni Lažljivac
ld-action-call-spot-on = Vikni Spot On
ld-bid-prompt = Odaberi okladu.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Okladiš se na { $quantity } { $face }.
    *[player] { $player } okladi se na { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Vičeš Lažljivac na okladu { $target } od { $quantity } { $face }.
    *[player] { $player } viče Lažljivac na okladu { $target } od { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Vičeš Spot On na okladu { $target } od { $quantity } { $face }.
    *[player] { $player } viče Spot On na okladu { $target } od { $quantity } { $face }.
}
ld-reveal-header = Čaše gore! Brojimo { $face } na stolu.
ld-reveal-line = { $player } je bacio: { $dice }.
ld-actual-count = Stvarni broj { $face } (s joker jedinicama): { $count }. Oklada je bila { $quantity }.
ld-actual-count-no-wild = Stvarni broj { $face } (bez jokera): { $count }. Oklada je bila { $quantity }.

ld-liar-bidder-loses = { $bidder } je previše okladio — gubi kocku.
ld-liar-caller-loses = Oklada je bila iskrena — { $caller } gubi kocku.
ld-spot-on-correct = Spot on! { $caller } pogodio točno — drugi gube po kocku.
ld-spot-on-wrong = Nije spot on. { $caller } gubi dvije kocke.

ld-lost-die = { $who ->
    [you] Izgubio si kocku. Imaš sada { $remaining } { $remaining ->
        [one] kocku
        [few] kocke
        *[other] kocki
    }.
    *[player] { $player } je izgubio kocku. Ima sada { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Izgubio si { $count } kocki. Imaš sada { $remaining } { $remaining ->
        [one] kocku
        [few] kocke
        *[other] kocki
    }.
    *[player] { $player } je izgubio { $count } kocki. Ima sada { $remaining }.
}
ld-eliminated = { $player } je ostao bez kocki i eliminiran je! Ostalo { $remaining } { $remaining ->
    [one] igrač
    [few] igrača
    *[other] igrača
}.
ld-winner = { $player } je posljednji s kockama — pobjeđuje!

ld-status-round = Runda { $round }.
ld-status-your-dice = Tvoje kocke: { $dice }.
ld-status-your-counts = Tvoji brojevi: { $counts }.
ld-status-no-dice = Nemaš kocki — eliminiran si.
ld-status-current-bid = Trenutna oklada: { $quantity } { $face }.
ld-status-no-bid = U ovoj rundi nema oklade.
ld-status-table-total = Ukupno kocki na stolu: { $total }.
ld-status-detailed-header = Detaljni status — preostalo { $count } igrača.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kocka
    [few] kocke
    *[other] kocki
}.
ld-status-detailed-out = { $player }: eliminiran.
ld-status-detailed-self-suffix = {" "}(ti)

ld-face-1 = jedinice
ld-face-2 = dvojke
ld-face-3 = trojke
ld-face-4 = četvorke
ld-face-5 = petice
ld-face-6 = šestice

ld-action-not-your-turn = Nije tvoj red.
ld-action-not-playing = Igra nije u tijeku.
ld-action-no-bid-to-call = Još nema oklade za osporavanje.
ld-action-eliminated = Eliminiran si.
