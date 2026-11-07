\*\*Chess\*\*

Chess is a duel of calculation, timing, and long-term planning on an 8 by 8 battlefield. Two players command opposing armies, each trying to break through the position, defend their king, and deliver checkmate before the other side can do the same.

\*\*Gameplay\*\*

Each side begins with sixteen pieces. White moves first, then the players alternate turns for the rest of the game.

The board is an 8 by 8 grid. On your turn, you choose one of your own pieces and then choose a legal destination square.

You can also type a move directly. The input accepts common chess formats, including coordinate notation such as `e2e4`, algebraic notation such as `Nf3` or `Rae1`, castling as `O-O` or `O-O-O`, and promotion such as `e8=Q`.

\* Pawns move forward, capture diagonally, and may advance two squares from their starting rank.
\* Knights move in an L shape and can jump over other pieces.
\* Bishops move diagonally across any number of open squares.
\* Rooks move horizontally or vertically across any number of open squares.
\* Queens combine rook and bishop movement.
\* Kings move one square in any direction.

You may never make a move that leaves your own king in check. If your king is under attack, you must answer that threat immediately by moving the king, blocking the line of attack, or capturing the attacking piece.

If a clock is enabled, only the active player's clock runs. After a legal move is completed, any increment from the selected time control is added to that player's remaining time. If a draw offer or undo request is waiting for a response, the clock is paused until that response is resolved.

\*\*Special Mechanics\*\*

\* \*\*Castling:\*\* Castling is legal if the king and rook involved have not moved, the squares between them are empty, the king is not currently in check, and the king does not move through or into check.
\* \*\*En passant:\*\* If an opposing pawn advances two squares in one move and lands beside your pawn, you may capture it immediately as though it had moved only one square.
\* \*\*Promotion:\*\* When a pawn reaches the last rank, it must be promoted to a queen, rook, bishop, or knight.
\* \*\*Checkmate:\*\* The game ends immediately when a player is in check and has no legal move.
\* \*\*Stalemate:\*\* The game is drawn if the side to move is not in check but has no legal move.
\* \*\*Insufficient material:\*\* The game is drawn automatically if neither side has enough material to force checkmate.
\* \*\*Timeout:\*\* If a player's clock reaches zero, that player loses on time unless the opponent does not have enough material to ever give checkmate, in which case the game is drawn.

\*\*Draws, Claims, and Agreements\*\*

Chess includes several ways for a game to end in a draw.

\* \*\*Threefold repetition:\*\* If the same position occurs three times with the same side to move and the same rights, the game may be drawn.
\* \*\*Fivefold repetition:\*\* If the same position occurs five times, the game is drawn automatically.
\* \*\*Fifty-move rule:\*\* If each player has made fifty consecutive moves without any pawn move or capture, the game may be drawn.
\* \*\*Seventy-five-move rule:\*\* If each player has made seventy-five consecutive moves without any pawn move or capture, the game is drawn automatically unless the final move checkmated.
\* \*\*Draw offer:\*\* If draw offers are enabled for the table, a player may offer a draw after both players have made at least one move, and the opponent may accept or decline.
\* \*\*Undo request:\*\* If undo requests are enabled for the table, a player may ask to take back the most recent move and the opponent may accept or decline.

The host decides whether threefold repetition and the fifty-move rule are handled automatically or must be claimed by the player whose turn it is. Fivefold repetition and the seventy-five-move rule are always automatic.

\*\*Customizable Options\*\*

\* \*\*Time Control:\*\* Choose the clock preset for both players (default `Untimed`, choices: `Bullet 1+0`, `Bullet 2+1`, `Blitz 3+0`, `Blitz 3+2`, `Blitz 5+0`, `Rapid 10+0`, `Rapid 10+5`, `Classical 30+0`).
\* \*\*Draw Handling:\*\* Choose whether threefold repetition and the fifty-move rule are automatic or must be claimed. Fivefold repetition and the seventy-five-move rule are always automatic (default `Automatic`, choices: `Automatic` or `Claim required`).
\* \*\*Allow Draw Offers:\*\* Whether players may offer draws during the game (default `On`).
\* \*\*Allow Undo Requests:\*\* Whether players may ask their opponent to take back moves (default `Off`).

\*\*Keyboard Shortcuts\*\*

\* \*\*Enter:\*\* Select the highlighted square on the board.
\* \*\*V:\*\* Read the board.
\* \*\*C:\*\* Check the current game status.
\* \*\*M:\*\* Type a move directly.
\* \*\*F:\*\* Flip the board orientation.
\* \*\*Shift+T:\*\* Check both clocks.
\* \*\*Shift+C:\*\* Claim a draw when the current position qualifies.
\* \*\*Shift+D:\*\* Offer a draw.
\* \*\*Shift+U:\*\* Request an undo.
\* \*\*Y:\*\* Accept a draw offer or undo request.
\* \*\*N:\*\* Decline a draw offer or undo request.
