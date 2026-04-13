# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = Risk

# Phase announcements
risk-reinforce-start = { $player } reçoit { $armies } armées à placer.
risk-attack-phase = { $player } peut maintenant attaquer.
risk-fortify-phase = { $player } peut maintenant fortifier.

# Reinforce
risk-placed-army = { $player } renforce { $territory } ({ $troops } troupes). { $remaining } restantes.

# Attack
risk-attack-from = { $player } attaque depuis { $territory }.
risk-combat-result =
    { $attacker } attaque { $def_territory } depuis { $att_territory }.
    Attaquant lance : { $att_rolls }. Défenseur lance : { $def_rolls }.
    Attaquant perd { $att_losses }, défenseur perd { $def_losses }.
risk-conquered = { $player } conquiert { $territory } ! { $moved } troupes entrent.
risk-eliminated = { $player } a été éliminé !
risk-skip-attack = Passer l'attaque
risk-cancel-attack = Annuler l'attaque

# Fortify
risk-fortify-from = { $player } fortifie depuis { $territory }.
risk-fortified = { $player } déplace { $moved } troupes de { $source } vers { $dest }.
risk-skip-fortify = Passer la fortification
risk-cancel-fortify = Annuler la fortification

# Cards
risk-cards-traded = { $player } échange des cartes contre { $armies } armées bonus.

# Territory labels by phase
risk-territory-reinforce = { $name } : { $troops } troupes ({ $remaining } à placer)
risk-territory-attack-from = { $name } : { $troops } troupes (attaquer d'ici)
risk-territory-attack-target = { $name } : { $troops } troupes ({ $owner })
risk-territory-fortify-from = { $name } : { $troops } troupes (déplacer d'ici)
risk-territory-fortify-to = { $name } : { $troops } troupes (déplacer ici)

# Status
risk-status-header = Vous contrôlez { $territories } territoires avec { $troops } troupes au total.
risk-status-continent = { $name } : { $owned }/{ $total } territoires. Bonus : { $bonus }.

# Winner
risk-winner = { $player } a conquis le monde !
risk-final-score = { $player } : { $territories } territoires

# Disabled reasons
risk-not-your-territory = Ce n'est pas votre territoire.
risk-need-more-troops = Il faut au moins 2 troupes pour attaquer ou fortifier d'ici.
risk-no-adjacent-enemy = Aucun territoire ennemi adjacent.
risk-cannot-attack-own = Vous ne pouvez pas attaquer votre propre territoire.
risk-not-adjacent = Ce territoire n'est pas adjacent.
risk-same-territory = Impossible de fortifier vers le même territoire.

# Options
risk-set-starting-armies = Armées de départ : { $armies }
risk-desc-starting-armies = Armées supplémentaires par joueur au début (0 = auto)
risk-enter-starting-armies = Entrez les armées de départ par joueur (0 pour auto) :
risk-option-changed-armies = Armées de départ changées à { $armies }

# Rules
risk-rules =
    Risk est un jeu de conquête mondiale pour 2 à 6 joueurs.
    Le plateau a 42 territoires répartis sur 6 continents.
    Chaque tour a 3 phases : renforcer, attaquer et fortifier.
    Renforcer : Placez des armées sur vos territoires. Vous recevez des armées selon vos territoires et les bonus de continents.
    Attaquer : Sélectionnez un territoire avec 2 troupes ou plus, puis un territoire ennemi adjacent. Les dés résolvent le combat.
    L'attaquant lance jusqu'à 3 dés, le défenseur jusqu'à 2. Les dés les plus hauts sont comparés.
    Si vous éliminez tous les défenseurs, vous conquérez le territoire.
    Fortifier : Déplacez des troupes vers un territoire ami adjacent.
    Conquérez au moins un territoire par tour pour gagner une carte. Échangez des ensembles de 3 cartes pour des armées bonus.
    Éliminez tous les adversaires pour gagner.
    Appuyez sur E pour voir votre statut.
risk-check-status = Check status
