# Mancala game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Pit { $pit }: { $stones } stones

# Game events
mancala-sow = { $player } sows { $stones } stones from pit { $pit }
mancala-capture = { $player } captures { $captured } stones!
mancala-extra-turn = Last stone in store! { $player } gets another turn.
mancala-winner = { $player } wins with { $score } stones!
mancala-draw = It's a draw! Both players have { $score } stones.

# Board status
mancala-board-status =
    Your pits: { $own_pits }. Your store: { $own_store }.
    Opponent's pits: { $opp_pits }. Opponent's store: { $opp_store }.

# Options
mancala-set-stones = Stones per pit: { $stones }
mancala-desc-stones = Number of stones in each pit at the start
mancala-enter-stones = Enter the number of starting stones per pit:
mancala-option-changed-stones = Starting stones changed to { $stones }

# Disabled reasons
mancala-pit-empty = That pit is empty.

# Rules
mancala-rules =
    Mancala is a two-player pit and stone game.
    Each player has 6 pits and a store.
    On your turn, pick one of your pits to sow from.
    Stones are dropped one by one into each pit going around the board, including your store but skipping your opponent's store.
    If your last stone lands in your store, you get another turn.
    If your last stone lands in an empty pit on your side, you capture that stone and all stones in the opposite pit.
    The game ends when one side is completely empty. Remaining stones go to that player's store.
    The player with the most stones wins.
    Use keys 1 through 6 to select a pit, or swipe to browse. Press E to check the board.

# End screen
mancala-final-score = { $player }: { $score } stones
