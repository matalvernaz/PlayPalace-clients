# Liar's Dice — tr
# AI-translated, native review pending — corrections welcome.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Her oyuncu, kabının altında gizlice zar atar. Sırayla masadaki belirli bir yüzün toplam sayısına gittikçe yükselen tahminler yapılır — son tahmine inanmıyorsan "Yalancı!" dersin. Yanlış tahmin bir zar kaybettirir. Elinde zar kalan son oyuncu kazanır.

liarsdice-rules =
    Liar's Dice, 2-6 oyuncu için bir zarla blöf oyunudur.
    Her oyuncu kabında 5 zarla başlar. Her turun başında herkes gizlice zar atar.
    Sırayla tüm masadaki belirli bir yüzün toplam sayısı için tahmin yaparsınız — örneğin "üç tane 4" demek tüm kaplar açıldığında en az üç tane 4 var demektir.
    Her yeni tahmin öncekinden yüksek olmalı: aynı yüzde daha çok sayı veya daha yüksek yüzde eşit veya daha çok sayı.
    1'ler joker — 1 dışındaki her tahmine sayılırlar. 1'ler üzerine tahmin yaparken jokerler devre dışıdır.
    1'ler üzerine geçince sayı yarıya iner (yukarı yuvarlama). 1'lerden normal yüze dönerken önceki sayının iki katından fazlası gerekir.
    Tahmin yerine "Yalancı!" diyerek son tahmine itiraz edebilirsin. Tüm kaplar açılır: tahmin doğruysa itiraz eden bir zar kaybeder; değilse tahmin yapan kaybeder.
    Spot On açıksa "Spot On" diyerek tahminin tam olarak doğru olduğuna oynayabilirsin. Doğruysa diğer herkes birer zar kaybeder; yanlışsa sen iki zar kaybedersin.
    Zarın sıfıra inince elenirsin. Elinde zar kalan son oyuncu kazanır.
    Masayı görmek için S'ye bas.

ld-set-starting-dice = Oyuncu başına başlangıç zarı: { $dice }
ld-desc-starting-dice = Her oyuncu kaç zarla başlar. Varsayılan 5. Daha çok zar = daha uzun oyun, daha çok blöf alanı.
ld-prompt-starting-dice = Başlangıç zarını gir (3-8)
ld-option-changed-starting-dice = Başlangıç zarı { $dice } olarak ayarlandı.

ld-toggle-wild-ones = 1'ler joker: { $enabled }
ld-desc-wild-ones = Açık: 1'ler 1 olmayan her tahmine sayılır. 1'ler üzerine tahmin yaparken o tahmin için jokerler devre dışı kalır. Kapalı: oyun jokersiz saf olasılık olur.
ld-option-changed-wild-ones = Joker 1'ler { $enabled }.

ld-toggle-spot-on = Spot On çağrısı etkin: { $enabled }
ld-desc-spot-on = Açık: "Yalancı" yanında "Spot On" diyebilirsin — tahminin tam doğru olduğuna oynarsın. Doğruysa diğerleri birer zar kaybeder. Yanlışsa sen iki kaybedersin. Yüksek risk, yüksek ödül.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Tur { $round } başlıyor. Masadaki toplam zar: { $total }. Herkes atar.
ld-your-roll = Bu turdaki zarların: { $dice }.
ld-your-counts = Sayıların: { $counts }.
ld-turn-start = Sıra { $player }'da. { $bid_state }
ld-no-bid-yet = Henüz tahmin yok — turu aç.
ld-current-bid = Şu anki tahmin: { $quantity } { $face }.

ld-action-bid = Tahmin yap
ld-action-call-liar = Yalancı de
ld-action-call-spot-on = Spot On de
ld-bid-prompt = Tahminini seç.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] { $quantity } { $face } tahmini yapıyorsun.
    *[player] { $player } { $quantity } { $face } tahmini yapıyor.
}

ld-call-liar = { $who ->
    [you] { $target }'in { $quantity } { $face } tahminine Yalancı diyorsun.
    *[player] { $player } { $target }'in { $quantity } { $face } tahminine Yalancı diyor.
}
ld-call-spot-on = { $who ->
    [you] { $target }'in { $quantity } { $face } tahminine Spot On diyorsun.
    *[player] { $player } { $target }'in { $quantity } { $face } tahminine Spot On diyor.
}
ld-reveal-header = Kaplar açılsın! Masadaki { $face } sayılıyor.
ld-reveal-line = { $player } attı: { $dice }.
ld-actual-count = { $face } gerçek sayısı (joker 1'lerle): { $count }. Tahmin { $quantity } idi.
ld-actual-count-no-wild = { $face } gerçek sayısı (jokersiz): { $count }. Tahmin { $quantity } idi.

ld-liar-bidder-loses = { $bidder } fazla tahmin etti — bir zar kaybediyor.
ld-liar-caller-loses = Tahmin dürüsttü — { $caller } bir zar kaybediyor.
ld-spot-on-correct = Spot on! { $caller } tam isabet — diğer herkes bir zar kaybediyor.
ld-spot-on-wrong = Spot on değil. { $caller } iki zar kaybediyor.

ld-lost-die = { $who ->
    [you] Bir zar kaybettin. Şimdi { $remaining } { $remaining ->
        [one] zar
        *[other] zar
    }'ın var.
    *[player] { $player } bir zar kaybetti. Şimdi { $remaining } zarı var.
}
ld-lost-dice-multi = { $who ->
    [you] { $count } zar kaybettin. Şimdi { $remaining } { $remaining ->
        [one] zar
        *[other] zar
    }'ın var.
    *[player] { $player } { $count } zar kaybetti. Şimdi { $remaining } zarı var.
}
ld-eliminated = { $player } zarı kalmadı, elendi! { $remaining } { $remaining ->
    [one] oyuncu
    *[other] oyuncu
} kaldı.
ld-winner = { $player } zarı kalan son oyuncu — kazandı!

ld-status-round = Tur { $round }.
ld-status-your-dice = Zarların: { $dice }.
ld-status-your-counts = Sayıların: { $counts }.
ld-status-no-dice = Zarın yok — elendin.
ld-status-current-bid = Şu anki tahmin: { $quantity } { $face }.
ld-status-no-bid = Bu turda tahmin yok.
ld-status-table-total = Masadaki toplam zar: { $total }.
ld-status-detailed-header = Ayrıntılı durum — { $count } oyuncu kaldı.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] zar
    *[other] zar
}.
ld-status-detailed-out = { $player }: elendi.
ld-status-detailed-self-suffix = {" "}(sen)

ld-face-1 = birler
ld-face-2 = ikiler
ld-face-3 = üçler
ld-face-4 = dörtler
ld-face-5 = beşler
ld-face-6 = altılar

ld-action-not-your-turn = Sıra sende değil.
ld-action-not-playing = Oyun devam etmiyor.
ld-action-no-bid-to-call = İtiraz edilecek bir tahmin yok.
ld-action-eliminated = Elendin.
