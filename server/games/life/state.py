"""Track, career, event, and Life-tile definitions for The Game of Life.

Every value here is static game data. Nothing in this module is mutated at
runtime — each game instance copies the data it needs into serializable
dataclass fields. This keeps the serialize/deserialize path clean and makes
the option system simple (option toggles just select which static data gets
copied in).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum


class SpaceType(str, Enum):
    """What happens when a player lands on (or passes) a space."""

    START = "start"
    NORMAL = "normal"
    EVENT = "event"
    PAYDAY = "payday"
    MARRY = "marry"
    BABY = "baby"
    INSURANCE = "insurance"
    STOCK = "stock"
    RISK_IT = "risk_it"
    COLLEGE_GRAD = "college_grad"
    CAREER_CHANGE = "career_change"
    RETIRE_JUNCTION = "retire_junction"
    FINISH = "finish"


@dataclass
class Space:
    """One square on the board.

    Attributes:
        index: 0-based position.
        type: What happens here.
        event_key: If type is EVENT, optional pre-baked event identifier;
            None means "draw from the event deck at resolution time".
    """

    index: int
    type: str  # SpaceType value (stored as string for serialization)
    event_key: str | None = None


@dataclass
class CareerCard:
    """A career + salary pairing drawn at the start of the game."""

    key: str  # localization key suffix, e.g., "doctor"
    label_key: str  # full localization key, e.g., "life-career-doctor"
    salary: int  # yearly salary in dollars
    degree_required: bool  # True if only available via College path


# ---------------------------------------------------------------------------
# Canonical career set
# ---------------------------------------------------------------------------

CANONICAL_CAREERS: list[CareerCard] = [
    CareerCard("doctor", "life-career-doctor", 100_000, True),
    CareerCard("lawyer", "life-career-lawyer", 90_000, True),
    CareerCard("accountant", "life-career-accountant", 70_000, True),
    CareerCard("computer_consultant", "life-career-computer-consultant", 80_000, True),
    CareerCard("teacher", "life-career-teacher", 40_000, True),
    CareerCard("athlete", "life-career-athlete", 80_000, False),
    CareerCard("entertainer", "life-career-entertainer", 60_000, False),
    CareerCard("police_officer", "life-career-police-officer", 50_000, False),
    CareerCard("salesperson", "life-career-salesperson", 40_000, False),
]


# ---------------------------------------------------------------------------
# Events ("Life happens" deck)
# ---------------------------------------------------------------------------


class EventEffect(str, Enum):
    CASH_GAIN = "cash_gain"
    CASH_LOSS = "cash_loss"
    LIFE_TILE = "life_tile"
    INSURABLE_FIRE = "insurable_fire"
    INSURABLE_AUTO = "insurable_auto"
    INSURABLE_LIFE = "insurable_life"
    LAWSUIT = "lawsuit"


@dataclass
class EventDef:
    """Definition of one event in the "Life happens" deck.

    Attributes:
        key: Unique identifier used both for serialization and for
            localization message lookup (life-event-<key>).
        effect: What the event does.
        amount: Money amount (always a positive integer; the effect
            decides whether it is a gain or a loss).
    """

    key: str
    effect: str  # EventEffect value
    amount: int = 0


EVENT_DECK: list[EventDef] = [
    # Financial gains
    EventDef("lottery", EventEffect.CASH_GAIN, 100_000),
    EventDef("inheritance", EventEffect.CASH_GAIN, 75_000),
    EventDef("found-money", EventEffect.CASH_GAIN, 5_000),
    EventDef("bestseller", EventEffect.CASH_GAIN, 80_000),
    EventDef("garage-sale", EventEffect.CASH_GAIN, 10_000),
    EventDef("uncle-visits", EventEffect.CASH_GAIN, 15_000),
    EventDef("promotion", EventEffect.CASH_GAIN, 20_000),
    EventDef("tax-refund", EventEffect.CASH_GAIN, 25_000),
    # Financial losses
    EventDef("taxes", EventEffect.CASH_LOSS, 15_000),
    EventDef("bought-boat", EventEffect.CASH_LOSS, 30_000),
    EventDef("vacation", EventEffect.CASH_LOSS, 20_000),
    EventDef("broken-leg", EventEffect.CASH_LOSS, 10_000),
    EventDef("adopted-pet", EventEffect.CASH_LOSS, 5_000),
    EventDef("gambling-loss", EventEffect.CASH_LOSS, 20_000),
    # Insurable — auto
    EventDef("flat-tire", EventEffect.INSURABLE_AUTO, 5_000),
    EventDef("car-accident", EventEffect.INSURABLE_AUTO, 15_000),
    # Insurable — fire
    EventDef("house-fire", EventEffect.INSURABLE_FIRE, 50_000),
    EventDef("tornado", EventEffect.INSURABLE_FIRE, 40_000),
    # Insurable — life (medical)
    EventDef("hospital", EventEffect.INSURABLE_LIFE, 25_000),
    # Life tile awards
    EventDef("nobel-prize", EventEffect.LIFE_TILE, 0),
    EventDef("design-award", EventEffect.LIFE_TILE, 0),
    EventDef("helped-elderly", EventEffect.LIFE_TILE, 0),
    EventDef("saved-ecosystem", EventEffect.LIFE_TILE, 0),
    # Lawsuit (stock-market option only; filtered out by game if disabled)
    EventDef("lawsuit", EventEffect.LAWSUIT, 50_000),
]


# Map insurable effect -> insurance type key used in player.insurance set.
INSURABLE_TO_TYPE: dict[str, str] = {
    EventEffect.INSURABLE_AUTO: "auto",
    EventEffect.INSURABLE_FIRE: "fire",
    EventEffect.INSURABLE_LIFE: "life",
}


# ---------------------------------------------------------------------------
# Life tile values — face-down in hidden mode, drawn without replacement.
# ---------------------------------------------------------------------------

LIFE_TILE_VALUES: list[int] = [
    20_000, 20_000, 30_000, 30_000, 40_000, 40_000, 50_000, 50_000,
    60_000, 60_000, 70_000, 80_000, 90_000, 100_000, 100_000, 120_000,
    150_000, 200_000,
]


# ---------------------------------------------------------------------------
# Track builder — produces a Space list for a given total length.
# ---------------------------------------------------------------------------

# Relative percent positions for key spaces. We snap each fraction to the
# nearest index that's unused; remaining indices get filled with NORMAL or
# EVENT spaces (EVENT filling is biased toward the middle third of the game).
_TRACK_LAYOUT: list[tuple[float, str]] = [
    (0.00, SpaceType.START),
    (0.10, SpaceType.COLLEGE_GRAD),
    (0.14, SpaceType.MARRY),
    (0.18, SpaceType.INSURANCE),
    (0.22, SpaceType.PAYDAY),
    (0.26, SpaceType.BABY),
    (0.30, SpaceType.STOCK),
    (0.34, SpaceType.EVENT),
    (0.38, SpaceType.RISK_IT),
    (0.42, SpaceType.CAREER_CHANGE),
    (0.46, SpaceType.PAYDAY),
    (0.50, SpaceType.BABY),
    (0.54, SpaceType.INSURANCE),
    (0.58, SpaceType.EVENT),
    (0.62, SpaceType.STOCK),
    (0.66, SpaceType.PAYDAY),
    (0.70, SpaceType.BABY),
    (0.74, SpaceType.RISK_IT),
    (0.78, SpaceType.EVENT),
    (0.82, SpaceType.PAYDAY),
    (0.88, SpaceType.EVENT),
    (0.94, SpaceType.RETIRE_JUNCTION),
    (1.00, SpaceType.FINISH),
]

TRACK_LENGTHS: dict[str, int] = {
    "short": 50,
    "standard": 80,
    "long": 125,
}


def build_track(length_key: str) -> list[Space]:
    """Build a Space list for the given track length option value.

    The last space is always FINISH. Intermediate key spaces are placed at
    roughly the same relative positions regardless of length. Filler spaces
    alternate between NORMAL and EVENT with a bias toward NORMAL near the
    start and end of the board.
    """
    length = TRACK_LENGTHS.get(length_key, TRACK_LENGTHS["standard"])
    spaces: list[str | None] = [None] * length

    for frac, stype in _TRACK_LAYOUT:
        idx = round(frac * (length - 1))
        idx = max(0, min(length - 1, idx))
        # If the slot is already taken, nudge forward until we find a free slot.
        while spaces[idx] is not None and idx < length - 1:
            idx += 1
        spaces[idx] = stype

    # Guarantee first/last anchors.
    spaces[0] = SpaceType.START
    spaces[-1] = SpaceType.FINISH
    # Retire junction must precede the finish; guarantee it sits somewhere
    # in the last 10% if the layout above didn't land it there.
    if SpaceType.RETIRE_JUNCTION not in spaces:
        # Find the last NORMAL/None/EVENT slot before the finish and convert.
        for idx in range(length - 2, length - 2 - max(3, length // 10), -1):
            if spaces[idx] in (None, SpaceType.NORMAL, SpaceType.EVENT):
                spaces[idx] = SpaceType.RETIRE_JUNCTION
                break

    # Fill remaining slots with NORMAL + EVENT (~40% events across filler).
    total_filler = sum(1 for s in spaces if s is None)
    target_events = max(3, total_filler * 2 // 5)
    events_placed = 0
    # Deterministic pattern: every other filler in the middle third is EVENT.
    start_third = length // 3
    end_third = (length * 2) // 3
    for idx in range(length):
        if spaces[idx] is not None:
            continue
        if start_third <= idx <= end_third and events_placed < target_events and idx % 2 == 0:
            spaces[idx] = SpaceType.EVENT
            events_placed += 1
        else:
            spaces[idx] = SpaceType.NORMAL

    # Top up events anywhere still NORMAL if we didn't hit target.
    if events_placed < target_events:
        for idx in range(length - 2, 1, -1):
            if events_placed >= target_events:
                break
            if spaces[idx] == SpaceType.NORMAL:
                spaces[idx] = SpaceType.EVENT
                events_placed += 1

    return [Space(index=i, type=t) for i, t in enumerate(spaces)]  # type: ignore[arg-type]


def filter_events_for_options(
    deck: list[EventDef],
    stock_market_enabled: bool,
    insurance_mode: str,
    life_tiles_mode: str,
) -> list[EventDef]:
    """Return an event deck pruned according to lobby options.

    - Drops lawsuits if stock market is off.
    - Drops Life-tile events if Life tiles are off.
    - Keeps insurable events in all insurance modes (the insurance mode
      only changes how players buy coverage; the events themselves still
      fire — just without any insured protection in "off" mode).
    """
    out: list[EventDef] = []
    for e in deck:
        if e.effect == EventEffect.LAWSUIT and not stock_market_enabled:
            continue
        if e.effect == EventEffect.LIFE_TILE and life_tiles_mode == "off":
            # Convert to a cash gain so the space still does something.
            out.append(EventDef(e.key, EventEffect.CASH_GAIN, 30_000))
            continue
        out.append(e)
    return out


# Insurance premiums (lobby-option-dependent).
INSURANCE_PREMIUMS: dict[str, int] = {
    "fire": 20_000,
    "auto": 10_000,
    "life": 15_000,
    "simplified": 35_000,  # single-policy premium in simplified mode
}

# Stock number cost
STOCK_COST: int = 50_000
STOCK_PAYOUT: int = 10_000

# Risk It: stake and prize, threshold
RISK_IT_STAKE: int = 25_000
RISK_IT_PRIZE: int = 100_000
RISK_IT_THRESHOLD: int = 7  # spin 7-10 wins

# College loan
COLLEGE_LOAN_PRINCIPAL: int = 100_000
COLLEGE_LOAN_INTEREST: int = 5_000  # charged whenever a loan-interest event fires

# Payday bonus per child
PAYDAY_PER_CHILD: int = 5_000

# Retirement bonuses
ACRES_BONUS: int = 1_000_000
ESTATES_WINNER_MULTIPLIER: int = 2  # doubles money
ESTATES_LOSER_PENALTY: int = 1_000_000
