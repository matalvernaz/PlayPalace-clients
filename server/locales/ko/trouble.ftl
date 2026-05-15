# Trouble — ko
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble은 파치시 계열의 경주 게임입니다.
    각 플레이어는 자신의 말을 집 영역에서 시작합니다.
    자기 차례에 주사위를 누르고 자신의 말 하나를 움직입니다.
    기본적으로 집에서 트랙으로 말을 내보내려면 6을 굴려야 합니다.
    기본적으로 6을 굴리면 추가 턴도 받습니다.
    말은 공유 트랙을 시계 방향으로 이동해 결승 구역을 향합니다.
    상대 말 위에 멈추면 그 말은 집으로 돌아갑니다(보호된 칸 제외).
    자신의 모든 말이 결승에 도달하면 승리합니다.
    팀 모드에서는 팀원 모두가 끝내면 팀이 승리합니다.
    숫자 1~6으로 움직일 말을 선택하고 R로 주사위를 누릅니다.
    언제든 E를 눌러 전체 보드 상태를 들을 수 있습니다.

trouble-action-roll = 주사위 누르기
trouble-action-move-token = 말 { $token } 이동
trouble-action-check-board = 보드 확인

trouble-token-label-home = 말 { $token }: 집
trouble-token-label-track = 말 { $token }: 트랙 { $position }번 칸
trouble-token-label-finish-lane = 말 { $token }: 결승선 { $position }/{ $total }
trouble-token-label-finished = 말 { $token }: 완주

trouble-rolled = { $player } 님이 { $roll } 을(를) 굴렸습니다.
trouble-leave-home = { $player } 님이 말 { $token } 을(를) 트랙으로 내보냅니다.
trouble-advance-track = { $player } 님이 말 { $token } 을(를) 트랙 { $position }번 칸으로 옮깁니다.
trouble-enter-finish-lane = { $player } 님이 말 { $token } 을(를) 결승선에 진입시킵니다.
trouble-advance-finish-lane =
    { $player } 님이 말 { $token } 을(를) 결승선 { $position }/{ $total } 위치로 진행합니다.
trouble-token-finished = { $player } 님의 말 { $token } 이(가) 결승에 도달.
trouble-bump =
    { $player } 님의 말 { $token } 이(가) { $opponent } 님의 말 { $opp_token } 을(를) 집으로 보냅니다.
trouble-no-legal-move = { $player } 님은 합법적 수가 없어 차례가 넘어갑니다.
trouble-extra-turn = { $player } 님이 6을 굴려 추가 턴을 받습니다.

trouble-winner = { $player } 님 승리! 모든 말이 결승에 도달.
trouble-team-winner = 팀 { $team } 승리! 팀원 전원 완주.
trouble-final-standing = { $player }: { $total } 중 { $finished } 완주.

trouble-turn-summary =
    집에 { $own_home }, 트랙에 { $own_track }, 결승에 { $own_finished } 있습니다.
    상대: { $opponents }.
trouble-opponent-summary = { $name }: 집 { $home }, 트랙 { $track }, 결승 { $finished }

trouble-board-status =
    내 말: { $own_tokens }.
    상대 말: { $opp_tokens }.

trouble-reason-not-rolled = 먼저 주사위를 누르세요.
trouble-reason-already-rolled = 이미 굴렸습니다. 옮길 말을 선택하세요.
trouble-reason-no-legal-moves = 이 굴림에는 합법적 수가 없습니다.
trouble-reason-token-home-needs-six = 이 말은 집에 있습니다. 내보내려면 6이 필요합니다.
trouble-reason-token-home-needs-any = 이 말은 집에 있습니다. 어떤 값이든 내보낼 수 있습니다.
trouble-reason-token-home-no-qualifying-roll =
    이 말은 집에 있고, 굴림이 내보내기 조건에 맞지 않습니다.
trouble-reason-token-finished = 이 말은 이미 완주했습니다.
trouble-reason-overshoot-wastes = 이 말은 결승을 넘지 않고 { $roll } 칸을 갈 수 없습니다.
trouble-reason-blocked = 이 이동은 막혀 있습니다.

trouble-option-track-size = 트랙 길이: { $track_size } 칸
trouble-option-select-track-size = 트랙 칸 수를 선택하세요.
trouble-option-changed-track-size = 트랙을 { $track_size } 칸으로 설정.
trouble-option-desc-track-size = 공유 트랙의 칸 수.

trouble-option-tokens-per-player = 플레이어당 말 수: { $tokens }
trouble-option-enter-tokens-per-player = 플레이어당 말 수를 입력(2-6):
trouble-option-changed-tokens-per-player = 플레이어당 말 수를 { $tokens } 로 설정.
trouble-option-desc-tokens-per-player = 각 플레이어가 결승으로 보내는 말 수.

trouble-option-extra-turn-on-six = 6 굴림 시 추가 턴: { $enabled }
trouble-option-changed-extra-turn-on-six = 6 굴림 시 추가 턴을 { $enabled ->
    [on] 활성화.
    [off] 비활성화.
   *[other] 업데이트.
}
trouble-option-desc-extra-turn-on-six =
    활성: 6을 굴리면 추가 턴(클래식 Hasbro 규칙).

trouble-option-six-to-leave-home = 집에서 나가려면 6 필요: { $enabled }
trouble-option-changed-six-to-leave-home = 집에서 나가려면 6 필요를 { $enabled ->
    [on] 활성화.
    [off] 비활성화.
   *[other] 업데이트.
}
trouble-option-desc-six-to-leave-home =
    활성: 말을 집에서 내보내려면 6 필요. 비활성: 모든 굴림 가능.

trouble-option-safe-spaces = 안전 칸: { $mode }
trouble-option-select-safe-spaces = 안전 칸 모드를 선택.
trouble-option-changed-safe-spaces = 안전 칸을 { $mode } 로 설정.
trouble-option-desc-safe-spaces = 말이 충돌로부터 보호되는지 결정.

trouble-safe-mode-none = 없음
trouble-safe-mode-home-stretch = 결승 직선만
trouble-safe-mode-every-seventh = 7칸마다

trouble-option-finish-behavior = 결승: { $mode }
trouble-option-select-finish-behavior = 결승 동작을 선택.
trouble-option-changed-finish-behavior = 결승 동작을 { $mode } 로 설정.
trouble-option-desc-finish-behavior = 결승을 넘는 굴림의 처리 방식.

trouble-finish-mode-exact = 정확한 굴림 필요
trouble-finish-mode-bounce = 초과 시 반사
trouble-finish-mode-allow = 초과 허용

trouble-option-bot-difficulty = 봇 난이도: { $level }
trouble-option-select-bot-difficulty = 봇 난이도 선택.
trouble-option-changed-bot-difficulty = 봇 난이도를 { $level } 로 설정.
trouble-option-desc-bot-difficulty = 내장 봇의 강도.

trouble-bot-difficulty-naive = 단순
trouble-bot-difficulty-greedy = 욕심

trouble-option-preset = 프리셋: { $preset }
trouble-option-select-preset = 변형을 선택. 호스트가 이후 개별 규칙 조정 가능.
trouble-option-changed-preset = 프리셋 적용: { $preset }.
trouble-option-desc-preset = 흔한 변형용 미리 묶인 옵션 세트.

trouble-preset-classic = 클래식 Hasbro
trouble-preset-fast = 빠름
trouble-preset-brutal = 잔혹
trouble-preset-custom = 사용자 지정
