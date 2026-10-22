# Messages de jeu partagés pour PlayPalace
# Ces messages sont communs à plusieurs jeux

# Noms de jeux
game-name-ninetynine = Quatre-vingt-dix-neuf

# Flux de manche et de tour
game-round-start = Manche { $round }.
game-round-end = Manche { $round } terminée.
game-turn-start = Tour de { $player }.
game-your-turn = Votre tour.
game-no-turn = Aucun tour en ce moment.

# Affichage des scores
game-scores-header = Scores actuels :
game-score-line = { $player } : { $score } points
game-final-scores-header = Scores finaux :

# Victoire/défaite
game-winner = { $player } gagne !
game-winner-score = { $player } gagne avec { $score } points !
game-tiebreaker = Égalité ! Manche de départage !
game-tiebreaker-players = Égalité entre { $players } ! Manche de départage !
game-eliminated = { $player } a été éliminé avec { $score } points.

# Options communes
game-set-target-score = Score cible : { $score }
game-enter-target-score = Entrez le score cible :
game-option-changed-target = Score cible défini sur { $score }.

game-set-team-mode = Mode équipe : { $mode }
game-select-team-mode = Sélectionnez le mode équipe
game-option-changed-team = Mode équipe défini sur { $mode }.
game-team-mode-individual = Individuel
game-team-mode-x-teams-of-y = { $num_teams } équipes de { $team_size }

# Valeurs d'options booléennes
option-on = activé
option-off = désactivé

# Boîte de statut

# Fin de jeu
game-leave = Quitter le jeu

# Minuterie de manche
round-timer-paused = { $player } a mis le jeu en pause (appuyez sur p pour démarrer la prochaine manche).
round-timer-resumed = Minuterie de manche reprise.
round-timer-countdown = Prochaine manche dans { $seconds }...

# Jeux de dés - garder/relancer les dés
dice-keeping = Garde { $value }.
dice-rerolling = Relance { $value }.
dice-locked = Ce dé est verrouillé et ne peut pas être changé.
dice-status-locked = locked
dice-status-kept = kept

# Distribution (jeux de cartes)
game-deal-counter = Distribution { $current }/{ $total }.
game-you-deal = Vous distribuez les cartes.
game-player-deals = { $player } distribue les cartes.

# Noms de cartes
card-name = { $rank } de { $suit }
no-cards = Aucune carte

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = noir
color-black-m = noir
color-black-f = noire
color-blue = bleu
color-blue-m = bleu
color-blue-f = bleue
color-brown = marron
color-brown-m = marron
color-brown-f = marron
color-gray = gris
color-gray-m = gris
color-gray-f = grise
color-green = vert
color-green-m = vert
color-green-f = verte
color-indigo = indigo
color-indigo-m = indigo
color-indigo-f = indigo
color-orange = orange
color-orange-m = orange
color-orange-f = orange
color-pink = rose
color-pink-m = rose
color-pink-f = rose
color-purple = violet
color-purple-m = violet
color-purple-f = violette
color-red = rouge
color-red-m = rouge
color-red-f = rouge
color-violet = violet
color-violet-m = violet
color-violet-f = violette
color-white = blanc
color-white-m = blanc
color-white-f = blanche
color-yellow = jaune
color-yellow-m = jaune
color-yellow-f = jaune

# Noms de couleurs
suit-diamonds = carreau
suit-clubs = trèfle
suit-hearts = cœur
suit-spades = pique

# Noms de rangs
rank-ace = as
rank-ace-plural = as
rank-two = 2
rank-two-plural = 2
rank-three = 3
rank-three-plural = 3
rank-four = 4
rank-four-plural = 4
rank-five = 5
rank-five-plural = 5
rank-six = 6
rank-six-plural = 6
rank-seven = 7
rank-seven-plural = 7
rank-eight = 8
rank-eight-plural = 8
rank-nine = 9
rank-nine-plural = 9
rank-ten = 10
rank-ten-plural = 10
rank-jack = valet
rank-jack-plural = valets
rank-queen = dame
rank-queen-plural = dames
rank-king = roi
rank-king-plural = rois

# Descriptions de mains de poker
poker-high-card-with = { $high } haute, avec { $rest }
poker-high-card = { $high } haute
poker-pair-with = Paire de { $pair }, avec { $rest }
poker-pair = Paire de { $pair }
poker-two-pair-with = Double paire, { $high } et { $low }, avec { $kicker }
poker-two-pair = Double paire, { $high } et { $low }
poker-trips-with = Brelan, { $trips }, avec { $rest }
poker-trips = Brelan, { $trips }
poker-straight-high = Suite à { $high }
poker-flush-high-with = Couleur à { $high }, avec { $rest }
poker-full-house = Full, { $trips } sur { $pair }
poker-quads-with = Carré, { $quads }, avec { $kicker }
poker-quads = Carré, { $quads }
poker-straight-flush-high = Quinte flush à { $high }
poker-unknown-hand = Main inconnue

# Erreurs de validation (communes à tous les jeux)
game-error-invalid-team-mode = Le mode équipe sélectionné n'est pas valide pour le nombre actuel de joueurs.

game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] point
   *[other] points
}
game-score-unit-chips = { $count ->
    [one] chip
   *[other] chips
}
game-score-unit-coins = { $count ->
    [one] coin
   *[other] coins
}
game-score-unit-health = health
game-score-unit-ninetynine-tokens = { $count ->
    [one] token
   *[other] tokens
}
game-score-unit-tokens-home = { $count ->
    [one] token home
   *[other] tokens home
}
game-score-unit-pawns-home = { $count ->
    [one] pawn home
   *[other] pawns home
}
game-score-unit-hand-wins = { $count ->
    [one] hand win
   *[other] hand wins
}
game-score-unit-light = light
game-winner-you = You win!
game-team-name = Team { $index }
team-arrangement-started = Team arrangement started. Review the teams, swap members if needed, then confirm to start.
team-arrangement-confirm = Confirm teams and start
team-arrangement-read = Read teams
team-arrangement-select-member-action = Select team member
team-arrangement-select-member = Select a team member
team-arrangement-select-swap-target = Select a player to swap with
team-arrangement-swap-member = Choose swap target
team-arrangement-swap-member-selected = Swap { $player } with...
team-arrangement-cancel = Cancel team arrangement
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Turn order: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selected
team-arrangement-not-selected = not selected
team-arrangement-member-selected = { $player } from { $team } selected. Choose a player from another team to swap with.
team-arrangement-swapped = { $first } and { $second } have swapped teams.
team-arrangement-cancelled = Team arrangement cancelled.
team-arrangement-cancelled-roster = Team arrangement cancelled because the player list changed.
team-arrangement-refreshed = The player list changed. Team arrangement has been refreshed.
team-arrangement-in-progress = Finish or cancel team arrangement first.
team-arrangement-not-active = Team arrangement is not active.
team-arrangement-select-first = Select a team member first.
team-arrangement-player-missing = That player is no longer available for team arrangement.
team-arrangement-same-team = Choose someone from a different team.
team-arrangement-swap-failed = Could not swap those team members.

status-box-closed = Status information closed.

dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)

poker-royal-flush = Royal Flush
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
contact = Contact
document-not-found = Document not found.
help = Help

# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: {$game}
game-info-players = Players: {$count}
game-info-host = Host: {$host}
game-info-status = Status: {$status}
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.

# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for {$game} are not available yet.
