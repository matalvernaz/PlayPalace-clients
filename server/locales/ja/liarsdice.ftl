# Liar's Dice — ja
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = 各プレイヤーは伏せたカップの中で密かにダイスを振ります。テーブル全体での特定の目の総数をかけて入札を続け、最後の入札を信じられなければ「ライアー!」と宣言します。間違えるとダイスを失います。最後までダイスを持っていた人の勝ちです。

liarsdice-rules =
    Liar's Dice は 2 から 6 人で遊ぶブラフのダイスゲームです。
    各プレイヤーはカップに 5 個のダイスを持って始めます。ラウンドの最初に全員が密かに振ります。
    順番に、テーブル全体での特定の目の総数を入札します。たとえば「3 個の 4」とは、すべてのカップを開いたとき少なくとも 4 が 3 個あるという意味です。
    新しい入札は前より高くしなければなりません。同じ目で数を増やすか、より高い目で数を同じか増やすかです。
    1 はワイルド扱いで、1 以外の目への入札に加算されます。1 自体への入札ではワイルドは無効です。
    1 への入札に切り替えると数は半分（切り上げ）になります。1 から通常の目に戻る場合は前回の数の 2 倍を超える必要があります。
    入札の代わりに「ライアー!」と宣言して直前の入札に異議を唱えられます。全カップを開け、入札が正しければ宣言者がダイスを 1 つ失い、そうでなければ入札者が 1 つ失います。
    Spot On 有効時は「Spot On」と宣言して入札がぴったり正しいと賭けられます。当たれば他のプレイヤー全員がダイスを 1 つ失い、外れれば自分が 2 つ失います。
    ダイスが 0 個になると脱落です。最後までダイスを持っていた人の勝ちです。
    S を押すとテーブルを確認できます。

ld-set-starting-dice = プレイヤー毎の開始ダイス数: { $dice }
ld-desc-starting-dice = 各プレイヤーが何個のダイスで始めるか。既定値は 5。ダイスが多いほどゲームが長くブラフの余地が広がります。
ld-prompt-starting-dice = 開始ダイス数を入力（3 から 8）
ld-option-changed-starting-dice = 開始ダイス数を { $dice } に設定しました。

ld-toggle-wild-ones = 1 がワイルド: { $enabled }
ld-desc-wild-ones = 有効: 1 は 1 以外への入札に加算されます。1 への入札ではワイルドが無効になります。無効ならゲームは純粋な確率となりワイルドはありません。
ld-option-changed-wild-ones = ワイルド 1 を { $enabled }。

ld-toggle-spot-on = Spot On 宣言を有効: { $enabled }
ld-desc-spot-on = 有効: 「ライアー」のほかに「Spot On」と宣言して、入札がぴったり正しいと賭けられます。当たれば他全員がダイス 1 つを失います。外れれば自分が 2 つ失います。高リスク高リターン。
ld-option-changed-spot-on = Spot On を { $enabled }。

ld-round-start = ラウンド { $round } 開始。テーブル上の総ダイス: { $total }。全員振ります。
ld-your-roll = このラウンドのあなたのダイス: { $dice }。
ld-your-counts = あなたの個数: { $counts }。
ld-turn-start = { $player } の番です。{ $bid_state }
ld-no-bid-yet = まだ入札なし — ラウンドを開いてください。
ld-current-bid = 現在の入札: { $quantity } 個の { $face }。

ld-action-bid = 入札する
ld-action-call-liar = ライアー宣言
ld-action-call-spot-on = Spot On 宣言
ld-bid-prompt = 入札を選んでください。
ld-bid-option = { $quantity } 個の { $face }
ld-bid-made = { $who ->
    [you] あなたは { $quantity } 個の { $face } に入札します。
    *[player] { $player } が { $quantity } 個の { $face } に入札します。
}

ld-call-liar = { $who ->
    [you] あなたは { $target } の入札「{ $quantity } 個の { $face }」にライアーを宣言します。
    *[player] { $player } が { $target } の入札「{ $quantity } 個の { $face }」にライアーを宣言します。
}
ld-call-spot-on = { $who ->
    [you] あなたは { $target } の入札「{ $quantity } 個の { $face }」に Spot On を宣言します。
    *[player] { $player } が { $target } の入札「{ $quantity } 個の { $face }」に Spot On を宣言します。
}
ld-reveal-header = カップを開けます! テーブル上の { $face } を数えます。
ld-reveal-line = { $player } の出目: { $dice }。
ld-actual-count = 実際の { $face } の数（ワイルド 1 を含む）: { $count }。入札は { $quantity } でした。
ld-actual-count-no-wild = 実際の { $face } の数（ワイルドなし）: { $count }。入札は { $quantity } でした。

ld-liar-bidder-loses = { $bidder } が過大入札 — ダイスを 1 つ失います。
ld-liar-caller-loses = 入札は正直でした — { $caller } がダイスを 1 つ失います。
ld-spot-on-correct = Spot on! { $caller } はぴったり正解 — 他のプレイヤー全員がダイスを 1 つ失います。
ld-spot-on-wrong = Spot on ではありません。{ $caller } がダイスを 2 つ失います。

ld-lost-die = { $who ->
    [you] あなたはダイスを 1 つ失いました。残り { $remaining } { $remaining ->
        [one] 個
        *[other] 個
    }。
    *[player] { $player } がダイスを 1 つ失いました。残り { $remaining } 個。
}
ld-lost-dice-multi = { $who ->
    [you] あなたはダイスを { $count } 個失いました。残り { $remaining } { $remaining ->
        [one] 個
        *[other] 個
    }。
    *[player] { $player } がダイスを { $count } 個失いました。残り { $remaining } 個。
}
ld-eliminated = { $player } がダイスを使い切り脱落しました! 残り { $remaining } { $remaining ->
    [one] 人
    *[other] 人
}。
ld-winner = { $player } が最後までダイスを持っていました — 勝利!

ld-status-round = ラウンド { $round }。
ld-status-your-dice = あなたのダイス: { $dice }。
ld-status-your-counts = あなたの個数: { $counts }。
ld-status-no-dice = ダイスがありません — 脱落しました。
ld-status-current-bid = 現在の入札: { $quantity } 個の { $face }。
ld-status-no-bid = このラウンドに入札はまだありません。
ld-status-table-total = テーブル上の総ダイス: { $total }。
ld-status-detailed-header = 詳細ステータス — 残り { $count } 人。
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] 個
    *[other] 個
}。
ld-status-detailed-out = { $player }: 脱落。
ld-status-detailed-self-suffix = {" "}(あなた)

ld-face-1 = 1
ld-face-2 = 2
ld-face-3 = 3
ld-face-4 = 4
ld-face-5 = 5
ld-face-6 = 6

ld-action-not-your-turn = あなたの番ではありません。
ld-action-not-playing = ゲームは進行中ではありません。
ld-action-no-bid-to-call = まだ異議を唱える入札がありません。
ld-action-eliminated = あなたは脱落しています。
