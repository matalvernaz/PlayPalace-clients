# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = Risk

# Phase announcements
risk-reinforce-start = { $player } receives { $armies } armies to place.
risk-attack-phase = { $player } may now attack.
risk-fortify-phase = { $player } may now fortify.

# Reinforce
risk-placed-army = { $player } reinforces { $territory } ({ $troops } troops). { $remaining } remaining.

# Attack
risk-attack-from = { $player } attacks from { $territory }.
risk-combat-result =
    { $attacker } attacks { $def_territory } from { $att_territory }.
    Attacker rolls: { $att_rolls }. Defender rolls: { $def_rolls }.
    Attacker loses { $att_losses }, defender loses { $def_losses }.
risk-conquered = { $player } conquers { $territory }! { $moved } troops move in.
risk-eliminated = { $player } has been eliminated!
risk-skip-attack = End attack phase
risk-cancel-attack = Cancel attack

# Fortify
risk-fortify-from = { $player } fortifies from { $territory }.
risk-fortified = { $player } moves { $moved } troops from { $source } to { $dest }.
risk-skip-fortify = Skip fortify
risk-cancel-fortify = Cancel fortify

# Status
risk-check-status = Check status

# Cards
risk-cards-traded = { $player } trades cards for { $armies } bonus armies.

# Territory labels by phase
risk-territory-reinforce = { $name }: { $troops } troops ({ $remaining } to place)
risk-territory-attack-from = { $name }: { $troops } troops (attack from here)
risk-territory-attack-target = { $name }: { $troops } troops ({ $owner })
risk-territory-fortify-from = { $name }: { $troops } troops (move from here)
risk-territory-fortify-to = { $name }: { $troops } troops (move here)

# Status
risk-status-header = You control { $territories } territories with { $troops } total troops.
risk-status-continent = { $name }: { $owned }/{ $total } territories. Bonus: { $bonus }.

# Winner
risk-winner = { $player } has conquered the world!
risk-final-score = { $player }: { $territories } territories

# Disabled reasons
risk-not-your-territory = That's not your territory.
risk-need-more-troops = Need at least 2 troops to attack or fortify from here.
risk-no-adjacent-enemy = No adjacent enemy territories.
risk-cannot-attack-own = You can't attack your own territory.
risk-not-adjacent = That territory is not adjacent.
risk-same-territory = Can't fortify to the same territory.

# Options
risk-set-starting-armies = Starting armies: { $armies }
risk-desc-starting-armies = Extra armies per player at start (0 = auto)
risk-enter-starting-armies = Enter starting armies per player (0 for auto):
risk-option-changed-armies = Starting armies changed to { $armies }

# Rules
risk-rules =
    Risk is a world conquest game for 2 to 6 players.
    The board has 42 territories across 6 continents.
    Each turn has 3 phases: reinforce, attack, and fortify.
    Reinforce: Place armies on your territories. You receive armies based on territories owned plus continent bonuses.
    Attack: Select a territory with 2 or more troops, then select an adjacent enemy territory. Dice are rolled to resolve combat. You may attack as many times as you want per turn — choose "End attack phase" when you're done.
    The attacker rolls up to 3 dice, the defender up to 2. Highest dice are compared: higher wins, ties go to defender.
    If you eliminate all defenders, you conquer the territory and move troops in.
    Fortify: Move troops from one territory to an adjacent friendly territory. One move per turn, then your turn ends.
    Conquer at least one territory per turn to earn a card. Trade sets of 3 cards for bonus armies.
    Eliminate all opponents to win.
    Press E to check your status.
