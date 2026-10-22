"""Every game's Play-menu category must be a real English message.

The categories menu turns each game's get_category() into text with
Localization.get, so a raw id such as "cards" shows up as "[cards]" in the
menu and logs a KeyError every time the menu is drawn.
"""

import server.games  # noqa: F401  (importing the package registers every game)
from server.games.registry import GameRegistry
from server.messages.localization import Localization


def test_every_game_category_is_a_defined_english_message():
    undefined = sorted(
        f"{game_class.get_type()}: {game_class.get_category()!r}"
        for game_class in GameRegistry.get_all()
        if Localization.get_optional("en", game_class.get_category()) is None
    )
    assert undefined == [], (
        "These games return a category with no English message. Return an "
        "existing category-* id or add one to locales/en/games.ftl: "
        + ", ".join(undefined)
    )
