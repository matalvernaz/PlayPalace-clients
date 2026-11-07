# pirates.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-pirates = Пираты затерянных морей
# Game start and setup
pirates-welcome = Добро пожаловать в игру «Пираты затерянных морей»! Бороздите океаны, собирайте самоцветы и сражайтесь с другими пиратами!
pirates-oceans = Ваше странствие пройдёт через: { $oceans }.
pirates-gems-placed =
    По всем морям было рассеяно { $total } { $total ->
        [one] самоцвет
        [few] самоцвета
       *[other] самоцветов
    }. Найдите их все!
pirates-golden-moon = Всходит Золотая луна! Весь получаемый опыт в этом раунде утроен!
# Turn announcements
pirates-turn = Ход игрока { $player }. Позиция: { $position }.
# Movement actions
pirates-move-left = Плыть влево
pirates-move-right = Плыть вправо
pirates-move-2-left = Проплыть 2 клетки влево
pirates-move-2-right = Проплыть 2 клетки вправо
pirates-move-3-left = Проплыть 3 клетки влево
pirates-move-3-right = Проплыть 3 клетки вправо
# Movement messages
pirates-move-you = Вы плывёте { $direction } на позицию { $position }.
pirates-move = { $player } плывёт { $direction } на позицию { $position }.
pirates-map-edge = Вы не можете плыть дальше. Ваша позиция: { $position }.
pirates-your-position = Ваша позиция: { $position } (океан: { $ocean })
pirates-check-position = Проверить позицию
pirates-check-moon = Проверить яркость луны
# Position and status
pirates-check-status = Проверить статус
pirates-check-status-detailed = Подробный статус
pirates-all-gems-collected = Все самоцветы собраны!
# Winner
pirates-winner = { $player } побеждает со счётом { $score }!
# Gem collection
pirates-gem-found-you =
    Вы нашли самоцвет ({ $gem })! Стоимость: { $value } { $value ->
        [one] очко
        [few] очка
       *[other] очков
    }.
pirates-gem-found =
    { $player } находит самоцвет ({ $gem })! Стоимость: { $value } { $value ->
        [one] очко
        [few] очка
       *[other] очков
    }.
pirates-level-up-you = Вы достигли { $level } уровня!
pirates-level-up = { $player } достигает { $level } уровня!
pirates-level-up-multiple-you = Вы получили сразу несколько уровней ({ $levels })! Теперь уровень: { $level }.
pirates-level-up-multiple = { $player } получает сразу несколько уровней ({ $levels })! Теперь уровень: { $level }.
pirates-skills-unlocked-you = Вы открыли новые навыки: { $skills }.
pirates-skills-unlocked = { $player } открывает новые навыки: { $skills }.
# Combat - Attack initiation
pirates-cannonball = Выстрелить из пушки
pirates-no-targets =
    Нет целей в радиусе { $range } { $range ->
        [one] клетки
        [few] клеток
       *[other] клеток
    }.
pirates-attack-you-fire = Вы стреляете пушечным ядром в игрока { $target }!
pirates-attack-incoming = { $attacker } стреляет в вас пушечным ядром!
pirates-attack-fired = { $attacker } стреляет пушечным ядром в игрока { $defender }!
# Combat - Hit results
pirates-attack-hit-you = Прямое попадание! Вы поразили цель ({ $target })!
pirates-attack-hit-them = В вас попал { $attacker }!
pirates-attack-hit = { $attacker } попадает в игрока { $defender }!
# Combat - Miss results
pirates-attack-miss-you = Ваше ядро прошло мимо игрока { $target }.
pirates-attack-miss-them = Пушечное ядро пролетело мимо вас!
pirates-attack-miss = { $attacker } промахивается по игроку { $defender }.
pirates-push = { $attacker } отталкивает { $defender } { $direction } с позиции { $old_pos } на { $new_pos }.
pirates-steal-success-you = Вы украли самоцвет ({ $gem }) у игрока { $target }!
pirates-steal-success-them = { $attacker } крадёт ваш самоцвет ({ $gem })!
pirates-steal-success = { $attacker } крадёт самоцвет ({ $gem }) у игрока { $defender }!
pirates-steal-failed = Попытка кражи провалилась!
# Skills menu
pirates-use-skill = Использовать навык
pirates-select-skill = Выберите навык для использования
# Skill activation
pirates-skill-activated = { $player } активирует навык «{ $skill }»!
pirates-buff-expired = Эффект навыка «{ $skill }» у игрока { $player } истёк.
# Portal skill
pirates-portal-no-ships = В поле зрения нет других кораблей для создания портала.
pirates-portal-fizzle = Портал игрока { $player } закрывается, так и не найдя цели.
pirates-portal-success = { $player } перемещается через портал в { $ocean } на позицию { $position }!
# Gem Seeker skill
pirates-gem-seeker-reveal = Морские волны шепчут, что на позиции { $position } есть самоцвет ({ $gem }). (Осталось использований: { $uses })
# Sword Fighter skill
pirates-sword-fighter-activated =
    «Мастер меча» активирован! +4 к бонусу атаки на { $turns } { $turns ->
        [one] ход
        [few] хода
       *[other] ходов
    }.
# Push skill (defense buff)
pirates-push-activated =
    «Толкание» активировано! +3 к бонусу защиты на { $turns } { $turns ->
        [one] ход
        [few] хода
       *[other] ходов
    }.
# Skilled Captain skill
pirates-skilled-captain-activated =
    «Опытный капитан» активирован! +2 к атаке и +2 к защите на { $turns } { $turns ->
        [one] ход
        [few] хода
       *[other] ходов
    }.
# Battleship skill
pirates-battleship-activated = «Линкор» активирован! Вы можете сделать два выстрела в этот ход!
pirates-battleship-shot = Производится выстрел №{ $shot }...
pirates-battleship-no-targets = Нет целей для выстрела №{ $shot }.
# Double Devastation skill
pirates-double-devastation-activated =
    «Двойное опустошение» активировано! Дальность атаки увеличена до 10 клеток на { $turns } { $turns ->
        [one] ход
        [few] хода
       *[other] ходов
    }.
# XP Multiplier options
pirates-set-combat-xp-multiplier = Множитель опыта за бой: { $combat_multiplier }
pirates-enter-combat-xp-multiplier = Введите множитель опыта за бой
pirates-set-find-gem-xp-multiplier = Множитель опыта за находку самоцвета: { $find_gem_multiplier }
pirates-enter-find-gem-xp-multiplier = Введите множитель опыта за нахождение самоцвета
# Gem stealing options
pirates-set-gem-stealing = Кража самоцветов: { $mode }
pirates-select-gem-stealing = Выберите режим кражи самоцветов
pirates-option-changed-stealing = Режим кражи самоцветов изменён на: { $mode }.
# Gem stealing mode choices
pirates-stealing-with-bonus = С бонусом к броску
pirates-stealing-no-bonus = Без бонуса к броску
pirates-stealing-disabled = Отключена
