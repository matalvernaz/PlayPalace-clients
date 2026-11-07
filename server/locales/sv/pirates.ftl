# pirates.ftl for locale sv. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = Piraterna från de Förlorade Haven
# Game start and setup
pirates-welcome = Välkommen till Piraterna från de Förlorade Haven! Segla på haven, samla ädelstenar och kämpa mot andra pirater!
pirates-oceans = Din resa kommer att ta dig genom: { $oceans }
pirates-gems-placed = { $total } ädelstenar har spridits över haven. Hitta dem alla!
pirates-golden-moon = Den Gyllene Månen stiger! Alla XP-vinster tredubblas denna runda!
# Turn announcements
pirates-turn = { $player }s tur. Position { $position }
# Movement actions
pirates-move-left = Segla vänster
pirates-move-right = Segla höger
pirates-move-2-left = Segla 2 rutor vänster
pirates-move-2-right = Segla 2 rutor höger
pirates-move-3-left = Segla 3 rutor vänster
pirates-move-3-right = Segla 3 rutor höger
# Movement messages
pirates-move-you = Du seglar { $direction } till position { $position }.
pirates-move = { $player } seglar { $direction } till position { $position }.
pirates-map-edge = Du kan inte segla längre. Du är vid position { $position }.
pirates-your-position = Din position: { $position } i { $ocean }
pirates-check-position = Kontrollera position
pirates-check-moon = Kontrollera månens ljusstyrka
# Position and status
pirates-check-status = Kontrollera status
pirates-all-gems-collected = Alla ädelstenar har samlats!
# Winner
pirates-winner = { $player } vinner med { $score } poäng!
# Gem collection
pirates-gem-found-you = Du hittade en { $gem }! Värd { $value } poäng.
pirates-gem-found = { $player } hittade en { $gem }! Värd { $value } poäng.
pirates-level-up-you = Du nådde nivå { $level }!
pirates-level-up = { $player } nådde nivå { $level }!
pirates-level-up-multiple-you = Du fick { $levels } nivåer! Nu nivå { $level }!
pirates-level-up-multiple = { $player } fick { $levels } nivåer! Nu nivå { $level }!
pirates-skills-unlocked-you = Du låste upp nya förmågor: { $skills }.
pirates-skills-unlocked = { $player } låste upp nya förmågor: { $skills }.
# Combat - Attack initiation
pirates-cannonball = Avfyra kanonkula
pirates-no-targets = Inga mål inom { $range } rutor.
pirates-attack-you-fire = Du avfyrar en kanonkula mot { $target }!
pirates-attack-incoming = { $attacker } avfyrar en kanonkula mot dig!
pirates-attack-fired = { $attacker } avfyrar en kanonkula mot { $defender }!
# Combat - Hit results
pirates-attack-hit-you = Direktträff! Du träffade { $target }!
pirates-attack-hit-them = Du blev träffad av { $attacker }!
pirates-attack-hit = { $attacker } träffar { $defender }!
# Combat - Miss results
pirates-attack-miss-you = Din kanonkula missade { $target }.
pirates-attack-miss-them = Kanonkulan missade dig!
pirates-attack-miss = { $attacker }s kanonkula missar { $defender }.
pirates-push = { $attacker } knuffar { $defender } { $direction } från { $old_pos } till { $new_pos }.
pirates-steal-success-you = Du stal en { $gem } från { $target }!
pirates-steal-success-them = { $attacker } stal din { $gem }!
pirates-steal-success = { $attacker } stjäl en { $gem } från { $defender }!
pirates-steal-failed = Stöldförsöket misslyckades!
# Skills menu
pirates-use-skill = Använd förmåga
pirates-select-skill = Välj en förmåga att använda
# Skill activation
pirates-skill-activated = { $player } aktiverar { $skill }!
pirates-buff-expired = { $player }s { $skill }-bonus har upphört.
# Portal skill
pirates-portal-no-ships = Inga andra skepp i sikte för portal.
pirates-portal-fizzle = { $player }s portal försvinner utan destination.
pirates-portal-success = { $player } teleporterar till { $ocean } vid position { $position }!
# Gem Seeker skill
pirates-gem-seeker-reveal = Haven viskar om en { $gem } vid position { $position }. ({ $uses } användningar kvar)
# Sword Fighter skill
pirates-sword-fighter-activated = Svärdkämpe aktiverad! +4 attackbonus i { $turns } drag.
# Push skill (defense buff)
pirates-push-activated = Knuff aktiverad! +3 försvarsbonus i { $turns } drag.
# Skilled Captain skill
pirates-skilled-captain-activated = Skicklig Kapten aktiverad! +2 attack och +2 försvar i { $turns } drag.
# Battleship skill
pirates-battleship-activated = Slagskepp aktiverat! Du kan avfyra två skott detta drag!
pirates-battleship-shot = Avfyrar skott { $shot }...
pirates-battleship-no-targets = Inga mål för skott { $shot }.
# Double Devastation skill
pirates-double-devastation-activated = Dubbel Förödelse aktiverad! Attackräckvidd ökad till 10 rutor i { $turns } drag.
# XP Multiplier options
pirates-set-combat-xp-multiplier = strid xp-multiplikator: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = erfarenhet för strid
pirates-set-find-gem-xp-multiplier = hitta ädelsten xp-multiplikator: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = erfarenhet för att hitta en ädelsten
# Gem stealing options
pirates-set-gem-stealing = Ädelstenstöld: { $mode }
pirates-select-gem-stealing = Välj ädelstenstöldläge
pirates-option-changed-stealing = Ädelstenstöld inställd på { $mode }.
# Gem stealing mode choices
pirates-stealing-with-bonus = Med kastbonus
pirates-stealing-no-bonus = Ingen kastbonus
pirates-stealing-disabled = Inaktiverad
