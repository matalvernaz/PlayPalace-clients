# ninetynine.ftl for locale cs. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Názvy her
game-name-ninetynine = Devadesát devět
# Kolo
ninetynine-round = Kolo { $round }.
# Hraní karet
ninetynine-you-play = Hrajete { $card }. Počet je nyní { $count }.
ninetynine-player-plays = { $player } hraje { $card }. Počet je nyní { $count }.
# Otočení směru
ninetynine-direction-reverses = Směr hry se obrací!
# Přeskočení
ninetynine-player-skipped = { $player } je přeskočen.
# Ztráta tokenů
ninetynine-you-lose-tokens =
    Ztrácíte { $amount } { $amount ->
        [one] token
        [few] tokeny
        [many] tokenu
       *[other] tokenů
    }.
ninetynine-player-loses-tokens =
    { $player } ztrácí { $amount } { $amount ->
        [one] token
        [few] tokeny
        [many] tokenu
       *[other] tokenů
    }.
# Vyřazení
ninetynine-player-eliminated = { $player } byl vyřazen!
# Konec hry
ninetynine-player-wins = { $player } vyhrává hru!
# Lízání karet
ninetynine-you-draw = Líznete { $card }.
ninetynine-player-draws = { $player } lízne kartu.
# Žádné platné karty
ninetynine-no-valid-cards = { $player } nemá žádné karty, které by nepřekročily 99!
# Stav - pro klávesu C
ninetynine-current-count = Počet je { $count }.
# Volba esa
ninetynine-ace-choice = Hrát eso jako +1 nebo +11?
ninetynine-ace-add-eleven = Přidat 11
ninetynine-ace-add-one = Přidat 1
# Volba desítky
ninetynine-ten-choice = Hrát 10 jako +10 nebo -10?
ninetynine-ten-add = Přidat 10
ninetynine-ten-subtract = Odečíst 10
# Manuální líznutí
ninetynine-draw-card = Líznout kartu
ninetynine-draw-prompt = Stiskněte mezerník nebo D pro líznutí karty.
# Možnosti
ninetynine-set-tokens = Počáteční tokeny: { $tokens }
ninetynine-enter-tokens = Zadejte počet počátečních tokenů:
ninetynine-option-changed-tokens = Počáteční tokeny nastaveny na { $tokens }.
ninetynine-set-rules = Varianta pravidel: { $rules }
ninetynine-select-rules = Vyberte variantu pravidel
ninetynine-option-changed-rules = Varianta pravidel nastavena na { $rules }.
ninetynine-set-hand-size = Velikost ruky: { $size }
ninetynine-enter-hand-size = Zadejte velikost ruky:
ninetynine-option-changed-hand-size = Velikost ruky nastavena na { $size }.
ninetynine-set-autodraw = Automatické lízání: { $enabled }
ninetynine-option-changed-autodraw = Automatické lízání nastaveno na { $enabled }.
# Důvody zakázaných akcí
ninetynine-choose-first = Musíte nejprve udělat volbu.
