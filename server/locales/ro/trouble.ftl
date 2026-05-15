# Trouble — ro
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble este un joc de cursă din familia Parcheesi.
    Fiecare jucător începe cu pionii în zona Acasă.
    În tura ta, apasă zarul și mută unul dintre pioni.
    Implicit trebuie să dai 6 pentru a elibera un pion din Acasă pe pistă.
    Implicit, un 6 dă și o tură suplimentară.
    Pionii se mișcă în sens orar pe pista comună spre zona de finish.
    Aterizarea pe pionul unui adversar îl trimite înapoi Acasă, dacă spațiul nu este protejat.
    Când toți pionii tăi ajung la finish, câștigi.
    În modul echipă, echipa ta câștigă când toți colegii au terminat.
    Folosește 1-6 pentru a alege un pion, R pentru a arunca.
    Apasă E oricând pentru a auzi starea completă a tablei.

trouble-action-roll = Apasă zarul
trouble-action-move-token = Mută pionul { $token }
trouble-action-check-board = Verifică tabla

trouble-token-label-home = Pionul { $token }: Acasă
trouble-token-label-track = Pionul { $token }: spațiul { $position } al pistei
trouble-token-label-finish-lane = Pionul { $token }: culoarul de finish { $position } din { $total }
trouble-token-label-finished = Pionul { $token }: terminat

trouble-rolled = { $player } a dat { $roll }.
trouble-leave-home = { $player } eliberează pionul { $token } pe pistă.
trouble-advance-track = { $player } mută pionul { $token } pe spațiul { $position }.
trouble-enter-finish-lane = { $player } duce pionul { $token } în culoarul de finish.
trouble-advance-finish-lane =
    { $player } avansează pionul { $token } pe spațiul { $position } din { $total } al culoarului.
trouble-token-finished = Pionul { $token } al lui { $player } ajunge la finish.
trouble-bump =
    Pionul { $token } al lui { $player } trimite pionul { $opp_token } al lui { $opponent } Acasă.
trouble-no-legal-move = { $player } nu are mutări legale. Tura trece.
trouble-extra-turn = { $player } primește o tură în plus pentru 6.

trouble-winner = { $player } câștigă! Toți pionii la finish.
trouble-team-winner = Echipa { $team } câștigă! Toți colegii au terminat.
trouble-final-standing = { $player }: { $finished } din { $total } pioni terminați.

trouble-turn-summary =
    Ai { $own_home } Acasă, { $own_track } pe pistă, { $own_finished } terminați.
    Adversari: { $opponents }.
trouble-opponent-summary = { $name }: { $home } acasă, { $track } pistă, { $finished } finish

trouble-board-status =
    Pionii tăi: { $own_tokens }.
    Pionii adversarilor: { $opp_tokens }.

trouble-reason-not-rolled = Apasă mai întâi zarul.
trouble-reason-already-rolled = Ai apăsat deja. Alege un pion de mutat.
trouble-reason-no-legal-moves = Nicio mutare legală pentru acest zar.
trouble-reason-token-home-needs-six = Acest pion e Acasă. Ai nevoie de 6 pentru a-l elibera.
trouble-reason-token-home-needs-any = Acest pion e Acasă. Orice zar îl eliberează.
trouble-reason-token-home-no-qualifying-roll =
    Acest pion e Acasă și zarul tău nu îndeplinește condiția de eliberare.
trouble-reason-token-finished = Acest pion a terminat deja.
trouble-reason-overshoot-wastes = Acest pion nu poate avansa { $roll } spații fără să depășească finishul.
trouble-reason-blocked = Această mutare este blocată.

trouble-option-track-size = Mărimea pistei: { $track_size } spații
trouble-option-select-track-size = Selectează numărul de spații al pistei.
trouble-option-changed-track-size = Pista setată la { $track_size } spații.
trouble-option-desc-track-size = Numărul de spații pe pista comună.

trouble-option-tokens-per-player = Pioni per jucător: { $tokens }
trouble-option-enter-tokens-per-player = Introdu numărul de pioni per jucător (2-6):
trouble-option-changed-tokens-per-player = Pioni per jucător setați la { $tokens }.
trouble-option-desc-tokens-per-player = Câți pioni duce fiecare jucător la finish.

trouble-option-extra-turn-on-six = Tură în plus la 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Tură în plus la 6 { $enabled ->
    [on] activată.
    [off] dezactivată.
   *[other] actualizată.
}
trouble-option-desc-extra-turn-on-six =
    Pornit: un 6 dă o tură în plus (regulă clasică Hasbro).

trouble-option-six-to-leave-home = Necesită 6 pentru a părăsi Acasă: { $enabled }
trouble-option-changed-six-to-leave-home = Șase pentru a părăsi Acasă { $enabled ->
    [on] activat.
    [off] dezactivat.
   *[other] actualizat.
}
trouble-option-desc-six-to-leave-home =
    Pornit: jucătorul trebuie să dea 6 pentru a elibera un pion. Oprit: orice zar îl eliberează.

trouble-option-safe-spaces = Spații sigure: { $mode }
trouble-option-select-safe-spaces = Selectează modul spațiilor sigure.
trouble-option-changed-safe-spaces = Spații sigure setate la { $mode }.
trouble-option-desc-safe-spaces = Decide dacă pionii pot fi protejați de loviri.

trouble-safe-mode-none = Niciunul
trouble-safe-mode-home-stretch = Doar linia de finish
trouble-safe-mode-every-seventh = La fiecare 7 spații

trouble-option-finish-behavior = Finish: { $mode }
trouble-option-select-finish-behavior = Selectează comportamentul de finish.
trouble-option-changed-finish-behavior = Comportament de finish setat la { $mode }.
trouble-option-desc-finish-behavior = Cum se gestionează un zar care depășește finishul.

trouble-finish-mode-exact = Zar exact necesar
trouble-finish-mode-bounce = Depășirea ricoșează
trouble-finish-mode-allow = Depășire permisă

trouble-option-bot-difficulty = Dificultate bot: { $level }
trouble-option-select-bot-difficulty = Selectează dificultatea botului.
trouble-option-changed-bot-difficulty = Dificultate bot setată la { $level }.
trouble-option-desc-bot-difficulty = Forța boților integrați.

trouble-bot-difficulty-naive = Naiv
trouble-bot-difficulty-greedy = Lacom

trouble-option-preset = Preset: { $preset }
trouble-option-select-preset = Alege o variantă. Gazda poate ajusta apoi regulile individuale.
trouble-option-changed-preset = Preset aplicat: { $preset }.
trouble-option-desc-preset = Seturi de opțiuni preconfigurate pentru variante comune.

trouble-preset-classic = Clasic Hasbro
trouble-preset-fast = Rapid
trouble-preset-brutal = Brutal
trouble-preset-custom = Personalizat
