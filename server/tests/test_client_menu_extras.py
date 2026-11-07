"""The iOS app's turn-menu extras: the game's rules text and its primary action."""

from server.documentation.manager import DocumentationManager
from server.core.client_menu_extras import primary_action_id, rules_text, turn_menu_extras
from server.games.pig.game import PigGame
from server.users.test_user import MockUser


def test_rules_come_from_the_game_manual():
    text = rules_text("pig", "en")
    assert text and "push-your-luck" in text


def test_a_game_without_a_manual_falls_back_to_its_rules_message(monkeypatch):
    """Every game has a manual now, so this pretends Mancala's is missing."""
    manager = DocumentationManager.get_instance()
    real_get_document = manager.get_document

    def without_mancala(path, locale):
        return None if path == "games/mancala" else real_get_document(path, locale)

    monkeypatch.setattr(manager, "get_document", without_mancala)
    rules_text.cache_clear()
    try:
        text = rules_text("mancala", "en")
    finally:
        rules_text.cache_clear()
    assert text and "pit and stone" in text


def test_a_game_with_a_manual_uses_it():
    manager = DocumentationManager.get_instance()
    manual = manager.get_document("games/mancala", "en")
    rules_text.cache_clear()
    assert manual
    assert rules_text("mancala", "en") == "\n".join(manager.render_markdown_lines(manual))


def test_a_game_with_neither_has_no_rules_text():
    rules_text.cache_clear()
    assert rules_text("no-such-game", "en") is None


def test_primary_action_and_extras_for_a_player():
    game = PigGame()
    alice = MockUser("Alice")
    game.add_player("Alice", alice)
    game.add_player("Bob", MockUser("Bob"))
    game.on_start()
    player = game.get_player_by_name("Alice")
    assert primary_action_id(game, player.id) == "roll"
    extras = turn_menu_extras(game, alice)
    assert extras["primary_action_id"] == "roll"
    assert extras["help_text"]
    assert turn_menu_extras(None, alice) == {}
