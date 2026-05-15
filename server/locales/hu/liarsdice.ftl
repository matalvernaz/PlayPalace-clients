# Liar's Dice — hu
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Minden játékos a poharában titokban dobja a kockákat. Felváltva egyre magasabb tétet tesznek egy adott szám összes példányának számára az asztalon — vagy "Hazudsz!"-t kiáltanak, ha nem hisznek az utolsó tétnek. Tévedés egy kockába kerül. Az utolsó, akinek van kockája, nyer.

liarsdice-rules =
    A Liar's Dice egy 2-6 fős blöff alapú kockajáték.
    Minden játékos 5 kockával indul a poharában. Minden forduló elején mindenki titokban dob.
    Felváltva tesznek tétet egy adott szám összes példányára az asztalon — például "három 4" azt jelenti, hogy minden pohár felfedésekor legalább három 4 van.
    Minden új tétnek magasabbnak kell lennie: ugyanaz a szám nagyobb mennyiséggel, vagy magasabb szám egyenlő vagy nagyobb mennyiséggel.
    Az 1-esek jokerek — minden, nem 1-re vonatkozó tétbe beleszámítanak.
    Az 1-re váltás megfelezi a mennyiséget (felfelé kerekítve). Az 1-ről egy normál számra visszatéréshez az előző mennyiség kétszeresénél többre van szükség.
    Tét helyett kiálthatod, hogy "Hazudsz!" és vitathatod az utolsó tétet. Minden pohár fel: ha a tét helyes, a vitató veszít egy kockát; ha nem, a tétet tevő veszít egy kockát.
    Spot On-nal "Spot On"-t is kiálthatsz, fogadva, hogy a tét pontosan helyes. Ha igazad van, minden más játékos veszít egy kockát; ha nem, te veszítesz kettőt.
    Kiestél, ha nulla kockád van. Az utolsó, akinek van kockája, nyer.
    Nyomd meg az S-t az asztal ellenőrzéséhez.

ld-set-starting-dice = Kezdő kockák játékosonként: { $dice }
ld-desc-starting-dice = Hány kockával kezd minden játékos. Alapértelmezés 5. Több kocka = hosszabb játékok és több blöff-lehetőség.
ld-prompt-starting-dice = Add meg a kezdő kockák számát (3-8)
ld-option-changed-starting-dice = Kezdő kockák { $dice }-ra állítva.

ld-toggle-wild-ones = 1-esek jokerek: { $enabled }
ld-desc-wild-ones = Be: az 1-esek minden, nem 1-re vonatkozó tétbe beleszámítanak. 1-re tét esetén a jokerek inaktiválódnak. Ki — a játék tiszta valószínűség, jokerek nélkül.
ld-option-changed-wild-ones = Joker 1-esek { $enabled }.

ld-toggle-spot-on = Spot On kiáltás engedélyezve: { $enabled }
ld-desc-spot-on = Be: "Hazudsz" mellett "Spot On"-t is kiálthatsz, fogadva, hogy a tét pontosan helyes. Talált — mások veszítenek egy kockát fejenként. Tévedés — te veszítesz kettőt. Magas kockázat, magas jutalom.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = { $round }. forduló kezdődik. Összes kocka az asztalon: { $total }. Mindenki dob.
ld-your-roll = Kockáid ebben a fordulóban: { $dice }.
ld-your-counts = Számolásaid: { $counts }.
ld-turn-start = { $player } következik. { $bid_state }
ld-no-bid-yet = Még nincs tét — nyisd meg a fordulót.
ld-current-bid = Jelenlegi tét: { $quantity } { $face }.

ld-action-bid = Tét tétele
ld-action-call-liar = Mondj Hazudsz-t
ld-action-call-spot-on = Mondj Spot On-t
ld-bid-prompt = Válaszd ki a tétet.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] { $quantity } { $face }-ot teszel.
    *[player] { $player } { $quantity } { $face }-ot tesz.
}

ld-call-liar = { $who ->
    [you] Hazudsz-t mondasz { $target } { $quantity } { $face } tétjére.
    *[player] { $player } Hazudsz-t mond { $target } { $quantity } { $face } tétjére.
}
ld-call-spot-on = { $who ->
    [you] Spot On-t mondasz { $target } { $quantity } { $face } tétjére.
    *[player] { $player } Spot On-t mond { $target } { $quantity } { $face } tétjére.
}
ld-reveal-header = Poharakat fel! Számoljuk a { $face }-okat az asztalon.
ld-reveal-line = { $player } dobta: { $dice }.
ld-actual-count = { $face } valódi száma (joker 1-esekkel): { $count }. A tét { $quantity } volt.
ld-actual-count-no-wild = { $face } valódi száma (jokerek nélkül): { $count }. A tét { $quantity } volt.

ld-liar-bidder-loses = { $bidder } túl magasra tett — veszít egy kockát.
ld-liar-caller-loses = A tét becsületes volt — { $caller } veszít egy kockát.
ld-spot-on-correct = Spot on! { $caller } pontosan talált — mások veszítenek egy-egy kockát.
ld-spot-on-wrong = Nem spot on. { $caller } veszít két kockát.

ld-lost-die = { $who ->
    [you] Elveszítettél egy kockát. Most { $remaining } { $remaining ->
        [one] kockád
        *[other] kockád
    } van.
    *[player] { $player } elveszített egy kockát. Most { $remaining } kockája van.
}
ld-lost-dice-multi = { $who ->
    [you] Elveszítettél { $count } kockát. Most { $remaining } { $remaining ->
        [one] kockád
        *[other] kockád
    } van.
    *[player] { $player } elveszített { $count } kockát. Most { $remaining } kockája van.
}
ld-eliminated = { $player } kifogyott a kockákból és kiesett! { $remaining } { $remaining ->
    [one] játékos
    *[other] játékos
} maradt.
ld-winner = { $player } az utolsó kockákkal — nyer!

ld-status-round = { $round }. forduló.
ld-status-your-dice = Kockáid: { $dice }.
ld-status-your-counts = Számolásaid: { $counts }.
ld-status-no-dice = Nincs kockád — kiestél.
ld-status-current-bid = Jelenlegi tét: { $quantity } { $face }.
ld-status-no-bid = Ebben a fordulóban nincs tét.
ld-status-table-total = Összes kocka az asztalon: { $total }.
ld-status-detailed-header = Részletes állapot — { $count } játékos maradt.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] kocka
    *[other] kocka
}.
ld-status-detailed-out = { $player }: kiesett.
ld-status-detailed-self-suffix = {" "}(te)

ld-face-1 = egyesek
ld-face-2 = kettesek
ld-face-3 = hármasok
ld-face-4 = négyesek
ld-face-5 = ötösök
ld-face-6 = hatosok

ld-action-not-your-turn = Most nem te következel.
ld-action-not-playing = A játék nem fut.
ld-action-no-bid-to-call = Még nincs vitatható tét.
ld-action-eliminated = Kiestél.
