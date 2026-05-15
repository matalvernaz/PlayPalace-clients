# Liar's Dice — fr
# Chaque joueur a un cornet de dés ; les mises portent sur le total d'une face
# sur toute la table. Les 1 sont des jokers sauf quand on mise sur les 1.

game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Chaque joueur lance ses dés en secret sous son cornet. À tour de rôle, on enchérit plus haut sur le total d'une face sur toute la table — ou on crie "Menteur !" si on ne croit pas la dernière mise. Une erreur coûte un dé. Le dernier avec des dés gagne.

liarsdice-rules =
    Liar's Dice est un jeu de bluff aux dés pour 2 à 6 joueurs.
    Chaque joueur démarre avec 5 dés dans un cornet. Au début de chaque manche, tout le monde lance ses dés en secret.
    À tour de rôle, vous misez sur le total d'une face sur tous les dés — par exemple, "trois 4" veut dire qu'il y a au moins trois 4 quand tous les cornets seront révélés.
    Chaque nouvelle mise doit être plus haute : même face avec plus de quantité, ou face plus haute avec quantité égale ou plus haute.
    Les 1 sont des jokers — ils comptent pour toute mise sauf si la mise porte sur les 1.
    Passer à une mise sur les 1 divise la quantité par deux (arrondi au supérieur). Revenir des 1 à une face normale exige plus du double de la quantité précédente.
    Au lieu de miser, vous pouvez crier "Menteur !" pour contester la dernière mise. Tous les cornets se découvrent : si la mise était bonne, le contestataire perd un dé ; sinon, le miseur perd un dé.
    Avec Spot On activé, vous pouvez aussi crier "Spot On" en pariant que la mise est exactement juste. Si vous avez raison, tous les autres perdent un dé ; sinon, vous en perdez deux.
    Éliminé à zéro dé. Le dernier avec des dés gagne.
    Appuyez sur S pour vérifier la table.

ld-set-starting-dice = Dés de départ par joueur : { $dice }
ld-desc-starting-dice = Combien de dés chaque joueur reçoit au départ. Par défaut 5. Plus de dés = parties plus longues et plus de marge pour bluffer.
ld-prompt-starting-dice = Entre le nombre de dés de départ (3 à 8)
ld-option-changed-starting-dice = Dés de départ réglés sur { $dice }.

ld-toggle-wild-ones = Les 1 sont jokers : { $enabled }
ld-desc-wild-ones = Activé, les 1 comptent pour toute mise hors mise sur les 1. Miser sur les 1 désactive les jokers pour cette mise. Désactivé, le jeu devient pure probabilité, sans joker.
ld-option-changed-wild-ones = 1 jokers { $enabled }.

ld-toggle-spot-on = Cri Spot On activé : { $enabled }
ld-desc-spot-on = Activé, en plus de "Menteur", vous pouvez crier "Spot On" en pariant que la mise est exacte. Si vous avez raison, les autres perdent un dé. Sinon, vous en perdez deux. Risque et récompense élevés.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Manche { $round } commence. Total de dés sur la table : { $total }. Tout le monde lance.
ld-your-roll = Vos dés cette manche : { $dice }.
ld-your-counts = Vos comptes : { $counts }.
ld-turn-start = Au tour de { $player }. { $bid_state }
ld-no-bid-yet = Pas encore de mise — ouvre la manche.
ld-current-bid = Mise actuelle : { $quantity } { $face }.

ld-action-bid = Faire une mise
ld-action-call-liar = Crier Menteur
ld-action-call-spot-on = Crier Spot On
ld-bid-prompt = Choisissez votre mise.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Vous misez { $quantity } { $face }.
    *[player] { $player } mise { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Vous criez Menteur sur la mise de { $target } de { $quantity } { $face }.
    *[player] { $player } crie Menteur sur la mise de { $target } de { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Vous criez Spot On sur la mise de { $target } de { $quantity } { $face }.
    *[player] { $player } crie Spot On sur la mise de { $target } de { $quantity } { $face }.
}
ld-reveal-header = Cornets levés ! On compte les { $face } sur la table.
ld-reveal-line = { $player } a sorti : { $dice }.
ld-actual-count = Compte réel de { $face } (jokers 1 inclus) : { $count }. La mise était { $quantity }.
ld-actual-count-no-wild = Compte réel de { $face } (sans jokers) : { $count }. La mise était { $quantity }.

ld-liar-bidder-loses = { $bidder } a surenchéri — perd un dé.
ld-liar-caller-loses = La mise était honnête — { $caller } perd un dé.
ld-spot-on-correct = Spot on ! { $caller } avait pile raison — tous les autres perdent un dé.
ld-spot-on-wrong = Pas spot on. { $caller } perd deux dés.

ld-lost-die = { $who ->
    [you] Vous perdez un dé. Il vous reste { $remaining } { $remaining ->
        [one] dé
        *[other] dés
    }.
    *[player] { $player } perd un dé. Il lui reste { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Vous perdez { $count } dés. Il vous reste { $remaining } { $remaining ->
        [one] dé
        *[other] dés
    }.
    *[player] { $player } perd { $count } dés. Il lui reste { $remaining }.
}
ld-eliminated = { $player } n'a plus de dés et est éliminé ! Il reste { $remaining } { $remaining ->
    [one] joueur
    *[other] joueurs
}.
ld-winner = { $player } est le dernier avec des dés — gagne !

ld-status-round = Manche { $round }.
ld-status-your-dice = Vos dés : { $dice }.
ld-status-your-counts = Vos comptes : { $counts }.
ld-status-no-dice = Vous n'avez plus de dés — vous êtes éliminé.
ld-status-current-bid = Mise actuelle : { $quantity } { $face }.
ld-status-no-bid = Pas de mise dans cette manche.
ld-status-table-total = Total de dés sur la table : { $total }.
ld-status-detailed-header = État détaillé — { $count } joueurs restants.
ld-status-detailed-line = { $player }{ $self_suffix } : { $dice } { $dice ->
    [one] dé
    *[other] dés
}.
ld-status-detailed-out = { $player } : éliminé.
ld-status-detailed-self-suffix = {" "}(vous)

ld-face-1 = uns
ld-face-2 = deux
ld-face-3 = trois
ld-face-4 = quatre
ld-face-5 = cinq
ld-face-6 = six

ld-action-not-your-turn = Ce n'est pas votre tour.
ld-action-not-playing = La partie n'est pas en cours.
ld-action-no-bid-to-call = Pas encore de mise à contester.
ld-action-eliminated = Vous êtes éliminé.
