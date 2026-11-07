# pirates.ftl for locale cs. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Název hry
game-name-pirates = Pirates of the Lost Seas
# Start hry a nastavení
pirates-welcome = Vítejte v Pirates of the Lost Seas! Plujte po moři, sbírejte drahokamy a bojujte s ostatními piráty!
pirates-oceans = Vaše plavba vás zavede přes: { $oceans }
pirates-gems-placed = { $total } drahokamů bylo rozmístěno po moři. Najděte je všechny!
pirates-golden-moon = Zlatý měsíc vychází! Všechny zisky XP jsou v tomto kole ztrojnásobeny!
# Oznámení tahů
pirates-turn = Tah hráče { $player }. Pozice { $position }
# Akce pohybu
pirates-move-left = Plout vlevo
pirates-move-right = Plout vpravo
pirates-move-2-left = Plout 2 pole vlevo
pirates-move-2-right = Plout 2 pole vpravo
pirates-move-3-left = Plout 3 pole vlevo
pirates-move-3-right = Plout 3 pole vpravo
# Zprávy o pohybu
pirates-move-you = Pluješ { $direction } na pozici { $position }.
pirates-move = { $player } pluje { $direction } na pozici { $position }.
pirates-map-edge = Nemůžeš plout dál. Jsi na pozici { $position }.
pirates-your-position = Vaše pozice: { $position } v { $ocean }
pirates-check-position = Zkontrolovat pozici
pirates-check-moon = Zkontrolovat jas měsíce
# Pozice a stav
pirates-check-status = Zkontrolovat stav
pirates-all-gems-collected = Všechny drahokamy byly sesbírány!
# Vítěz
pirates-winner = { $player } vyhrává s { $score } body!
# Sběr drahokamů
pirates-gem-found-you = Našel jsi { $gem }! Za { $value } bodů.
pirates-gem-found = { $player } našel { $gem }! Za { $value } bodů.
pirates-level-up-you = Dosáhl jsi úrovně { $level }!
pirates-level-up = { $player } dosáhl úrovně { $level }!
pirates-level-up-multiple-you =
    Získal jsi { $levels } { $levels ->
        [one] úroveň
        [few] úrovně
        [many] úrovně
       *[other] úrovní
    }! Nyní úroveň { $level }!
pirates-level-up-multiple =
    { $player } získal { $levels } { $levels ->
        [one] úroveň
        [few] úrovně
        [many] úrovně
       *[other] úrovní
    }! Nyní úroveň { $level }!
pirates-skills-unlocked-you = Odemkl jsi nové dovednosti: { $skills }.
pirates-skills-unlocked = { $player } odemkl nové dovednosti: { $skills }.
# Boj - Zahájení útoku
pirates-cannonball = Vystřelit dělovou kouli
pirates-no-targets = Žádné cíle do { $range } polí.
pirates-attack-you-fire = Střílíš dělovou kouli na { $target }!
pirates-attack-incoming = { $attacker } střílí dělovou kouli na tebe!
pirates-attack-fired = { $attacker } střílí dělovou kouli na { $defender }!
# Boj - Výsledky zásahu
pirates-attack-hit-you = Přímý zásah! Zasáhl jsi { $target }!
pirates-attack-hit-them = Byl jsi zasažen hráčem { $attacker }!
pirates-attack-hit = { $attacker } zasahuje { $defender }!
# Boj - Výsledky minutí
pirates-attack-miss-you = Tvoje dělová koule minula { $target }.
pirates-attack-miss-them = Dělová koule tě minula!
pirates-attack-miss = Dělová koule hráče { $attacker } mine { $defender }.
pirates-push = { $attacker } odtlačuje { $defender } { $direction } z { $old_pos } na { $new_pos }.
pirates-steal-success-you = Ukradl jsi { $gem } od { $target }!
pirates-steal-success-them = { $attacker } ti ukradl { $gem }!
pirates-steal-success = { $attacker } krade { $gem } od { $defender }!
pirates-steal-failed = Pokus o krádež selhal!
# Menu dovedností
pirates-use-skill = Použít dovednost
pirates-select-skill = Vyberte dovednost k použití
# Aktivace dovednosti
pirates-skill-activated = { $player } aktivuje { $skill }!
pirates-buff-expired = Buff { $skill } hráče { $player } vypršel.
# Dovednost Portal
pirates-portal-no-ships = Žádné jiné lodě na dohled pro portál.
pirates-portal-fizzle = Portál hráče { $player } vyhasíná bez cíle.
pirates-portal-success = { $player } se teleportuje do { $ocean } na pozici { $position }!
# Dovednost Gem Seeker
pirates-gem-seeker-reveal = Moře šeptá o { $gem } na pozici { $position }. (Zbývá { $uses } použití)
# Dovednost Sword Fighter
pirates-sword-fighter-activated =
    Sword Fighter aktivován! +4 bonus útoku na { $turns } { $turns ->
        [one] tah
        [few] tahy
        [many] tahu
       *[other] tahů
    }.
# Dovednost Push (obranný buff)
pirates-push-activated =
    Push aktivován! +3 bonus obrany na { $turns } { $turns ->
        [one] tah
        [few] tahy
        [many] tahu
       *[other] tahů
    }.
# Dovednost Skilled Captain
pirates-skilled-captain-activated =
    Skilled Captain aktivován! +2 útoku a +2 obrany na { $turns } { $turns ->
        [one] tah
        [few] tahy
        [many] tahu
       *[other] tahů
    }.
# Dovednost Battleship
pirates-battleship-activated = Battleship aktivován! Můžeš vystřelit dvakrát v tomto tahu!
pirates-battleship-shot = Střílí se výstřel { $shot }...
pirates-battleship-no-targets = Žádné cíle pro výstřel { $shot }.
# Dovednost Double Devastation
pirates-double-devastation-activated =
    Double Devastation aktivován! Dosah útoku zvýšen na 10 polí na { $turns } { $turns ->
        [one] tah
        [few] tahy
        [many] tahu
       *[other] tahů
    }.
# Multiplikátory XP
pirates-set-combat-xp-multiplier = multiplikátor XP za boj: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = zkušenosti za boj
pirates-set-find-gem-xp-multiplier = multiplikátor XP za nalezení drahokamu: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = zkušenosti za nalezení drahokamu
# Možnosti krádeže drahokamů
pirates-set-gem-stealing = Krádež drahokamů: { $mode }
pirates-select-gem-stealing = Vyberte režim krádeže drahokamů
pirates-option-changed-stealing = Krádež drahokamů nastavena na { $mode }.
# Volby režimu krádeže drahokamů
pirates-stealing-with-bonus = S bonusem hodu
pirates-stealing-no-bonus = Bez bonusu hodu
pirates-stealing-disabled = Zakázáno
