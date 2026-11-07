# pirates.ftl for locale pl. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = Pirates of the Lost Seas
# Game start and setup
pirates-welcome = Welcome to Pirates of the Lost Seas! Sail the seas, collect gems, and battle other pirates!
pirates-oceans = Your voyage will take you through: { $oceans }
pirates-gems-placed = { $total } gems have been scattered across the seas. Find them all!
pirates-golden-moon = The Golden Moon rises! All XP gains are tripled this round!
# Turn announcements
pirates-turn = { $player }'s turn. Position { $position }
# Movement actions
pirates-move-left = Sail left
pirates-move-right = Sail right
pirates-move-2-left = Sail 2 tiles left
pirates-move-2-right = Sail 2 tiles right
pirates-move-3-left = Sail 3 tiles left
pirates-move-3-right = Sail 3 tiles right
# Movement messages
pirates-move-you = You sail { $direction } to position { $position }.
pirates-move = { $player } sails { $direction } to position { $position }.
pirates-map-edge = You cannot sail further. You are at position { $position }.
pirates-your-position = Your position: { $position } in { $ocean }
pirates-check-position = Check position
pirates-check-moon = Check moon brightness
# Position and status
pirates-check-status = Check status
pirates-check-status-detailed = Szczegółowy status
pirates-all-gems-collected = All gems have been collected!
# Winner
pirates-winner = { $player } wins with { $score } points!
# Gem collection
pirates-gem-found-you = You found a { $gem }! Worth { $value } points.
pirates-gem-found = { $player } found a { $gem }! Worth { $value } points.
pirates-level-up-you = You reached level { $level }!
pirates-level-up = { $player } reached level { $level }!
pirates-level-up-multiple-you = You gained { $levels } levels! Now level { $level }!
pirates-level-up-multiple = { $player } gained { $levels } levels! Now level { $level }!
pirates-skills-unlocked-you = You unlocked new skills: { $skills }.
pirates-skills-unlocked = { $player } unlocked new skills: { $skills }.
# Combat - Attack initiation
pirates-cannonball = Fire cannonball
pirates-no-targets = No targets within { $range } tiles.
pirates-attack-you-fire = You fire a cannonball at { $target }!
pirates-attack-incoming = { $attacker } fires a cannonball at you!
pirates-attack-fired = { $attacker } fires a cannonball at { $defender }!
# Combat - Hit results
pirates-attack-hit-you = Direct hit! You struck { $target }!
pirates-attack-hit-them = You've been hit by { $attacker }!
pirates-attack-hit = { $attacker } hits { $defender }!
# Combat - Miss results
pirates-attack-miss-you = Your cannonball missed { $target }.
pirates-attack-miss-them = The cannonball missed you!
pirates-attack-miss = { $attacker }'s cannonball misses { $defender }.
pirates-push = { $attacker } pushes { $defender } { $direction } from { $old_pos } to { $new_pos }.
pirates-steal-success-you = You stole a { $gem } from { $target }!
pirates-steal-success-them = { $attacker } stole your { $gem }!
pirates-steal-success = { $attacker } steals a { $gem } from { $defender }!
pirates-steal-failed = The steal attempt failed!
# Skills menu
pirates-use-skill = Use skill
pirates-select-skill = Select a skill to use
# Skill activation
pirates-skill-activated = { $player } activates { $skill }!
pirates-buff-expired = { $player }'s { $skill } buff has worn off.
# Portal skill
pirates-portal-no-ships = No other ships in sight to portal to.
pirates-portal-fizzle = { $player }'s portal fizzles out with no destination.
pirates-portal-success = { $player } portals to { $ocean } at position { $position }!
# Gem Seeker skill
pirates-gem-seeker-reveal = The seas whisper of a { $gem } at position { $position }. ({ $uses } uses remaining)
# Sword Fighter skill
pirates-sword-fighter-activated = Sword Fighter activated! +4 attack bonus for { $turns } turns.
# Push skill (defense buff)
pirates-push-activated = Push activated! +3 defense bonus for { $turns } turns.
# Skilled Captain skill
pirates-skilled-captain-activated = Skilled Captain activated! +2 attack and +2 defense for { $turns } turns.
# Battleship skill
pirates-battleship-activated = Battleship activated! You can fire two shots this turn!
pirates-battleship-shot = Firing shot { $shot }...
pirates-battleship-no-targets = No targets for shot { $shot }.
# Double Devastation skill
pirates-double-devastation-activated = Double Devastation activated! Attack range increased to 10 tiles for { $turns } turns.
# XP Multiplier options
pirates-set-combat-xp-multiplier = combat xp multiplier: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = experience for combat
pirates-set-find-gem-xp-multiplier = find gem xp multiplier: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = experience for finding a gem
# Gem stealing options
pirates-set-gem-stealing = Gem stealing: { $mode }
pirates-select-gem-stealing = Select gem stealing mode
pirates-option-changed-stealing = Gem stealing set to { $mode }.
# Gem stealing mode choices
pirates-stealing-with-bonus = With roll bonus
pirates-stealing-no-bonus = No roll bonus
pirates-stealing-disabled = Disabled
