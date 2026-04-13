# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = 风险

# Phase announcements
risk-reinforce-start = { $player } 获得 { $armies } 支军队部署。
risk-attack-phase = { $player } 现在可以进攻。
risk-fortify-phase = { $player } 现在可以调动。

# Reinforce
risk-placed-army = { $player } 增援 { $territory }（{ $troops } 部队）。剩余 { $remaining }。

# Attack
risk-attack-from = { $player } 从 { $territory } 进攻。
risk-combat-result =
    { $attacker } 从 { $att_territory } 进攻 { $def_territory }。
    进攻方骰点：{ $att_rolls }。防守方骰点：{ $def_rolls }。
    进攻方损失 { $att_losses }，防守方损失 { $def_losses }。
risk-conquered = { $player } 征服 { $territory }！{ $moved } 部队进驻。
risk-eliminated = { $player } 已被淘汰！
risk-skip-attack = 跳过进攻
risk-cancel-attack = 取消进攻

# Fortify
risk-fortify-from = { $player } 从 { $territory } 调动。
risk-fortified = { $player } 将 { $moved } 部队从 { $source } 移至 { $dest }。
risk-skip-fortify = 跳过调动
risk-cancel-fortify = 取消调动

# Cards
risk-cards-traded = { $player } 用卡牌换取 { $armies } 支奖励军队。

# Territory labels by phase
risk-territory-reinforce = { $name }：{ $troops } 部队（还需部署 { $remaining }）
risk-territory-attack-from = { $name }：{ $troops } 部队（从此进攻）
risk-territory-attack-target = { $name }：{ $troops } 部队（{ $owner }）
risk-territory-fortify-from = { $name }：{ $troops } 部队（从此调动）
risk-territory-fortify-to = { $name }：{ $troops } 部队（调至此处）

# Status
risk-status-header = 你控制 { $territories } 个领地，共 { $troops } 部队。
risk-status-continent = { $name }：{ $owned }/{ $total } 个领地。奖励：{ $bonus }。

# Winner
risk-winner = { $player } 征服了世界！
risk-final-score = { $player }：{ $territories } 个领地

# Disabled reasons
risk-not-your-territory = 那不是你的领地。
risk-need-more-troops = 需要至少 2 部队才能进攻或调动。
risk-no-adjacent-enemy = 没有相邻的敌方领地。
risk-cannot-attack-own = 不能进攻自己的领地。
risk-not-adjacent = 该领地不相邻。
risk-same-territory = 不能调动到同一领地。

# Options
risk-set-starting-armies = 起始军队：{ $armies }
risk-desc-starting-armies = 每位玩家起始的额外军队（0 = 自动）
risk-enter-starting-armies = 输入每位玩家起始军队数（0 为自动）：
risk-option-changed-armies = 起始军队已改为 { $armies }

# Rules
risk-rules =
    风险是 2 到 6 人的世界征服游戏。
    棋盘上有 6 大洲 42 个领地。
    每回合分 3 个阶段：增援、进攻、调动。
    增援：在你的领地上部署军队。按领地数量和大洲奖励获得军队。
    进攻：选择有 2 支以上部队的领地，然后选相邻敌方领地。骰子决定战斗。
    进攻方最多掷 3 骰，防守方最多 2 骰。最高骰比较，平局归防守方。
    若消灭所有防守者，你征服该领地。
    调动：将部队移至相邻的自己领地。
    每回合至少征服一个领地获得一张卡。3 张同组卡牌可换取奖励军队。
    消灭所有对手即获胜。
    按 E 查看状态。
risk-check-status = Check status
