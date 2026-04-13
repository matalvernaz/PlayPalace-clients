# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = Risiko

# Phase announcements
risk-reinforce-start = { $player } erhält { $armies } Armeen zum Platzieren.
risk-attack-phase = { $player } kann jetzt angreifen.
risk-fortify-phase = { $player } kann jetzt verstärken.

# Reinforce
risk-placed-army = { $player } verstärkt { $territory } ({ $troops } Truppen). { $remaining } verbleibend.

# Attack
risk-attack-from = { $player } greift von { $territory } an.
risk-combat-result =
    { $attacker } greift { $def_territory } von { $att_territory } an.
    Angreifer würfelt: { $att_rolls }. Verteidiger würfelt: { $def_rolls }.
    Angreifer verliert { $att_losses }, Verteidiger verliert { $def_losses }.
risk-conquered = { $player } erobert { $territory }! { $moved } Truppen ziehen ein.
risk-eliminated = { $player } wurde eliminiert!
risk-skip-attack = Angriff überspringen
risk-cancel-attack = Angriff abbrechen

# Fortify
risk-fortify-from = { $player } verstärkt von { $territory }.
risk-fortified = { $player } bewegt { $moved } Truppen von { $source } nach { $dest }.
risk-skip-fortify = Verstärkung überspringen
risk-cancel-fortify = Verstärkung abbrechen

# Cards
risk-cards-traded = { $player } tauscht Karten gegen { $armies } Bonus-Armeen.

# Territory labels by phase
risk-territory-reinforce = { $name }: { $troops } Truppen ({ $remaining } zu platzieren)
risk-territory-attack-from = { $name }: { $troops } Truppen (von hier angreifen)
risk-territory-attack-target = { $name }: { $troops } Truppen ({ $owner })
risk-territory-fortify-from = { $name }: { $troops } Truppen (von hier bewegen)
risk-territory-fortify-to = { $name }: { $troops } Truppen (hierher bewegen)

# Status
risk-status-header = Du kontrollierst { $territories } Territorien mit insgesamt { $troops } Truppen.
risk-status-continent = { $name }: { $owned }/{ $total } Territorien. Bonus: { $bonus }.

# Winner
risk-winner = { $player } hat die Welt erobert!
risk-final-score = { $player }: { $territories } Territorien

# Disabled reasons
risk-not-your-territory = Das ist nicht dein Territorium.
risk-need-more-troops = Du brauchst mindestens 2 Truppen, um anzugreifen oder zu verstärken.
risk-no-adjacent-enemy = Keine angrenzenden feindlichen Territorien.
risk-cannot-attack-own = Du kannst dein eigenes Territorium nicht angreifen.
risk-not-adjacent = Dieses Territorium grenzt nicht an.
risk-same-territory = Kann nicht zum selben Territorium verstärken.

# Options
risk-set-starting-armies = Start-Armeen: { $armies }
risk-desc-starting-armies = Zusätzliche Armeen pro Spieler zu Beginn (0 = auto)
risk-enter-starting-armies = Gib Start-Armeen pro Spieler ein (0 für auto):
risk-option-changed-armies = Start-Armeen auf { $armies } geändert

# Rules
risk-rules =
    Risiko ist ein Weltstrategie-Spiel für 2 bis 6 Spieler.
    Das Brett hat 42 Territorien auf 6 Kontinenten.
    Jeder Zug hat 3 Phasen: Verstärken, Angreifen, Verstärken (Fortify).
    Verstärken: Platziere Armeen auf deinen Territorien. Du erhältst Armeen basierend auf Territorien und Kontinent-Boni.
    Angreifen: Wähle ein Territorium mit 2+ Truppen, dann ein angrenzendes feindliches Territorium. Würfel entscheiden den Kampf.
    Angreifer würfelt bis zu 3 Würfel, Verteidiger bis zu 2. Höchste Würfel werden verglichen.
    Wenn du alle Verteidiger eliminierst, eroberst du das Territorium.
    Verstärken (Fortify): Bewege Truppen zu einem angrenzenden eigenen Territorium.
    Erobere mindestens ein Territorium pro Zug für eine Karte. Tausche Sets aus 3 Karten gegen Bonus-Armeen.
    Eliminiere alle Gegner um zu gewinnen.
    Drücke E für deinen Status.
