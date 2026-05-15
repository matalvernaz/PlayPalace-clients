# Liar's Dice — de
# Jeder Spieler hat einen Würfelbecher; Gebote zählen die Gesamtzahl einer Augenzahl
# auf dem ganzen Tisch. 1en sind Joker, außer beim Bieten auf 1en.

game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Jeder Spieler würfelt heimlich unter dem Becher. Reihum bietet ihr immer höhere Mengen einer Augenzahl auf dem ganzen Tisch — oder ruft "Lüge!", wenn ihr dem letzten Gebot nicht traut. Falsch geraten kostet einen Würfel. Wer zuletzt noch Würfel hat, gewinnt.

liarsdice-rules =
    Liar's Dice ist ein Bluffwürfelspiel für 2 bis 6 Spieler.
    Jeder Spieler startet mit 5 Würfeln im Becher. Zu Beginn jeder Runde würfeln alle heimlich.
    Reihum bietet ihr auf die Gesamtzahl einer Augenzahl über alle Würfel — zum Beispiel "drei 4en" heißt: mindestens drei 4en sind da, wenn alle Becher aufgedeckt werden.
    Jedes neue Gebot muss höher sein: gleiche Augenzahl mit höherer Menge, oder höhere Augenzahl mit gleicher oder höherer Menge.
    1en sind Joker — sie zählen zu jedem Gebot außer Geboten auf 1en selbst.
    Auf 1en zu wechseln halbiert die Menge (aufgerundet). Von 1en zurück zu einer normalen Augenzahl verlangt mehr als die doppelte vorherige Menge.
    Statt zu bieten kannst du "Lüge!" rufen, um das letzte Gebot anzufechten. Alle Becher hoch: stimmt das Gebot, verliert der Anfechter einen Würfel; sonst der Bieter.
    Mit aktiviertem Spot On kannst du stattdessen "Spot On" rufen — du wettest, dass das Gebot exakt stimmt. Bei richtig verliert jeder andere einen Würfel; bei falsch verlierst du zwei.
    Mit null Würfeln bist du draußen. Wer zuletzt noch Würfel hat, gewinnt.
    Drücke S, um den Tisch zu prüfen.

ld-set-starting-dice = Startwürfel pro Spieler: { $dice }
ld-desc-starting-dice = Wie viele Würfel jeder Spieler zu Beginn hat. Standard 5. Mehr Würfel = längere Partien, mehr Spielraum zum Bluffen.
ld-prompt-starting-dice = Startwürfel eingeben (3 bis 8)
ld-option-changed-starting-dice = Startwürfel auf { $dice } gesetzt.

ld-toggle-wild-ones = 1en sind Joker: { $enabled }
ld-desc-wild-ones = An: 1en zählen zu jedem Nicht-1-Gebot. Auf 1en zu bieten deaktiviert die Joker für dieses Gebot. Aus macht das Spiel zu reiner Wahrscheinlichkeit ohne Joker.
ld-option-changed-wild-ones = 1-Joker { $enabled }.

ld-toggle-spot-on = Spot-On-Ruf aktiviert: { $enabled }
ld-desc-spot-on = An: zusätzlich zu "Lüge" kannst du "Spot On" rufen — du wettest, dass das Gebot exakt stimmt. Bei richtig verliert jeder andere einen Würfel. Bei falsch verlierst du zwei. Hohes Risiko, hohe Belohnung.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Runde { $round } beginnt. Würfel auf dem Tisch insgesamt: { $total }. Alle würfeln.
ld-your-roll = Deine Würfel diese Runde: { $dice }.
ld-your-counts = Deine Anzahlen: { $counts }.
ld-turn-start = { $player } ist dran. { $bid_state }
ld-no-bid-yet = Noch kein Gebot — eröffne die Runde.
ld-current-bid = Aktuelles Gebot: { $quantity } { $face }.

ld-action-bid = Ein Gebot abgeben
ld-action-call-liar = Lüge rufen
ld-action-call-spot-on = Spot On rufen
ld-bid-prompt = Wähle dein Gebot.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Du bietest { $quantity } { $face }.
    *[player] { $player } bietet { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Du rufst Lüge auf { $target }s Gebot von { $quantity } { $face }.
    *[player] { $player } ruft Lüge auf { $target }s Gebot von { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Du rufst Spot On auf { $target }s Gebot von { $quantity } { $face }.
    *[player] { $player } ruft Spot On auf { $target }s Gebot von { $quantity } { $face }.
}
ld-reveal-header = Becher hoch! Wir zählen die { $face } auf dem Tisch.
ld-reveal-line = { $player } hat gewürfelt: { $dice }.
ld-actual-count = Tatsächliche { $face }-Anzahl (mit Joker-1en): { $count }. Gebot war { $quantity }.
ld-actual-count-no-wild = Tatsächliche { $face }-Anzahl (ohne Joker): { $count }. Gebot war { $quantity }.

ld-liar-bidder-loses = { $bidder } hat zu hoch geboten — verliert einen Würfel.
ld-liar-caller-loses = Das Gebot war ehrlich — { $caller } verliert einen Würfel.
ld-spot-on-correct = Spot on! { $caller } hatte genau richtig — alle anderen verlieren einen Würfel.
ld-spot-on-wrong = Kein Spot on. { $caller } verliert zwei Würfel.

ld-lost-die = { $who ->
    [you] Du verlierst einen Würfel. Du hast jetzt { $remaining } { $remaining ->
        [one] Würfel
        *[other] Würfel
    }.
    *[player] { $player } verliert einen Würfel. Hat jetzt { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Du verlierst { $count } Würfel. Du hast jetzt { $remaining } { $remaining ->
        [one] Würfel
        *[other] Würfel
    }.
    *[player] { $player } verliert { $count } Würfel. Hat jetzt { $remaining }.
}
ld-eliminated = { $player } hat keine Würfel mehr und ist draußen! { $remaining } { $remaining ->
    [one] Spieler
    *[other] Spieler
} übrig.
ld-winner = { $player } ist der letzte mit Würfeln — gewinnt!

ld-status-round = Runde { $round }.
ld-status-your-dice = Deine Würfel: { $dice }.
ld-status-your-counts = Deine Anzahlen: { $counts }.
ld-status-no-dice = Du hast keine Würfel — du bist draußen.
ld-status-current-bid = Aktuelles Gebot: { $quantity } { $face }.
ld-status-no-bid = Noch kein Gebot in dieser Runde.
ld-status-table-total = Würfel auf dem Tisch insgesamt: { $total }.
ld-status-detailed-header = Detaillierter Stand — { $count } Spieler übrig.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] Würfel
    *[other] Würfel
}.
ld-status-detailed-out = { $player }: draußen.
ld-status-detailed-self-suffix = {" "}(du)

ld-face-1 = Einsen
ld-face-2 = Zweien
ld-face-3 = Dreien
ld-face-4 = Vieren
ld-face-5 = Fünfen
ld-face-6 = Sechsen

ld-action-not-your-turn = Du bist nicht dran.
ld-action-not-playing = Die Partie läuft nicht.
ld-action-no-bid-to-call = Noch kein Gebot zum Anfechten.
ld-action-eliminated = Du bist draußen.
