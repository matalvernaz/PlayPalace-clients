# PlayPalaceの共通ゲームメッセージ
# これらのメッセージは複数のゲームで共通です

# ゲーム名
game-name-ninetynine = Ninety Nine

# ラウンドとターンの流れ
game-round-start = ラウンド{ $round }。
game-round-end = ラウンド{ $round }が完了しました。
game-turn-start = { $player }のターンです。
game-your-turn = あなたのターンです。
game-no-turn = 現在は誰のターンでもありません。

# スコア表示
game-scores-header = 現在のスコア:
game-score-line = { $player }: { $score }点
game-final-scores-header = 最終スコア:

# 勝利/敗北
game-winner = { $player }の勝利!
game-winner-score = { $player }が{ $score }点で勝利!
game-tiebreaker = 引き分けです!タイブレーカーラウンド!
game-tiebreaker-players = { $players }間で引き分けです!タイブレーカーラウンド!
game-eliminated = { $player }は{ $score }点で敗退しました。

# 共通オプション
game-set-target-score = 目標スコア: { $score }
game-enter-target-score = 目標スコアを入力:
game-option-changed-target = 目標スコアが{ $score }に設定されました。

game-set-team-mode = チームモード: { $mode }
game-select-team-mode = チームモードを選択
game-option-changed-team = チームモードが{ $mode }に設定されました。
game-team-mode-individual = 個人
game-team-mode-x-teams-of-y = { $num_teams }チーム、各{ $team_size }人

# ブール値オプション
option-on = オン
option-off = オフ

# ステータスボックス

# ゲーム終了
game-leave = ゲームを退出

# ラウンドタイマー
round-timer-paused = { $player }がゲームを一時停止しました(pを押して次のラウンドを開始)。
round-timer-resumed = ラウンドタイマーが再開されました。
round-timer-countdown = 次のラウンドまで{ $seconds }秒...

# サイコロゲーム - サイコロの保持/再ロール
dice-keeping = { $value }を保持します。
dice-rerolling = { $value }を再ロールします。
dice-locked = そのサイコロはロックされており変更できません。
dice-status-locked = locked
dice-status-kept = kept

# 配る(カードゲーム)
game-deal-counter = { $current }/{ $total }を配ります。
game-you-deal = あなたがカードを配ります。
game-player-deals = { $player }がカードを配ります。

# カード名
card-name = { $suit }の{ $rank }
no-cards = カードなし

# Colors (with gendered forms: m = masculine, f = feminine)
color-black = 黒
color-black-m = 黒
color-black-f = 黒
color-blue = 青
color-blue-m = 青
color-blue-f = 青
color-brown = 茶色
color-brown-m = 茶色
color-brown-f = 茶色
color-gray = 灰色
color-gray-m = 灰色
color-gray-f = 灰色
color-green = 緑
color-green-m = 緑
color-green-f = 緑
color-indigo = 藍色
color-indigo-m = 藍色
color-indigo-f = 藍色
color-orange = オレンジ
color-orange-m = オレンジ
color-orange-f = オレンジ
color-pink = ピンク
color-pink-m = ピンク
color-pink-f = ピンク
color-purple = 紫
color-purple-m = 紫
color-purple-f = 紫
color-red = 赤
color-red-m = 赤
color-red-f = 赤
color-violet = すみれ色
color-violet-m = すみれ色
color-violet-f = すみれ色
color-white = 白
color-white-m = 白
color-white-f = 白
color-yellow = 黄色
color-yellow-m = 黄色
color-yellow-f = 黄色

# スート名
suit-diamonds = ダイヤ
suit-clubs = クラブ
suit-hearts = ハート
suit-spades = スペード

# ランク名
rank-ace = エース
rank-ace-plural = エース
rank-two = 2
rank-two-plural = 2
rank-three = 3
rank-three-plural = 3
rank-four = 4
rank-four-plural = 4
rank-five = 5
rank-five-plural = 5
rank-six = 6
rank-six-plural = 6
rank-seven = 7
rank-seven-plural = 7
rank-eight = 8
rank-eight-plural = 8
rank-nine = 9
rank-nine-plural = 9
rank-ten = 10
rank-ten-plural = 10
rank-jack = ジャック
rank-jack-plural = ジャック
rank-queen = クイーン
rank-queen-plural = クイーン
rank-king = キング
rank-king-plural = キング

# ポーカーハンドの説明
poker-high-card-with = { $high }ハイ、{ $rest }
poker-high-card = { $high }ハイ
poker-pair-with = { $pair }のペア、{ $rest }
poker-pair = { $pair }のペア
poker-two-pair-with = ツーペア、{ $high }と{ $low }、キッカー{ $kicker }
poker-two-pair = ツーペア、{ $high }と{ $low }
poker-trips-with = スリーカード、{ $trips }、{ $rest }
poker-trips = スリーカード、{ $trips }
poker-straight-high = { $high }ハイストレート
poker-flush-high-with = { $high }ハイフラッシュ、{ $rest }
poker-full-house = フルハウス、{ $trips }オーバー{ $pair }
poker-quads-with = フォーカード、{ $quads }、キッカー{ $kicker }
poker-quads = フォーカード、{ $quads }
poker-straight-flush-high = { $high }ハイストレートフラッシュ
poker-unknown-hand = 不明なハンド

# 検証エラー(ゲーム共通)
game-error-invalid-team-mode = 選択されたチームモードは現在のプレイヤー数に対して有効ではありません。

game-turn-start-you = It is your turn.
game-turn-start-player = It is { $player }'s turn.
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points = { $count ->
    [one] point
   *[other] points
}
game-score-unit-chips = { $count ->
    [one] chip
   *[other] chips
}
game-score-unit-coins = { $count ->
    [one] coin
   *[other] coins
}
game-score-unit-health = health
game-score-unit-ninetynine-tokens = { $count ->
    [one] token
   *[other] tokens
}
game-score-unit-tokens-home = { $count ->
    [one] token home
   *[other] tokens home
}
game-score-unit-pawns-home = { $count ->
    [one] pawn home
   *[other] pawns home
}
game-score-unit-hand-wins = { $count ->
    [one] hand win
   *[other] hand wins
}
game-score-unit-light = light
game-winner-you = You win!
game-team-name = Team { $index }
team-arrangement-started = Team arrangement started. Review the teams, swap members if needed, then confirm to start.
team-arrangement-confirm = Confirm teams and start
team-arrangement-read = Read teams
team-arrangement-select-member-action = Select team member
team-arrangement-select-member = Select a team member
team-arrangement-select-swap-target = Select a player to swap with
team-arrangement-swap-member = Choose swap target
team-arrangement-swap-member-selected = Swap { $player } with...
team-arrangement-cancel = Cancel team arrangement
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Turn order: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selected
team-arrangement-not-selected = not selected
team-arrangement-member-selected = { $player } from { $team } selected. Choose a player from another team to swap with.
team-arrangement-swapped = { $first } and { $second } have swapped teams.
team-arrangement-cancelled = Team arrangement cancelled.
team-arrangement-cancelled-roster = Team arrangement cancelled because the player list changed.
team-arrangement-refreshed = The player list changed. Team arrangement has been refreshed.
team-arrangement-in-progress = Finish or cancel team arrangement first.
team-arrangement-not-active = Team arrangement is not active.
team-arrangement-select-first = Select a team member first.
team-arrangement-player-missing = That player is no longer available for team arrangement.
team-arrangement-same-team = Choose someone from a different team.
team-arrangement-swap-failed = Could not swap those team members.

status-box-closed = Status information closed.

dice-status-label-locked = { $value } (locked)
dice-status-label-kept = { $value } (kept)

poker-royal-flush = Royal Flush
documentation-menu = Documentation
introduction = Introduction
community-rules = Community Rules
global-keys = Global Controls
game-rules = Game Rules
changelog = Changelog
donation = Donation
contact = Contact
document-not-found = Document not found.
help = Help

# Game Info (Ctrl+I)
game-info = Game Info
game-info-header = Current Game Information
game-info-name = Game: {$game}
game-info-players = Players: {$count}
game-info-host = Host: {$host}
game-info-status = Status: {$status}
game-info-status-waiting = Waiting in lobby
game-info-status-playing = In progress
game-info-options-header = Settings:
game-info-no-options = This game has no custom configuration options.

# How to Play (Ctrl+F1)
how-to-play = How to Play
game-rules-not-available = Rules for {$game} are not available yet.
