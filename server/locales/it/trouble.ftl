# Trouble — it
game-name-trouble = Trouble

trouble-rules =
    Trouble è un gioco di corsa della famiglia Parcheesi.
    Ogni giocatore inizia con i propri segnalini nella Casa.
    Al tuo turno, fai scattare il dado e muovi uno dei tuoi segnalini.
    Per impostazione predefinita devi ottenere un 6 per liberare un segnalino dalla Casa sul percorso.
    Per impostazione predefinita, un 6 concede anche un turno extra.
    I segnalini si muovono in senso orario sul percorso condiviso fino alla zona di arrivo.
    Atterrare sul segnalino di un avversario lo rimanda nella sua Casa, a meno che lo spazio sia protetto.
    Quando tutti i tuoi segnalini raggiungono l'arrivo, vinci.
    In modalità squadre, la tua squadra vince quando tutti i compagni hanno finito.
    Usa i tasti da 1 a 6 per scegliere un segnalino da muovere, o premi R per tirare.
    Premi E per ascoltare lo stato completo del tavolo in qualsiasi momento.

trouble-action-roll = Far scattare il dado
trouble-action-move-token = Muovi segnalino { $token }
trouble-action-check-board = Controlla il tavolo

trouble-token-label-home = Segnalino { $token }: in Casa
trouble-token-label-track = Segnalino { $token }: spazio { $position } del percorso
trouble-token-label-finish-lane = Segnalino { $token }: corsia di arrivo { $position } di { $total }
trouble-token-label-finished = Segnalino { $token }: arrivato

trouble-rolled = { $player } ha tirato un { $roll }.
trouble-leave-home = { $player } libera il segnalino { $token } sul percorso.
trouble-advance-track = { $player } muove il segnalino { $token } allo spazio { $position }.
trouble-enter-finish-lane = { $player } porta il segnalino { $token } nella corsia di arrivo.
trouble-advance-finish-lane =
    { $player } avanza il segnalino { $token } allo spazio { $position } di { $total } della corsia di arrivo.
trouble-token-finished = Il segnalino { $token } di { $player } raggiunge l'arrivo.
trouble-bump =
    Il segnalino { $token } di { $player } rimanda il segnalino { $opp_token } di { $opponent } a Casa.
trouble-no-legal-move = { $player } non ha mosse legali. Il turno passa.
trouble-extra-turn = { $player } ottiene un turno extra per il 6.

trouble-winner = { $player } vince! Tutti i segnalini all'arrivo.
trouble-team-winner = La squadra { $team } vince! Tutti i compagni hanno finito.
trouble-final-standing = { $player }: { $finished } segnalini all'arrivo su { $total }.

trouble-turn-summary =
    Hai { $own_home } in Casa, { $own_track } sul percorso, { $own_finished } all'arrivo.
    Avversari: { $opponents }.
trouble-opponent-summary = { $name }: { $home } casa, { $track } percorso, { $finished } arrivo

trouble-board-status =
    I tuoi segnalini: { $own_tokens }.
    Segnalini avversari: { $opp_tokens }.

trouble-reason-not-rolled = Prima fai scattare il dado.
trouble-reason-already-rolled = Hai già tirato. Scegli un segnalino da muovere.
trouble-reason-no-legal-moves = Nessuna mossa legale per questo tiro.
trouble-reason-token-home-needs-six = Questo segnalino è in Casa. Serve un 6 per liberarlo.
trouble-reason-token-home-needs-any = Questo segnalino è in Casa. Qualsiasi tiro lo libera.
trouble-reason-token-home-no-qualifying-roll =
    Questo segnalino è in Casa e il tuo tiro non basta a liberarlo.
trouble-reason-token-finished = Questo segnalino è già arrivato.
trouble-reason-overshoot-wastes = Questo segnalino non può muoversi di { $roll } spazi senza superare l'arrivo.
trouble-reason-blocked = Questa mossa è bloccata.

trouble-option-track-size = Lunghezza del percorso: { $track_size } spazi
trouble-option-select-track-size = Seleziona il numero di spazi del percorso.
trouble-option-changed-track-size = Percorso impostato a { $track_size } spazi.
trouble-option-desc-track-size = Numero di spazi sul percorso condiviso.

trouble-option-tokens-per-player = Segnalini per giocatore: { $tokens }
trouble-option-enter-tokens-per-player = Inserisci i segnalini per giocatore (2-6):
trouble-option-changed-tokens-per-player = Segnalini per giocatore impostati a { $tokens }.
trouble-option-desc-tokens-per-player = Numero di segnalini che ogni giocatore porta all'arrivo.

trouble-option-extra-turn-on-six = Turno extra al 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Turno extra al 6 { $enabled ->
    [on] attivato.
    [off] disattivato.
   *[other] aggiornato.
}
trouble-option-desc-extra-turn-on-six =
    Attivo: un 6 concede un turno extra (regola classica Hasbro).

trouble-option-six-to-leave-home = Richiedi 6 per uscire dalla Casa: { $enabled }
trouble-option-changed-six-to-leave-home = Sei per uscire dalla Casa { $enabled ->
    [on] attivato.
    [off] disattivato.
   *[other] aggiornato.
}
trouble-option-desc-six-to-leave-home =
    Attivo: serve un 6 per liberare un segnalino dalla Casa. Disattivo: qualsiasi tiro lo libera.

trouble-option-safe-spaces = Spazi sicuri: { $mode }
trouble-option-select-safe-spaces = Seleziona la modalità degli spazi sicuri.
trouble-option-changed-safe-spaces = Spazi sicuri impostati a { $mode }.
trouble-option-desc-safe-spaces = Decidi se i segnalini possono essere protetti dagli urti.

trouble-safe-mode-none = Nessuno
trouble-safe-mode-home-stretch = Solo rettilineo finale
trouble-safe-mode-every-seventh = Ogni 7º spazio

trouble-option-finish-behavior = Arrivo: { $mode }
trouble-option-select-finish-behavior = Seleziona il comportamento di arrivo.
trouble-option-changed-finish-behavior = Comportamento di arrivo impostato a { $mode }.
trouble-option-desc-finish-behavior = Come viene gestito un tiro che supera l'arrivo.

trouble-finish-mode-exact = Tiro esatto richiesto
trouble-finish-mode-bounce = Rimbalzo per eccesso
trouble-finish-mode-allow = Superamento consentito

trouble-option-bot-difficulty = Difficoltà del bot: { $level }
trouble-option-select-bot-difficulty = Seleziona la difficoltà del bot.
trouble-option-changed-bot-difficulty = Difficoltà del bot impostata a { $level }.
trouble-option-desc-bot-difficulty = Forza dei bot integrati.

trouble-bot-difficulty-naive = Ingenuo
trouble-bot-difficulty-greedy = Avido

trouble-option-preset = Preimpostazione: { $preset }
trouble-option-select-preset = Scegli una variante. L'host può modificare regole singole dopo.
trouble-option-changed-preset = Preimpostazione applicata: { $preset }.
trouble-option-desc-preset = Pacchetti di opzioni preconfigurati per varianti comuni.

trouble-preset-classic = Classico Hasbro
trouble-preset-fast = Rapido
trouble-preset-brutal = Brutale
trouble-preset-custom = Personalizzato
