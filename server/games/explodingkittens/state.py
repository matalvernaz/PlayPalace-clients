"""Card definitions and deck construction for Exploding Kittens.

Cards are stored as plain string identifiers so the game state serializes
cleanly. The deck is a list of card identifiers with the top of the deck
at index 0 (so we draw from the front).
"""

from __future__ import annotations

import random


# ---------------------------------------------------------------------------
# Card identifiers — stored verbatim in player hands, deck, discard.
# ---------------------------------------------------------------------------

CARD_DEFUSE = "defuse"
CARD_EXPLODING_KITTEN = "exploding-kitten"
CARD_STREAKING_KITTEN = "streaking-kitten"
CARD_SKIP = "skip"
CARD_ATTACK = "attack"
CARD_SEE_FUTURE = "see-the-future"
CARD_SHUFFLE = "shuffle"
CARD_FAVOR = "favor"
CARD_NOPE = "nope"
CARD_TACOCAT = "tacocat"
CARD_HAIRY_POTATO = "hairy-potato-cat"
CARD_RAINBOW_RALPH = "rainbow-ralph-cat"
CARD_BEARD = "beard-cat"
CARD_CATTERMELON = "cattermelon"

ALL_CAT_TYPES: tuple[str, ...] = (
    CARD_TACOCAT,
    CARD_HAIRY_POTATO,
    CARD_RAINBOW_RALPH,
    CARD_BEARD,
    CARD_CATTERMELON,
)

CARD_TYPES: tuple[str, ...] = (
    CARD_DEFUSE,
    CARD_EXPLODING_KITTEN,
    CARD_STREAKING_KITTEN,
    CARD_SKIP,
    CARD_ATTACK,
    CARD_SEE_FUTURE,
    CARD_SHUFFLE,
    CARD_FAVOR,
    CARD_NOPE,
    *ALL_CAT_TYPES,
)


# ---------------------------------------------------------------------------
# Card classification helpers.
# ---------------------------------------------------------------------------

_ACTION_CARDS = {CARD_SKIP, CARD_ATTACK, CARD_SEE_FUTURE, CARD_SHUFFLE, CARD_FAVOR}
_CANCELLABLE = _ACTION_CARDS | set(ALL_CAT_TYPES) | {CARD_NOPE}


def is_action_card(card: str) -> bool:
    """Return True if the card is a single-play action card."""
    return card in _ACTION_CARDS


def is_cat_card(card: str) -> bool:
    return card in ALL_CAT_TYPES


def is_cancellable(card: str) -> bool:
    """Cards whose play opens a Nope window (Nope itself is included so Nope chains work)."""
    return card in _CANCELLABLE


# ---------------------------------------------------------------------------
# Localization key helpers.
# ---------------------------------------------------------------------------

def card_label_key(card: str, edition: str) -> str:
    """Return the Fluent message id for a card name in the given edition."""
    return f"ek-card-{card}-{edition}"


# ---------------------------------------------------------------------------
# Starting hand / deck construction.
# ---------------------------------------------------------------------------

# Card counts in the deck (excluding Defuses and Exploding Kittens, which
# scale with player count). These match the canonical 56-card base game.
_BASE_CARD_COUNTS: dict[str, int] = {
    CARD_SKIP: 4,
    CARD_ATTACK: 4,
    CARD_SEE_FUTURE: 5,
    CARD_SHUFFLE: 4,
    CARD_FAVOR: 4,
    CARD_NOPE: 5,
    CARD_TACOCAT: 4,
    CARD_HAIRY_POTATO: 4,
    CARD_RAINBOW_RALPH: 4,
    CARD_BEARD: 4,
    CARD_CATTERMELON: 4,
}

_TOTAL_DEFUSES = 6
_DEFAULT_HAND_SIZE = 7


def build_starting_deck(
    player_count: int,
    rng: random.Random,
    hand_size: int = _DEFAULT_HAND_SIZE,
    streaking_kittens: bool = False,
) -> tuple[list[list[str]], list[str]]:
    """Build initial hands and the deck after dealing.

    Standard rules:
      1. Take all base cards (no Defuses, no Exploding Kittens).
      2. Shuffle. Deal each player 1 Defuse + `hand_size` other cards.
      3. Add remaining Defuses (up to 6 total) to the deck.
      4. Add (player_count - 1) Exploding Kittens.
      5. Add 1 Streaking Kitten if the variant is on.
      6. Shuffle the deck.

    Returns (hands, deck) where each hand is a list of card identifiers
    and deck[0] is the top of the deck.
    """
    pool: list[str] = []
    for card, count in _BASE_CARD_COUNTS.items():
        pool.extend([card] * count)
    rng.shuffle(pool)

    hands: list[list[str]] = []
    cards_per_player_excl_defuse = hand_size
    for _ in range(player_count):
        hand = [CARD_DEFUSE]
        for _ in range(cards_per_player_excl_defuse):
            if pool:
                hand.append(pool.pop())
        hands.append(hand)

    deck: list[str] = list(pool)
    # Remaining defuses (after one per player) go in the deck.
    remaining_defuses = max(0, _TOTAL_DEFUSES - player_count)
    deck.extend([CARD_DEFUSE] * remaining_defuses)
    deck.extend([CARD_EXPLODING_KITTEN] * max(0, player_count - 1))
    if streaking_kittens:
        deck.append(CARD_STREAKING_KITTEN)
    rng.shuffle(deck)
    return hands, deck


def hand_count(hand: list[str], card: str) -> int:
    return sum(1 for c in hand if c == card)


def hand_summary(hand: list[str]) -> dict[str, int]:
    """Return a {card_id: count} summary, useful for display and bot logic."""
    out: dict[str, int] = {}
    for c in hand:
        out[c] = out.get(c, 0) + 1
    return out


def remove_one(hand: list[str], card: str) -> bool:
    """Remove a single instance of `card` from `hand`. Returns True if found."""
    if card in hand:
        hand.remove(card)
        return True
    return False
