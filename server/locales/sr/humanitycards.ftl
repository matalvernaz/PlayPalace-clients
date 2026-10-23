# Humanity Cards - English localization

# Options
hc-set-winning-score = Rezultat za pobedu: { $score }
hc-enter-winning-score = Upišite rezultat za pobedu:
hc-option-changed-winning-score = Rezultat za pobedu podešen na { $score }.
hc-desc-winning-score = The number of winning cards a player needs to collect to win the match (default 7, range 3-20).
hc-set-hand-size = Veličina ruke: { $count }
hc-enter-hand-size = Upišite veličinu ruke:
hc-option-changed-hand-size = Veličina ruke podešena na { $count }.
hc-desc-hand-size = How many answer cards each player holds after each refill. Larger hands give more choices but make rounds take longer (default 10, range 5-15).
hc-set-card-language = Card language: { $language }
hc-select-card-language = Select the card language
hc-option-changed-card-language = Card language set to { $language }.
hc-desc-card-language = Sets the language of every prompt and answer card in the match. This is independent of each player's interface language (default English; choices English, Spanish, and Brazilian Portuguese).
hc-card-language-pt-br = Brazilian Portuguese
hc-card-blank = blank
hc-card-same-again = same card again
hc-set-card-packs = Paketi karata ({ $count } od { $total } izabrano)
hc-option-changed-card-packs = Izbor paketa karata promenjen.
hc-desc-card-packs = Choose which English answer and prompt packs are shuffled into the game. Exact duplicate cards from overlapping packs are included only once. At least one pack must stay selected.
hc-pack-group-current = Current US main deck
hc-pack-group-main-decks = Main deck editions
hc-pack-group-official-add-ons = Official expansions and packs
hc-pack-group-family = Family Edition
hc-pack-group-community = Community packs
hc-pack-group-all = All packs
hc-set-czar-selection = Izbor karata: { $mode }
hc-select-czar-selection = Izaberite režim izbora karata
hc-option-changed-czar-selection = Izbor karata podešen na { $mode }.
hc-desc-czar-selection = Controls who judges each round: rotating in seating order, randomly chosen, or the most recent round winner.
hc-set-num-judges = Broj sudija: { $count }
hc-enter-num-judges = Upišite broj sudija:
hc-option-changed-num-judges = Broj sudija podešen na { $count }.
hc-desc-num-judges = How many Card Czars judge each round. The count must be lower than the player count so at least one non-judge can submit; with multiple judges, any judge can pick the winner (default 1, range 1-3).
hc-czar-rotating = Rotirajući
hc-czar-random = Nasumičan
hc-czar-winner = Poslednji pobednik
# Game flow
hc-game-starting = Mešanje špilova...
hc-dealing-cards = Deljenje { $count } karata svakom igraču.
hc-round-start = Runda { $round }.
# Judge announcement
hc-judge-is =
    { $judges } { $count ->
        [1] is the Card Czar
       *[other] are the Card Czars
    }.
hc-you-are-judge = Vi ste sudija u ovoj rundi.
hc-you-and-others-are-judges = You and { $judges } are the Card Czars this round.
# Black card
hc-black-card = Rečenica je: { $text }
hc-black-card-draw =
    Draw { $count } extra { $count ->
        [one] card
       *[other] cards
    } first.
hc-black-card-pick = Izaberite { $count }.
hc-view-black-card = Pogledaj kartu pitanja
hc-no-question-card = There is no active question card right now.
# Submission phase
hc-select-cards =
    Izaberite { $count } { $count ->
        [one] kartu
        [few] karte
       *[other] karata
    } iz vaše ruke.
hc-card-selected = { $text }, izabrano
hc-card-selected-position = { $text }, selected as answer { $position }
hc-card-not-selected = { $text }
hc-submit-cards = Pošalji ({ $selected } od { $required } izabrano)
hc-submission-progress = { $submitted } od { $total } igrača je stavilo svoje karte.
hc-already-submitted = Već ste stavili vaše karte.
hc-you-submitted = You submitted your cards.
hc-player-submitted = { $player } submitted { GENDER_TERM($player_gender, "possessive-determiner") } cards.
hc-judge-cannot-submit = You are the Card Czar this round, so you cannot submit an answer.
hc-not-submission-phase = You can only select and submit white cards during the submission phase.
hc-card-not-in-hand = That card slot is not in your hand.
hc-judge-has-no-submission = The Card Czar does not have a submission to preview this round.
hc-no-submission-active = There is no active submission to preview right now.
hc-wrong-card-count =
    Morate da izaberete tačno { $count } { $count ->
        [one] kartu
        [few] karte
       *[other] karata
    }.
hc-selection-full =
    You already selected { $count } { $count ->
        [one] card
       *[other] cards
    }. Deselect one before choosing another.
# Judging phase
hc-judging-start = Sve karte su stavljene! vreme je da se ocene.
hc-choose-best-card = Choose the best card
hc-choose-best-card-for = Choose the best card that matches: { $prompt }
hc-card-number = Card { $number }
hc-submission-number = Submission { $number }
hc-only-judges-pick = Only the Card Czar can choose the winning submission.
hc-not-judging-phase = You can only choose a winning submission during the judging phase.
hc-submission-not-available = That submission is no longer available.
# Results
hc-you-win-round = You win the round! Your score is now { $score }.
hc-player-wins-round = { $player } wins the round! Score: { $score }.
hc-score-line =
    { $player }: { $score } { $score ->
        [one] poen
       *[other] poena
    }
hc-final-score-line =
    { $rank }. { $player }: { $score } { $score ->
        [one] point
       *[other] points
    }
hc-all-submissions = Drugi predlozi:
hc-your-winning-answer = Your winning answer: { $text }
hc-winning-answer-player = { $player }'s winning answer: { $text }
hc-your-other-submission = Your other submission: { $text }
hc-other-submission-player = { $player }: { $text }
# View
hc-preview-submission = Pogledaj svoj preglod
hc-view-submission = Pogledaj svoj predlog
hc-preview-submission-text = Pregled: { $text }
hc-your-submission = Vaš predlog: { $text }
hc-select-cards-first = Prvo izaberite bar jednu kartu.
hc-review-hand = Review your hand
hc-hand-empty = Your hand is empty.
hc-hand-card = { $number }. { $text }
hc-hand-card-selected = { $number }. { $text }, selected as answer { $position }
hc-review-answers = Review the answers
hc-answer-line = Answer { $number }: { $text }
hc-no-answers-to-review = There are no answers to review right now.
# Win
hc-game-winner = { $player } pobeđuje sa { $score } poena!
hc-you-win = Pobeđujete sa { $score } poena!
# Deck management
hc-deck-reshuffled = Odbačene bele karte su promešane nazad u špil.
hc-black-deck-reshuffled = Odbačene crne karte su promešane nazad u špil.
hc-not-enough-cards = Nema dovoljno karata. Pokušajte da omogućite više paketa.
hc-error-too-many-judges = { $judges } judges require at least { $required } players, but this table has { $players }. Lower the number of judges or add more players.
hc-error-no-valid-packs = No valid card packs are selected. Select at least one pack before starting.
hc-error-no-black-cards = The selected card packs do not contain any black prompt cards. Select another pack before starting.
hc-error-not-enough-white-cards = { $players } players with a hand size of { $hand_size } need at least { $needed } white cards, but the selected packs only provide { $available }. Enable more packs or lower the hand size.
hc-error-pick-exceeds-hand-size = The selected packs include a prompt that requires { $pick } answers, but the hand size is only { $hand_size }. Increase the hand size or choose different packs.
# Hand management
hc-toggle-card-keybind = Toggle card { $number }
hc-submit-cards-keybind = Submit cards
# Whose turn / whose judge
hc-whose-judge = Ko je sudija
hc-waiting-for = Čeka se da { $names } odigraju.
hc-all-submitted-waiting-judge = Svi igrači su poslali svoje predloge. Čeka se da { $judge } presudi.
