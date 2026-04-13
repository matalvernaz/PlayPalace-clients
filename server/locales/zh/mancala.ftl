# Mancala game messages — zh
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = 播棋

# Actions
mancala-pit-label = 坑 { $pit }：{ $stones } 颗石子

# Game events
mancala-sow = { $player } 从坑 { $pit } 播种 { $stones } 颗石子
mancala-capture = { $player } 俘获 { $captured } 颗石子！
mancala-extra-turn = 最后一颗石子落入仓库！{ $player } 再来一回合。
mancala-winner = { $player } 以 { $score } 颗石子获胜！
mancala-draw = 平局！双方各有 { $score } 颗石子。

# Board status
mancala-board-status =
    你的坑：{ $own_pits }。你的仓库：{ $own_store }。对手的坑：{ $opp_pits }。对手的仓库：{ $opp_store }。

# Options
mancala-set-stones = 每坑石子数：{ $stones }
mancala-desc-stones = 开始时每个坑中的石子数
mancala-enter-stones = 输入每坑的初始石子数：
mancala-option-changed-stones = 初始石子数已改为 { $stones }

# Disabled reasons
mancala-pit-empty = 该坑为空。

# Rules
mancala-rules =
    播棋是一种双人坑洞和石子游戏。
    每位玩家有6个坑和1个仓库。
    轮到你时，选择一个己方的坑进行播种。
    石子沿棋盘逐个放入每个坑中，包括你的仓库，但跳过对手的仓库。
    如果最后一颗石子落入你的仓库，你可以再走一步。
    如果最后一颗石子落入己方空坑，你俘获该石子及对面坑中的所有石子。
    当一方的坑全部清空时游戏结束。
    石子最多的玩家获胜。
    使用按键1-6选择坑位。按E查看棋盘。

# End screen
mancala-final-score = { $player }：{ $score } 颗石子
