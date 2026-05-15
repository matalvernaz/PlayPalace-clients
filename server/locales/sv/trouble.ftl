# Trouble — sv
# AI-translated, native review pending — corrections welcome.
game-name-trouble = Trouble

trouble-rules =
    Trouble är ett racingspel ur Parcheesi-familjen.
    Varje spelare börjar med pjäser i sitt Hus-område.
    På din tur poppar du tärningen och flyttar en av dina pjäser.
    Som standard måste du slå 6 för att släppa ut en pjäs från Huset på banan.
    Som standard ger en 6 också en extra tur.
    Pjäserna rör sig medurs på den gemensamma banan mot målområdet.
    Att landa på en motståndares pjäs skickar tillbaka den till deras Hus, om inte rutan är skyddad.
    När alla dina pjäser når mål vinner du.
    I lagläge vinner ditt lag när alla lagkamrater är i mål.
    Använd 1-6 för att välja pjäs, R för att slå.
    Tryck E när som helst för att höra fullständigt brädstatus.

trouble-action-roll = Poppa tärningen
trouble-action-move-token = Flytta pjäs { $token }
trouble-action-check-board = Kolla brädet

trouble-token-label-home = Pjäs { $token }: i Huset
trouble-token-label-track = Pjäs { $token }: banruta { $position }
trouble-token-label-finish-lane = Pjäs { $token }: målgång { $position } av { $total }
trouble-token-label-finished = Pjäs { $token }: i mål

trouble-rolled = { $player } slog { $roll }.
trouble-leave-home = { $player } släpper ut pjäs { $token } på banan.
trouble-advance-track = { $player } flyttar pjäs { $token } till banruta { $position }.
trouble-enter-finish-lane = { $player } för pjäs { $token } in i målgången.
trouble-advance-finish-lane =
    { $player } avancerar pjäs { $token } till målgångsruta { $position } av { $total }.
trouble-token-finished = { $player }s pjäs { $token } når mål.
trouble-bump =
    { $player }s pjäs { $token } skickar { $opponent }s pjäs { $opp_token } tillbaka hem.
trouble-no-legal-move = { $player } har inget lagligt drag. Turen går vidare.
trouble-extra-turn = { $player } får extra tur för 6:an.

trouble-winner = { $player } vinner! Alla pjäser i mål.
trouble-team-winner = Lag { $team } vinner! Alla lagkamrater är i mål.
trouble-final-standing = { $player }: { $finished } av { $total } pjäser i mål.

trouble-turn-summary =
    Du har { $own_home } i Huset, { $own_track } på banan, { $own_finished } i mål.
    Motståndare: { $opponents }.
trouble-opponent-summary = { $name }: { $home } hus, { $track } bana, { $finished } mål

trouble-board-status =
    Dina pjäser: { $own_tokens }.
    Motståndarpjäser: { $opp_tokens }.

trouble-reason-not-rolled = Poppa tärningen först.
trouble-reason-already-rolled = Du har redan poppat. Välj en pjäs att flytta.
trouble-reason-no-legal-moves = Inga lagliga drag för det här kastet.
trouble-reason-token-home-needs-six = Den här pjäsen är i Huset. Du behöver 6 för att släppa ut den.
trouble-reason-token-home-needs-any = Den här pjäsen är i Huset. Vilket kast som helst släpper ut den.
trouble-reason-token-home-no-qualifying-roll =
    Den här pjäsen är i Huset och ditt kast räcker inte för att släppa ut den.
trouble-reason-token-finished = Den här pjäsen är redan i mål.
trouble-reason-overshoot-wastes = Den här pjäsen kan inte flyttas { $roll } rutor utan att passera målet.
trouble-reason-blocked = Det här draget är blockerat.

trouble-option-track-size = Banlängd: { $track_size } rutor
trouble-option-select-track-size = Välj antal banrutor.
trouble-option-changed-track-size = Bana satt till { $track_size } rutor.
trouble-option-desc-track-size = Antal rutor på den gemensamma banan.

trouble-option-tokens-per-player = Pjäser per spelare: { $tokens }
trouble-option-enter-tokens-per-player = Ange pjäser per spelare (2-6):
trouble-option-changed-tokens-per-player = Pjäser per spelare satt till { $tokens }.
trouble-option-desc-tokens-per-player = Antal pjäser varje spelare för i mål.

trouble-option-extra-turn-on-six = Extra tur på 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Extra tur på 6 { $enabled ->
    [on] aktiverad.
    [off] inaktiverad.
   *[other] uppdaterad.
}
trouble-option-desc-extra-turn-on-six =
    På: en 6 ger en extra tur (klassisk Hasbro-regel).

trouble-option-six-to-leave-home = Kräver 6 för att lämna Huset: { $enabled }
trouble-option-changed-six-to-leave-home = Sexa för att lämna Huset { $enabled ->
    [on] aktiverad.
    [off] inaktiverad.
   *[other] uppdaterad.
}
trouble-option-desc-six-to-leave-home =
    På: spelaren måste slå 6 för att släppa ut en pjäs. Av: vilket kast som helst släpper ut.

trouble-option-safe-spaces = Säkra rutor: { $mode }
trouble-option-select-safe-spaces = Välj säkerläge.
trouble-option-changed-safe-spaces = Säkra rutor satt till { $mode }.
trouble-option-desc-safe-spaces = Bestäm om pjäser kan skyddas från krockar.

trouble-safe-mode-none = Inga
trouble-safe-mode-home-stretch = Bara målgången
trouble-safe-mode-every-seventh = Var 7:e ruta

trouble-option-finish-behavior = Mål: { $mode }
trouble-option-select-finish-behavior = Välj målbeteende.
trouble-option-changed-finish-behavior = Målbeteende satt till { $mode }.
trouble-option-desc-finish-behavior = Hur ett kast som passerar målet hanteras.

trouble-finish-mode-exact = Exakt kast krävs
trouble-finish-mode-bounce = Översträckning studsar
trouble-finish-mode-allow = Översträckning tillåts

trouble-option-bot-difficulty = Bot-svårighet: { $level }
trouble-option-select-bot-difficulty = Välj bot-svårighet.
trouble-option-changed-bot-difficulty = Bot-svårighet satt till { $level }.
trouble-option-desc-bot-difficulty = Styrkan hos de inbyggda botarna.

trouble-bot-difficulty-naive = Naiv
trouble-bot-difficulty-greedy = Girig

trouble-option-preset = Förinställning: { $preset }
trouble-option-select-preset = Välj variant. Värden kan sedan justera regler.
trouble-option-changed-preset = Förinställning tillämpad: { $preset }.
trouble-option-desc-preset = Förbuntade alternativsamlingar för vanliga varianter.

trouble-preset-classic = Klassisk Hasbro
trouble-preset-fast = Snabb
trouble-preset-brutal = Brutal
trouble-preset-custom = Anpassad
