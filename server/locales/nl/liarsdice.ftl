# Liar's Dice — nl
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Iedere speler gooit zijn dobbelstenen in het geheim onder de beker. Om de beurt bied je hoger op het totale aantal van een ogenwaarde op de hele tafel — of roep je "Leugen!" als je het laatste bod niet gelooft. Mis gegokt = een dobbelsteen kwijt. Wie als laatste dobbelstenen heeft, wint.

liarsdice-rules =
    Liar's Dice is een bluffend dobbelspel voor 2 tot 6 spelers.
    Elke speler begint met 5 dobbelstenen in een beker. Aan het begin van elke ronde gooit iedereen in het geheim.
    Om de beurt bied je op het totale aantal van een ogenwaarde over alle dobbelstenen — bijvoorbeeld "drie 4-en" betekent dat er minstens drie 4-en zijn als alle bekers omhoog gaan.
    Elk nieuw bod moet hoger zijn: zelfde ogenwaarde met hogere hoeveelheid, of hogere ogenwaarde met gelijke of hogere hoeveelheid.
    1-en zijn jokers — ze tellen voor elk bod behalve een bod op 1-en zelf.
    Naar een bod op 1-en overschakelen halveert de hoeveelheid (naar boven afgerond). Terug van 1-en naar een normale ogenwaarde vereist meer dan het dubbele van de vorige hoeveelheid.
    In plaats van bieden mag je "Leugen!" roepen om het laatste bod aan te vechten. Alle bekers omhoog: klopt het bod, dan verliest de uitdager een dobbelsteen; zo niet, dan verliest de bieder een dobbelsteen.
    Met Spot On aan mag je ook "Spot On" roepen, om in te zetten dat het bod precies klopt. Heb je gelijk, dan verliest iedereen anders een dobbelsteen; zit je mis, dan verlies je er twee.
    Uitgeschakeld bij nul dobbelstenen. Wie als laatste dobbelstenen heeft, wint.
    Druk op S om de tafel te bekijken.

ld-set-starting-dice = Startdobbelstenen per speler: { $dice }
ld-desc-starting-dice = Met hoeveel dobbelstenen elke speler begint. Standaard 5. Meer dobbelstenen = langere partijen en meer ruimte om te bluffen.
ld-prompt-starting-dice = Voer startdobbelstenen in (3 tot 8)
ld-option-changed-starting-dice = Startdobbelstenen ingesteld op { $dice }.

ld-toggle-wild-ones = 1-en zijn jokers: { $enabled }
ld-desc-wild-ones = Aan: 1-en tellen voor elk bod dat niet op 1-en is. Op 1-en bieden schakelt de jokers voor dat bod uit. Uit maakt het spel puur kansrekening zonder joker.
ld-option-changed-wild-ones = 1-jokers { $enabled }.

ld-toggle-spot-on = Spot On roepen aan: { $enabled }
ld-desc-spot-on = Aan: naast "Leugen" mag je "Spot On" roepen om in te zetten dat het bod precies klopt. Goed: anderen verliezen elk één dobbelsteen. Mis: jij verliest er twee. Hoog risico, hoge beloning.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Ronde { $round } begint. Totaal dobbelstenen op tafel: { $total }. Iedereen gooit.
ld-your-roll = Jouw worp deze ronde: { $dice }.
ld-your-counts = Jouw aantallen: { $counts }.
ld-turn-start = { $player } is aan zet. { $bid_state }
ld-no-bid-yet = Nog geen bod — open de ronde.
ld-current-bid = Huidig bod: { $quantity } { $face }.

ld-action-bid = Een bod doen
ld-action-call-liar = Leugen roepen
ld-action-call-spot-on = Spot On roepen
ld-bid-prompt = Kies je bod.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Jij biedt { $quantity } { $face }.
    *[player] { $player } biedt { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Jij roept Leugen op { $target }s bod van { $quantity } { $face }.
    *[player] { $player } roept Leugen op { $target }s bod van { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Jij roept Spot On op { $target }s bod van { $quantity } { $face }.
    *[player] { $player } roept Spot On op { $target }s bod van { $quantity } { $face }.
}
ld-reveal-header = Bekers omhoog! We tellen de { $face } op de tafel.
ld-reveal-line = { $player } gooide: { $dice }.
ld-actual-count = Echt aantal { $face } (met joker-1en): { $count }. Bod was { $quantity }.
ld-actual-count-no-wild = Echt aantal { $face } (zonder jokers): { $count }. Bod was { $quantity }.

ld-liar-bidder-loses = { $bidder } heeft overdreven — verliest een dobbelsteen.
ld-liar-caller-loses = Het bod was eerlijk — { $caller } verliest een dobbelsteen.
ld-spot-on-correct = Spot on! { $caller } had het precies goed — alle anderen verliezen een dobbelsteen.
ld-spot-on-wrong = Niet spot on. { $caller } verliest twee dobbelstenen.

ld-lost-die = { $who ->
    [you] Je verliest een dobbelsteen. Je hebt nu { $remaining } { $remaining ->
        [one] dobbelsteen
        *[other] dobbelstenen
    }.
    *[player] { $player } verliest een dobbelsteen. Heeft nu { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Je verliest { $count } dobbelstenen. Je hebt nu { $remaining } { $remaining ->
        [one] dobbelsteen
        *[other] dobbelstenen
    }.
    *[player] { $player } verliest { $count } dobbelstenen. Heeft nu { $remaining }.
}
ld-eliminated = { $player } is door zijn dobbelstenen heen en uitgeschakeld! Nog { $remaining } { $remaining ->
    [one] speler
    *[other] spelers
} over.
ld-winner = { $player } is de laatste met dobbelstenen — wint!

ld-status-round = Ronde { $round }.
ld-status-your-dice = Jouw dobbelstenen: { $dice }.
ld-status-your-counts = Jouw aantallen: { $counts }.
ld-status-no-dice = Je hebt geen dobbelstenen — je bent uitgeschakeld.
ld-status-current-bid = Huidig bod: { $quantity } { $face }.
ld-status-no-bid = Nog geen bod deze ronde.
ld-status-table-total = Totaal dobbelstenen op tafel: { $total }.
ld-status-detailed-header = Detailstatus — { $count } spelers over.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] dobbelsteen
    *[other] dobbelstenen
}.
ld-status-detailed-out = { $player }: uitgeschakeld.
ld-status-detailed-self-suffix = {" "}(jij)

ld-face-1 = enen
ld-face-2 = tweeën
ld-face-3 = drieën
ld-face-4 = vieren
ld-face-5 = vijven
ld-face-6 = zessen

ld-action-not-your-turn = Het is niet jouw beurt.
ld-action-not-playing = De partij is niet bezig.
ld-action-no-bid-to-call = Er is nog geen bod om aan te vechten.
ld-action-eliminated = Je bent uitgeschakeld.
