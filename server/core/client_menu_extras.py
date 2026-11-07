"""Turn-menu extras for the iOS app: the current game's rules text and its primary action.

The iOS app shows the rules in its Help sheet and maps a two-finger
double-tap to the turn's main action. Both arrive as fields on the
``turn_menu`` packet. PlayAural's engine has no such fields, so the network
user asks this module for them whenever it sends a turn menu.
"""

from __future__ import annotations

from functools import lru_cache
from typing import TYPE_CHECKING, Any

from ..documentation.manager import DocumentationManager
from ..messages.localization import Localization

if TYPE_CHECKING:
    from ..games.base import Game

# Common primary action ids, most specific first. The first one present in
# the player's action sets wins.
PRIMARY_ACTION_CANDIDATES = (
    "roll",
    "draw",
    "draw_card",
    "hit",
    "shoot",
    "play",
    "attack",
    "deal",
    "bid",
    "spin",
)


@lru_cache(maxsize=512)
def rules_text(game_type: str, locale: str) -> str | None:
    """Return a game's rules as plain lines of text, or None if it has no manual.

    Manuals are files that don't change while the server runs, so the
    rendered text is cached per game and language.
    """
    manager = DocumentationManager.get_instance()
    content = manager.get_document(f"games/{game_type}", locale)
    if not content:
        # Games without a manual yet may still have the short rules message
        # the old engine sent.
        message_id = f"{game_type}-rules"
        if Localization.has_message(locale, message_id):
            return Localization.get(locale, message_id)
        return None
    lines = manager.render_markdown_lines(content)
    return "\n".join(lines) or None


def primary_action_id(game: "Game", player_id: str) -> str | None:
    """Return the player's primary action id for this turn, or None."""
    for action_set in game.player_action_sets.get(player_id, []):
        actions = getattr(action_set, "_actions", {})
        for candidate in PRIMARY_ACTION_CANDIDATES:
            if candidate in actions:
                return candidate
    return None


def turn_menu_extras(game: "Game | None", user: Any) -> dict[str, str | None]:
    """Build the help text and primary action for one user's turn menu."""
    if game is None:
        return {}
    player = game.get_player_by_id(user.uuid)
    return {
        "help_text": rules_text(game.get_type(), user.locale),
        "primary_action_id": primary_action_id(game, player.id) if player else None,
    }
