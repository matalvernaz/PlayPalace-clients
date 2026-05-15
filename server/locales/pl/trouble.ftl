# Trouble — pl
game-name-trouble = Trouble

trouble-rules =
    Trouble to wyścigowa gra z rodziny Parcheesi.
    Każdy gracz zaczyna z pionkami w swoim Domu.
    W swojej turze uruchom kostkę i przesuń jeden z pionków.
    Domyślnie musisz wyrzucić 6, aby uwolnić pionek z Domu na tor.
    Domyślnie 6 daje też dodatkową turę.
    Pionki poruszają się zgodnie z ruchem wskazówek zegara po wspólnym torze do strefy mety.
    Wejście na pionek przeciwnika odsyła go do Domu, chyba że pole jest chronione.
    Gdy wszystkie twoje pionki dotrą do mety, wygrywasz.
    W trybie drużynowym twoja drużyna wygrywa, gdy wszyscy członkowie zakończą.
    Klawisze 1-6 wybierają pionek, R rzuca.
    E w dowolnym momencie odczyta pełny stan planszy.

trouble-action-roll = Uruchom kostkę
trouble-action-move-token = Przesuń pionek { $token }
trouble-action-check-board = Sprawdź planszę

trouble-token-label-home = Pionek { $token }: w Domu
trouble-token-label-track = Pionek { $token }: pole { $position } toru
trouble-token-label-finish-lane = Pionek { $token }: tor mety { $position } z { $total }
trouble-token-label-finished = Pionek { $token }: na mecie

trouble-rolled = { $player } wyrzucił { $roll }.
trouble-leave-home = { $player } uwalnia pionek { $token } na tor.
trouble-advance-track = { $player } przesuwa pionek { $token } na pole { $position }.
trouble-enter-finish-lane = { $player } wprowadza pionek { $token } na tor mety.
trouble-advance-finish-lane =
    { $player } przesuwa pionek { $token } na pole { $position } z { $total } toru mety.
trouble-token-finished = Pionek { $token } gracza { $player } dociera do mety.
trouble-bump =
    Pionek { $token } gracza { $player } odsyła pionek { $opp_token } gracza { $opponent } do Domu.
trouble-no-legal-move = { $player } nie ma legalnych ruchów. Tura przechodzi.
trouble-extra-turn = { $player } dostaje dodatkową turę za 6.

trouble-winner = { $player } wygrywa! Wszystkie pionki na mecie.
trouble-team-winner = Drużyna { $team } wygrywa! Wszyscy zakończyli.
trouble-final-standing = { $player }: { $finished } z { $total } pionków na mecie.

trouble-turn-summary =
    Masz { $own_home } w Domu, { $own_track } na torze, { $own_finished } na mecie.
    Przeciwnicy: { $opponents }.
trouble-opponent-summary = { $name }: { $home } dom, { $track } tor, { $finished } meta

trouble-board-status =
    Twoje pionki: { $own_tokens }.
    Pionki przeciwników: { $opp_tokens }.

trouble-reason-not-rolled = Najpierw uruchom kostkę.
trouble-reason-already-rolled = Już rzuciłeś. Wybierz pionek do ruchu.
trouble-reason-no-legal-moves = Brak legalnych ruchów dla tego rzutu.
trouble-reason-token-home-needs-six = Ten pionek jest w Domu. Potrzebujesz 6, aby go uwolnić.
trouble-reason-token-home-needs-any = Ten pionek jest w Domu. Każdy rzut go uwolni.
trouble-reason-token-home-no-qualifying-roll =
    Ten pionek jest w Domu, a twój rzut nie wystarcza, aby go uwolnić.
trouble-reason-token-finished = Ten pionek jest już na mecie.
trouble-reason-overshoot-wastes = Ten pionek nie może ruszyć { $roll } pól bez przekroczenia mety.
trouble-reason-blocked = Ten ruch jest zablokowany.

trouble-option-track-size = Rozmiar toru: { $track_size } pól
trouble-option-select-track-size = Wybierz liczbę pól toru.
trouble-option-changed-track-size = Tor ustawiony na { $track_size } pól.
trouble-option-desc-track-size = Liczba pól na wspólnym torze.

trouble-option-tokens-per-player = Pionki na gracza: { $tokens }
trouble-option-enter-tokens-per-player = Wpisz pionki na gracza (2-6):
trouble-option-changed-tokens-per-player = Pionki na gracza: { $tokens }.
trouble-option-desc-tokens-per-player = Ile pionków każdy gracz prowadzi do mety.

trouble-option-extra-turn-on-six = Dodatkowa tura przy 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Dodatkowa tura przy 6 { $enabled ->
    [on] włączona.
    [off] wyłączona.
   *[other] zaktualizowana.
}
trouble-option-desc-extra-turn-on-six =
    Włączone: 6 daje dodatkową turę (klasyczna zasada Hasbro).

trouble-option-six-to-leave-home = Wymaganie 6 do wyjścia z Domu: { $enabled }
trouble-option-changed-six-to-leave-home = Sześć na wyjście z Domu { $enabled ->
    [on] włączone.
    [off] wyłączone.
   *[other] zaktualizowane.
}
trouble-option-desc-six-to-leave-home =
    Włączone: gracz musi wyrzucić 6, aby uwolnić pionek z Domu. Wyłączone: każdy rzut uwalnia.

trouble-option-safe-spaces = Bezpieczne pola: { $mode }
trouble-option-select-safe-spaces = Wybierz tryb bezpiecznych pól.
trouble-option-changed-safe-spaces = Bezpieczne pola: { $mode }.
trouble-option-desc-safe-spaces = Wybierz, czy pionki mogą być chronione przed uderzeniami.

trouble-safe-mode-none = Brak
trouble-safe-mode-home-stretch = Tylko prosta końcowa
trouble-safe-mode-every-seventh = Co 7. pole

trouble-option-finish-behavior = Meta: { $mode }
trouble-option-select-finish-behavior = Wybierz zachowanie mety.
trouble-option-changed-finish-behavior = Zachowanie mety: { $mode }.
trouble-option-desc-finish-behavior = Jak traktować rzut przekraczający metę.

trouble-finish-mode-exact = Wymagany dokładny rzut
trouble-finish-mode-bounce = Nadmiar odbija się
trouble-finish-mode-allow = Nadmiar dozwolony

trouble-option-bot-difficulty = Poziom bota: { $level }
trouble-option-select-bot-difficulty = Wybierz poziom bota.
trouble-option-changed-bot-difficulty = Poziom bota: { $level }.
trouble-option-desc-bot-difficulty = Siła wbudowanych botów.

trouble-bot-difficulty-naive = Naiwny
trouble-bot-difficulty-greedy = Zachłanny

trouble-option-preset = Preset: { $preset }
trouble-option-select-preset = Wybierz wariant. Gospodarz może potem ustawić poszczególne reguły.
trouble-option-changed-preset = Preset zastosowany: { $preset }.
trouble-option-desc-preset = Gotowe zestawy opcji dla popularnych wariantów.

trouble-preset-classic = Klasyczny Hasbro
trouble-preset-fast = Szybki
trouble-preset-brutal = Brutalny
trouble-preset-custom = Własny
