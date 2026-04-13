"""Bid validation and dice helpers for Liar's Dice.

A bid is a (quantity, face) tuple. quantity >= 1, face in 1..6.

The default rule set treats 1s as wild — they count toward any non-1 bid.
This affects two things: counting actual dice for resolution, and what
the next valid bid is.

Bid progression (with wild 1s on):
  - Same face, higher quantity: always valid.
  - Higher face, same or higher quantity: valid (face only goes up if you
    keep at least the current quantity).
  - Switching to 1s (from a non-1 bid of quantity Q): minimum quantity is
    ceil(Q / 2). Bidding 1s disables wilds for the count of that bid.
  - Switching from 1s (current bid is on 1s of quantity Q1) to a non-1
    face: minimum quantity is 2*Q1 + 1.

With wild 1s off, every non-1 face is independent and bids only need to
be strictly higher in either quantity or face.
"""

from __future__ import annotations

import math


def count_face(dice: list[int], face: int, wild_ones: bool) -> int:
    """Count dice matching `face`. If wild_ones, 1s also count (unless face is 1)."""
    count = sum(1 for d in dice if d == face)
    if wild_ones and face != 1:
        count += sum(1 for d in dice if d == 1)
    return count


def starting_bid_quantity_for_face(face: int) -> int:
    return 1


def is_higher_bid(
    new_bid: tuple[int, int],
    current: tuple[int, int] | None,
    wild_ones: bool,
) -> bool:
    """True if `new_bid` is a legal raise over `current`."""
    nq, nf = new_bid
    if nq < 1 or nf < 1 or nf > 6:
        return False
    if current is None:
        return True
    cq, cf = current

    if not wild_ones:
        # Strict ordering: higher quantity (any face) OR same quantity higher face.
        if nq > cq:
            return True
        if nq == cq and nf > cf:
            return True
        return False

    # Wild-ones progression.
    if cf == 1 and nf == 1:
        return nq > cq
    if cf == 1 and nf != 1:
        # Switching from 1s back to a regular face.
        return nq >= 2 * cq + 1
    if cf != 1 and nf == 1:
        # Switching from a regular face to 1s.
        return nq >= math.ceil(cq / 2)
    # Both non-1.
    if nq > cq:
        return True
    if nq == cq and nf > cf:
        return True
    return False


def enumerate_valid_bids(
    current: tuple[int, int] | None,
    total_dice: int,
    wild_ones: bool,
    max_options: int = 60,
) -> list[tuple[int, int]]:
    """Return up to `max_options` legal next bids, sorted by face then quantity.

    The list is bounded to keep menu sizes reasonable. We start from the
    smallest legal bid for each face and walk up to `total_dice` quantity.
    """
    out: list[tuple[int, int]] = []
    for face in range(1, 7):
        # Find minimum legal quantity for this face.
        min_q = 1
        if current is not None:
            cq, cf = current
            if not wild_ones:
                if face > cf:
                    min_q = cq
                else:
                    min_q = cq + 1
            else:
                if cf == 1 and face == 1:
                    min_q = cq + 1
                elif cf == 1 and face != 1:
                    min_q = 2 * cq + 1
                elif cf != 1 and face == 1:
                    min_q = max(1, math.ceil(cq / 2))
                elif face > cf:
                    min_q = cq
                else:
                    min_q = cq + 1
        for q in range(min_q, total_dice + 1):
            out.append((q, face))
            if len(out) >= max_options:
                return out
    return out
