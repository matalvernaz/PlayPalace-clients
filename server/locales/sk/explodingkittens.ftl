# Exploding Kittens — localization
#
# Two editions share mechanics; only card names + flavor differ.
# Game code passes the edition-localized $card name to action messages,
# so this file owns the "which name shows up where" mapping.
#
# $who = "you" / "player" pattern is used universally.

# ==========================================================================
# Game metadata
# ==========================================================================
game-name-explodingkittens = Exploding Kittens
game-explodingkittens-desc = Draw cards, dodge exploding kittens, defuse what you can. Last one not exploded wins. Action cards let you skip your turn, peek at the deck, force opponents to give you cards, or shout "Nope!" to cancel anything.

# Rules (for the in-game help system)
explodingkittens-rules =
    Exploding Kittens is a card game for 2 to 5 players.
    Each turn, you may play any number of cards, then end your turn by drawing one card from the deck.
    If you draw an Exploding Kitten and have a Defuse, you defuse it and tuck it back into the deck wherever you want. If you draw an Exploding Kitten and have no Defuse, you explode and are out of the game.
    Action cards: Skip ends your turn without drawing. Attack ends your turn and forces the next player to take 2 turns in a row. See the Future shows you the top 3 cards. Shuffle reshuffles the deck. Favor lets you take a card of an opponent's choice from their hand.
    Cat cards have no effect alone. Two matching cat cards = steal a random card from any player. Three matching cat cards = name a card and steal it if they have it.
    Nope cards can be played at any time, even out of turn, to cancel any action card someone else just played. Another Nope cancels the Nope, and so on.
    Last player not exploded wins. Press S to check your hand and the deck.

# ==========================================================================
# Lobby options
# ==========================================================================

# Edition (MenuOption: standard / nsfw)
ek-set-edition = Edition: { $edition }
ek-desc-edition = Standard uses the original card art and tame card names. NSFW (adult) replaces card names and flavor text with crude / sexual / profane parodies — same mechanics, raunchier vibe. Pick a friend group, not a family group, before turning this on.
ek-prompt-edition = Select edition
ek-option-changed-edition = Edition set to { $edition }.
ek-edition-standard = standard
ek-edition-nsfw = NSFW (adult)

# Streaking Kittens variant (BoolOption)
ek-toggle-streaking = Streaking Kittens variant: { $enabled }
ek-desc-streaking = When on, one Streaking Kitten card joins the deck. A player holding it doesn't explode when they later draw a regular Exploding Kitten — but if they're caught holding both at once, both go off. Adds bluffing pressure to who's hoarding what.
ek-option-changed-streaking = Streaking Kittens variant { $enabled }.

# Starting hand size (IntOption)
ek-set-hand-size = Starting hand size: { $cards } cards
ek-desc-hand-size = Cards each player draws at the start (not counting their starting Defuse). Default is 7. Smaller hands make the game more cutthroat; larger hands give more room for combos.
ek-prompt-hand-size = Enter starting hand size (4 to 10)
ek-option-changed-hand-size = Starting hand size set to { $cards } cards.

# See-the-future peek count (IntOption)
ek-set-peek-count = See the Future shows: { $cards } cards
ek-desc-peek-count = How many cards See the Future reveals from the top of the deck. Default is 3. Higher gives more information.
ek-prompt-peek-count = Enter See the Future peek count (1 to 5)
ek-option-changed-peek-count = See the Future shows { $cards } cards.

# Nope window length (IntOption, in seconds)
ek-set-nope-window = Nope window: { $seconds } seconds
ek-desc-nope-window = How long after each cancellable action everyone has to play a Nope card. Default is 5 seconds. Shorter is faster, longer gives screen-reader users more time to react.
ek-prompt-nope-window = Enter Nope window in seconds (2 to 15)
ek-option-changed-nope-window = Nope window set to { $seconds } seconds.

# ==========================================================================
# Card names — STANDARD edition
# ==========================================================================
ek-card-defuse-standard = Defuse
ek-card-exploding-kitten-standard = Exploding Kitten
ek-card-streaking-kitten-standard = Streaking Kitten
ek-card-skip-standard = Skip
ek-card-attack-standard = Attack
ek-card-see-the-future-standard = See the Future
ek-card-shuffle-standard = Shuffle
ek-card-favor-standard = Favor
ek-card-nope-standard = Nope
ek-card-tacocat-standard = Tacocat
ek-card-hairy-potato-cat-standard = Hairy Potato Cat
ek-card-rainbow-ralph-cat-standard = Rainbow-Ralphing Cat
ek-card-beard-cat-standard = Beard Cat
ek-card-cattermelon-standard = Cattermelon

# ==========================================================================
# Card names — NSFW edition
# Crude / sexual party-game parodies in the spirit of the actual NSFW deck.
# ==========================================================================
ek-card-defuse-nsfw = Safe Word
ek-card-exploding-kitten-nsfw = Exploding Asshole
ek-card-streaking-kitten-nsfw = Streaking Asshole
ek-card-skip-nsfw = Premature Excuse
ek-card-attack-nsfw = Mindfuck
ek-card-see-the-future-nsfw = Peek-a-Boo
ek-card-shuffle-nsfw = Bend Over
ek-card-favor-nsfw = Strip Search
ek-card-nope-nsfw = Fuck That!
ek-card-tacocat-nsfw = Cock-of-the-Walk
ek-card-hairy-potato-cat-nsfw = Hairy Ballsack
ek-card-rainbow-ralph-cat-nsfw = Vomit Hooker
ek-card-beard-cat-nsfw = Pubic Beard
ek-card-cattermelon-nsfw = Watermelon Tits

# ==========================================================================
# Turn / draw flow
# ==========================================================================
ek-turn-start = { $player }'s turn. { $remaining } cards left in the deck.{ $extra_turns ->
    [0] {""}
    [one] {" "}({ $extra_turns } extra turn pending.)
    *[other] {" "}({ $extra_turns } extra turns pending.)
}
ek-action-draw = Draw a card
ek-action-end-turn = Pass turn
ek-drew-safe = { $who ->
    [you] You drew: { $card }.
    *[player] { $player } drew a card.
}
ek-drew-streaking-kitten = { $who ->
    [you] You drew a { $card }! You don't explode while you hold it — but draw a real Exploding Kitten and you're done.
    *[player] { $player } drew a { $card }.
}
ek-drew-exploding-survived = { $who ->
    [you] You drew an { $card } — but you have a { $defuse }! You defuse it and tuck it back into the deck.
    *[player] { $player } drew an { $card } and defused it with a { $defuse }.
}
ek-drew-exploding-no-defuse = { $who ->
    [you] You drew an { $card } and have no { $defuse }! You explode and are out of the game.
    *[player] { $player } drew an { $card } with no { $defuse } and is out of the game!
}
ek-defuse-prompt-position = Where do you want to put the { $card } back in the deck?
ek-defuse-position-top = Top of the deck
ek-defuse-position-second = Second from top
ek-defuse-position-bottom = Bottom of the deck
ek-defuse-position-random = Random spot
ek-defuse-tucked = { $who ->
    [you] You tucked the { $card } { $where }.
    *[player] { $player } tucked the { $card } back into the deck.
}

# ==========================================================================
# Action card plays
# ==========================================================================
ek-played-skip = { $who ->
    [you] You play { $card }. Your turn ends without drawing.
    *[player] { $player } plays { $card } and ends their turn.
}
ek-played-attack = { $who ->
    [you] You play { $card }. Your turn ends and { $target } must take 2 turns in a row.
    *[player] { $player } plays { $card }! { $target } must take 2 turns in a row.
}
ek-played-shuffle = { $who ->
    [you] You play { $card }. The deck is shuffled.
    *[player] { $player } plays { $card } and shuffles the deck.
}
ek-played-see-future = { $who ->
    [you] You play { $card }. The top { $count } cards are: { $cards }.
    *[player] { $player } plays { $card } and peeks at the top of the deck.
}
ek-played-favor = { $who ->
    [you] You play { $card } targeting { $target }. They must give you a card of their choice.
    *[player] { $player } plays { $card } targeting { $target }.
}
ek-played-cat-pair = { $who ->
    [you] You play a pair of { $card } cards targeting { $target }. You steal a random card from their hand.
    *[player] { $player } plays a pair of { $card } cards targeting { $target }.
}
ek-played-cat-trio = { $who ->
    [you] You play three { $card } cards targeting { $target }. Name a card to steal if they have it.
    *[player] { $player } plays three { $card } cards targeting { $target }.
}

# Favor / steal results
ek-favor-given = { $who ->
    [you] You give { $target } a { $card }.
    *[player] { $player } gives { $target } a { $card }.
}
ek-favor-received = { $who ->
    [you] { $source } gave you a { $card }.
    *[player] {""}
}
ek-cat-pair-stole = { $who ->
    [you] You stole { $card } from { $target }.
    *[player] { $player } steals a card from { $target }.
}
ek-cat-pair-stole-private = { $who ->
    [you] { $source } stole your { $card }.
    *[player] {""}
}
ek-cat-pair-empty = { $who ->
    [you] { $target } has no cards to steal.
    *[player] { $target } has no cards to steal.
}
ek-cat-trio-success = { $who ->
    [you] You stole { $card } from { $target }!
    *[player] { $player } guessed correctly and stole a { $card } from { $target }.
}
ek-cat-trio-fail = { $who ->
    [you] You named { $card } but { $target } didn't have one.
    *[player] { $player } named { $card } but { $target } didn't have one.
}

# Cat trio name prompt
ek-cat-trio-name-prompt = Name a card to steal from { $target }.

# Target prompts
ek-target-prompt = Choose a target.

# ==========================================================================
# Nope window
# ==========================================================================
ek-nope-window-open = Nope window open ({ $seconds } seconds): anyone with { $card } can cancel { $original_player }'s { $original_card }.
ek-action-play-nope = Play { $card } to cancel
ek-action-skip-nope = Let it stand
ek-noped = { $who ->
    [you] You play { $card }! { $original_player }'s { $original_card } is cancelled.
    *[player] { $player } plays { $card }! { $original_player }'s { $original_card } is cancelled.
}
ek-yes-noped = { $who ->
    [you] You play { $card } against the Nope! The original action goes through.
    *[player] { $player } plays { $card } against the Nope! The original action goes through.
}
ek-nope-window-closed = Nope window closed.

# ==========================================================================
# Hand / deck inspection (S key)
# ==========================================================================
ek-status-deck = Deck: { $count } cards remaining.
ek-status-deck-with-kittens = Deck: { $count } cards remaining (including { $kittens ->
    [one] 1 Exploding Kitten
    *[other] { $kittens } Exploding Kittens
}).
ek-status-discard = Discard pile: { $count } cards.
ek-status-hand-header = Your hand ({ $count } { $count ->
    [one] card
    *[other] cards
}):
ek-status-hand-card = { $card }
ek-status-hand-empty = Your hand is empty.
ek-status-extra-turns = You owe { $count } extra { $count ->
    [one] turn
    *[other] turns
}.
ek-status-eliminated = You have been eliminated.
ek-status-future-peek = Top of deck (your last peek): { $cards }.
ek-status-future-no-peek = You haven't peeked at the deck.

# Detailed status — opponent summary
ek-status-detailed-header = Detailed status — { $count } players left.
ek-status-detailed-line = { $player }{ $self_suffix }: { $hand_count } cards in hand.
ek-status-detailed-out = { $player }: eliminated.
ek-status-detailed-self-suffix = {" "}(you)

# ==========================================================================
# Game end
# ==========================================================================
ek-eliminated = { $player } has been eliminated! { $remaining } { $remaining ->
    [one] player
    *[other] players
} left.
ek-winner = { $player } is the last one standing!
ek-end-score = { $rank }. { $player }: { $status }
ek-end-status-survived = survived
ek-end-status-eliminated = eliminated

# ==========================================================================
# Misc
# ==========================================================================
ek-action-not-your-turn = It's not your turn.
ek-action-not-playing = The game is not in progress.
ek-action-must-respond-nope = A Nope window is open — choose to play Nope or let it stand.
ek-action-no-targets = No valid targets.
ek-action-no-cat-pair = You don't have a pair of matching cat cards.
ek-action-no-cat-trio = You don't have three matching cat cards.
ek-action-no-defuse = You have no Defuse card to play.
ek-cat-defuse-not-stealable = Defuse cards cannot be named in a three-of-a-kind steal.
