# Liar's Dice — ko
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = 각 플레이어는 컵 아래에서 비밀리에 주사위를 굴립니다. 차례대로 테이블 전체에서 특정 눈의 총 개수에 대해 점점 더 높은 베팅을 하거나, 마지막 베팅을 믿지 못하면 "거짓말!"을 외칩니다. 틀리면 주사위 하나를 잃습니다. 주사위를 마지막까지 남긴 사람이 승리합니다.

liarsdice-rules =
    Liar's Dice는 2~6명이 즐기는 블러핑 주사위 게임입니다.
    각 플레이어는 컵에 주사위 5개로 시작합니다. 매 라운드 시작 시 모두 비밀리에 굴립니다.
    차례대로 테이블의 모든 주사위 중 특정 눈의 총 개수에 베팅합니다. 예: "4가 3개"는 모든 컵을 열었을 때 4가 최소 3개 있다는 뜻입니다.
    새 베팅은 이전보다 높아야 합니다. 같은 눈이면 수량을 늘리거나, 더 높은 눈이면 수량을 같거나 높게 합니다.
    1은 와일드입니다. 1 자체에 대한 베팅이 아니라면 모든 베팅에 포함됩니다.
    1에 대한 베팅으로 전환하면 수량이 절반이 됩니다(올림). 1에서 일반 눈으로 돌아갈 때는 이전 수량의 두 배 이상이 필요합니다.
    베팅 대신 "거짓말!"을 외쳐 직전 베팅에 이의를 제기할 수 있습니다. 모든 컵을 열어 베팅이 맞으면 도전자가 주사위 하나를 잃고, 아니면 베팅한 사람이 잃습니다.
    Spot On이 켜져 있으면 "Spot On"을 외쳐 베팅이 정확히 맞다고 걸 수 있습니다. 맞으면 다른 모두가 주사위 하나씩 잃고, 틀리면 본인이 두 개 잃습니다.
    주사위가 0이 되면 탈락입니다. 주사위를 마지막까지 가진 사람이 승리합니다.
    S 키로 테이블을 확인합니다.

ld-set-starting-dice = 플레이어별 시작 주사위: { $dice }
ld-desc-starting-dice = 각 플레이어가 몇 개의 주사위로 시작하는지. 기본 5. 주사위가 많을수록 게임이 길고 블러핑 여지도 큽니다.
ld-prompt-starting-dice = 시작 주사위 입력 (3~8)
ld-option-changed-starting-dice = 시작 주사위를 { $dice }(으)로 설정했습니다.

ld-toggle-wild-ones = 1이 와일드: { $enabled }
ld-desc-wild-ones = 켜짐: 1은 1 외의 모든 베팅에 포함됩니다. 1 자체 베팅 시 와일드가 비활성화됩니다. 꺼짐: 와일드 없이 순수 확률 게임이 됩니다.
ld-option-changed-wild-ones = 와일드 1 { $enabled }.

ld-toggle-spot-on = Spot On 외침 활성화: { $enabled }
ld-desc-spot-on = 켜짐: "거짓말" 외에도 "Spot On"을 외쳐 베팅이 정확히 맞다고 걸 수 있습니다. 맞으면 다른 모두가 주사위 하나씩 잃고, 틀리면 본인이 두 개 잃습니다. 고위험 고보상.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = 라운드 { $round } 시작. 테이블 위 총 주사위: { $total }. 모두 굴립니다.
ld-your-roll = 이번 라운드의 당신 주사위: { $dice }.
ld-your-counts = 당신의 개수: { $counts }.
ld-turn-start = { $player } 님 차례. { $bid_state }
ld-no-bid-yet = 아직 베팅 없음 — 라운드를 여세요.
ld-current-bid = 현재 베팅: { $quantity } { $face }.

ld-action-bid = 베팅하기
ld-action-call-liar = 거짓말 외치기
ld-action-call-spot-on = Spot On 외치기
ld-bid-prompt = 베팅을 선택하세요.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] 당신은 { $quantity } { $face }(으)로 베팅합니다.
    *[player] { $player } 님이 { $quantity } { $face }(으)로 베팅합니다.
}

ld-call-liar = { $who ->
    [you] 당신은 { $target } 님의 베팅 "{ $quantity } { $face }"에 거짓말을 외칩니다.
    *[player] { $player } 님이 { $target } 님의 베팅 "{ $quantity } { $face }"에 거짓말을 외칩니다.
}
ld-call-spot-on = { $who ->
    [you] 당신은 { $target } 님의 베팅 "{ $quantity } { $face }"에 Spot On을 외칩니다.
    *[player] { $player } 님이 { $target } 님의 베팅 "{ $quantity } { $face }"에 Spot On을 외칩니다.
}
ld-reveal-header = 컵 공개! 테이블 위 { $face }의 개수를 셉니다.
ld-reveal-line = { $player } 님이 굴린 결과: { $dice }.
ld-actual-count = { $face }의 실제 개수(와일드 1 포함): { $count }. 베팅은 { $quantity }이었습니다.
ld-actual-count-no-wild = { $face }의 실제 개수(와일드 없음): { $count }. 베팅은 { $quantity }이었습니다.

ld-liar-bidder-loses = { $bidder } 님이 과대 베팅 — 주사위 하나를 잃습니다.
ld-liar-caller-loses = 베팅은 정직했습니다 — { $caller } 님이 주사위 하나를 잃습니다.
ld-spot-on-correct = Spot on! { $caller } 님이 정확히 맞췄습니다 — 다른 모두가 주사위 하나씩 잃습니다.
ld-spot-on-wrong = Spot on 아님. { $caller } 님이 주사위 두 개를 잃습니다.

ld-lost-die = { $who ->
    [you] 당신은 주사위 하나를 잃었습니다. 현재 { $remaining } { $remaining ->
        [one] 개
        *[other] 개
    }.
    *[player] { $player } 님이 주사위 하나를 잃었습니다. 현재 { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] 당신은 주사위 { $count }개를 잃었습니다. 현재 { $remaining } { $remaining ->
        [one] 개
        *[other] 개
    }.
    *[player] { $player } 님이 주사위 { $count }개를 잃었습니다. 현재 { $remaining }.
}
ld-eliminated = { $player } 님이 주사위를 모두 잃고 탈락! 남은 인원: { $remaining } { $remaining ->
    [one] 명
    *[other] 명
}.
ld-winner = { $player } 님이 주사위를 마지막까지 보유 — 승리!

ld-status-round = 라운드 { $round }.
ld-status-your-dice = 당신의 주사위: { $dice }.
ld-status-your-counts = 당신의 개수: { $counts }.
ld-status-no-dice = 주사위가 없습니다 — 탈락했습니다.
ld-status-current-bid = 현재 베팅: { $quantity } { $face }.
ld-status-no-bid = 이번 라운드에 베팅 없음.
ld-status-table-total = 테이블 위 총 주사위: { $total }.
ld-status-detailed-header = 상세 상태 — { $count }명 남음.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] 개
    *[other] 개
}.
ld-status-detailed-out = { $player }: 탈락.
ld-status-detailed-self-suffix = {" "}(나)

ld-face-1 = 1
ld-face-2 = 2
ld-face-3 = 3
ld-face-4 = 4
ld-face-5 = 5
ld-face-6 = 6

ld-action-not-your-turn = 당신의 차례가 아닙니다.
ld-action-not-playing = 게임이 진행 중이 아닙니다.
ld-action-no-bid-to-call = 아직 도전할 베팅이 없습니다.
ld-action-eliminated = 당신은 탈락했습니다.
