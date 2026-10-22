# Crazy Eights Rules

PlayPalace implements the standard one-pack rules published by Bicycle.

## Object

Be the first player to empty your hand. The round winner scores the cards
remaining in every opponent's hand. The first player to reach the table's
winning score wins the match; the default target is 500 points.

## Deal

Crazy Eights supports 2 to 8 players and uses one standard 52-card deck.
Each player receives 5 cards. The rest form the face-down stock.

The dealer turns one card face up as the starter. If it is an 8, it is
returned to the stock, the stock is shuffled, and another starter is turned.
Any other card, including a jack, queen, or king, is a valid starter.

The player to the dealer's left goes first. The dealer rotates after each
round.

## Playing a Card

Play one card matching either the suit or rank of the top discard.

For example, if the top card is the queen of clubs, you may play any club or
any queen.

An 8 is wild and may be played at any time. After playing one, choose clubs,
diamonds, hearts, or spades. The next player must play that suit or another 8.

Jacks, queens, and kings are ordinary matching cards. They do not reverse,
skip, or make another player draw.

## Drawing and Passing

If you cannot play, draw from the stock until you can play or the stock is
empty. Once a playable card is available, play one card.

You may choose to draw one card even when your hand already contains a legal
play. After that voluntary draw, play a legal card.

The discard pile is not recycled. If the stock is empty and you have no legal
play, pass. If every player passes consecutively, PlayPalace redeals the round
without awarding points; this is the digital deadlock rule for a position the
printed rules do not otherwise resolve.

## Ending and Scoring a Round

The first player with no cards wins the round and receives:

- 50 points for each 8
- 10 points for each 10, jack, queen, or king
- 1 point for each ace
- Face value for every other card

Scores carry across rounds until someone reaches the configured target.

## Controls

- `Space`: draw
- `P`: pass when the stock is empty and you cannot play
- `C`: read the top discard
- `E`: read hand and stock counts
- `Shift+T`: read the turn timer

After playing an 8:

- `C`: clubs
- `D`: diamonds
- `H`: hearts
- `S`: spades

The legacy All in Play-inspired sounds are audio feedback only; they do not
give face cards action powers.
