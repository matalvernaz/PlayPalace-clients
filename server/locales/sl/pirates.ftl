# pirates.ftl for locale sl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = Pirati Izgubljenih Morij
# Game start and setup
pirates-welcome = Dobrodošli v Piratih Izgubljenih Morij! Plujte po morjih, zbirajte dragulje in se borite z drugimi pirati!
pirates-oceans = Vaše potovanje vas bo vodilo skozi: { $oceans }
pirates-gems-placed = { $total } draguljev je bilo razpršenih po morjih. Najdite jih vse!
pirates-golden-moon = Zlata Luna vzhaja! Vsi dobički XP so potrojeni ta krog!
# Turn announcements
pirates-turn = Poteza igralca { $player }. Položaj { $position }
# Movement actions
pirates-move-left = Pluj levo
pirates-move-right = Pluj desno
pirates-move-2-left = Pluj 2 polji levo
pirates-move-2-right = Pluj 2 polji desno
pirates-move-3-left = Pluj 3 polja levo
pirates-move-3-right = Pluj 3 polja desno
# Movement messages
pirates-move-you = Plujete { $direction } na položaj { $position }.
pirates-move = { $player } pluje { $direction } na položaj { $position }.
pirates-map-edge = Ne morete pluti naprej. Ste na položaju { $position }.
pirates-your-position = Vaš položaj: { $position } v { $ocean }
pirates-check-position = Preveri položaj
pirates-check-moon = Preveri svetlost lune
# Position and status
pirates-check-status = Preveri stanje
pirates-all-gems-collected = Vsi dragulji so bili zbrani!
# Winner
pirates-winner = { $player } zmaga s { $score } točkami!
# Gem collection
pirates-gem-found-you = Našli ste { $gem }! Vreden { $value } točk.
pirates-gem-found = { $player } je našel { $gem }! Vreden { $value } točk.
pirates-level-up-you = Dosegli ste raven { $level }!
pirates-level-up = { $player } je dosegel raven { $level }!
pirates-level-up-multiple-you = Pridobili ste { $levels } ravni! Zdaj raven { $level }!
pirates-level-up-multiple = { $player } je pridobil { $levels } ravni! Zdaj raven { $level }!
pirates-skills-unlocked-you = Odklenili ste nove sposobnosti: { $skills }.
pirates-skills-unlocked = { $player } je odklenil nove sposobnosti: { $skills }.
# Combat - Attack initiation
pirates-cannonball = Izstreli topovsko kroglo
pirates-no-targets = Ni ciljev v dosegu { $range } polj.
pirates-attack-you-fire = Izstreljujete topovsko kroglo na { $target }!
pirates-attack-incoming = { $attacker } izstreli topovsko kroglo na vas!
pirates-attack-fired = { $attacker } izstreli topovsko kroglo na { $defender }!
# Combat - Hit results
pirates-attack-hit-you = Direkten zadetek! Zadeli ste { $target }!
pirates-attack-hit-them = Zadel vas je { $attacker }!
pirates-attack-hit = { $attacker } zadene { $defender }!
# Combat - Miss results
pirates-attack-miss-you = Vaša topovska krogla je zgrešila { $target }.
pirates-attack-miss-them = Topovska krogla vas je zgrešila!
pirates-attack-miss = Topovska krogla igralca { $attacker } zgreši { $defender }.
pirates-push = { $attacker } potiska { $defender } { $direction } iz { $old_pos } na { $new_pos }.
pirates-steal-success-you = Ukradli ste { $gem } igralcu { $target }!
pirates-steal-success-them = { $attacker } vam je ukradel { $gem }!
pirates-steal-success = { $attacker } ukrade { $gem } igralcu { $defender }!
pirates-steal-failed = Poskus kraje ni uspel!
# Skills menu
pirates-use-skill = Uporabi sposobnost
pirates-select-skill = Izberite sposobnost za uporabo
# Skill activation
pirates-skill-activated = { $player } aktivira { $skill }!
pirates-buff-expired = Bonus { $skill } igralca { $player } je potekel.
# Portal skill
pirates-portal-no-ships = Ni drugih ladij v vidnem polju za portal.
pirates-portal-fizzle = Portal igralca { $player } izgine brez cilja.
pirates-portal-success = { $player } se teleportira v { $ocean } na položaj { $position }!
# Gem Seeker skill
pirates-gem-seeker-reveal = Morja šepetajo o { $gem } na položaju { $position }. ({ $uses } uporab preostalo)
# Sword Fighter skill
pirates-sword-fighter-activated = Borec z Mečem aktiviran! +4 bonus napada za { $turns } potez.
# Push skill (defense buff)
pirates-push-activated = Potisk aktiviran! +3 bonus obrambe za { $turns } potez.
# Skilled Captain skill
pirates-skilled-captain-activated = Izkušen Kapitan aktiviran! +2 napad in +2 obramba za { $turns } potez.
# Battleship skill
pirates-battleship-activated = Bojna ladja aktivirana! Lahko izstrelite dva strela to potezo!
pirates-battleship-shot = Streljanje strela { $shot }...
pirates-battleship-no-targets = Ni ciljev za strel { $shot }.
# Double Devastation skill
pirates-double-devastation-activated = Dvojna Devastacija aktivirana! Doseg napada povečan na 10 polj za { $turns } potez.
# XP Multiplier options
pirates-set-combat-xp-multiplier = množitelj xp za boj: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = izkušnje za boj
pirates-set-find-gem-xp-multiplier = množitelj xp za najdbo dragulja: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = izkušnje za najdbo dragulja
# Gem stealing options
pirates-set-gem-stealing = Kraja draguljev: { $mode }
pirates-select-gem-stealing = Izberite način kraje draguljev
pirates-option-changed-stealing = Kraja draguljev nastavljena na { $mode }.
# Gem stealing mode choices
pirates-stealing-with-bonus = Z bonusom meta
pirates-stealing-no-bonus = Brez bonusa meta
pirates-stealing-disabled = Onemogočeno
