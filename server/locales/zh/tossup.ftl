# tossup.ftl for locale zh. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# 游戏信息
game-name-tossup = 掷骰冒险
# 操作
tossup-roll-first = 掷 { $count } 个骰子
tossup-roll-remaining = 掷剩余的 { $count } 个骰子
tossup-bank = 存入 { $points } 分
tossup-you-roll = 你掷出：{ $results }。
tossup-player-rolls = { $player } 掷出：{ $results }。
# 回合状态
tossup-you-have-points = 回合分数：{ $turn_points }。剩余骰子：{ $dice_count }。
tossup-player-has-points = { $player } 有 { $turn_points } 回合分数。剩余 { $dice_count } 个骰子。
# 新骰子
tossup-you-get-fresh = 骰子用完了！获得 { $count } 个新骰子。
tossup-player-gets-fresh = { $player } 获得 { $count } 个新骰子。
# 爆掉
tossup-you-bust = 爆掉了！你失去本回合的 { $points } 分。
tossup-player-busts = { $player } 爆掉了，失去 { $points } 分！
# 存入
tossup-you-bank = 你存入 { $points } 分。总分：{ $total }。
tossup-player-banks = { $player } 存入 { $points } 分。总分：{ $total }。
# 胜利者
tossup-winner = { $player } 获胜，得分 { $score }！
tossup-tie-tiebreaker = { $players } 之间平局！进入决胜回合！
# 选项
tossup-set-rules-variant = 规则变体：{ $variant }
tossup-select-rules-variant = 选择规则变体：
tossup-option-changed-rules = 规则变体已改为 { $variant }
tossup-set-starting-dice = 起始骰子数：{ $count }
tossup-enter-starting-dice = 输入起始骰子数：
tossup-option-changed-dice = 起始骰子数已改为 { $count }
# 规则变体
tossup-rules-standard = 标准
# 规则说明
tossup-rules-standard-desc = 每个骰子 3 绿 2 黄 1 红。没有绿色且至少有一个红色时爆掉。
