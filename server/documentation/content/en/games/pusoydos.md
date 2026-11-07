\*\*Pusoy Dos\*\*

Pusoy Dos (also known as Big Two or Deuces) is a popular shedding-type card game that originated in coastal China in the 1980s. It quickly spread and became a staple card game across Asia, particularly in the Philippines where it gained the name Pusoy Dos (Filipino Poker).

The objective is simple: be the first player to get rid of all your cards.

**Gameplay**

The game supports 2 to 4 players and uses a standard 52-card deck. With 4 players, each player is dealt 13 cards. With 3 players, the 3 of Spades is removed from the deck so that each player is dealt 17 cards evenly.

* **Card Rankings:** The number 2 is the highest card, followed by Ace, King, Queen, Jack, 10, 9, 8, 7, 6, 5, 4, and 3 is the lowest.
* **Suit Rankings:** Diamonds (highest) > Hearts > Spades > Clubs (lowest).
* **First Turn:** The player holding the 3 of Clubs starts the first trick, and must include it in their first play. If playing with fewer than 4 players and no one holds the 3 of Clubs, the player with the lowest value card starts instead.

Players take turns playing card combinations. The combination played must beat the previous combination on the table and be of the exactly same type.

The types of combinations are:

* **Single:** A single card.
* **Pair:** Two cards of the same rank.
* **Three of a Kind:** Three cards of the same rank.
* **Five-Card Hand:** You can play five-card combinations, exactly like poker hands. They rank from lowest to highest as follows:
  * **Straight:** Five consecutive cards of mixed suits (e.g., 3-4-5-6-7). The highest card determines the strength of the straight.
  * **Flush:** Five cards of the exact same suit (e.g., five Spades). A Flush beats any Straight. The suit is the primary decider of strength between Flushes; within the same suit, the highest card wins.
  * **Full House:** Three of a kind combined with a pair. A Full House beats any Flush or Straight. The rank of the three-of-a-kind part dictates its strength.
  * **Four of a Kind:** Four cards of the same rank, played with any single kicker card to make five. Beats a Full House.
  * **Straight Flush:** Five consecutive cards of the exact same suit. The strongest possible 5-card combination.

A trick ends when all other players pass consecutively. The last player to play cards starts a new trick with any valid combination they choose.

**Instant Wins**

When the Instant Wins option is enabled (on by default), certain dealt hands win the round immediately before play begins:

* **Dragon:** One card of every rank — a complete 13-card straight from 3 through 2.
* **Four 2s:** All four 2s in a single hand.
* **Six Pairs:** Exactly six pairs plus one odd card (seven distinct ranks, six of which appear twice).

Instant Wins and Card Passing are mutually exclusive setup options. If both are enabled, the game will refuse to start and ask the host to disable one of them.

**Card Passing**

After the first round, the Card Passing option can require winners and losers to exchange cards before play begins each subsequent round.

* **Simple:** The 1st-place finisher and the last-place finisher swap 1 card each. The loser automatically gives their highest card; the winner chooses which card to return.
* **Full:** 1st and last swap 2 cards; 2nd and 2nd-to-last swap 1 card (requires exactly 2 or 4 players).

**Example Turn**

* It's the start of the game. Alice holds the lowest card (3 of Clubs) and plays a Pair: 3 of Clubs and 3 of Hearts.
* It is Bob's turn. Because Alice played a "Pair", Bob *must* play a "Pair". He plays a pair of 5s.
* It is Charlie's turn. He doesn't have a pair higher than 5s, so he decides to press "P" to Pass.
* Alice plays a pair of Kings.
* Bob passes. Since both opponents passed consecutively, Alice wins the trick.
* Alice can now start the next trick with *any* combination. She chooses to play a Five-Card Straight.
* Bob must now play a Five-Card combination that beats a Straight (like a higher Straight, or a Flush).

**Scoring**

The first player to shed all their cards wins the round and the hand ends immediately. For modes that need the rest of the finishing order, remaining players are ranked by fewest cards left, with the lower highest card winning ties. What happens next depends on the Game Mode.

* **Elimination:** The first player to win the required number of rounds is eliminated as a winner. The game continues until only one player remains; that player loses (default game mode, default rounds to win: 2).
* **Losses:** The last-place finisher each round accumulates a strike. The first player to reach the loss limit loses the game (default loss limit: 3).
* **Points:** The round winner collects penalty points from each loser based on the number of cards left in their hand. The first player to reach the target score wins the game (default target score: 100).
* **Points Elimination:** Losers accumulate their own penalty points. Any player who reaches the target score is eliminated. The last player standing wins.

In Points and Points Elimination modes, the penalty for remaining cards scales with the Penalty Tier setting:

* **Standard:** 1 point per card (1-9 cards), x2 (10-12 cards), x3 (all 13 cards) (default).
* **Aggressive:** 1 point per card (1-7 cards), x2 (8-9 cards), x3 (10-12 cards), x4 (all 13 cards).
* **Flat:** 1 point per card remaining, no multiplier.

The optional **Penalty per 2 Held** setting doubles the total penalty for each 2 the losing player still holds.

**Game Options**

* **Game Mode:** Choose the match structure (default Elimination, choices: Elimination, Losses, Points, or Points Elimination; see Scoring above).
* **Rounds to Win** *(Elimination only):* How many rounds a player must win before being eliminated (default 2, range 1 to 10).
* **Losses to Lose** *(Losses only):* How many last-place finishes before a player loses (default 3, range 1 to 10).
* **Target Score** *(Points / Points Elimination only):* The score threshold for winning or elimination (default 100, range 10 to 10000).
* **Turn Timer:** Per-turn time limit (default Unlimited, choices: 10, 15, 20, 30, 45, 60, or 90 seconds, or Unlimited).
* **Allow 2 in Straights:** Whether the 2 may appear in straights, such as A-2-3-4-5 (default off).
* **Instant Wins:** Whether Dragon, Four 2s, and Six Pairs win the round on the deal. Cannot be combined with Card Passing (default on).
* **Card Passing:** Full passing is valid only with exactly 2 or 4 players. Cannot be combined with Instant Wins (default Off, choices: Off, Simple, or Full; see Card Passing above).
* **Penalty Tier** *(Points / Points Elimination only):* How remaining-card penalties are scaled (default Standard, choices: Standard, Aggressive, or Flat).
* **Penalty per 2 Held** *(Points / Points Elimination only):* Doubles the penalty for each 2 remaining in a losing hand (default off).

**Keyboard Shortcuts**

* **Space:** Play Selected Cards.
* **P:** Pass.
* **C:** Check current trick.
* **H:** Read your hand.
* **E:** Read card counts (number of cards remaining in each player's hand).
* **Shift+T:** Check turn timer.
