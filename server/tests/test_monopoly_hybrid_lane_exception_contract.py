"""Contract tests for hybrid-lane unresolved literal card handling."""

from __future__ import annotations

import pytest

from server.games.monopoly.manual_rules.loader import load_manual_rule_set


@pytest.mark.parametrize("board_id", ("marvel_avengers_legacy", "marvel_flip"))
def test_hybrid_lane_not_observed_cards_have_evidence_notes(board_id: str):
    rule_set = load_manual_rule_set(board_id)
    unresolved = [
        card
        for deck_id in ("chance", "community_chest")
        for card in rule_set.cards.get(deck_id, [])
        if card.get("text_status") == "not_observed_in_available_manual_sources"
    ]

    assert unresolved
    assert all(isinstance(card.get("text_note"), str) and card["text_note"].strip() for card in unresolved)
