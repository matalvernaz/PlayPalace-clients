# The Game of Life — localization
#
# Design notes:
# - Game key: life. Folder: server/games/life/. Class: GameOfLifeGame.
# - All player-visible strings go through Fluent. No hardcoded English in game code.
# - "You vs. player" is handled with the $who select expression universally:
#     $who = "you"   -> message to the acting player
#     $who = "player" -> message to everyone else (player name in $player)
#   See the broadcast_personal_l pattern in existing games.
# - Money values are passed raw (integers); Fluent interpolates them. Game
#   code is responsible for formatting with commas via python-side helpers
#   before interpolation when needed — we pass pre-formatted strings in
#   $money for cash amounts to keep this locale file flexible for translators.

# ==========================================================================
# Game metadata
# ==========================================================================
game-name-life = The Game of Life
game-life-desc = Spin the wheel, pick a career, buy a house, start a family, and race your way to retirement. Highest total at the end wins.

# ==========================================================================
# Lobby options — labels, descriptions, prompts, change announcements.
# Every option exposes a `*-desc-*` key that the client reads when the
# user focuses an option (space key on desktop, similar on iOS).
# ==========================================================================

# Track length (MenuOption: short / standard / long)
life-set-track-length = Track length: { $length }
life-desc-track-length = How many spaces the board has. Short is 50 spaces, standard is 80, and long is the classic 145-space route.
life-prompt-track-length = Select track length
life-option-changed-track-length = Track length set to { $length }.
life-length-short = short
life-length-standard = standard
life-length-long = long

# College path (BoolOption)
life-toggle-college-path = College path: { $enabled }
life-desc-college-path = When on, each player chooses College (two $20,000 bank-loan notes and access to degree careers) or Career (one random non-degree Career Card and one random Salary Card). When off, everyone receives random cards with no tuition debt; this is a house-rule variant.
life-option-changed-college-path = College path { $enabled }.

# Marriage and children (BoolOption)
life-toggle-family = Marriage and children: { $enabled }
life-desc-family = When on, Get Married, Baby, and Twins spaces add people pegs and award LIFE tiles. Turning this off is a house-rule variant.
life-option-changed-family = Marriage and children { $enabled }.

# Life tiles (MenuOption: hidden / revealed / off)
life-set-life-tiles = Life tiles: { $mode }
life-desc-life-tiles = Life tiles are bonus rewards worth random amounts of cash. In hidden mode (classic), you earn tiles face-down and do not learn their values until the end of the game. In revealed mode, you see each tile's value when you earn it. In off mode, Life tiles are removed entirely.
life-prompt-life-tiles = Select Life tile mode
life-option-changed-life-tiles = Life tiles set to { $mode }.
life-tiles-hidden = hidden
life-tiles-revealed = revealed
life-tiles-off = off

# Insurance (MenuOption: full / simplified / off)
life-set-insurance = Insurance: { $mode }
life-desc-insurance = In full mode (classic), automobile insurance costs $10,000 and homeowner's insurance costs the amount on your House Deed. Simplified and off are house-rule variants.
life-prompt-insurance = Select insurance mode
life-option-changed-insurance = Insurance set to { $mode }.
life-insurance-full = full
life-insurance-simplified = simplified
life-insurance-off = off

# Stock market (BoolOption)
life-toggle-stock-market = Stock market: { $enabled }
life-desc-stock-market = When on, you may buy one available Stock numbered 1 through 9 for $50,000 at the beginning of a turn. Collect $10,000 whenever any player spins your number. Stock Market Zooms and Slumps still apply. Turning this off is a house-rule variant.
life-option-changed-stock-market = Stock market { $enabled }.

# Retirement style (MenuOption: classic / safe / none)
life-set-retirement = Retirement style: { $mode }
life-desc-retirement = In classic mode, Countryside Acres gives one protected LIFE tile; Millionaire Estates leaves tiles exposed, but its richest retiree receives the four reserved LIFE tiles. Safe and none are house-rule variants.
life-prompt-retirement = Select retirement style
life-option-changed-retirement = Retirement style set to { $mode }.
life-retire-classic = classic
life-retire-safe = safe
life-retire-none = none

# Event layout (MenuOption: fixed / random)
life-set-event-layout = Event layout: { $mode }
life-desc-event-layout = In fixed mode, the same events appear at the same spaces every game, so you can learn the board. In random mode, events are shuffled onto event spaces at the start of each game, so every playthrough feels different.
life-prompt-event-layout = Select event layout
life-option-changed-event-layout = Event layout set to { $mode }.
life-layout-fixed = fixed
life-layout-random = random

# Starting cash (IntOption)
life-set-starting-cash = Starting cash: ${ $money }
life-desc-starting-cash = How much money each player starts with. Default is $10,000. Raising this makes loans easier to avoid; lowering it makes early events matter more.
life-prompt-starting-cash = Enter starting cash (0 to 100000)
life-option-changed-starting-cash = Starting cash set to ${ $money }.

# ==========================================================================
# Turn flow
# ==========================================================================
life-turn-start = { $player }'s turn. Space { $position } of { $total }.
life-turn-retirement = { $player }'s turn. They have reached retirement.
life-action-spin = Spin
life-action-spin-disabled-finished = You have already retired.

# Spinner animation and result
life-spinner-spinning = The spinner is spinning...
life-spin-result = { $who ->
    [you] You spun a { $value }.
    *[player] { $player } spun a { $value }.
}

# Movement
life-move = { $who ->
    [you] You moved to space { $position }.
    *[player] { $player } moved to space { $position }.
}
life-pass-payday = { $who ->
    [you] You passed Pay Day and collected ${ $money }.
    *[player] { $player } passed Pay Day and collected ${ $money }.
}

# ==========================================================================
# College / Career fork (start of game)
# ==========================================================================
life-path-prompt = Choose your starting path.
life-action-choose-college = Go to college
life-action-choose-career = Start a career
life-chose-college = { $who ->
    [you] You chose college. You take two $20,000 bank-loan notes for tuition. Spin now.
    *[player] { $player } chose college.
}
life-chose-career = { $who ->
    [you] You chose to start a career. You received one random non-degree Career Card and one random Salary Card. Spin now.
    *[player] { $player } chose career.
}
life-college-graduated = { $who ->
    [you] You graduated from college.
    *[player] { $player } graduated from college.
}

# Career draw (shown as a menu of cards; each card line is a menu item)
life-career-draw-prompt = Pick your career.
life-career-card-line = { $career }{ $degree ->
    [yes] , requires degree
    *[no] {""}
}
life-salary-card-line = Salary ${ $salary }, Taxes Due ${ $taxes }
life-career-chosen = { $who ->
    [you] Your Career Card is { $career }.
    *[player] { $player }'s Career Card is { $career }.
}
life-salary-chosen = { $who ->
    [you] Your Salary Card pays ${ $salary }; Taxes Due is ${ $taxes }.
    *[player] { $player }'s Salary Card pays ${ $salary }.
}

# ==========================================================================
# Pay Day and salary
# ==========================================================================
life-payday = { $who ->
    [you] Pay day! You earned your salary of ${ $money }.
    *[player] Pay day! { $player } earned their salary of ${ $money }.
}
life-payday-with-kids = { $who ->
    [you] Pay day! You earned ${ $money } (${ $salary } salary plus ${ $bonus } for { $kids ->
        [one] 1 child
        *[other] { $kids } children
    }).
    *[player] Pay day! { $player } earned ${ $money } (${ $salary } salary plus ${ $bonus } for { $kids ->
        [one] 1 child
        *[other] { $kids } children
    }).
}

# ==========================================================================
# Events — "Life happens" spaces.
# Each event uses the $who select pattern and includes the money effect.
# Pattern: life-event-<name> with [you] and [player] variants.
# ==========================================================================

# Financial gains
life-event-lottery = { $who ->
    [you] You win the lottery! Collect ${ $money }.
    *[player] { $player } wins the lottery and collects ${ $money }.
}
life-event-inheritance = { $who ->
    [you] A distant relative leaves you an inheritance. Collect ${ $money }.
    *[player] { $player } inherits ${ $money } from a distant relative.
}
life-event-found-money = { $who ->
    [you] You find ${ $money } in an old coat pocket.
    *[player] { $player } finds ${ $money } in an old coat pocket.
}
life-event-bestseller = { $who ->
    [you] You write a best-seller! Collect ${ $money }.
    *[player] { $player } writes a best-seller and collects ${ $money }.
}
life-event-garage-sale = { $who ->
    [you] You hold a garage sale and clear ${ $money }.
    *[player] { $player } holds a garage sale and clears ${ $money }.
}
life-event-uncle-visits = { $who ->
    [you] Your generous uncle visits and hands you ${ $money }.
    *[player] { $player }'s generous uncle hands them ${ $money }.
}
life-event-promotion = { $who ->
    [you] You get promoted! Collect ${ $money } in back pay.
    *[player] { $player } gets promoted and collects ${ $money } in back pay.
}
life-event-tax-refund = { $who ->
    [you] Tax refund! Collect ${ $money }.
    *[player] { $player } gets a tax refund of ${ $money }.
}

# Financial losses
life-event-taxes = { $who ->
    [you] Pay taxes. Lose ${ $money }.
    *[player] { $player } pays ${ $money } in taxes.
}
life-event-bought-boat = { $who ->
    [you] You buy a boat. Pay ${ $money }.
    *[player] { $player } buys a boat for ${ $money }.
}
life-event-vacation = { $who ->
    [you] You take an expensive vacation. Pay ${ $money }.
    *[player] { $player } takes an expensive vacation, paying ${ $money }.
}
life-event-broken-leg = { $who ->
    [you] You break your leg skiing. Pay ${ $money } in medical bills.
    *[player] { $player } breaks a leg skiing and pays ${ $money } in medical bills.
}
life-event-adopted-pet = { $who ->
    [you] You adopt a pet. Pay ${ $money } in vet bills.
    *[player] { $player } adopts a pet, paying ${ $money } in vet bills.
}
life-event-gambling-loss = { $who ->
    [you] You lose big at the casino. Pay ${ $money }.
    *[player] { $player } loses ${ $money } at the casino.
}

# Insurable events (mitigated if the right insurance is held)
life-event-flat-tire = { $who ->
    [you] Flat tire! Pay ${ $money }{ $insured ->
        [yes] {""}, but your auto insurance covers it.
        *[no] .
    }
    *[player] { $player } gets a flat tire{ $insured ->
        [yes] , covered by auto insurance.
        *[no] and pays ${ $money }.
    }
}
life-event-car-accident = { $who ->
    [you] Car accident! Pay ${ $money }{ $insured ->
        [yes] {""}, but your auto insurance covers it.
        *[no] .
    }
    *[player] { $player } is in a car accident{ $insured ->
        [yes] , covered by auto insurance.
        *[no] and pays ${ $money }.
    }
}
life-event-house-fire = { $who ->
    [you] House fire! Pay ${ $money }{ $insured ->
        [yes] {""}, but your fire insurance covers it.
        *[no] .
    }
    *[player] { $player }'s house catches fire{ $insured ->
        [yes] , covered by fire insurance.
        *[no] . They pay ${ $money }.
    }
}
life-event-tornado = { $who ->
    [you] A tornado damages your home! Pay ${ $money }{ $insured ->
        [yes] {""}, but your fire insurance covers it.
        *[no] .
    }
    *[player] A tornado damages { $player }'s home{ $insured ->
        [yes] , covered by fire insurance.
        *[no] . They pay ${ $money }.
    }
}
life-event-hospital = { $who ->
    [you] Hospital stay. Pay ${ $money }{ $insured ->
        [yes] {""}, but your life insurance covers it.
        *[no] .
    }
    *[player] { $player } has a hospital stay{ $insured ->
        [yes] , covered by life insurance.
        *[no] . They pay ${ $money }.
    }
}

# Life tile awards
life-event-nobel-prize = { $who ->
    [you] You win the Nobel Prize! Collect a Life tile.
    *[player] { $player } wins the Nobel Prize and earns a Life tile.
}
life-event-design-award = { $who ->
    [you] You win a design award. Collect a Life tile.
    *[player] { $player } wins a design award and earns a Life tile.
}
life-event-helped-elderly = { $who ->
    [you] You help an elderly neighbor. Collect a Life tile for your good deed.
    *[player] { $player } helps an elderly neighbor and earns a Life tile.
}
life-event-saved-ecosystem = { $who ->
    [you] You save a local ecosystem. Collect a Life tile.
    *[player] { $player } saves a local ecosystem and earns a Life tile.
}

# ==========================================================================
# Marriage and children
# ==========================================================================
life-event-get-married = { $who ->
    [you] You get married!
    *[player] { $player } gets married.
}
life-event-already-married = { $who ->
    [you] You are already married. The space has no effect.
    *[player] { $player } is already married; no effect.
}
life-event-baby-boy = { $who ->
    [you] It's a baby boy!
    *[player] { $player } has a baby boy.
}
life-event-baby-girl = { $who ->
    [you] It's a baby girl!
    *[player] { $player } has a baby girl.
}
life-event-twins = { $who ->
    [you] It's twins!
    *[player] { $player } has twins.
}
life-event-baby = { $who ->
    [you] You have a baby!
    *[player] { $player } has a baby.
}
life-event-baby-needs-marriage = { $who ->
    [you] You reach a Have a Baby space, but you must be married first. No effect.
    *[player] { $player } reaches a Have a Baby space but is not married; no effect.
}

# ==========================================================================
# Life tiles (earn + end-game reveal)
# ==========================================================================
life-tile-earned-hidden = { $who ->
    [you] You earned a Life tile. Its value is hidden until the end.
    *[player] { $player } earned a Life tile.
}
life-tile-earned-revealed = { $who ->
    [you] You earned a Life tile worth ${ $money }.
    *[player] { $player } earned a Life tile worth ${ $money }.
}
life-tile-steal-prompt = { $who ->
    [you] The LIFE-tile draw pile is empty. Choose a player and take one of their unprotected tiles.
    *[player] { $player } must take an unprotected LIFE tile from another player.
}
life-action-steal-tile = Take a LIFE tile from { $player }
life-tile-stolen = { $who ->
    [you] You took one LIFE tile from { $victim }.
    *[player] { $player } took one LIFE tile from { $victim }.
}
life-tile-reveal-header = Revealing Life tiles...
life-tile-reveal-line = { $player }'s tile: ${ $money }.
life-tile-reveal-total = { $player }'s Life tiles total: ${ $money }.

# ==========================================================================
# Insurance
# ==========================================================================
life-action-buy-fire = Buy homeowner's insurance (${ $money })
life-action-buy-auto = Buy auto insurance (${ $money })
life-action-buy-life = Buy life insurance (${ $money })
life-action-buy-insurance = Buy insurance (${ $money })
life-action-skip-insurance = Skip
life-insurance-offer = { $who ->
    [you] You reach an insurance space. Buy insurance?
    *[player] { $player } reaches an insurance space.
}
life-home-insurance-offer = { $who ->
    [you] You may buy homeowner's insurance now for the premium on your House Deed, or skip it and spin again.
    *[player] { $player } may buy homeowner's insurance.
}
life-bought-fire = { $who ->
    [you] You bought fire insurance for ${ $money }.
    *[player] { $player } bought fire insurance.
}
life-bought-auto = { $who ->
    [you] You bought auto insurance for ${ $money }.
    *[player] { $player } bought auto insurance.
}
life-bought-life = { $who ->
    [you] You bought life insurance for ${ $money }.
    *[player] { $player } bought life insurance.
}
life-bought-insurance = { $who ->
    [you] You bought a full insurance policy for ${ $money }.
    *[player] { $player } bought a full insurance policy.
}
life-skipped-insurance = { $who ->
    [you] You skipped the insurance offer.
    *[player] { $player } skipped the insurance offer.
}
life-insurance-unaffordable = You cannot afford ${ $money } in premiums right now.
life-insurance-already-held = You already hold that insurance.

# ==========================================================================
# Stock market
# ==========================================================================
life-action-buy-stock = Buy a stock number (${ $money })
life-action-sell-stock = Sell your stock
life-action-skip-stock = Skip
life-stock-offer = { $who ->
    [you] You reach a stock space. Buy a stock number?
    *[player] { $player } reaches a stock space.
}
life-stock-prompt = Pick an available stock number from 1 to 9.
life-stock-bought = { $who ->
    [you] You bought stock number { $number } for ${ $money }.
    *[player] { $player } bought stock number { $number }.
}
life-stock-already-held = You already own a stock number.
life-stock-skipped = { $who ->
    [you] You skipped buying a stock.
    *[player] { $player } skipped buying a stock.
}
life-stock-paid = { $who ->
    [you] Your stock number { $number } was spun! Collect ${ $money }.
    *[player] { $player }'s stock number { $number } was spun; they collect ${ $money }.
}
life-stock-zooms = { $who ->
    [you] Stock Market Zooms! Take Stock number { $number } free, even if you already own one.
    *[player] Stock Market Zooms gives { $player } free Stock number { $number }.
}
life-stock-slumps = { $who ->
    [you] Stock Market Slumps! Return Stock number { $number }.
    *[player] Stock Market Slumps makes { $player } return Stock number { $number }.
}
life-police-paid = { $who ->
    [you] { $spinner } spun 10. As Police Officer, you collect ${ $money } from them.
    *[player] { $player } collects ${ $money } from { $spinner } for spinning 10.
}
life-stock-sold = { $who ->
    [you] You sold your stock for ${ $money }.
    *[player] { $player } sold their stock for ${ $money }.
}

# ==========================================================================
# Risk It / Spin to Win
# ==========================================================================
life-action-risk-it = Risk it (${ $stake } stake)
life-action-skip-risk-it = Skip
life-risk-it-offer = { $who ->
    [you] Risk It space. Wager ${ $stake } for a chance to win ${ $prize } if you spin { $target } or higher?
    *[player] { $player } reaches a Risk It space.
}
life-risk-it-taken = { $who ->
    [you] You risk it. Stake ${ $stake }.
    *[player] { $player } risks it with a ${ $stake } stake.
}
life-risk-it-skipped = { $who ->
    [you] You skip the Risk It offer.
    *[player] { $player } skips the Risk It offer.
}
life-risk-it-won = { $who ->
    [you] You spun a { $value } and won ${ $prize }!
    *[player] { $player } spun a { $value } and won ${ $prize }.
}
life-risk-it-lost = { $who ->
    [you] You spun a { $value } and lost your ${ $stake } stake.
    *[player] { $player } spun a { $value } and lost their stake.
}

# ==========================================================================
# Lawsuit events (stock market option only)
# ==========================================================================
life-lawsuit-announce = Lawsuit! Everyone spins to determine who pays whom.
life-lawsuit-result = { $winner } wins the lawsuit; { $loser } pays { $winner } ${ $money }.

# ==========================================================================
# College loan
# ==========================================================================
life-loan-interest-due = { $who ->
    [you] Loan interest. You owe ${ $money } on your college loan.
    *[player] { $player } owes ${ $money } in loan interest.
}
life-action-take-loan = Take a $20,000 bank loan
life-action-pay-loan = Repay one bank loan (${ $money })
life-loan-taken = { $who ->
    [you] You borrowed ${ $money }. Outstanding principal: ${ $balance }.
    *[player] { $player } borrowed ${ $money } from the bank.
}
life-automatic-loan = { $who ->
    [you] You needed ${ $money } in bank loans to make the required payment. Outstanding principal: ${ $balance }.
    *[player] { $player } took ${ $money } in bank loans for a required payment.
}
life-loan-paid = { $who ->
    [you] You repaid one $20,000 bank loan for ${ $money }. Outstanding principal: ${ $remaining }.
    *[player] { $player } repaid one bank loan.
}
life-loan-partial = { $who ->
    [you] You paid ${ $money } toward your college loan. Balance: ${ $remaining }.
    *[player] { $player } paid ${ $money } toward their college loan.
}
life-loan-none = You have no outstanding college loan.
life-loan-cannot-afford = You cannot afford the payment.
life-retirement-loans-paid = { $who ->
    [you] At retirement you repaid all bank loans and interest: ${ $money }.
    *[player] { $player } repaid all bank loans at retirement.
}

# ==========================================================================
# Retirement
# ==========================================================================
life-retirement-reached = { $who ->
    [you] You reach the RETIRE space.
    *[player] { $player } reaches the RETIRE space.
}
life-retirement-prompt = Choose your retirement.
life-action-choose-estates = Millionaire Estates (tiles can be taken; richest Estates retiree gets 4 reserved tiles)
life-action-choose-acres = Countryside Acres (take 1 LIFE tile; all your tiles are protected)
life-chose-estates = { $who ->
    [you] You chose Millionaire Estates.
    *[player] { $player } chose Millionaire Estates.
}
life-chose-acres = { $who ->
    [you] You chose Countryside Acres.
    *[player] { $player } chose Countryside Acres.
}
life-acres-tile = { $who ->
    [you] You take one LIFE tile at Countryside Acres. Your LIFE tiles are now protected.
    *[player] { $player } takes one protected LIFE tile at Countryside Acres.
}
life-estates-tiles-awarded = { $player }, the richest Millionaire Estates retiree, receives { $count } reserved LIFE { $count ->
    [one] tile
    *[other] tiles
}.
life-acres-bonus = { $who ->
    [you] Countryside Acres bonus: you collect ${ $money }.
    *[player] { $player } collects a ${ $money } Countryside Acres bonus.
}
life-estates-spin-header = Millionaire Estates spin-off!
life-estates-spin = { $player } spun a { $value }.
life-estates-winner = { $player } had the highest spin and doubles their money! They now have ${ $money }.
life-estates-loser = { $player } lost ${ $money } at Millionaire Estates. Remaining: ${ $remaining }.
life-estates-tie = { $players } tied the highest spin; each doubles their money.

# Retirement for "none" mode
life-retirement-skipped = No retirement bonus in this game; totals are final.

# ==========================================================================
# End game
# ==========================================================================
life-end-header = All players have retired. Tallying final totals...
life-end-cash-line = { $player }: cash ${ $cash }, Life tiles ${ $tiles } ({ $count } { $count ->
    [one] tile
    *[other] tiles
}), total ${ $total }.
life-end-winner = { $player } wins with ${ $money }!
life-end-tie = Tie at ${ $money }! Winners: { $players }.

# End screen (final-scores)
life-end-score = { $rank }. { $player }: ${ $total }

# ==========================================================================
# Status readouts — each line becomes a navigable menu item.
# S opens self-status; Shift+S opens detailed (all players) status.
# ==========================================================================
life-status-space = Space { $current } of { $total }.
life-status-space-retired = Retired ({ $retirement }).
life-status-career = Career: { $career }; salary ${ $salary }; Taxes Due ${ $taxes }.
life-status-career-none = Career: none yet.
life-status-house = House: { $house }.
life-status-cash = Cash: ${ $money }.
life-status-tiles-hidden = Life tiles: { $count }.
life-status-tiles-revealed = Life tiles: { $count } ({ $money } total).
life-status-tiles-none = Life tiles: none.
life-status-family-single = Family: single, { $kids ->
    [0] no children.
    [one] 1 child.
    *[other] { $kids } children.
}
life-status-family-married = Family: married, { $kids ->
    [0] no children.
    [one] 1 child.
    *[other] { $kids } children.
}
life-status-insurance-full = Insurance: { $list }.
life-status-insurance-single = Insurance: covered.
life-status-insurance-none = Insurance: none.
life-status-loan = Bank-loan principal: ${ $money }; retirement payoff ${ $repayment }.
life-status-loan-none = Bank loans: none.
life-status-stock = Stock numbers: { $numbers }.
life-status-stock-none = Stock: none.

# Detailed status (Shift+S): one header then one line per player.
life-status-detailed-header = Detailed status — { $count } players.
life-status-detailed-self-suffix = {" "}(you)
life-status-detailed-line = { $player }{ $self_suffix }: space { $position }, career { $career }, cash ${ $money }, { $tiles } { $tiles ->
    [one] tile
    *[other] tiles
}, family { $family }.
life-status-detailed-family-single-0 = single
life-status-detailed-family-single-kids = single with { $kids } { $kids ->
    [one] child
    *[other] children
}
life-status-detailed-family-married-0 = married
life-status-detailed-family-married-kids = married with { $kids } { $kids ->
    [one] child
    *[other] children
}

# Helper fragments used in status
life-insurance-fire = homeowner's
life-insurance-auto = auto
life-insurance-life = life
life-career-none = none
life-family-single = single
life-family-married = married

# ==========================================================================
# Actions menu labels
# ==========================================================================
life-action-check-status = Check status
life-action-detailed-status = Detailed status
life-action-view-events = Review recent events

# ==========================================================================
# Careers (canonical set)
# ==========================================================================
life-career-doctor = Doctor
life-career-accountant = Accountant
life-career-teacher = Teacher
life-career-athlete = Athlete
life-career-police-officer = Police Officer
life-career-salesperson = Salesperson
life-career-artist = Artist
life-career-superstar = Superstar
life-career-travel-agent = Travel Agent

# Career, Taxes Due, house, and job-change spaces
life-career-change = { $who ->
    [you] You were fired or changed careers. Draw one new eligible Career Card and one new Salary Card.
    *[player] { $player } draws a new Career Card and Salary Card.
}
life-night-school = { $who ->
    [you] Night School: choose one of two eligible Career Cards or keep your current career, then do the same with Salary Cards.
    *[player] { $player } may change career and salary at Night School.
}
life-career-payment-self = { $who ->
    [you] This is your own { $career } Career space, so you pay nothing.
    *[player] { $player } owns the { $career } Career Card and pays nothing.
}
life-career-payment-player = { $who ->
    [you] Pay { $recipient }, the { $career }, ${ $money }.
    *[player] { $player } pays { $recipient } ${ $money } for the { $career } Career space.
}
life-career-payment-bank = { $who ->
    [you] No player is the { $career }; pay the bank ${ $money }.
    *[player] No player is the { $career }, so { $player } pays the bank ${ $money }.
}
life-taxes-self = { $who ->
    [you] You are the Accountant, so you pay no Taxes Due.
    *[player] { $player } is the Accountant and pays no Taxes Due.
}
life-taxes-player = { $who ->
    [you] Taxes Due: pay { $recipient } ${ $money }.
    *[player] { $player } pays { $recipient } ${ $money } in Taxes Due.
}
life-taxes-bank = { $who ->
    [you] Taxes Due: no player is the Accountant, so pay the bank ${ $money }.
    *[player] No player is the Accountant, so { $player } pays the bank ${ $money }.
}

life-house-bought = { $who ->
    [you] You must buy the { $house } for ${ $money }.
    *[player] { $player } buys the { $house } for ${ $money }.
}
life-house-split-level = Split-Level
life-house-mobile-home = Mobile Home
life-house-log-cabin = Log Cabin
life-house-country-cottage = Country Cottage
life-house-dutch-colonial = Dutch Colonial
life-house-beach-house = Beach House
life-house-farmhouse = Farmhouse
life-house-tudor = Tudor
life-house-victorian = Victorian

# ==========================================================================
# Miscellaneous / validation
# ==========================================================================
life-action-not-your-turn = It's not your turn.
life-action-not-playing = The game is not in progress.
life-action-already-retired = You have already retired.
life-action-must-spin-first = You must spin before taking other actions.
life-already-insured = You are already fully insured.
life-cannot-afford = You cannot afford that action.
life-space-generic = { $who ->
    [you] Nothing happens on this space.
    *[player] Nothing happens on { $player }'s space.
}
