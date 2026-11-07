# pirates.ftl for locale zh. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = 失落海域的海盗
# Game start and setup
pirates-welcome = 欢迎来到失落海域的海盗！航行于海洋，收集宝石，与其他海盗战斗！
pirates-oceans = 你的航程将穿越：{ $oceans }
pirates-gems-placed = { $total }颗宝石已散落在海洋中。找到它们全部！
pirates-golden-moon = 金月升起！本回合所有XP获得三倍！
# Turn announcements
pirates-turn = { $player }的回合。位置{ $position }
# Movement actions
pirates-move-left = 向左航行
pirates-move-right = 向右航行
pirates-move-2-left = 向左航行2格
pirates-move-2-right = 向右航行2格
pirates-move-3-left = 向左航行3格
pirates-move-3-right = 向右航行3格
# Movement messages
pirates-move-you = 你向{ $direction }航行到位置{ $position }。
pirates-move = { $player }向{ $direction }航行到位置{ $position }。
pirates-map-edge = 你不能再航行更远了。你在位置{ $position }。
pirates-your-position = 你的位置：{ $ocean }的{ $position }
pirates-check-position = 检查位置
pirates-check-moon = 检查月亮亮度
# Position and status
pirates-check-status = 检查状态
pirates-check-status-detailed = 详细状态
pirates-all-gems-collected = 所有宝石都已被收集！
# Winner
pirates-winner = { $player }以{ $score }点获胜！
# Gem collection
pirates-gem-found-you = 你找到了{ $gem }！价值{ $value }点。
pirates-gem-found = { $player }找到了{ $gem }！价值{ $value }点。
pirates-level-up-you = 你达到等级{ $level }！
pirates-level-up = { $player }达到等级{ $level }！
pirates-level-up-multiple-you = 你升了{ $levels }级！现在是等级{ $level }！
pirates-level-up-multiple = { $player }升了{ $levels }级！现在是等级{ $level }！
pirates-skills-unlocked-you = 你解锁了新技能：{ $skills }。
pirates-skills-unlocked = { $player }解锁了新技能：{ $skills }。
# Combat - Attack initiation
pirates-cannonball = 发射炮弹
pirates-no-targets = { $range }格内没有目标。
pirates-attack-you-fire = 你向{ $target }发射炮弹！
pirates-attack-incoming = { $attacker }向你发射炮弹！
pirates-attack-fired = { $attacker }向{ $defender }发射炮弹！
# Combat - Hit results
pirates-attack-hit-you = 直接命中！你击中了{ $target }！
pirates-attack-hit-them = 你被{ $attacker }击中了！
pirates-attack-hit = { $attacker }击中{ $defender }！
# Combat - Miss results
pirates-attack-miss-you = 你的炮弹未击中{ $target }。
pirates-attack-miss-them = 炮弹未击中你！
pirates-attack-miss = { $attacker }的炮弹未击中{ $defender }。
pirates-push = { $attacker }将{ $defender }从{ $old_pos }推向{ $direction }到{ $new_pos }。
pirates-steal-success-you = 你从{ $target }偷到了{ $gem }！
pirates-steal-success-them = { $attacker }偷走了你的{ $gem }！
pirates-steal-success = { $attacker }从{ $defender }偷到{ $gem }！
pirates-steal-failed = 偷窃失败！
# Skills menu
pirates-use-skill = 使用技能
pirates-select-skill = 选择要使用的技能
# Skill activation
pirates-skill-activated = { $player }激活{ $skill }！
pirates-buff-expired = { $player }的{ $skill }增益效果已消失。
# Portal skill
pirates-portal-no-ships = 没有其他船只可以传送。
pirates-portal-fizzle = { $player }的传送门消失了，没有目的地。
pirates-portal-success = { $player }传送到{ $ocean }的位置{ $position }！
# Gem Seeker skill
pirates-gem-seeker-reveal = 海洋低语着位置{ $position }有{ $gem }。（剩余{ $uses }次使用）
# Sword Fighter skill
pirates-sword-fighter-activated = 剑客激活！攻击加成+4，持续{ $turns }回合。
# Push skill (defense buff)
pirates-push-activated = 推击激活！防御加成+3，持续{ $turns }回合。
# Skilled Captain skill
pirates-skilled-captain-activated = 熟练船长激活！攻击+2和防御+2，持续{ $turns }回合。
# Battleship skill
pirates-battleship-activated = 战舰激活！本回合你可以发射两次炮弹！
pirates-battleship-shot = 发射第{ $shot }次射击...
pirates-battleship-no-targets = 第{ $shot }次射击没有目标。
# Double Devastation skill
pirates-double-devastation-activated = 双重毁灭激活！攻击范围增加到10格，持续{ $turns }回合。
# XP Multiplier options
pirates-set-combat-xp-multiplier = 战斗经验倍数：{ $combat_multiplier }
pirates-enter-combat-xp-multiplier = 战斗经验
pirates-set-find-gem-xp-multiplier = 找到宝石经验倍数：{ $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = 找到宝石的经验
# Gem stealing options
pirates-set-gem-stealing = 宝石偷窃：{ $mode }
pirates-select-gem-stealing = 选择宝石偷窃模式
pirates-option-changed-stealing = 宝石偷窃设置为{ $mode }。
# Gem stealing mode choices
pirates-stealing-with-bonus = 带掷骰加成
pirates-stealing-no-bonus = 无掷骰加成
pirates-stealing-disabled = 禁用
