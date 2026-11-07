"""Every game must land in a real Play-menu category with a spoken label.

The categories menu groups games by get_category() and reads each group as
game-category-<id>. An id the engine doesn't know is quietly filed under
Miscellaneous, and a missing label is read out as its raw message id, which
is how "[cards]" ended up on the live server in October.
"""

import server.games  # noqa: F401  (importing the package registers every game)
from server.games.categories import GAME_CATEGORY_IDS
from server.games.registry import GameRegistry
from server.messages.localization import Localization


def test_every_game_reports_a_known_category():
    unknown = sorted(
        f"{game_class.get_type()}: {game_class.get_category()!r}"
        for game_class in GameRegistry.get_all()
        if game_class.get_category() not in GAME_CATEGORY_IDS
    )
    assert unknown == [], (
        "These games report a category the engine doesn't know, so they'd be "
        "filed under Miscellaneous. Return one of games/categories.py's ids: "
        + ", ".join(unknown)
    )


def test_every_category_has_an_english_label():
    unlabelled = sorted(
        category
        for category in GAME_CATEGORY_IDS
        if not Localization.has_message("en", f"game-category-{category}")
    )
    assert unlabelled == []
