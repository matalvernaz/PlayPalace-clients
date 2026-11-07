# tossup.ftl for locale ja. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# ゲーム情報
game-name-tossup = トスアップ
# アクション
tossup-roll-first = { $count }個のサイコロをロール
tossup-roll-remaining = 残り{ $count }個のサイコロをロール
tossup-bank = { $points }点をバンク
tossup-you-roll = あなたは{ $results }をロールしました。
tossup-player-rolls = { $player }は{ $results }をロールしました。
# ターンステータス
tossup-you-have-points = ターン点数: { $turn_points }。残りサイコロ: { $dice_count }。
tossup-player-has-points = { $player }はターン点数{ $turn_points }を持っています。残りサイコロ{ $dice_count }個。
# フレッシュダイス
tossup-you-get-fresh = サイコロがなくなりました!{ $count }個の新しいサイコロを取得します。
tossup-player-gets-fresh = { $player }は{ $count }個の新しいサイコロを取得します。
# バスト
tossup-you-bust = バスト!あなたはこのターンで{ $points }点を失いました。
tossup-player-busts = { $player }がバストして{ $points }点を失いました!
# バンク
tossup-you-bank = あなたは{ $points }点をバンクしました。合計スコア: { $total }。
tossup-player-banks = { $player }は{ $points }点をバンクしました。合計スコア: { $total }。
# 勝者
tossup-winner = { $player }が{ $score }点で勝利!
tossup-tie-tiebreaker = { $players }間で引き分けです!タイブレーカーラウンド!
# オプション
tossup-set-rules-variant = ルールバリアント: { $variant }
tossup-select-rules-variant = ルールバリアントを選択:
tossup-option-changed-rules = ルールバリアントが{ $variant }に変更されました
tossup-set-starting-dice = 開始サイコロ: { $count }
tossup-enter-starting-dice = 開始サイコロの数を入力:
tossup-option-changed-dice = 開始サイコロが{ $count }に変更されました
# ルールバリアント
tossup-rules-standard = スタンダード
# ルール説明
tossup-rules-standard-desc = サイコロごとに緑3、黄2、赤1。緑がなく赤が少なくとも1つある場合バスト。
