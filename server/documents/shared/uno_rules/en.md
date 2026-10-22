# UNO Rules

PlayPalace defaults to Mattel's classic 108-card UNO rules. Options explicitly
described as house rules can change those defaults.

## Object and Deal

UNO supports 2 to 10 players. Each player receives 7 cards. The remaining
cards form the draw pile, and one card starts the discard pile.

The player to the dealer's left begins. The dealer rotates each round. A
starting action card applies normally:

- Skip skips the first player.
- Reverse changes direction; the dealer acts first.
- Draw Two makes the first player draw 2 and lose the turn.
- Wild lets the first player choose the opening color.
- Wild Draw Four is returned to the deck and replaced.

The default match ends when a player reaches 500 points.

## Playing and Drawing

On your turn, play one card matching the discard's color, number, or action
symbol. A Wild may always be played.

You may choose not to play a legal card and draw exactly one card instead.
After choosing to draw:

- If the drawn card is playable, you may play that card only.
- You may keep it instead.
- You may not play a different card from your hand.
- If the drawn card is not playable, the turn ends.

This official optional draw is represented by the default “Free draws per
turn” value of 1. Setting it to 0 removes the option and is a house-rule
variant.

When the draw pile is empty, all but the top discard are shuffled to make a
new draw pile.

## Action Cards

- Skip: the next player loses their turn.
- Reverse: play direction reverses. With two players, it acts like Skip and
  the same player acts again.
- Draw Two: the next player draws 2 and loses their turn.
- Wild: choose the active color.
- Wild Draw Four: choose the active color; the next player draws 4 and loses
  their turn unless they successfully challenge.

Official UNO does not allow stacking Draw Twos or Wild Draw Fours. The
stacking and advanced-response options are house rules and default off.

## Wild Draw Four Challenges

Wild Draw Four is legal only when its player holds no card matching the active
color. Cards matching only the number or action symbol do not make it illegal.

The targeted player may challenge:

- If the play was illegal, the Wild Draw Four player draws 4 and the
  challenger keeps the turn.
- If the play was legal, the challenger draws 6 and loses the turn.
- If there is no challenge, the target draws 4 and loses the turn.

A Wild Draw Four played as the final card still allows the official challenge
before the round is scored.

## Calling UNO

Call UNO when playing your next-to-last card. Press `U`, or use the UNO action
on touch clients.

If a player fails to call UNO, another player may catch them after that card
is played and before the next player begins a play or draw. The caught player
draws 2 cards.

## Round Scoring

When a player empties their hand, that player receives the value of every card
remaining in opponents' hands. Any final Draw Two or Wild Draw Four penalty is
drawn before scoring.

- Number cards: face value
- Skip, Reverse, and Draw Two: 20 points
- Wild and Wild Draw Four: 50 points

The first player to 500 wins under the default scoring mode.

## House-Rule Options

The following are not part of classic official UNO and default off:

- Elimination scoring
- Draw-penalty stacking
- Advanced responses to draw stacks
- Straights
- Interceptions and super interceptions
- The zero/seven rule

“Draw penalties skip turn” and Wild Draw Four challenges default on, matching
the official game. “Wait for draw responses” matters only when the stacking
house rule is enabled.

## Controls

- `Space`: draw or accept a draw penalty
- `U`: call UNO or catch a missed call
- `C`: read the top card
- `V`: read the active color
- `E`: read card counts
- `D`: read your hand size and point value
- `Shift+C`: sort by color
- `Shift+N`: sort by number or type
- `S`: read scores
- `Shift+S`: detailed scores
- `T`: read the current turn
- `Ctrl+F1`: open these rules

When choosing a Wild color, use `R`, `Y`, `G`, or `B`.
