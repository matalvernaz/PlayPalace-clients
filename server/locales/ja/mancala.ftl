# Mancala game messages — ja
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = マンカラ

# Actions
mancala-pit-label = ポケット{ $pit }：石{ $stones }個

# Game events
mancala-sow = { $player }がポケット{ $pit }から石{ $stones }個を蒔きます
mancala-capture = { $player }が石{ $captured }個を獲得！
mancala-extra-turn = 最後の石がストアに！{ $player }はもう一度プレイできます。
mancala-winner = { $player }が石{ $score }個で勝利！
mancala-draw = 引き分け！両プレイヤーとも石{ $score }個です。

# Board status
mancala-board-status =
    あなたのポケット：{ $own_pits }。あなたのストア：{ $own_store }。相手のポケット：{ $opp_pits }。相手のストア：{ $opp_store }。

# Options
mancala-set-stones = ポケットあたりの石：{ $stones }
mancala-desc-stones = 開始時の各ポケットの石の数
mancala-enter-stones = ポケットあたりの初期石数を入力：
mancala-option-changed-stones = 初期石数が{ $stones }に変更されました

# Disabled reasons
mancala-pit-empty = そのポケットは空です。

# Rules
mancala-rules =
    マンカラは2人用のポケットと石のゲームです。
    各プレイヤーは6つのポケットと1つのストアを持ちます。
    自分のターンで、蒔くポケットを1つ選びます。
    石はボードの各ポケットに1つずつ置かれます。自分のストアには入れますが、相手のストアは飛ばします。
    最後の石が自分のストアに入ったら、もう一度プレイできます。
    最後の石が自分側の空のポケットに入ったら、その石と向かいのポケットの石をすべて獲得します。
    片側が完全に空になったらゲーム終了です。
    石が最も多いプレイヤーの勝ちです。
    キー1〜6でポケットを選択。Eでボードを確認。

# End screen
mancala-final-score = { $player }：石{ $score }個
