"""Gender-aware localization ported from PlayAural.

GENDER_TERM renders a grammatical form in the listener's language, and
broadcasts give each player-name argument a matching <name>_gender selector.
Our accounts have no gender field, so real players resolve to the neutral
forms; explicit selectors exercise the other branches.
"""

from pathlib import Path

import pytest

from server.core.users.test_user import MockUser
from server.games.humanitycards.game import HumanityCardsGame
from server.games.pig.game import PigGame
from server.messages.localization import Localization


@pytest.mark.parametrize(
    ("gender", "expected"),
    [
        ("male", "his"),
        ("female", "her"),
        ("non-binary", "their"),
        ("unspecified", "their"),
        ("nonsense", "their"),
    ],
)
def test_gender_term_renders_each_english_form(gender, expected):
    text = Localization.get("en", "hc-player-submitted", player="Alice", player_gender=gender)
    assert text == f"Alice submitted {expected} cards."


def test_gender_term_uses_english_forms_where_a_locale_has_none():
    # French has no gender-term messages, so GENDER_TERM falls back to English.
    assert Localization._format_gender_term("fr", "female", "possessive-determiner") == "her"
    assert Localization._format_gender_term("fr", "unspecified", "subject-capitalized") == "They"


def test_gender_term_prefers_the_listeners_language():
    assert Localization.get("es", "hc-player-submitted", player="Alicia", player_gender="male") == (
        "Alicia envió sus cartas."
    )


def test_gender_term_works_after_a_cold_compile_and_after_a_cache_reload(tmp_path, monkeypatch):
    monkeypatch.setattr(Localization, "_cache_enabled", True)
    monkeypatch.setattr(Localization, "_cache_dir", tmp_path)
    locale_dir = Localization._locales_dir / "en"
    payloads, fingerprint = Localization._load_locale_payloads(locale_dir, "en")

    cold = Localization._compile_bundle("en", payloads, fingerprint)
    cached = Localization._load_bundle_from_cache("en", fingerprint)

    assert cached is not None
    for bundle in (cold, cached):
        text, errors = bundle.format("hc-player-submitted", {"player": "Alice", "player_gender": "male"})
        assert errors == []
        assert text.replace("⁨", "").replace("⁩", "") == "Alice submitted his cards."


def test_regional_locale_reuses_its_language_bundle():
    Localization._bundles.pop("pt-BR", None)
    language_bundle = Localization._get_bundle("pt")

    assert Localization._get_bundle("pt-BR") is language_bundle
    assert Localization.get("pt-BR", "hc-card-blank") == "espaço em branco"


def test_broadcast_resolves_once_per_listener_and_transcript_matches_speech():
    game = HumanityCardsGame()
    english = MockUser("Alice", locale="en", uuid="gender-en")
    spanish = MockUser("Bruno", locale="es", uuid="gender-es")
    game.add_player("Alice", english)
    game.add_player("Bruno", spanish)
    transcript: dict[str, list[str]] = {}
    game.record_transcript_event = lambda player, text, buffer: transcript.setdefault(player.name, []).append(text)
    calls: list[str] = []

    def submitter_for(locale: str) -> str:
        calls.append(locale)
        return "Alice"

    game.broadcast_l("hc-player-submitted", player=submitter_for)

    assert sorted(calls) == ["en", "es"]
    assert transcript["Alice"] == ["Alice submitted their cards."]
    assert transcript["Bruno"] == [spanish.get_last_spoken()]
    assert english.get_last_spoken() == "Alice submitted their cards."


def test_player_valued_arguments_render_the_same_as_names_in_existing_games():
    game = PigGame()
    alice_user = MockUser("Alice", uuid="pig-gender-1")
    bob_user = MockUser("Bob", uuid="pig-gender-2")
    alice = game.add_player("Alice", alice_user)
    game.add_player("Bob", bob_user)

    game.broadcast_l("pig-player-rolled", player=alice.name, roll=4, total=9)
    by_name = bob_user.get_last_spoken()
    game.broadcast_l("pig-player-rolled", player=alice, roll=4, total=9)
    by_player = bob_user.get_last_spoken()

    assert by_name == by_player == Localization.get("en", "pig-player-rolled", player="Alice", roll=4, total=9)
