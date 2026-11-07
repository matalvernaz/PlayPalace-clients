# sorry.ftl for locale ru. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

game-name-sorry = Sorry!
sorry-rules-profile-classic-00390 = Классика 00390
sorry-rules-profile-a5065-core = A5065 (базовый)
# Turn actions
sorry-draw-card = Взять карту
sorry-move-slot = Вариант хода { $slot }
sorry-move-slot-fallback = Выберите ход
# Move labels (for dynamic move menu entries)
sorry-move-start = Вывести фишку { $pawn } со старта
sorry-move-forward =
    Продвинуть фишку { $pawn } вперёд на { $steps } { $steps ->
        [one] клетку
        [few] клетки
       *[other] клеток
    }
sorry-move-backward =
    Подвинуть фишку { $pawn } назад на { $steps } { $steps ->
        [one] клетку
        [few] клетки
       *[other] клеток
    }
sorry-move-swap = Поменять фишку { $pawn } местами с фишкой { $target_pawn } игрока { $target_player }
sorry-move-sorry = Заменить фишку { $target_pawn } игрока { $target_player } своей фишкой { $pawn }
# Gameplay announcements
sorry-card-sorry = Sorry!
sorry-draw-announcement = { $player } берёт карту: { $card }.
sorry-no-legal-moves = У игрока { $player } нет доступных ходов для карты { $card }.
# Home arrival announcements
sorry-pawn-home = { $player } pawn { $pawn } has arrived home!
sorry-you-pawn-home = Your pawn { $pawn } has arrived home!
