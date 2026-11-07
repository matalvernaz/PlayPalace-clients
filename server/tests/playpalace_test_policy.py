"""Which of PlayAural's tests don't apply to this server, and which wait on our sound pack.

PlayAural's game and engine tests are copied in unchanged on every sync, so
instead of editing them, this pytest plugin (loaded from pyproject.toml)
skips the ones that test PlayAural's own clients, protocol or tooling, and
marks the ones that check our sound pack as expected failures until the
sounds exist. Each entry says why. Remove an entry as soon as it no longer
applies; the sound entries are strict, so they fail loudly once the sounds land.
"""

from __future__ import annotations

import pytest

# Tests of things this server doesn't have: PlayAural's own network user and
# packet shapes, its client features, its tooling, or a mistake in its tree.
NOT_APPLICABLE = {
    "tests/test_bot_naming.py::test_cli_capture_keeps_duplicate_bot_bases_distinct": "tests PlayAural's command-line simulator, not this server's",
    "tests/test_menu_content_diff.py::test_focus_context_capture_and_restore_are_one_shot_directives": "focus-context snapshots are a PlayAural client feature our clients don't have",
    "tests/test_menu_content_diff.py::test_invalid_focus_context_ids_are_rejected": "focus-context snapshots are a PlayAural client feature our clients don't have",
    "tests/test_menu_content_diff.py::test_remove_editbox_notifies_remote_client": "our protocol has no remove_editbox packet; the next menu replaces the editbox",
    "tests/test_menu_content_diff.py::test_remove_editbox_forces_next_menu_reshow": "our network user re-sends the next menu when the editbox opens, not when it's removed",
    "tests/test_menu_coalescing.py::test_non_menu_packets_preserved_in_order": "asserts PlayAural's audio packet type; ours sends play_sound and friends",
    "tests/test_menu_coalescing.py::test_focus_context_directives_survive_same_menu_coalescing": "focus-context snapshots are a PlayAural client feature our clients don't have",
    "tests/test_menu_coalescing.py::test_focus_context_capture_survives_later_explicit_item_focus": "focus-context snapshots are a PlayAural client feature our clients don't have",
    "tests/test_buffer_categories.py::test_all_server_speech_calls_supply_buffer_category": "PlayAural's rule for its own core; our core leaves the buffer at its default",
    "tests/test_buffer_categories.py::test_network_user_speak_serializes_misc_buffer_explicitly": "our protocol omits the buffer when it's misc",
    "tests/test_buffer_categories.py::test_network_user_speak_l_serializes_misc_buffer_explicitly": "our protocol omits the buffer when it's misc",
    "tests/test_buffer_categories.py::test_network_user_serializes_history_bypass_only_when_requested": "our clients keep every message, so the history flag isn't sent",
    "tests/test_audio_engine.py::test_network_audio_packets_are_unified_and_ordered": "tests PlayAural's audio packet; our network user translates commands into our sound packets (tests/test_legacy_audio.py)",
    "tests/test_audio_engine.py::test_network_audio_sequence_is_one_ordered_websocket_packet": "tests PlayAural's audio packet; our network user plays sequences part by part (tests/test_legacy_audio.py)",
    "tests/test_menu_sealing.py::TestPersistentStartAction::test_stale_surface_forces_authoritative_input_menu_packet": "asserts a message key on speech packets, which only PlayAural's network user sends",
    "tests/test_pref_engine.py::test_to_dict_key_set_is_stable": "tests PlayAural's preference set; this server keeps its own (users/preferences.py)",
    "tests/test_pref_engine.py::test_declarative_categories_and_fields": "tests PlayAural's preference set; this server keeps its own (users/preferences.py)",
    "tests/test_pref_engine.py::test_reset_category_and_all_clear_overrides": "tests PlayAural's preference set; this server keeps its own (users/preferences.py)",
    "tests/test_humanitycards.py::test_humanitycards_vendored_datasets_are_clean_and_complete": "fails on PlayAural's own published tree: its pinned hash for humanity_packs_es.json doesn't match the file they ship (ours is byte-identical to theirs)",
    "tests/test_deadmansdice.py::test_cinematic_timing_constants_match_the_shipped_audio": "compares PlayAural's timing constants with PlayAural's own recordings; our sounds are different recordings",
    "tests/test_blackjack.py::test_blackjack_whose_turn_between_hands_uses_localized_waiting_message": "assumes Serbian has no Blackjack translation; this server ships one",
}

# Tests that check our sound pack has every sound a game asks for. They pass
# once the sound batch adds the missing files to clients/desktop/sounds.
WAITING_FOR_SOUNDS = {
    "tests/test_audio_engine.py::test_shared_presence_and_notification_assets_match_every_sound_pack": "table presence sounds not in our pack yet",
    "tests/test_deadmansdice.py::test_sound_assets_are_complete_identical_ogg_files_in_every_client": "Dead Man's Dice sounds not in our pack yet",
    "tests/test_zombiedice.py::test_sound_assets_are_complete_identical_and_use_authored_formats": "Zombie Dice sounds not in our pack yet",
    "tests/test_monopoly.py::test_monopoly_audio_assets_match_every_first_party_sound_pack": "Monopoly sounds not in our pack yet",
    "tests/test_flip7.py::test_flip7_audio_reuses_complete_shared_assets_with_exact_fallbacks": "Flip 7 sounds not in our pack yet",
    "tests/test_bang.py::test_every_bang_audio_asset_exists_in_all_shipped_sound_packs": "BANG! sounds not in our pack yet",
    "tests/test_dice_sounds.py::test_shared_dice_assets_match_across_clients": "shared dice sounds not in our pack yet",
}


def _matches(nodeid: str, table: dict[str, str]) -> str | None:
    """Return the reason for a test id, matching parametrized variants too."""
    if nodeid in table:
        return table[nodeid]
    base = nodeid.split("[", 1)[0]
    return table.get(base)


def pytest_collection_modifyitems(config, items):
    for item in items:
        nodeid = item.nodeid.removeprefix("server/")
        reason = _matches(nodeid, NOT_APPLICABLE)
        if reason:
            item.add_marker(pytest.mark.skip(reason=f"not applicable here: {reason}"))
            continue
        reason = _matches(nodeid, WAITING_FOR_SOUNDS)
        if reason:
            item.add_marker(pytest.mark.xfail(reason=f"waiting for the sound batch: {reason}", strict=True))
