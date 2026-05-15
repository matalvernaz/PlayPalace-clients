# Trouble — ja
game-name-trouble = Trouble

trouble-rules =
    Trouble はパーチージ系のレースゲームです。
    各プレイヤーは自分のコマをホームエリアから始めます。
    自分の番でダイスをポップしてコマを 1 つ動かします。
    デフォルトでは 6 を出さないとホームからトラックにコマを出せません。
    デフォルトでは 6 を出すと追加ターンも得られます。
    コマは共有トラックを時計回りに進み、ゴールエリアを目指します。
    相手のコマに止まると、そのコマはホームに戻されます(保護されたマスを除く)。
    自分のすべてのコマがゴールに達したら勝ちです。
    チームモードでは全員がゴールしたチームが勝ちます。
    1 から 6 のキーで動かすコマを選び、R でダイスを振ります。
    いつでも E を押すと盤面全体の状態を聞けます。

trouble-action-roll = ダイスをポップ
trouble-action-move-token = コマ { $token } を動かす
trouble-action-check-board = 盤面を確認

trouble-token-label-home = コマ { $token }: ホーム
trouble-token-label-track = コマ { $token }: トラック { $position } 番目
trouble-token-label-finish-lane = コマ { $token }: ゴールレーン { $position }/{ $total }
trouble-token-label-finished = コマ { $token }: ゴール

trouble-rolled = { $player } は { $roll } を出しました。
trouble-leave-home = { $player } がコマ { $token } をトラックへ出しました。
trouble-advance-track = { $player } がコマ { $token } をトラック { $position } 番目へ進めました。
trouble-enter-finish-lane = { $player } がコマ { $token } をゴールレーンに入れました。
trouble-advance-finish-lane =
    { $player } がコマ { $token } をゴールレーンの { $position }/{ $total } へ進めました。
trouble-token-finished = { $player } のコマ { $token } がゴールに到達。
trouble-bump =
    { $player } のコマ { $token } が { $opponent } のコマ { $opp_token } をホームに送り返しました。
trouble-no-legal-move = { $player } に合法手がありません。ターン経過。
trouble-extra-turn = { $player } は 6 を出して追加ターンを得ました。

trouble-winner = { $player } の勝ち! 全コマがゴールに到達。
trouble-team-winner = チーム { $team } の勝ち! 全員がゴール。
trouble-final-standing = { $player }: { $total } 中 { $finished } コマ完走。

trouble-turn-summary =
    ホームに { $own_home }、トラックに { $own_track }、ゴール済み { $own_finished } です。
    相手: { $opponents }。
trouble-opponent-summary = { $name }: ホーム { $home }、トラック { $track }、ゴール { $finished }

trouble-board-status =
    自分のコマ: { $own_tokens }。
    相手のコマ: { $opp_tokens }。

trouble-reason-not-rolled = 先にダイスをポップしてください。
trouble-reason-already-rolled = すでにポップ済みです。動かすコマを選んでください。
trouble-reason-no-legal-moves = この出目では合法手がありません。
trouble-reason-token-home-needs-six = このコマはホームにいます。出すには 6 が必要です。
trouble-reason-token-home-needs-any = このコマはホームにいます。どの値でも出せます。
trouble-reason-token-home-no-qualifying-roll =
    このコマはホームにいて、出目が解放条件を満たしません。
trouble-reason-token-finished = このコマはすでにゴールしています。
trouble-reason-overshoot-wastes = このコマはゴールを超えずに { $roll } マス進めません。
trouble-reason-blocked = この移動はブロックされています。

trouble-option-track-size = トラックの長さ: { $track_size } マス
trouble-option-select-track-size = トラックのマス数を選んでください。
trouble-option-changed-track-size = トラックを { $track_size } マスに設定しました。
trouble-option-desc-track-size = 共有トラック上のマス数。

trouble-option-tokens-per-player = プレイヤー毎のコマ数: { $tokens }
trouble-option-enter-tokens-per-player = プレイヤー毎のコマ数を入力(2 から 6):
trouble-option-changed-tokens-per-player = プレイヤー毎のコマ数を { $tokens } に設定しました。
trouble-option-desc-tokens-per-player = 各プレイヤーがゴールへ進める駒の数。

trouble-option-extra-turn-on-six = 6 で追加ターン: { $enabled }
trouble-option-changed-extra-turn-on-six = 6 での追加ターンを { $enabled ->
    [on] 有効にしました。
    [off] 無効にしました。
   *[other] 更新しました。
}
trouble-option-desc-extra-turn-on-six =
    有効: 6 を出すと追加ターンが得られます(クラシック Hasbro ルール)。

trouble-option-six-to-leave-home = ホームを出るのに 6 が必要: { $enabled }
trouble-option-changed-six-to-leave-home = ホームを出るのに 6 が必要、を { $enabled ->
    [on] 有効にしました。
    [off] 無効にしました。
   *[other] 更新しました。
}
trouble-option-desc-six-to-leave-home =
    有効: ホームからコマを出すには 6 が必要。無効: どの出目でも出せます。

trouble-option-safe-spaces = セーフマス: { $mode }
trouble-option-select-safe-spaces = セーフマスのモードを選んでください。
trouble-option-changed-safe-spaces = セーフマスを { $mode } に設定しました。
trouble-option-desc-safe-spaces = コマが攻撃から守られるかを選びます。

trouble-safe-mode-none = なし
trouble-safe-mode-home-stretch = ホームストレッチのみ
trouble-safe-mode-every-seventh = 7 マスごと

trouble-option-finish-behavior = ゴール: { $mode }
trouble-option-select-finish-behavior = ゴール動作を選んでください。
trouble-option-changed-finish-behavior = ゴール動作を { $mode } に設定しました。
trouble-option-desc-finish-behavior = ゴールを超える出目の扱い。

trouble-finish-mode-exact = 正確な出目が必要
trouble-finish-mode-bounce = 超過分は跳ね返る
trouble-finish-mode-allow = 超過を許可

trouble-option-bot-difficulty = ボットの難易度: { $level }
trouble-option-select-bot-difficulty = ボットの難易度を選んでください。
trouble-option-changed-bot-difficulty = ボットの難易度を { $level } に設定しました。
trouble-option-desc-bot-difficulty = 内蔵ボットの強さ。

trouble-bot-difficulty-naive = ナイーブ
trouble-bot-difficulty-greedy = グリーディ

trouble-option-preset = プリセット: { $preset }
trouble-option-select-preset = バリアントを選んでください。ホストは後で個別ルールを上書きできます。
trouble-option-changed-preset = プリセットを適用: { $preset }。
trouble-option-desc-preset = よく使うバリアント用のオプションセット。

trouble-preset-classic = クラシック Hasbro
trouble-preset-fast = 速い
trouble-preset-brutal = ブルータル
trouble-preset-custom = カスタム
