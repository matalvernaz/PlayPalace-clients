"""Bot decision-making heuristics for The Game of Life.

Bots make simple rule-of-thumb decisions. The rules aim for "plays
believably" — not optimally. Bots still have room to lose so they don't
feel rigged, but they won't do obviously silly things like refuse free
money or skip cheap insurance against expensive events.

Every helper takes the LifePlayer and the live game so it can read options
and global state. All return values are strings matching one of the
choices the game presented; the caller maps that back to an action.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from .state import (
    BANK_LOAN_REPAYMENT,
    INSURANCE_PREMIUMS,
    SALARY_CARDS,
    STOCK_COST,
    RISK_IT_PRIZE,
    RISK_IT_STAKE,
    RISK_IT_THRESHOLD,
)

if TYPE_CHECKING:
    from .game import GameOfLifeGame
    from .player import LifePlayer


# ---------------------------------------------------------------------------
# Path fork (College vs Career).
# ---------------------------------------------------------------------------

def choose_path(player: "LifePlayer") -> str:
    """Bots with more starting cash tend toward college; less toward career."""
    if player.cash >= 25_000:
        return "college"
    # Most bots accept the two $20,000 loan notes for access to degree careers.
    return "college" if (hash(player.id) & 0b11) != 0 else "career"


# ---------------------------------------------------------------------------
# Career pick — prefer highest salary available.
# ---------------------------------------------------------------------------

def pick_career(options: list[int]) -> int:
    """Return an offered-card slot."""
    if not options:
        return 0
    return 0


def pick_salary(options: list[int]) -> int:
    """Return the slot containing the highest offered Salary Card."""
    if not options:
        return 0
    return max(
        range(len(options)),
        key=lambda slot: SALARY_CARDS[options[slot]].salary,
    )


# ---------------------------------------------------------------------------
# Insurance.
# ---------------------------------------------------------------------------

def choose_insurance(
    player: "LifePlayer",
    game: "GameOfLifeGame",
    available_types: list[str],
) -> str:
    """Decide which insurance (if any) to buy from the offered list.

    Rule: buy insurance if we can afford it *and* don't already have it,
    preferring homeowner's insurance over auto insurance. In simplified
    mode, buy if premium <= 40% of cash.
    """
    if not available_types:
        return "skip"

    mode = game.options.insurance
    if mode == "simplified":
        premium = INSURANCE_PREMIUMS["simplified"]
        if not player.has_full_insurance and player.cash >= premium + 20_000:
            return "full"
        return "skip"

    # Full mode — pick the most valuable type we don't have, if affordable.
    priorities = ["fire", "auto"]
    for t in priorities:
        if t not in available_types:
            continue
        if player.covers(t):
            continue
        premium = (
            player.house_insurance_cost
            if t == "fire"
            else INSURANCE_PREMIUMS[t]
        )
        # Affordability: keep at least $20k reserve.
        if player.cash >= premium + 20_000:
            return t
    return "skip"


# ---------------------------------------------------------------------------
# Stock market.
# ---------------------------------------------------------------------------

def choose_stock(player: "LifePlayer") -> str:
    """Buy a stock if we can afford it and don't already own one.

    Bots pick a lucky number that varies per-id so different bots don't
    all pile onto the same number. Return a string "1".."9" or "skip".
    """
    if player.stock_number != 0:
        return "skip"
    if player.cash < STOCK_COST + 25_000:
        return "skip"
    # Pick a deterministic but varied number from the player id.
    num = (abs(hash(player.id)) % 9) + 1
    return str(num)


# ---------------------------------------------------------------------------
# Risk It.
# ---------------------------------------------------------------------------

def choose_risk_it(player: "LifePlayer") -> str:
    """Take the bet if expected value is positive *and* we can afford the stake."""
    # EV: (4/10) * PRIZE - (6/10) * STAKE  (spin 7-10 wins)
    win_prob = (11 - RISK_IT_THRESHOLD) / 10.0
    ev = win_prob * RISK_IT_PRIZE - (1 - win_prob) * RISK_IT_STAKE
    if ev > 0 and player.cash >= RISK_IT_STAKE + 25_000:
        return "risk"
    return "skip"


# ---------------------------------------------------------------------------
# Retirement choice.
# ---------------------------------------------------------------------------

def choose_retirement(player: "LifePlayer", all_cash: list[int]) -> str:
    """Choose Estates when currently richest; otherwise protect tiles at Acres."""
    my_cash = player.cash
    others = [c for c in all_cash if c != my_cash]
    if not others:
        return "estates"
    highest_other = max(others)
    if my_cash >= highest_other:
        return "estates"
    return "acres"


# ---------------------------------------------------------------------------
# Loan repayment (called as an always-available action).
# ---------------------------------------------------------------------------

def should_pay_loan(player: "LifePlayer") -> bool:
    """Repay one bank-loan note while keeping a $50,000 reserve."""
    if player.college_loan <= 0:
        return False
    return player.cash - BANK_LOAN_REPAYMENT >= 50_000
