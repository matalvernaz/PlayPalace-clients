# Trouble — nl
game-name-trouble = Trouble

trouble-rules =
    Trouble is een racespel uit de Parcheesi-familie.
    Iedere speler begint met zijn pionnen in Huis.
    Op je beurt activeer je de dobbelsteen en verplaats je één van je pionnen.
    Standaard moet je 6 gooien om een pion van Huis op de baan te brengen.
    Standaard geeft een 6 ook een extra beurt.
    Pionnen lopen met de klok mee over de gedeelde baan naar de finish.
    Op de pion van een tegenstander landen stuurt die terug naar Huis, tenzij het vakje beschermd is.
    Als al je pionnen de finish bereiken, win je.
    In teammodus wint je team wanneer alle teamgenoten zijn binnen.
    Gebruik 1 tot 6 om een pion te kiezen, of R om te gooien.
    Druk op E om op elk moment de volledige bordstatus te horen.

trouble-action-roll = Dobbelsteen poppen
trouble-action-move-token = Pion { $token } verplaatsen
trouble-action-check-board = Bord bekijken

trouble-token-label-home = Pion { $token }: in Huis
trouble-token-label-track = Pion { $token }: baanvak { $position }
trouble-token-label-finish-lane = Pion { $token }: finishbaan { $position } van { $total }
trouble-token-label-finished = Pion { $token }: gefinisht

trouble-rolled = { $player } gooide een { $roll }.
trouble-leave-home = { $player } brengt pion { $token } op de baan.
trouble-advance-track = { $player } verplaatst pion { $token } naar baanvak { $position }.
trouble-enter-finish-lane = { $player } brengt pion { $token } in de finishbaan.
trouble-advance-finish-lane =
    { $player } zet pion { $token } op finishbaan-vak { $position } van { $total }.
trouble-token-finished = Pion { $token } van { $player } bereikt de finish.
trouble-bump =
    Pion { $token } van { $player } stuurt pion { $opp_token } van { $opponent } terug naar Huis.
trouble-no-legal-move = { $player } heeft geen geldige zet. De beurt gaat verder.
trouble-extra-turn = { $player } krijgt een extra beurt voor de 6.

trouble-winner = { $player } wint! Alle pionnen aan de finish.
trouble-team-winner = Team { $team } wint! Alle teamgenoten zijn binnen.
trouble-final-standing = { $player }: { $finished } van { $total } pionnen binnen.

trouble-turn-summary =
    Je hebt { $own_home } in Huis, { $own_track } op de baan, { $own_finished } gefinisht.
    Tegenstanders: { $opponents }.
trouble-opponent-summary = { $name }: { $home } huis, { $track } baan, { $finished } finish

trouble-board-status =
    Jouw pionnen: { $own_tokens }.
    Pionnen tegenstander: { $opp_tokens }.

trouble-reason-not-rolled = Pop eerst de dobbelsteen.
trouble-reason-already-rolled = Je hebt al gepopt. Kies een pion om te verplaatsen.
trouble-reason-no-legal-moves = Geen geldige zetten voor deze worp.
trouble-reason-token-home-needs-six = Deze pion staat in Huis. Je hebt een 6 nodig om hem te laten gaan.
trouble-reason-token-home-needs-any = Deze pion staat in Huis. Elke worp laat hem gaan.
trouble-reason-token-home-no-qualifying-roll =
    Deze pion staat in Huis en je worp voldoet niet om hem te laten gaan.
trouble-reason-token-finished = Deze pion is al gefinisht.
trouble-reason-overshoot-wastes = Deze pion kan geen { $roll } vakken bewegen zonder voorbij de finish te schieten.
trouble-reason-blocked = Deze zet is geblokkeerd.

trouble-option-track-size = Baanlengte: { $track_size } vakken
trouble-option-select-track-size = Kies het aantal vakken op de baan.
trouble-option-changed-track-size = Baan ingesteld op { $track_size } vakken.
trouble-option-desc-track-size = Aantal vakken op de gedeelde baan.

trouble-option-tokens-per-player = Pionnen per speler: { $tokens }
trouble-option-enter-tokens-per-player = Voer pionnen per speler in (2 tot 6):
trouble-option-changed-tokens-per-player = Pionnen per speler ingesteld op { $tokens }.
trouble-option-desc-tokens-per-player = Aantal pionnen dat elke speler naar de finish brengt.

trouble-option-extra-turn-on-six = Extra beurt bij 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Extra beurt bij 6 { $enabled ->
    [on] aan.
    [off] uit.
   *[other] bijgewerkt.
}
trouble-option-desc-extra-turn-on-six =
    Aan: een 6 geeft een extra beurt (klassieke Hasbro-regel).

trouble-option-six-to-leave-home = 6 vereist om Huis te verlaten: { $enabled }
trouble-option-changed-six-to-leave-home = Zes om Huis te verlaten { $enabled ->
    [on] aan.
    [off] uit.
   *[other] bijgewerkt.
}
trouble-option-desc-six-to-leave-home =
    Aan: speler moet 6 gooien om een pion uit Huis te halen. Uit: elke worp haalt hem uit.

trouble-option-safe-spaces = Veilige vakken: { $mode }
trouble-option-select-safe-spaces = Kies de modus voor veilige vakken.
trouble-option-changed-safe-spaces = Veilige vakken ingesteld op { $mode }.
trouble-option-desc-safe-spaces = Bepaal of pionnen beschermd kunnen worden tegen klappen.

trouble-safe-mode-none = Geen
trouble-safe-mode-home-stretch = Alleen finishrechte
trouble-safe-mode-every-seventh = Elke 7e vak

trouble-option-finish-behavior = Finish: { $mode }
trouble-option-select-finish-behavior = Kies finishgedrag.
trouble-option-changed-finish-behavior = Finishgedrag ingesteld op { $mode }.
trouble-option-desc-finish-behavior = Hoe een worp die de finish voorbijschiet wordt behandeld.

trouble-finish-mode-exact = Exacte worp vereist
trouble-finish-mode-bounce = Overschot kaatst terug
trouble-finish-mode-allow = Overschot toegestaan

trouble-option-bot-difficulty = Bot-moeilijkheid: { $level }
trouble-option-select-bot-difficulty = Kies bot-moeilijkheid.
trouble-option-changed-bot-difficulty = Bot-moeilijkheid ingesteld op { $level }.
trouble-option-desc-bot-difficulty = Sterkte van de ingebouwde bots.

trouble-bot-difficulty-naive = Naïef
trouble-bot-difficulty-greedy = Gulzig

trouble-option-preset = Vooraf ingesteld: { $preset }
trouble-option-select-preset = Kies een variant. De host kan daarna regels apart aanpassen.
trouble-option-changed-preset = Vooraf ingesteld toegepast: { $preset }.
trouble-option-desc-preset = Vooraf gebundelde optiesets voor veelvoorkomende varianten.

trouble-preset-classic = Klassiek Hasbro
trouble-preset-fast = Snel
trouble-preset-brutal = Bruut
trouble-preset-custom = Aangepast
