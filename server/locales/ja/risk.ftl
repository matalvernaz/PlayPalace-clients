# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = リスク

# Phase announcements
risk-reinforce-start = { $player } に { $armies } 軍団が配備されます。
risk-attack-phase = { $player } は攻撃できます。
risk-fortify-phase = { $player } は増援できます。

# Reinforce
risk-placed-army = { $player } が { $territory } を補強（{ $troops } 部隊）。残り { $remaining }。

# Attack
risk-attack-from = { $player } が { $territory } から攻撃。
risk-combat-result =
    { $attacker } が { $att_territory } から { $def_territory } を攻撃。
    攻撃側: { $att_rolls }。防御側: { $def_rolls }。
    攻撃側 { $att_losses } 損失、防御側 { $def_losses } 損失。
risk-conquered = { $player } が { $territory } を征服！{ $moved } 部隊が進軍。
risk-eliminated = { $player } が敗北！
risk-skip-attack = 攻撃をスキップ
risk-cancel-attack = 攻撃をキャンセル

# Fortify
risk-fortify-from = { $player } が { $territory } から増援。
risk-fortified = { $player } が { $moved } 部隊を { $source } から { $dest } に移動。
risk-skip-fortify = 増援をスキップ
risk-cancel-fortify = 増援をキャンセル

# Cards
risk-cards-traded = { $player } がカードを { $armies } ボーナス軍団に交換。

# Territory labels by phase
risk-territory-reinforce = { $name }：{ $troops } 部隊（残り { $remaining } 配備）
risk-territory-attack-from = { $name }：{ $troops } 部隊（ここから攻撃）
risk-territory-attack-target = { $name }：{ $troops } 部隊（{ $owner }）
risk-territory-fortify-from = { $name }：{ $troops } 部隊（ここから移動）
risk-territory-fortify-to = { $name }：{ $troops } 部隊（ここへ移動）

# Status
risk-status-header = あなたは { $territories } 領地、{ $troops } 部隊を支配しています。
risk-status-continent = { $name }：{ $owned }/{ $total } 領地。ボーナス：{ $bonus }。

# Winner
risk-winner = { $player } が世界を征服！
risk-final-score = { $player }：{ $territories } 領地

# Disabled reasons
risk-not-your-territory = あなたの領地ではありません。
risk-need-more-troops = 攻撃または移動には 2 部隊以上必要です。
risk-no-adjacent-enemy = 隣接する敵領地がありません。
risk-cannot-attack-own = 自分の領地は攻撃できません。
risk-not-adjacent = その領地は隣接していません。
risk-same-territory = 同じ領地には増援できません。

# Options
risk-set-starting-armies = 初期軍団：{ $armies }
risk-desc-starting-armies = 開始時のプレイヤーあたりの追加軍団（0 = 自動）
risk-enter-starting-armies = プレイヤーあたりの初期軍団を入力（0 で自動）：
risk-option-changed-armies = 初期軍団が { $armies } に変更されました

# Rules
risk-rules =
    リスクは 2〜6 人のための世界征服ゲームです。
    ボードには 6 大陸にまたがる 42 の領地があります。
    各ターンは 3 つのフェーズ：補強、攻撃、増援。
    補強：領地に軍団を配置。領地と大陸ボーナスに応じて軍団を得ます。
    攻撃：2 部隊以上の領地を選び、隣接する敵領地を攻撃。ダイスで戦闘を決定。
    攻撃側は最大 3 ダイス、防御側は最大 2 ダイス。高いダイスを比較し、引き分けは防御側の勝ち。
    全防御者を倒せば領地を征服します。
    増援：自軍部隊を隣接する自領地に移動。
    各ターン領地を征服するとカードを獲得。3 枚セットをボーナス軍団と交換できます。
    全員を倒せば勝利。
    E で状態を確認。
risk-check-status = Check status
