# Trouble — de
game-name-trouble = Trouble

trouble-rules =
    Trouble ist ein Wettlaufspiel aus der Parcheesi-Familie.
    Jeder Spieler beginnt mit seinen Spielsteinen im Haus.
    Im eigenen Zug löst du den Würfel aus und ziehst einen deiner Spielsteine.
    Standardmäßig brauchst du eine 6, um einen Stein aus dem Haus auf die Bahn zu bringen.
    Standardmäßig gibt eine 6 außerdem einen Extra-Zug.
    Die Steine ziehen im Uhrzeigersinn über die gemeinsame Bahn zum Zielbereich.
    Auf einem gegnerischen Stein zu landen schickt diesen zurück ins Haus, außer das Feld ist geschützt.
    Wenn alle deine Steine im Ziel sind, gewinnst du.
    Im Team-Modus gewinnt dein Team, wenn alle Teammitglieder im Ziel sind.
    Drücke 1 bis 6 zum Auswählen eines Steins oder R zum Würfeln.
    Drücke E, um jederzeit den vollen Brettstatus zu hören.

trouble-action-roll = Würfel auslösen
trouble-action-move-token = Stein { $token } bewegen
trouble-action-check-board = Brett anschauen

trouble-token-label-home = Stein { $token }: im Haus
trouble-token-label-track = Stein { $token }: Bahnfeld { $position }
trouble-token-label-finish-lane = Stein { $token }: Zielgerade { $position } von { $total }
trouble-token-label-finished = Stein { $token }: im Ziel

trouble-rolled = { $player } würfelte eine { $roll }.
trouble-leave-home = { $player } bringt Stein { $token } auf die Bahn.
trouble-advance-track = { $player } zieht Stein { $token } auf Bahnfeld { $position }.
trouble-enter-finish-lane = { $player } zieht Stein { $token } in die Zielgerade.
trouble-advance-finish-lane =
    { $player } rückt Stein { $token } auf Zielgeraden-Feld { $position } von { $total }.
trouble-token-finished = { $player }s Stein { $token } erreicht das Ziel.
trouble-bump =
    { $player }s Stein { $token } schlägt { $opponent }s Stein { $opp_token } zurück ins Haus.
trouble-no-legal-move = { $player } hat keinen gültigen Zug. Der Zug geht weiter.
trouble-extra-turn = { $player } erhält einen Extra-Zug für die 6.

trouble-winner = { $player } gewinnt! Alle Steine im Ziel.
trouble-team-winner = Team { $team } gewinnt! Alle Teammitglieder sind im Ziel.
trouble-final-standing = { $player }: { $finished } von { $total } Steinen im Ziel.

trouble-turn-summary =
    Du hast { $own_home } im Haus, { $own_track } auf der Bahn, { $own_finished } im Ziel.
    Gegner: { $opponents }.
trouble-opponent-summary = { $name }: { $home } Haus, { $track } Bahn, { $finished } Ziel

trouble-board-status =
    Deine Steine: { $own_tokens }.
    Gegnerische Steine: { $opp_tokens }.

trouble-reason-not-rolled = Würfle zuerst.
trouble-reason-already-rolled = Du hast schon gewürfelt. Wähle einen Stein zum Ziehen.
trouble-reason-no-legal-moves = Keine gültigen Züge für diesen Wurf.
trouble-reason-token-home-needs-six = Dieser Stein ist im Haus. Du brauchst eine 6, um ihn zu lösen.
trouble-reason-token-home-needs-any = Dieser Stein ist im Haus. Jeder Wurf löst ihn.
trouble-reason-token-home-no-qualifying-roll =
    Dieser Stein ist im Haus und dein Wurf erfüllt die Bedingung nicht.
trouble-reason-token-finished = Dieser Stein ist schon im Ziel.
trouble-reason-overshoot-wastes = Dieser Stein kann nicht { $roll } Felder ziehen, ohne über das Ziel zu schießen.
trouble-reason-blocked = Dieser Zug ist blockiert.

trouble-option-track-size = Bahnlänge: { $track_size } Felder
trouble-option-select-track-size = Wähle die Anzahl der Bahnfelder.
trouble-option-changed-track-size = Bahnlänge auf { $track_size } Felder gesetzt.
trouble-option-desc-track-size = Anzahl der Felder auf der gemeinsamen Bahn.

trouble-option-tokens-per-player = Steine pro Spieler: { $tokens }
trouble-option-enter-tokens-per-player = Gib die Steinzahl pro Spieler ein (2 bis 6):
trouble-option-changed-tokens-per-player = Steine pro Spieler auf { $tokens } gesetzt.
trouble-option-desc-tokens-per-player = Anzahl der Steine, die jeder Spieler ins Ziel bringt.

trouble-option-extra-turn-on-six = Extra-Zug bei 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Extra-Zug bei 6 { $enabled ->
    [on] aktiviert.
    [off] deaktiviert.
   *[other] aktualisiert.
}
trouble-option-desc-extra-turn-on-six =
    Aktiviert: eine 6 gibt einen Extra-Zug (klassische Hasbro-Regel).

trouble-option-six-to-leave-home = 6 nötig zum Verlassen des Hauses: { $enabled }
trouble-option-changed-six-to-leave-home = Sechs zum Verlassen des Hauses { $enabled ->
    [on] aktiviert.
    [off] deaktiviert.
   *[other] aktualisiert.
}
trouble-option-desc-six-to-leave-home =
    Aktiviert: der Spieler braucht eine 6, um einen Stein aus dem Haus zu lösen. Deaktiviert: jeder Wurf löst.

trouble-option-safe-spaces = Sichere Felder: { $mode }
trouble-option-select-safe-spaces = Wähle den Modus für sichere Felder.
trouble-option-changed-safe-spaces = Sichere Felder auf { $mode } gesetzt.
trouble-option-desc-safe-spaces = Lege fest, ob Steine vor Schlägen geschützt werden können.

trouble-safe-mode-none = Keine
trouble-safe-mode-home-stretch = Nur Zielgerade
trouble-safe-mode-every-seventh = Jedes 7. Feld

trouble-option-finish-behavior = Ziel: { $mode }
trouble-option-select-finish-behavior = Wähle das Verhalten am Ziel.
trouble-option-changed-finish-behavior = Zielverhalten auf { $mode } gesetzt.
trouble-option-desc-finish-behavior = Wie ein Wurf behandelt wird, der über das Ziel hinausgeht.

trouble-finish-mode-exact = Exakter Wurf nötig
trouble-finish-mode-bounce = Übersprung zurück
trouble-finish-mode-allow = Übersprung erlaubt

trouble-option-bot-difficulty = Bot-Schwierigkeit: { $level }
trouble-option-select-bot-difficulty = Wähle die Bot-Schwierigkeit.
trouble-option-changed-bot-difficulty = Bot-Schwierigkeit auf { $level } gesetzt.
trouble-option-desc-bot-difficulty = Stärke der eingebauten Bots.

trouble-bot-difficulty-naive = Naiv
trouble-bot-difficulty-greedy = Gierig

trouble-option-preset = Voreinstellung: { $preset }
trouble-option-select-preset = Wähle eine Variante. Der Gastgeber kann danach einzelne Regeln anpassen.
trouble-option-changed-preset = Voreinstellung angewendet: { $preset }.
trouble-option-desc-preset = Vorgefertigte Optionspakete für gängige Varianten.

trouble-preset-classic = Klassisch Hasbro
trouble-preset-fast = Schnell
trouble-preset-brutal = Brutal
trouble-preset-custom = Benutzerdefiniert
