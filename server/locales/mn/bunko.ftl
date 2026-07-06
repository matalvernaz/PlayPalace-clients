game-name-bunko = Bunko

bunko-roll = Roll the dice
bunko-check-status = Check status
bunko-check-last-roll = Check latest roll

bunko-game-start = Bunko begins. Players: { $players }.
bunko-round-start = Round { $round } of { $total_rounds }. The target number for this round is { $target }.
bunko-round-start-brief = Round { $round }/{ $total_rounds }. Target { $target }.
bunko-you-win-round = You win round { $round } with { $score } points against target { $target }.
bunko-player-wins-round = { $player } wins round { $round } with { $score } points against target { $target }.
bunko-you-win-round-brief = You win R{ $round }: { $score }.
bunko-player-wins-round-brief = { $player } wins R{ $round }: { $score }.

bunko-you-roll-match = You roll { $dice } and score { $points } { $points ->
    [one] point
   *[other] points
} toward target { $target }. Round total: { $round_total }. Overall score: { $total }.
bunko-player-rolls-match = { $player } rolls { $dice } and scores { $points } { $points ->
    [one] point
   *[other] points
} toward target { $target }. Round total: { $round_total }. Overall score: { $total }.
bunko-you-roll-match-brief = You: { $dice }, +{ $points }. Round { $round_total }; total { $total }.
bunko-player-rolls-match-brief = { $player }: { $dice }, +{ $points }. Round { $round_total }; total { $total }.

bunko-you-roll-mini_bunko = You roll { $dice }, score a mini Bunko because all dice match each other but not target { $target }, and gain { $points } points. Round total: { $round_total }. Overall score: { $total }.
bunko-player-rolls-mini_bunko = { $player } rolls { $dice }, scores a mini Bunko because all dice match each other but not target { $target }, and gains { $points } points. Round total: { $round_total }. Overall score: { $total }.
bunko-you-roll-mini_bunko-brief = You: mini Bunko { $dice }, +{ $points }. Round { $round_total }; total { $total }.
bunko-player-rolls-mini_bunko-brief = { $player }: mini Bunko { $dice }, +{ $points }. Round { $round_total }; total { $total }.

bunko-you-roll-bunko = You roll { $dice } and score a Bunko: three target { $target }s for { $points } points. Round total: { $round_total }. Overall score: { $total }.
bunko-player-rolls-bunko = { $player } rolls { $dice } and scores a Bunko: three target { $target }s for { $points } points. Round total: { $round_total }. Overall score: { $total }.
bunko-you-roll-bunko-brief = You: Bunko { $dice }, +{ $points }. Round { $round_total }; total { $total }.
bunko-player-rolls-bunko-brief = { $player }: Bunko { $dice }, +{ $points }. Round { $round_total }; total { $total }.

bunko-you-roll-no_score = You roll { $dice } and score nothing because none of the dice match target { $target } and there is no mini Bunko. Your turn passes.
bunko-player-rolls-no_score = { $player } rolls { $dice } and scores nothing because none of the dice match target { $target } and there is no mini Bunko. The turn passes.
bunko-you-roll-no_score-brief = You: { $dice }, 0. Pass.
bunko-player-rolls-no_score-brief = { $player }: { $dice }, 0. Pass.

bunko-last-roll-none = No roll has been made yet this round.
bunko-last-roll-match = { $player } last rolled { $dice } and scored { $points } { $points ->
    [one] point
   *[other] points
} toward target { $target }.
bunko-last-roll-match-you = You last rolled { $dice } and scored { $points } { $points ->
    [one] point
   *[other] points
} toward target { $target }.
bunko-last-roll-mini_bunko = { $player } last rolled { $dice } for a mini Bunko, scoring { $points } points because the dice matched each other but not target { $target }.
bunko-last-roll-mini_bunko-you = You last rolled { $dice } for a mini Bunko, scoring { $points } points because the dice matched each other but not target { $target }.
bunko-last-roll-bunko = { $player } last rolled { $dice } for a Bunko: three target { $target }s, worth { $points } points.
bunko-last-roll-bunko-you = You last rolled { $dice } for a Bunko: three target { $target }s, worth { $points } points.
bunko-last-roll-no_score = { $player } last rolled { $dice } and scored nothing against target { $target }.
bunko-last-roll-no_score-you = You last rolled { $dice } and scored nothing against target { $target }.

bunko-status-round = Round { $round } of { $total_rounds }. Target number: { $target }.
bunko-status-turn = Current player: { $player }.
bunko-status-leader = Leader: { $player } with { $rounds } { $rounds ->
    [one] round win
   *[other] round wins
} and { $total } overall points.

bunko-standings-header = Standings. Winner decided by { $mode }.
bunko-score-line = { $rank }. { $player }: { $rounds } { $rounds ->
    [one] round win
   *[other] round wins
}, { $total } overall points, { $current } this round, { $bunkos } { $bunkos ->
    [one] Bunko
   *[other] Bunkos
}, { $mini_bunkos } { $mini_bunkos ->
    [one] mini Bunko
   *[other] mini Bunkos
}

bunko-roll-already-resolving = Your dice are still rolling. Wait for the result before rolling again.
bunko-error-round-count-invalid = Bunko requires between { $min } and { $max } rounds. The current setting is { $count }.
bunko-error-winning-mode-invalid = Bunko does not support the winning mode "{ $mode }". Choose round wins or total score.

bunko-set-round-count = Rounds: { $count }
bunko-enter-round-count = Enter the number of rounds:
bunko-option-changed-round-count = Number of rounds changed to { $count }.
bunko-desc-round-count = How many Bunko rounds are played before the winner is decided (default 6, range 1-12).

bunko-set-winning-mode = Winning mode: { $mode }
bunko-select-winning-mode = Select the winning mode:
bunko-option-changed-winning-mode = Winning mode changed to { $mode }.
bunko-desc-winning-mode = Chooses whether Bunko winners are ranked by rounds won or by total score.
bunko-winning-mode-round-wins = round wins
bunko-winning-mode-total-score = total score
