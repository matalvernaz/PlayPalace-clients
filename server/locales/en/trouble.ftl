# Trouble game messages
# Note: Common messages like round-start, turn-start, team-mode are in games.ftl

# ==========================================================================
# Game info
# ==========================================================================
game-name-trouble = Trouble

# ==========================================================================
# Rules (displayed in the help menu — each line becomes one navigable item)
# ==========================================================================
trouble-rules =
    Trouble is a Parcheesi-family race game.
    Each player starts with their tokens in their Home area.
    On your turn, pop the die and move one of your tokens.
    By default you must roll a 6 to release a token from Home into the track.
    By default, rolling a 6 also grants you an extra turn.
    Tokens move clockwise around the shared track toward the finish area.
    Landing on an opponent's token sends it back to their Home, unless that space is protected.
    When all of your tokens have reached the finish, you win.
    In team mode, your team wins when all teammates have finished.
    Use keys 1 through 6 to pick a token to move, or press R to roll.
    Press E to hear the full board state at any time.

# ==========================================================================
# Actions and menu labels
# ==========================================================================
trouble-action-roll = Pop the die
trouble-action-move-token = Move token { $token }
trouble-action-check-board = Check board

# Per-token labels, rendered live from state. These show next to each numbered
# action so a blind player can flick through their tokens and hear where each
# one is without having to pop the die.
trouble-token-label-home = Token { $token }: in Home
trouble-token-label-track = Token { $token }: track space { $position }
trouble-token-label-finish-lane = Token { $token }: finish lane { $position } of { $total }
trouble-token-label-finished = Token { $token }: finished

# ==========================================================================
# Turn events (broadcast to the table buffer)
# ==========================================================================
trouble-rolled = { $player } popped a { $roll }.
trouble-leave-home = { $player } releases token { $token } onto the track.
trouble-advance-track = { $player } moves token { $token } to track space { $position }.
trouble-enter-finish-lane = { $player } moves token { $token } into the finish lane.
trouble-advance-finish-lane =
    { $player } advances token { $token } to finish-lane space { $position } of { $total }.
trouble-token-finished = { $player }'s token { $token } reaches the finish.
trouble-bump =
    { $player }'s token { $token } bumps { $opponent }'s token { $opp_token } back to Home.
trouble-no-legal-move = { $player } has no legal move. Turn passes.
trouble-extra-turn = { $player } gets another turn for rolling a 6.

# ==========================================================================
# End of game
# ==========================================================================
trouble-winner = { $player } wins! All tokens have reached the finish.
trouble-team-winner = Team { $team } wins! All teammates have finished.
trouble-final-standing = { $player }: { $finished } of { $total } tokens finished.

# ==========================================================================
# Turn-start board summary (personal, per-perspective)
# Short summary so blind players always hear the state as their turn begins.
# ==========================================================================
trouble-turn-summary =
    You have { $own_home } in Home, { $own_track } on the track, { $own_finished } finished.
    Opponents: { $opponents }.
trouble-opponent-summary = { $name }: { $home } home, { $track } track, { $finished } finished

# Full board (check-board action output)
trouble-board-status =
    Your tokens: { $own_tokens }.
    Opponent tokens: { $opp_tokens }.

# ==========================================================================
# Disabled-action reasons (spoken when a locked action is chosen)
# ==========================================================================
trouble-reason-not-rolled = Pop the die first.
trouble-reason-already-rolled = You have already popped. Choose a token to move.
trouble-reason-no-legal-moves = No legal moves for this roll.
trouble-reason-token-home-needs-six = This token is in Home. You need to roll a 6 to release it.
trouble-reason-token-home-needs-any = This token is in Home. Roll any value to release it.
trouble-reason-token-home-no-qualifying-roll =
    This token is in Home and your roll does not qualify to release it.
trouble-reason-token-finished = This token has already finished.
trouble-reason-overshoot-wastes = This token cannot move { $roll } spaces without overshooting the finish.
trouble-reason-blocked = This move is blocked.

# ==========================================================================
# Options — track size
# ==========================================================================
trouble-option-track-size = Track size: { $track_size } spaces
trouble-option-select-track-size = Select the number of track spaces.
trouble-option-changed-track-size = Track size set to { $track_size } spaces.
trouble-option-desc-track-size = Number of spaces around the shared track.

# ==========================================================================
# Options — tokens per player
# ==========================================================================
trouble-option-tokens-per-player = Tokens per player: { $tokens }
trouble-option-enter-tokens-per-player = Enter tokens per player (2 to 6):
trouble-option-changed-tokens-per-player = Tokens per player set to { $tokens }.
trouble-option-desc-tokens-per-player = Number of tokens each player races to the finish.

# ==========================================================================
# Options — extra turn on 6
# ==========================================================================
trouble-option-extra-turn-on-six = Extra turn on rolling a 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Extra turn on 6 { $enabled ->
    [on] enabled.
    [off] disabled.
   *[other] updated.
}
trouble-option-desc-extra-turn-on-six =
    When on, rolling a 6 grants an extra turn (classic Hasbro rule).

# ==========================================================================
# Options — six to leave home
# ==========================================================================
trouble-option-six-to-leave-home = Require 6 to leave Home: { $enabled }
trouble-option-changed-six-to-leave-home = Six-to-leave-home { $enabled ->
    [on] enabled.
    [off] disabled.
   *[other] updated.
}
trouble-option-desc-six-to-leave-home =
    When on, a player must roll 6 to release a token from Home. When off, any roll releases.

# ==========================================================================
# Options — safe spaces
# ==========================================================================
trouble-option-safe-spaces = Safe spaces: { $mode }
trouble-option-select-safe-spaces = Select safe-space mode.
trouble-option-changed-safe-spaces = Safe spaces set to { $mode }.
trouble-option-desc-safe-spaces = Choose whether tokens can be protected from bumps.

trouble-safe-mode-none = None
trouble-safe-mode-home-stretch = Home stretch only
trouble-safe-mode-every-seventh = Every 7th space

# ==========================================================================
# Options — finish behavior
# ==========================================================================
trouble-option-finish-behavior = Finish: { $mode }
trouble-option-select-finish-behavior = Select finish behavior.
trouble-option-changed-finish-behavior = Finish behavior set to { $mode }.
trouble-option-desc-finish-behavior = How a roll that overshoots the finish is handled.

trouble-finish-mode-exact = Exact roll required
trouble-finish-mode-bounce = Overshoot bounces back
trouble-finish-mode-allow = Overshoot allowed

# ==========================================================================
# Options — bot difficulty
# ==========================================================================
trouble-option-bot-difficulty = Bot difficulty: { $level }
trouble-option-select-bot-difficulty = Select bot difficulty.
trouble-option-changed-bot-difficulty = Bot difficulty set to { $level }.
trouble-option-desc-bot-difficulty = Strength of the built-in bots.

trouble-bot-difficulty-naive = Naive
trouble-bot-difficulty-greedy = Greedy

# ==========================================================================
# Options — preset
# ==========================================================================
trouble-option-preset = Preset: { $preset }
trouble-option-select-preset = Choose a variant preset. The host can override individual rules afterward.
trouble-option-changed-preset = Preset applied: { $preset }.
trouble-option-desc-preset = Pre-bundled option sets for common variants.

trouble-preset-classic = Classic Hasbro
trouble-preset-fast = Fast
trouble-preset-brutal = Brutal
trouble-preset-custom = Custom
