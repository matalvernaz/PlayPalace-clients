# Liar's Dice — zh
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = 每位玩家在自己的杯子下偷偷掷骰子。轮流叫出全桌某个面值的总数，越叫越高 — 不相信前一个叫价就喊"骗子!"猜错就丢一颗骰子。最后还有骰子的人获胜。

liarsdice-rules =
    Liar's Dice 是一款 2 到 6 人玩的骰子博弈游戏。
    每位玩家从杯子里的 5 颗骰子开始。每回合开始时所有人秘密掷骰。
    轮流对全桌某个面值的总数下注，例如"三颗 4"表示全部杯子揭开时至少有三颗 4。
    每次新叫价必须高过上一次：同样面值更高数量，或者更高面值数量持平或更多。
    1 是百搭 — 计入除"叫 1"以外的所有叫价。叫 1 时百搭失效。
    切换到叫 1 时数量减半（向上取整）。从 1 切回普通面值需要超过前一次数量两倍。
    可以不叫价改喊"骗子!"挑战上家。所有杯子揭开：若上家叫对了，挑战者丢一颗骰子；否则上家丢一颗。
    若 Spot On 开启，可改喊"Spot On"赌叫价完全准确。猜中 — 其他所有人各丢一颗；猜错 — 自己丢两颗。
    骰子归零即出局。最后还有骰子的人获胜。
    按 S 查看桌面。

ld-set-starting-dice = 每位玩家起始骰子: { $dice }
ld-desc-starting-dice = 每位玩家开始时拥有多少骰子。默认 5。骰子越多游戏越长，下注空间越大。
ld-prompt-starting-dice = 输入起始骰子数（3 到 8）
ld-option-changed-starting-dice = 起始骰子设为 { $dice }。

ld-toggle-wild-ones = 1 为百搭: { $enabled }
ld-desc-wild-ones = 开启：1 计入所有非 1 叫价。叫 1 时该次的百搭失效。关闭则游戏纯凭概率，没有百搭。
ld-option-changed-wild-ones = 1 百搭 { $enabled }。

ld-toggle-spot-on = Spot On 喊声启用: { $enabled }
ld-desc-spot-on = 开启时，除了"骗子"外还可以喊"Spot On"赌叫价完全准确。猜中 — 其他人各丢一颗骰子。猜错 — 自己丢两颗。高风险高回报。
ld-option-changed-spot-on = Spot On { $enabled }。

ld-round-start = 第 { $round } 回合开始。桌上骰子总数: { $total }。所有人开始掷。
ld-your-roll = 你本回合的骰子: { $dice }。
ld-your-counts = 你的点数统计: { $counts }。
ld-turn-start = 轮到 { $player } 了。{ $bid_state }
ld-no-bid-yet = 还没人叫价 — 请开局。
ld-current-bid = 当前叫价: { $quantity } 颗 { $face }。

ld-action-bid = 下注
ld-action-call-liar = 喊骗子
ld-action-call-spot-on = 喊 Spot On
ld-bid-prompt = 选择你的叫价。
ld-bid-option = { $quantity } 颗 { $face }
ld-bid-made = { $who ->
    [you] 你叫 { $quantity } 颗 { $face }。
    *[player] { $player } 叫 { $quantity } 颗 { $face }。
}

ld-call-liar = { $who ->
    [you] 你对 { $target } 的叫价"{ $quantity } 颗 { $face }"喊骗子。
    *[player] { $player } 对 { $target } 的叫价"{ $quantity } 颗 { $face }"喊骗子。
}
ld-call-spot-on = { $who ->
    [you] 你对 { $target } 的叫价"{ $quantity } 颗 { $face }"喊 Spot On。
    *[player] { $player } 对 { $target } 的叫价"{ $quantity } 颗 { $face }"喊 Spot On。
}
ld-reveal-header = 揭杯! 数桌上的 { $face }。
ld-reveal-line = { $player } 掷出: { $dice }。
ld-actual-count = { $face } 的实际数量（含 1 百搭）: { $count }。叫价为 { $quantity }。
ld-actual-count-no-wild = { $face } 的实际数量（无百搭）: { $count }。叫价为 { $quantity }。

ld-liar-bidder-loses = { $bidder } 叫高了 — 丢一颗骰子。
ld-liar-caller-loses = 叫价属实 — { $caller } 丢一颗骰子。
ld-spot-on-correct = Spot on! { $caller } 猜得分毫不差 — 其他所有人各丢一颗骰子。
ld-spot-on-wrong = 不是 spot on。{ $caller } 丢两颗骰子。

ld-lost-die = { $who ->
    [you] 你丢了一颗骰子。还剩 { $remaining } { $remaining ->
        [one] 颗
        *[other] 颗
    }。
    *[player] { $player } 丢了一颗骰子。还剩 { $remaining } 颗。
}
ld-lost-dice-multi = { $who ->
    [you] 你丢了 { $count } 颗骰子。还剩 { $remaining } { $remaining ->
        [one] 颗
        *[other] 颗
    }。
    *[player] { $player } 丢了 { $count } 颗骰子。还剩 { $remaining } 颗。
}
ld-eliminated = { $player } 骰子用光出局了! 还剩 { $remaining } { $remaining ->
    [one] 人
    *[other] 人
}。
ld-winner = { $player } 是最后一个还有骰子的人 — 获胜!

ld-status-round = 第 { $round } 回合。
ld-status-your-dice = 你的骰子: { $dice }。
ld-status-your-counts = 你的点数统计: { $counts }。
ld-status-no-dice = 你没有骰子了 — 已出局。
ld-status-current-bid = 当前叫价: { $quantity } 颗 { $face }。
ld-status-no-bid = 本回合还没人叫价。
ld-status-table-total = 桌上骰子总数: { $total }。
ld-status-detailed-header = 详细状态 — 还剩 { $count } 名玩家。
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] 颗
    *[other] 颗
}。
ld-status-detailed-out = { $player }: 已出局。
ld-status-detailed-self-suffix = {" "}(你)

ld-face-1 = 1
ld-face-2 = 2
ld-face-3 = 3
ld-face-4 = 4
ld-face-5 = 5
ld-face-6 = 6

ld-action-not-your-turn = 还没轮到你。
ld-action-not-playing = 游戏未在进行中。
ld-action-no-bid-to-call = 还没有可以挑战的叫价。
ld-action-eliminated = 你已经出局了。
