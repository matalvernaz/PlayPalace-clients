# pig.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Game info
game-name-pig = Свинья
# Actions
pig-roll = Бросить кубик
# Disabled reasons
pig-need-more-points = Вам нужно больше очков, чтобы забрать их в банк.
# Pig-specific options
pig-set-min-bank = Минимальный банк: { $points }
pig-set-dice-sides = Граней у кубика: { $sides }
pig-enter-min-bank = Введите минимальное количество очков для банка:
pig-enter-dice-sides = Введите количество граней кубика:
pig-option-changed-min-bank = Минимальный порог очков для банка изменён на { $points }.
pig-option-changed-dice =
    Теперь у кубика { $sides } { $sides ->
        [one] грань
        [few] грани
       *[other] граней
    }.
# Validation errors
pig-error-min-bank-too-high = Минимальный порог банка должен быть меньше, чем конечный счёт.
