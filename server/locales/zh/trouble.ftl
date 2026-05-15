# Trouble — zh
game-name-trouble = Trouble

trouble-rules =
    Trouble 是 Parcheesi 家族的赛跑游戏。
    每位玩家从自己的家区域开始放置棋子。
    轮到你时，按下骰子并移动一枚棋子。
    默认情况下必须掷出 6 才能将棋子从家中释放到赛道。
    默认掷出 6 还可获得额外回合。
    棋子沿共享赛道顺时针向终点区域移动。
    踩到对方棋子会将其送回对方家中，除非该格受保护。
    所有棋子到达终点时你获胜。
    团队模式下，全部队员完成时该队获胜。
    使用 1-6 键选择棋子，R 键投掷。
    随时按 E 听取完整盘面状态。

trouble-action-roll = 按骰子
trouble-action-move-token = 移动棋子 { $token }
trouble-action-check-board = 查看盘面

trouble-token-label-home = 棋子 { $token }: 在家
trouble-token-label-track = 棋子 { $token }: 赛道第 { $position } 格
trouble-token-label-finish-lane = 棋子 { $token }: 终点道 { $position }/{ $total }
trouble-token-label-finished = 棋子 { $token }: 已完成

trouble-rolled = { $player } 掷出 { $roll }。
trouble-leave-home = { $player } 将棋子 { $token } 释放到赛道。
trouble-advance-track = { $player } 将棋子 { $token } 移到第 { $position } 格。
trouble-enter-finish-lane = { $player } 将棋子 { $token } 移入终点道。
trouble-advance-finish-lane =
    { $player } 将棋子 { $token } 前进到终点道第 { $position }/{ $total } 格。
trouble-token-finished = { $player } 的棋子 { $token } 到达终点。
trouble-bump =
    { $player } 的棋子 { $token } 将 { $opponent } 的棋子 { $opp_token } 撞回家。
trouble-no-legal-move = { $player } 无合法着法，轮次跳过。
trouble-extra-turn = { $player } 凭 6 获得额外回合。

trouble-winner = { $player } 获胜！所有棋子到达终点。
trouble-team-winner = 队伍 { $team } 获胜！所有队员均已完成。
trouble-final-standing = { $player }: { $finished }/{ $total } 棋子完成。

trouble-turn-summary =
    你在家中有 { $own_home }，赛道上 { $own_track }，终点 { $own_finished }。
    对手: { $opponents }。
trouble-opponent-summary = { $name }: 家 { $home }、赛道 { $track }、终点 { $finished }

trouble-board-status =
    你的棋子: { $own_tokens }。
    对手棋子: { $opp_tokens }。

trouble-reason-not-rolled = 请先按骰子。
trouble-reason-already-rolled = 已经按过了，请选择要移动的棋子。
trouble-reason-no-legal-moves = 这次掷点没有合法着法。
trouble-reason-token-home-needs-six = 此棋子在家。需要掷 6 才能释放。
trouble-reason-token-home-needs-any = 此棋子在家。任何点数都可释放。
trouble-reason-token-home-no-qualifying-roll =
    此棋子在家，而你的掷点不符合释放条件。
trouble-reason-token-finished = 此棋子已完成。
trouble-reason-overshoot-wastes = 此棋子无法在不超过终点的情况下前进 { $roll } 格。
trouble-reason-blocked = 此移动被阻挡。

trouble-option-track-size = 赛道长度: { $track_size } 格
trouble-option-select-track-size = 选择赛道格数。
trouble-option-changed-track-size = 赛道设为 { $track_size } 格。
trouble-option-desc-track-size = 共享赛道上的格数。

trouble-option-tokens-per-player = 每位玩家棋子数: { $tokens }
trouble-option-enter-tokens-per-player = 输入每位玩家棋子数 (2-6):
trouble-option-changed-tokens-per-player = 每位玩家棋子数设为 { $tokens }。
trouble-option-desc-tokens-per-player = 每位玩家送到终点的棋子数。

trouble-option-extra-turn-on-six = 掷 6 额外回合: { $enabled }
trouble-option-changed-extra-turn-on-six = 6 额外回合 { $enabled ->
    [on] 已启用。
    [off] 已禁用。
   *[other] 已更新。
}
trouble-option-desc-extra-turn-on-six =
    启用时掷 6 给一个额外回合 (经典 Hasbro 规则)。

trouble-option-six-to-leave-home = 离家须掷 6: { $enabled }
trouble-option-changed-six-to-leave-home = 离家须掷 6 { $enabled ->
    [on] 已启用。
    [off] 已禁用。
   *[other] 已更新。
}
trouble-option-desc-six-to-leave-home =
    启用时必须掷 6 才能从家中释放棋子；禁用时任何点数都可释放。

trouble-option-safe-spaces = 安全格: { $mode }
trouble-option-select-safe-spaces = 选择安全格模式。
trouble-option-changed-safe-spaces = 安全格设为 { $mode }。
trouble-option-desc-safe-spaces = 决定棋子是否可免于被撞。

trouble-safe-mode-none = 无
trouble-safe-mode-home-stretch = 仅终点直道
trouble-safe-mode-every-seventh = 每 7 格

trouble-option-finish-behavior = 终点: { $mode }
trouble-option-select-finish-behavior = 选择终点行为。
trouble-option-changed-finish-behavior = 终点行为设为 { $mode }。
trouble-option-desc-finish-behavior = 处理超出终点的掷点方式。

trouble-finish-mode-exact = 需要恰好的点数
trouble-finish-mode-bounce = 超出反弹
trouble-finish-mode-allow = 允许超出

trouble-option-bot-difficulty = 机器人难度: { $level }
trouble-option-select-bot-difficulty = 选择机器人难度。
trouble-option-changed-bot-difficulty = 机器人难度设为 { $level }。
trouble-option-desc-bot-difficulty = 内置机器人的强度。

trouble-bot-difficulty-naive = 朴素
trouble-bot-difficulty-greedy = 贪婪

trouble-option-preset = 预设: { $preset }
trouble-option-select-preset = 选择变体。主机随后可调整单项规则。
trouble-option-changed-preset = 已应用预设: { $preset }。
trouble-option-desc-preset = 为常见变体预先打包的选项集。

trouble-preset-classic = 经典 Hasbro
trouble-preset-fast = 快速
trouble-preset-brutal = 残酷
trouble-preset-custom = 自定义
