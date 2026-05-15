# Liar's Dice — sl
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Vsak igralec skrivaj vrže kocke pod skodelico. Izmenjaje povečujete stave na skupno število strani na celi mizi — ali zakričite "Lažnivec!", če ne verjamete zadnji stavi. Napaka stane kocko. Zadnji s kockami zmaga.

liarsdice-rules =
    Liar's Dice je blefirska igra s kockami za 2 do 6 igralcev.
    Vsak igralec začne s 5 kockami v skodelici. Na začetku vsake runde vsi skrivaj vržejo.
    Izmenjaje stavite na skupno število strani na vseh kockah — npr. "tri 4" pomeni, da je po razkritju vseh skodelic vsaj tri 4.
    Vsaka nova stava mora biti večja: enaka stran z večjo količino ali višja stran z enako ali večjo količino.
    Enice so jokerji — štejejo se v vse stave razen na enice.
    Prehod na stavo na enice prepolovi količino (zaokroženo navzgor). Vrnitev iz enic na običajno stran zahteva več kot dvojno prejšnjo količino.
    Namesto stave lahko zakričiš "Lažnivec!" in izpodbiješ zadnjo stavo. Vse skodelice gor: če je stava bila pravilna, izpodbijajoči izgubi kocko; sicer izgubi stavitelj.
    Z vklopljenim Spot On lahko zakričiš "Spot On" in staviš, da je stava točno pravilna. Če imaš prav, drugi izgubijo po kocko; sicer ti izgubiš dve.
    Izločen pri nič kockah. Zadnji s kockami zmaga.
    Pritisni S za pregled mize.

ld-set-starting-dice = Začetne kocke na igralca: { $dice }
ld-desc-starting-dice = S koliko kockami vsak igralec začne. Privzeto 5. Več kock = daljše igre in več prostora za blef.
ld-prompt-starting-dice = Vnesi začetne kocke (3 do 8)
ld-option-changed-starting-dice = Začetne kocke nastavljene na { $dice }.

ld-toggle-wild-ones = Enice so jokerji: { $enabled }
ld-desc-wild-ones = Vklopljeno: enice se štejejo v vsako stavo, ki ni na enice. Stava na enice izklopi jokerje za to stavo. Izklopljeno — igra je čista verjetnost brez jokerja.
ld-option-changed-wild-ones = Joker enice { $enabled }.

ld-toggle-spot-on = Klic Spot On omogočen: { $enabled }
ld-desc-spot-on = Vklopljeno: poleg "Lažnivec" lahko zakričiš "Spot On" in staviš, da je stava točno pravilna. Pravilno — drugi izgubijo po kocko. Napačno — ti izgubiš dve. Visoko tveganje, visoka nagrada.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Runda { $round } se začne. Skupaj kock na mizi: { $total }. Vsi vržejo.
ld-your-roll = Tvoje kocke v tej rundi: { $dice }.
ld-your-counts = Tvoje številke: { $counts }.
ld-turn-start = Na potezi je { $player }. { $bid_state }
ld-no-bid-yet = Še brez stave — odpri rundo.
ld-current-bid = Trenutna stava: { $quantity } { $face }.

ld-action-bid = Postavi stavo
ld-action-call-liar = Zakliči Lažnivec
ld-action-call-spot-on = Zakliči Spot On
ld-bid-prompt = Izberi stavo.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Staviš { $quantity } { $face }.
    *[player] { $player } stavi { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Zaklikneš Lažnivec na stavo { $target } { $quantity } { $face }.
    *[player] { $player } zakliče Lažnivec na stavo { $target } { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Zaklikneš Spot On na stavo { $target } { $quantity } { $face }.
    *[player] { $player } zakliče Spot On na stavo { $target } { $quantity } { $face }.
}
ld-reveal-header = Skodelice gor! Štejemo { $face } na mizi.
ld-reveal-line = { $player } je vrgel: { $dice }.
ld-actual-count = Dejansko število { $face } (z joker enicami): { $count }. Stava je bila { $quantity }.
ld-actual-count-no-wild = Dejansko število { $face } (brez jokerjev): { $count }. Stava je bila { $quantity }.

ld-liar-bidder-loses = { $bidder } je preveč stavil — izgubi kocko.
ld-liar-caller-loses = Stava je bila poštena — { $caller } izgubi kocko.
ld-spot-on-correct = Spot on! { $caller } je zadel točno — drugi izgubijo po kocko.
ld-spot-on-wrong = Ni spot on. { $caller } izgubi dve kocki.

ld-lost-die = { $who ->
    [you] Izgubil si kocko. Imaš zdaj { $remaining } { $remaining ->
        [one] kocko
        [two] kocki
        [few] kocke
        *[other] kock
    }.
    *[player] { $player } je izgubil kocko. Ima zdaj { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Izgubil si { $count } kock. Imaš zdaj { $remaining } { $remaining ->
        [one] kocko
        [two] kocki
        [few] kocke
        *[other] kock
    }.
    *[player] { $player } je izgubil { $count } kock. Ima zdaj { $remaining }.
}
ld-eliminated = { $player } je ostal brez kock in je izločen! Ostalo { $remaining } { $remaining ->
    [one] igralec
    [two] igralca
    [few] igralci
    *[other] igralcev
}.
ld-winner = { $player } je zadnji s kockami — zmaga!

ld-status-round = Runda { $round }.
ld-status-your-dice = Tvoje kocke: { $dice }.
ld-status-your-counts = Tvoje številke: { $counts }.
ld-status-no-dice = Nimaš kock — izločen si.
ld-status-current-bid = Trenutna stava: { $quantity } { $face }.
ld-status-no-bid = V tej rundi ni stave.
ld-status-table-total = Skupaj kock na mizi: { $total }.
ld-status-detailed-header = Podroben status — ostalo { $count } igralcev.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kocka
    [two] kocki
    [few] kocke
    *[other] kock
}.
ld-status-detailed-out = { $player }: izločen.
ld-status-detailed-self-suffix = {" "}(ti)

ld-face-1 = enke
ld-face-2 = dvojke
ld-face-3 = trojke
ld-face-4 = štirke
ld-face-5 = petke
ld-face-6 = šestke

ld-action-not-your-turn = Nisi na potezi.
ld-action-not-playing = Igra ne poteka.
ld-action-no-bid-to-call = Še ni stave za izpodbijanje.
ld-action-eliminated = Izločen si.
