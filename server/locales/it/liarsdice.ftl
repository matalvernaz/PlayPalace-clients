# Liar's Dice — it
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Ogni giocatore lancia i dadi in segreto sotto il bicchiere. A turno, si rilanciano puntate sempre più alte sul totale di una faccia in tutto il tavolo — oppure si grida "Bugiardo!" se non si crede all'ultima puntata. Sbagliando, perdi un dado. Vince l'ultimo con dadi.

liarsdice-rules =
    Liar's Dice è un gioco di bluff con i dadi per 2-6 giocatori.
    Ogni giocatore parte con 5 dadi nel bicchiere. All'inizio di ogni round, tutti lanciano i dadi in segreto.
    A turno si fanno puntate sul totale di una faccia su tutti i dadi del tavolo — per esempio, "tre 4" significa che ci sono almeno tre 4 quando tutti i bicchieri vengono scoperti.
    Ogni nuova puntata deve essere più alta della precedente: stessa faccia con più quantità, o faccia più alta con quantità uguale o superiore.
    Gli 1 sono jolly — contano per qualsiasi puntata tranne quando si punta sugli 1 stessi.
    Passare a una puntata sugli 1 dimezza la quantità (arrotondata per eccesso). Tornare dagli 1 a una faccia normale richiede più del doppio della quantità precedente.
    Invece di puntare puoi gridare "Bugiardo!" per contestare la puntata. Tutti i bicchieri su: se la puntata era giusta, lo sfidante perde un dado; altrimenti chi ha puntato perde un dado.
    Con Spot On attivo puoi gridare "Spot On" scommettendo che la puntata sia esatta. Se hai ragione, tutti gli altri perdono un dado; se sbagli, ne perdi due.
    Eliminato a zero dadi. Vince chi ha ancora dadi.
    Premi S per controllare il tavolo.

ld-set-starting-dice = Dadi iniziali per giocatore: { $dice }
ld-desc-starting-dice = Con quanti dadi ogni giocatore parte. Default 5. Più dadi = partite più lunghe e più spazio per il bluff.
ld-prompt-starting-dice = Inserisci i dadi iniziali (3-8)
ld-option-changed-starting-dice = Dadi iniziali impostati a { $dice }.

ld-toggle-wild-ones = Gli 1 sono jolly: { $enabled }
ld-desc-wild-ones = Attivo: gli 1 contano per qualsiasi puntata non sugli 1. Puntare sugli 1 disabilita i jolly per quella puntata. Disattivo, il gioco è pura probabilità senza jolly.
ld-option-changed-wild-ones = Jolly 1 { $enabled }.

ld-toggle-spot-on = Chiamata Spot On attiva: { $enabled }
ld-desc-spot-on = Attivo: oltre a "Bugiardo", puoi chiamare "Spot On" scommettendo che la puntata sia esatta. Se hai ragione, gli altri perdono un dado. Se sbagli, ne perdi due. Alto rischio, alta ricompensa.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Round { $round } inizia. Dadi totali sul tavolo: { $total }. Tutti lanciano.
ld-your-roll = I tuoi dadi in questo round: { $dice }.
ld-your-counts = I tuoi conteggi: { $counts }.
ld-turn-start = Turno di { $player }. { $bid_state }
ld-no-bid-yet = Nessuna puntata — apri il round.
ld-current-bid = Puntata attuale: { $quantity } { $face }.

ld-action-bid = Fai una puntata
ld-action-call-liar = Chiama Bugiardo
ld-action-call-spot-on = Chiama Spot On
ld-bid-prompt = Scegli la tua puntata.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Punti { $quantity } { $face }.
    *[player] { $player } punta { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Chiami Bugiardo sulla puntata di { $target } di { $quantity } { $face }.
    *[player] { $player } chiama Bugiardo sulla puntata di { $target } di { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Chiami Spot On sulla puntata di { $target } di { $quantity } { $face }.
    *[player] { $player } chiama Spot On sulla puntata di { $target } di { $quantity } { $face }.
}
ld-reveal-header = Bicchieri su! Contiamo i { $face } sul tavolo.
ld-reveal-line = { $player } ha tirato: { $dice }.
ld-actual-count = Conteggio reale di { $face } (con 1 jolly): { $count }. La puntata era { $quantity }.
ld-actual-count-no-wild = Conteggio reale di { $face } (senza jolly): { $count }. La puntata era { $quantity }.

ld-liar-bidder-loses = { $bidder } ha puntato troppo — perde un dado.
ld-liar-caller-loses = La puntata era giusta — { $caller } perde un dado.
ld-spot-on-correct = Spot on! { $caller } ha azzeccato esattamente — tutti gli altri perdono un dado.
ld-spot-on-wrong = Non è spot on. { $caller } perde due dadi.

ld-lost-die = { $who ->
    [you] Perdi un dado. Ora hai { $remaining } { $remaining ->
        [one] dado
        *[other] dadi
    }.
    *[player] { $player } perde un dado. Ora ne ha { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Perdi { $count } dadi. Ora hai { $remaining } { $remaining ->
        [one] dado
        *[other] dadi
    }.
    *[player] { $player } perde { $count } dadi. Ora ne ha { $remaining }.
}
ld-eliminated = { $player } è senza dadi ed è eliminato! Rimangono { $remaining } { $remaining ->
    [one] giocatore
    *[other] giocatori
}.
ld-winner = { $player } è l'ultimo con dadi — vince!

ld-status-round = Round { $round }.
ld-status-your-dice = I tuoi dadi: { $dice }.
ld-status-your-counts = I tuoi conteggi: { $counts }.
ld-status-no-dice = Non hai dadi — sei eliminato.
ld-status-current-bid = Puntata attuale: { $quantity } { $face }.
ld-status-no-bid = Nessuna puntata in questo round.
ld-status-table-total = Dadi totali sul tavolo: { $total }.
ld-status-detailed-header = Stato dettagliato — { $count } giocatori rimasti.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] dado
    *[other] dadi
}.
ld-status-detailed-out = { $player }: eliminato.
ld-status-detailed-self-suffix = {" "}(tu)

ld-face-1 = uno
ld-face-2 = due
ld-face-3 = tre
ld-face-4 = quattro
ld-face-5 = cinque
ld-face-6 = sei

ld-action-not-your-turn = Non è il tuo turno.
ld-action-not-playing = La partita non è in corso.
ld-action-no-bid-to-call = Nessuna puntata da contestare.
ld-action-eliminated = Sei eliminato.
