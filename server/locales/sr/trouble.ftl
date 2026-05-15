# Trouble — sr
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble је тркачка игра из Парчизи фамилије.
    Сваки играч почиње са жетонима у својој Кући.
    У потезу притисни коцкицу и помери један жетон.
    Подразумевано мораш да бациш 6 да пустиш жетон из Куће на стазу.
    Подразумевано 6 даје и додатни потез.
    Жетони се крећу у смеру казаљке на сату по заједничкој стази до циља.
    Слетање на противнички жетон шаље га назад у његову Кућу, осим ако је поље заштићено.
    Када сви твоји жетони стигну до циља, побеђујеш.
    У тимском режиму твој тим побеђује кад сви саиграчи заврше.
    Тастери 1-6 бирају жетон, R баца.
    Притисни E за пуни статус табле у било ком тренутку.

trouble-action-roll = Притисни коцкицу
trouble-action-move-token = Помери жетон { $token }
trouble-action-check-board = Провери таблу

trouble-token-label-home = Жетон { $token }: у Кући
trouble-token-label-track = Жетон { $token }: поље { $position } стазе
trouble-token-label-finish-lane = Жетон { $token }: циљна стаза { $position } од { $total }
trouble-token-label-finished = Жетон { $token }: завршен

trouble-rolled = { $player } је бацио { $roll }.
trouble-leave-home = { $player } пушта жетон { $token } на стазу.
trouble-advance-track = { $player } помера жетон { $token } на поље { $position }.
trouble-enter-finish-lane = { $player } уводи жетон { $token } у циљну стазу.
trouble-advance-finish-lane =
    { $player } помера жетон { $token } на поље { $position } од { $total } у циљној стази.
trouble-token-finished = Жетон { $token } играча { $player } стигао у циљ.
trouble-bump =
    Жетон { $token } играча { $player } шаље жетон { $opp_token } играча { $opponent } назад у Кућу.
trouble-no-legal-move = { $player } нема легалних потеза. Ред прелази даље.
trouble-extra-turn = { $player } добија додатни потез за 6.

trouble-winner = { $player } побеђује! Сви жетони у циљу.
trouble-team-winner = Тим { $team } побеђује! Сви саиграчи завршили.
trouble-final-standing = { $player }: { $finished } од { $total } жетона завршено.

trouble-turn-summary =
    Имаш { $own_home } у Кући, { $own_track } на стази, { $own_finished } у циљу.
    Противници: { $opponents }.
trouble-opponent-summary = { $name }: { $home } кућа, { $track } стаза, { $finished } циљ

trouble-board-status =
    Твоји жетони: { $own_tokens }.
    Противнички жетони: { $opp_tokens }.

trouble-reason-not-rolled = Прво притисни коцкицу.
trouble-reason-already-rolled = Већ си притиснуо. Изабери жетон за померање.
trouble-reason-no-legal-moves = Нема легалних потеза за ово бацање.
trouble-reason-token-home-needs-six = Овај жетон је у Кући. Треба ти 6 за пуштање.
trouble-reason-token-home-needs-any = Овај жетон је у Кући. Било које бацање пушта.
trouble-reason-token-home-no-qualifying-roll =
    Овај жетон је у Кући и твоје бацање не испуњава услов.
trouble-reason-token-finished = Овај жетон је већ завршио.
trouble-reason-overshoot-wastes = Овај жетон не може да пређе { $roll } поља без прелажења циља.
trouble-reason-blocked = Овај потез је блокиран.

trouble-option-track-size = Величина стазе: { $track_size } поља
trouble-option-select-track-size = Изабери број поља на стази.
trouble-option-changed-track-size = Стаза постављена на { $track_size } поља.
trouble-option-desc-track-size = Број поља на заједничкој стази.

trouble-option-tokens-per-player = Жетона по играчу: { $tokens }
trouble-option-enter-tokens-per-player = Унеси жетона по играчу (2-6):
trouble-option-changed-tokens-per-player = Жетона по играчу постављено на { $tokens }.
trouble-option-desc-tokens-per-player = Колико жетона сваки играч води у циљ.

trouble-option-extra-turn-on-six = Додатни потез на 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Додатни потез на 6 { $enabled ->
    [on] укључен.
    [off] искључен.
   *[other] ажуриран.
}
trouble-option-desc-extra-turn-on-six =
    Укључено: 6 даје додатни потез (класично Hasbro правило).

trouble-option-six-to-leave-home = Захтевај 6 за напуштање Куће: { $enabled }
trouble-option-changed-six-to-leave-home = Шестица за напуштање Куће { $enabled ->
    [on] укључено.
    [off] искључено.
   *[other] ажурирано.
}
trouble-option-desc-six-to-leave-home =
    Укључено: играч мора бацити 6 за пуштање жетона. Искључено: било које бацање пушта.

trouble-option-safe-spaces = Сигурна поља: { $mode }
trouble-option-select-safe-spaces = Изабери режим сигурних поља.
trouble-option-changed-safe-spaces = Сигурна поља постављена на { $mode }.
trouble-option-desc-safe-spaces = Одреди да ли жетони могу бити заштићени од удара.

trouble-safe-mode-none = Ниједно
trouble-safe-mode-home-stretch = Само завршна равнина
trouble-safe-mode-every-seventh = Свако 7. поље

trouble-option-finish-behavior = Циљ: { $mode }
trouble-option-select-finish-behavior = Изабери понашање циља.
trouble-option-changed-finish-behavior = Понашање циља постављено на { $mode }.
trouble-option-desc-finish-behavior = Како се обрађује бацање које прелази циљ.

trouble-finish-mode-exact = Тачно бацање потребно
trouble-finish-mode-bounce = Прекорачење се одбија
trouble-finish-mode-allow = Прекорачење дозвољено

trouble-option-bot-difficulty = Тежина бота: { $level }
trouble-option-select-bot-difficulty = Изабери тежину бота.
trouble-option-changed-bot-difficulty = Тежина бота постављена на { $level }.
trouble-option-desc-bot-difficulty = Снага уграђених ботова.

trouble-bot-difficulty-naive = Наиван
trouble-bot-difficulty-greedy = Похлепан

trouble-option-preset = Шаблон: { $preset }
trouble-option-select-preset = Изабери варијанту. Домаћин може касније променити правила.
trouble-option-changed-preset = Шаблон примењен: { $preset }.
trouble-option-desc-preset = Унапред припремљени скупови опција за уобичајене варијанте.

trouble-preset-classic = Класични Hasbro
trouble-preset-fast = Брзи
trouble-preset-brutal = Брутални
trouble-preset-custom = Прилагођен
