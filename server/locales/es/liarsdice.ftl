# Liar's Dice — localization
#
# Each player has a cup of dice; bids are made on the total count of a face
# across the whole table. 1s are wild unless bidding on 1s specifically.

# ==========================================================================
# Game metadata
# ==========================================================================
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Each player rolls dice secretly under their cup. Take turns bidding higher and higher counts of a face value across the whole table — or call "Liar!" if you don't believe the last bid. Lose a die when you guess wrong. Last with dice wins.

liarsdice-rules =
    Liar's Dice is a bluffing dice game for 2 to 6 players.
    Each player starts with 5 dice in a cup. At the start of each round, every player rolls their dice secretly.
    Take turns making bids on the total count of a face across all dice on the table — for example, "three 4s" means at least three 4s exist when all cups are revealed.
    Each new bid must be higher than the last: either the same face with a higher count, or a higher face with the same or higher count.
    1s are wild — they count toward any bid except a bid on 1s themselves.
    Switching to a bid on 1s halves the quantity (rounded up). Switching back from 1s to a regular face requires more than double the previous quantity.
    Instead of bidding, you may call "Liar!" to challenge the previous bid. All cups reveal: if the bid is correct, the challenger loses a die; if not, the bidder loses a die.
    With Spot On enabled, you may instead call "Spot On" to bet the bid is exactly correct. If you're right, every other player loses a die; if not, you lose two dice.
    Eliminated when you reach zero dice. Last player with any dice wins.
    Press S to check the table.

# ==========================================================================
# Lobby options
# ==========================================================================
ld-set-starting-dice = Starting dice per player: { $dice }
ld-desc-starting-dice = How many dice each player starts with. Default 5. More dice = longer games and more bluffing room.
ld-prompt-starting-dice = Enter starting dice (3 to 8)
ld-option-changed-starting-dice = Starting dice set to { $dice }.

ld-toggle-wild-ones = 1s are wild: { $enabled }
ld-desc-wild-ones = When on, 1s count toward any non-1 bid. Bidding on 1s themselves disables wilds for that bid. Off makes the game purely about probability with no wild card.
ld-option-changed-wild-ones = Wild 1s { $enabled }.

ld-toggle-spot-on = Spot On call enabled: { $enabled }
ld-desc-spot-on = When on, in addition to "Liar", you may call "Spot On" — betting the bid is exactly the right number. If correct, every other player loses a die. If wrong, you lose two dice. High risk, high reward.
ld-option-changed-spot-on = Spot On { $enabled }.

# ==========================================================================
# Round flow
# ==========================================================================
ld-round-start = Round { $round } begins. Total dice on the table: { $total }. Everyone rolls.
ld-your-roll = Your dice this round: { $dice }.
ld-your-counts = Your counts: { $counts }.
ld-turn-start = { $player }'s turn. { $bid_state }
ld-no-bid-yet = No bid yet — open the round.
ld-current-bid = Current bid: { $quantity } { $face }.

# ==========================================================================
# Bidding
# ==========================================================================
ld-action-bid = Make a bid
ld-action-call-liar = Call Liar
ld-action-call-spot-on = Call Spot On
ld-bid-prompt = Choose your bid.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] You bid { $quantity } { $face }.
    *[player] { $player } bids { $quantity } { $face }.
}

# ==========================================================================
# Calls / reveals
# ==========================================================================
ld-call-liar = { $who ->
    [you] You call Liar on { $target }'s bid of { $quantity } { $face }.
    *[player] { $player } calls Liar on { $target }'s bid of { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] You call Spot On for { $target }'s bid of { $quantity } { $face }.
    *[player] { $player } calls Spot On for { $target }'s bid of { $quantity } { $face }.
}
ld-reveal-header = Cups up! Counting the { $face } across the table.
ld-reveal-line = { $player } rolled: { $dice }.
ld-actual-count = Actual count of { $face } (including wild 1s): { $count }. Bid was { $quantity }.
ld-actual-count-no-wild = Actual count of { $face } (no wilds): { $count }. Bid was { $quantity }.

# Outcome
ld-liar-bidder-loses = { $bidder } overbid — they lose a die.
ld-liar-caller-loses = The bid was honest — { $caller } loses a die.
ld-spot-on-correct = Spot on! { $caller } was exactly right — every other player loses a die.
ld-spot-on-wrong = Not spot on. { $caller } loses two dice.

# Dice count changes
ld-lost-die = { $who ->
    [you] You lost a die. You now have { $remaining } { $remaining ->
        [one] die
        *[other] dice
    }.
    *[player] { $player } lost a die. They now have { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] You lost { $count } dice. You now have { $remaining } { $remaining ->
        [one] die
        *[other] dice
    }.
    *[player] { $player } lost { $count } dice. They now have { $remaining }.
}
ld-eliminated = { $player } is out of dice and is eliminated! { $remaining } { $remaining ->
    [one] player
    *[other] players
} left.
ld-winner = { $player } is the last one with dice — they win!

# ==========================================================================
# Status readout
# ==========================================================================
ld-status-round = Round { $round }.
ld-status-your-dice = Your dice: { $dice }.
ld-status-your-counts = Your counts: { $counts }.
ld-status-no-dice = You have no dice — you've been eliminated.
ld-status-current-bid = Current bid: { $quantity } { $face }.
ld-status-no-bid = No bid yet this round.
ld-status-table-total = Total dice on the table: { $total }.
ld-status-detailed-header = Detailed status — { $count } players remaining.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] die
    *[other] dice
}.
ld-status-detailed-out = { $player }: eliminated.
ld-status-detailed-self-suffix = {" "}(you)

# ==========================================================================
# Face-name helpers (for natural speech: "three sixes" not "three 6s")
# ==========================================================================
ld-face-1 = ones
ld-face-2 = twos
ld-face-3 = threes
ld-face-4 = fours
ld-face-5 = fives
ld-face-6 = sixes

# ==========================================================================
# Errors / disabled actions
# ==========================================================================
ld-action-not-your-turn = It's not your turn.
ld-action-not-playing = The game is not in progress.
ld-action-no-bid-to-call = There's no bid to challenge yet.
ld-action-eliminated = You're eliminated.
