# Liar's Dice — zu
# AI-translated with limited fluency, native review strongly recommended.
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Umdlali ngamunye uphosa amadayisi akhe ngasese ngaphansi kwesigxotsho. Ngokulandelana, niphakamisa amabhethi aphezulu ngempela ezinombolweni eziphezulu kwetafula lonke — noma nikhale "Mqambimanga!" uma ningakholwa ibhethi okugcina. Ukuphambana kukubize idayisi. Owokugcina onamadayisi uyawina.

liarsdice-rules =
    Liar's Dice umdlalo wamadayisi we-bluff wabadlali abangu-2 kuya kwabangu-6.
    Umdlali ngamunye uqala ngamadayisi angu-5 esigxotsweni. Ekuqaleni komjikelezo ngamunye wonke baphosa ngasese.
    Ngokulandelana niphakamisa amabhethi ezinombolweni eziphezulu kuwo wonke amadayisi etafuleni — isibonelo, "ama-4 amathathu" kusho ukuthi uma izigxotsho zonke zembulwa, kunama-4 okungenani amathathu.
    Ibhethi entsha ngayinye kufanele iphakeme: indawo efanayo enenombolo ephakeme, noma indawo ephakeme enenombolo elinganayo noma ephakeme.
    Ama-1 angama-wild — abalwa kunoma yiliphi ibhethi ngaphandle kombhethi wama-1 ngokwawo.
    Ukuvula kubhethi kuma-1 kuhlukanisa inombolo phakathi (kuzungeziwe ngenhla). Ukubuyela kusukela kuma-1 kuya endaweni evamile kufuna ngaphezu kwesibili inombolo yangaphambili.
    Esikhundleni sokubheja, ungakhala "Mqambimanga!" ukungasekeli ibhethi yangaphambilini. Zonke izigxotsho phezulu: uma ibhethi yayilungile, omthukuthelisile ulahla idayisi; uma kungenjalo, obhejile ulahla idayisi.
    Ngokuvulwa kwe-Spot On, ungakhala "Spot On" ubheja ukuthi ibhethi inembe. Uma uqinisile, bonke abanye balahla idayisi ngalinye; uma ungalungile, ulahla amadayisi amabili.
    Ukukhishwa ekuthi amadayisi afika kuzero. Owokugcina onamadayisi uyawina.
    Cindezela S ukuhlola itafula.

ld-set-starting-dice = Amadayisi okuqala kumdlali ngamunye: { $dice }
ld-desc-starting-dice = Umdlali ngamunye uqala ngamangaki amadayisi. Okuzenzakalelayo 5. Amadayisi amaningi = imidlalo emide nendawo eyengeziwe ye-bluff.
ld-prompt-starting-dice = Faka amadayisi okuqala (3 kuya ku-8)
ld-option-changed-starting-dice = Amadayisi okuqala asethelwe ku-{ $dice }.

ld-toggle-wild-ones = Ama-1 angama-wild: { $enabled }
ld-desc-wild-ones = Kuvuliwe: ama-1 abalwa kunoma yiliphi ibhethi engeyona kuma-1. Ibhethi kuma-1 ivimba ama-wild kuleyo bhethi. Kuvaliwe — umdlalo ube ngamandla obhansi kuphela ngaphandle kwe-wild.
ld-option-changed-wild-ones = Ama-wild 1 { $enabled }.

ld-toggle-spot-on = Ukubiza i-Spot On kuvuliwe: { $enabled }
ld-desc-spot-on = Kuvuliwe: ngaphezu kuka "Mqambimanga" ungakhala "Spot On" ubheja ukuthi ibhethi inembe. Iyalungile — abanye balahla idayisi ngalinye. Ayilungile — ulahla amabili. Ingozi ephakeme, umvuzo ophakeme.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Umjikelezo { $round } uqala. Inani lonke lamadayisi etafuleni: { $total }. Bonke bayaposha.
ld-your-roll = Amadayisi akho kulo mjikelezo: { $dice }.
ld-your-counts = Izibalo zakho: { $counts }.
ld-turn-start = Yithuba lika-{ $player }. { $bid_state }
ld-no-bid-yet = Akukabikho bhethi — vula umjikelezo.
ld-current-bid = Ibhethi yamanje: { $quantity } { $face }.

ld-action-bid = Faka ibhethi
ld-action-call-liar = Khala Mqambimanga
ld-action-call-spot-on = Khala Spot On
ld-bid-prompt = Khetha ibhethi yakho.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Ufaka ibhethi ye-{ $quantity } { $face }.
    *[player] { $player } ufaka ibhethi ye-{ $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Ukhala Mqambimanga ebhethini ka-{ $target } ye-{ $quantity } { $face }.
    *[player] { $player } ukhala Mqambimanga ebhethini ka-{ $target } ye-{ $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Ukhala Spot On ebhethini ka-{ $target } ye-{ $quantity } { $face }.
    *[player] { $player } ukhala Spot On ebhethini ka-{ $target } ye-{ $quantity } { $face }.
}
ld-reveal-header = Izigxotsho phezulu! Sibala { $face } etafuleni.
ld-reveal-line = { $player } uphosile: { $dice }.
ld-actual-count = Inani langempela le-{ $face } (kufaka ama-wild 1): { $count }. Ibhethi bekungu-{ $quantity }.
ld-actual-count-no-wild = Inani langempela le-{ $face } (ngaphandle kwama-wild): { $count }. Ibhethi bekungu-{ $quantity }.

ld-liar-bidder-loses = { $bidder } ubheje phezulu kakhulu — ulahla idayisi.
ld-liar-caller-loses = Ibhethi ibithembekile — { $caller } ulahla idayisi.
ld-spot-on-correct = Spot on! { $caller } uqagele ngempela — abanye balahla idayisi ngalinye.
ld-spot-on-wrong = Akusiyo spot on. { $caller } ulahla amadayisi amabili.

ld-lost-die = { $who ->
    [you] Ulahlekelwe yidayisi. Manje unawo amadayisi angu-{ $remaining } { $remaining ->
        [one] idayisi
        *[other] amadayisi
    }.
    *[player] { $player } ulahlekelwe yidayisi. Manje unawo angu-{ $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Ulahlekelwe yi-{ $count } amadayisi. Manje unawo angu-{ $remaining } { $remaining ->
        [one] idayisi
        *[other] amadayisi
    }.
    *[player] { $player } ulahlekelwe yi-{ $count } amadayisi. Manje unawo angu-{ $remaining }.
}
ld-eliminated = { $player } akasenamadayisi futhi ukhishiwe! Kusele { $remaining } { $remaining ->
    [one] umdlali
    *[other] abadlali
}.
ld-winner = { $player } ngowokugcina onamadayisi — uyawina!

ld-status-round = Umjikelezo { $round }.
ld-status-your-dice = Amadayisi akho: { $dice }.
ld-status-your-counts = Izibalo zakho: { $counts }.
ld-status-no-dice = Awunamadayisi — ukhishiwe.
ld-status-current-bid = Ibhethi yamanje: { $quantity } { $face }.
ld-status-no-bid = Akukho bhethi kulo mjikelezo.
ld-status-table-total = Inani lonke lamadayisi etafuleni: { $total }.
ld-status-detailed-header = Isimo esinikeziwe — kusele { $count } abadlali.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] idayisi
    *[other] amadayisi
}.
ld-status-detailed-out = { $player }: ukhishiwe.
ld-status-detailed-self-suffix = {" "}(wena)

ld-face-1 = ama-1
ld-face-2 = ama-2
ld-face-3 = ama-3
ld-face-4 = ama-4
ld-face-5 = ama-5
ld-face-6 = ama-6

ld-action-not-your-turn = Akusilo ithuba lakho.
ld-action-not-playing = Umdlalo awuqhubeki.
ld-action-no-bid-to-call = Akukabikho bhethi yokungasekeli.
ld-action-eliminated = Ukhishiwe.
