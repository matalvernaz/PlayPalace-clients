# Liar's Dice — pl
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Każdy gracz potajemnie rzuca kośćmi pod kubkiem. Na zmianę licytujecie coraz wyższe sumy danego oczka na całym stole — albo wołacie „Kłamca!", jeśli nie wierzycie ostatniej licytacji. Pomyłka kosztuje kość. Wygrywa ten, kto zostanie z kośćmi.

liarsdice-rules =
    Liar's Dice to gra w blef kośćmi dla 2-6 graczy.
    Każdy gracz zaczyna z 5 kośćmi w kubku. Na początku rundy wszyscy rzucają potajemnie.
    Na zmianę licytujecie sumę danego oczka na wszystkich kościach — np. „trzy 4" znaczy, że jest co najmniej trzy 4 po odsłonięciu kubków.
    Każda nowa licytacja musi być wyższa: to samo oczko z większą liczbą, albo wyższe oczko z liczbą równą lub większą.
    Jedynki są jokerami — liczą się do każdej licytacji oprócz licytacji na jedynki.
    Przejście na licytację jedynek dzieli liczbę na pół (zaokrąglenie w górę). Powrót z jedynek do zwykłego oczka wymaga ponad podwójnej poprzedniej liczby.
    Zamiast licytować możesz krzyknąć „Kłamca!", aby zakwestionować ostatnią licytację. Wszyscy odsłaniają kubki: jeśli licytacja była prawdziwa, kwestionujący traci kość; jeśli nie, licytujący traci kość.
    Jeśli włączony Spot On, możesz zawołać „Spot On", obstawiając, że licytacja jest dokładnie poprawna. Trafienie — wszyscy inni tracą po kości; pomyłka — ty tracisz dwie.
    Eliminacja przy zerze kości. Wygrywa ostatni z kośćmi.
    Naciśnij S, aby sprawdzić stół.

ld-set-starting-dice = Początkowe kości na gracza: { $dice }
ld-desc-starting-dice = Z iloma kośćmi zaczyna każdy gracz. Domyślnie 5. Więcej kości = dłuższe gry i więcej miejsca na blef.
ld-prompt-starting-dice = Wprowadź początkowe kości (3 do 8)
ld-option-changed-starting-dice = Początkowe kości ustawione na { $dice }.

ld-toggle-wild-ones = Jedynki są jokerami: { $enabled }
ld-desc-wild-ones = Włączone: jedynki liczą się do każdej licytacji niebędącej licytacją na jedynki. Licytacja na jedynki wyłącza jokery dla tej licytacji. Wyłączone — gra to czysta probabilistyka, bez jokerów.
ld-option-changed-wild-ones = Jokery-jedynki { $enabled }.

ld-toggle-spot-on = Wołanie Spot On włączone: { $enabled }
ld-desc-spot-on = Włączone: oprócz „Kłamcy" możesz zawołać „Spot On", obstawiając, że licytacja jest dokładnie poprawna. Trafienie — inni tracą po kości. Pudło — tracisz dwie. Wysokie ryzyko, wysoka nagroda.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Runda { $round } zaczyna się. Łącznie kości na stole: { $total }. Wszyscy rzucają.
ld-your-roll = Twoje kości w tej rundzie: { $dice }.
ld-your-counts = Twoje liczby: { $counts }.
ld-turn-start = Tura gracza { $player }. { $bid_state }
ld-no-bid-yet = Brak licytacji — otwórz rundę.
ld-current-bid = Aktualna licytacja: { $quantity } { $face }.

ld-action-bid = Licytuj
ld-action-call-liar = Zawołaj Kłamcę
ld-action-call-spot-on = Zawołaj Spot On
ld-bid-prompt = Wybierz licytację.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Licytujesz { $quantity } { $face }.
    *[player] { $player } licytuje { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Wołasz Kłamcę na licytację { $target }: { $quantity } { $face }.
    *[player] { $player } woła Kłamcę na licytację { $target }: { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Wołasz Spot On na licytację { $target }: { $quantity } { $face }.
    *[player] { $player } woła Spot On na licytację { $target }: { $quantity } { $face }.
}
ld-reveal-header = Kubki w górę! Liczymy { $face } na stole.
ld-reveal-line = { $player } wyrzucił: { $dice }.
ld-actual-count = Rzeczywista liczba { $face } (z jokerami-1): { $count }. Licytacja była { $quantity }.
ld-actual-count-no-wild = Rzeczywista liczba { $face } (bez jokerów): { $count }. Licytacja była { $quantity }.

ld-liar-bidder-loses = { $bidder } przelicytował — traci kość.
ld-liar-caller-loses = Licytacja była uczciwa — { $caller } traci kość.
ld-spot-on-correct = Spot on! { $caller } trafił dokładnie — inni tracą po kości.
ld-spot-on-wrong = Nie spot on. { $caller } traci dwie kości.

ld-lost-die = { $who ->
    [you] Tracisz kość. Masz teraz { $remaining } { $remaining ->
        [one] kość
        *[other] kości
    }.
    *[player] { $player } traci kość. Ma teraz { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Tracisz { $count } kości. Masz teraz { $remaining } { $remaining ->
        [one] kość
        *[other] kości
    }.
    *[player] { $player } traci { $count } kości. Ma teraz { $remaining }.
}
ld-eliminated = { $player } został bez kości i jest wyeliminowany! Pozostało { $remaining } { $remaining ->
    [one] gracz
    *[other] graczy
}.
ld-winner = { $player } jest ostatnim z kośćmi — wygrywa!

ld-status-round = Runda { $round }.
ld-status-your-dice = Twoje kości: { $dice }.
ld-status-your-counts = Twoje liczby: { $counts }.
ld-status-no-dice = Nie masz kości — jesteś wyeliminowany.
ld-status-current-bid = Aktualna licytacja: { $quantity } { $face }.
ld-status-no-bid = Brak licytacji w tej rundzie.
ld-status-table-total = Łącznie kości na stole: { $total }.
ld-status-detailed-header = Szczegółowy status — pozostało { $count } graczy.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kość
    *[other] kości
}.
ld-status-detailed-out = { $player }: wyeliminowany.
ld-status-detailed-self-suffix = {" "}(ty)

ld-face-1 = jedynki
ld-face-2 = dwójki
ld-face-3 = trójki
ld-face-4 = czwórki
ld-face-5 = piątki
ld-face-6 = szóstki

ld-action-not-your-turn = To nie twoja tura.
ld-action-not-playing = Gra nie trwa.
ld-action-no-bid-to-call = Brak licytacji do zakwestionowania.
ld-action-eliminated = Jesteś wyeliminowany.
