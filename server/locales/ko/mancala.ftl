# Mancala game messages — ko
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = 만칼라

# Actions
mancala-pit-label = 구멍 { $pit }: 돌 { $stones }개

# Game events
mancala-sow = { $player }이(가) 구멍 { $pit }에서 돌 { $stones }개를 뿌립니다
mancala-capture = { $player }이(가) 돌 { $captured }개를 획득!
mancala-extra-turn = 마지막 돌이 창고에! { $player }이(가) 추가 턴을 얻습니다.
mancala-winner = { $player }이(가) 돌 { $score }개로 승리!
mancala-draw = 무승부! 양쪽 모두 돌 { $score }개입니다.

# Board status
mancala-board-status =
    내 구멍: { $own_pits }. 내 창고: { $own_store }. 상대 구멍: { $opp_pits }. 상대 창고: { $opp_store }.

# Options
mancala-set-stones = 구멍당 돌: { $stones }
mancala-desc-stones = 시작 시 각 구멍의 돌 수
mancala-enter-stones = 구멍당 시작 돌 수를 입력하세요:
mancala-option-changed-stones = 시작 돌이 { $stones }(으)로 변경됨

# Disabled reasons
mancala-pit-empty = 그 구멍은 비어 있습니다.

# Rules
mancala-rules =
    만칼라는 2인용 구멍과 돌 게임입니다.
    각 플레이어는 6개의 구멍과 1개의 창고를 가집니다.
    자신의 턴에 뿌릴 구멍 하나를 선택합니다.
    돌은 보드를 돌며 각 구멍에 하나씩 놓입니다. 자신의 창고에는 넣지만 상대 창고는 건너뜁니다.
    마지막 돌이 자신의 창고에 들어가면 추가 턴을 얻습니다.
    마지막 돌이 자기 쪽 빈 구멍에 들어가면 그 돌과 맞은편 구멍의 모든 돌을 획득합니다.
    한쪽이 완전히 비면 게임이 끝납니다.
    돌이 가장 많은 플레이어가 승리합니다.
    1~6 키로 구멍을 선택하세요. E를 눌러 보드를 확인하세요.

# End screen
mancala-final-score = { $player }: 돌 { $score }개
mancala-check-board = Check board
