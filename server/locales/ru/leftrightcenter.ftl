# leftrightcenter.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game name
game-name-leftrightcenter = Влево, вправо, в центр
# Actions
lrc-roll =
    Бросить { $count } { $count ->
        [one] кубик
        [few] кубика
       *[other] кубиков
    }
# Dice faces
lrc-face-left = Влево
lrc-face-center = Центр
lrc-face-right = Вправо
lrc-face-dot = Точка
lrc-center-pot =
    В центре { $count } { $count ->
        [one] фишка
        [few] фишки
       *[other] фишек
    }.
# Options
lrc-set-starting-chips = Стартовые фишки: { $count }
lrc-enter-starting-chips = Введите количество стартовых фишек:
lrc-option-changed-starting-chips = Стартовое количество фишек установлено на { $count }.
