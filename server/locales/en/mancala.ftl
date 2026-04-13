# Mancala game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Pit { $pit }: { $stones } stones
mancala-check-board = Check board

# Game events
mancala-sow =
    { $player } sows { $stones } stones from pit { $pit }. Last stone lands in { $landed_in ->
        [own_store] { $player }'s store.
        [own_pit] { $player }'s pit { $landed_pit }.
        [opp_pit] { $opponent }'s pit { $landed_pit }.
       *[other] the board.
    }
mancala-capture = { $player }'s pit { $own_pit } captures { $captured } stones from { $opponent }'s pit { $opp_pit }.
mancala-extra-turn = { $player } gets another turn.
mancala-winner = { $player } wins with { $score } stones!
mancala-draw = It's a draw! Both players have { $score } stones.

# Board status (used by Check Board action and automatic turn-start announcement)
mancala-board-status =
    Your store: { $own_store }. Opponent's store: { $opp_store }.
    Your pits: { $own_pits }. Opponent's pits: { $opp_pits }.

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
