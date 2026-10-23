"""The build_menu_items hook leaves existing games' turn menus unchanged.

Both menu painters now ask build_menu_items for their items. Its default must
give exactly the items _build_action_menu_items always produced.
"""

import pytest

import server.games  # noqa: F401  (importing the package registers every game)
from server.core.users.test_user import MockUser
from server.game_utils.menu_management_mixin import MenuBuild
from server.games.registry import get_game_class


def _item_tuples(items):
    return [(item.text, item.id, item.sound) for item in items]


# Games that override a painter (chess, backgammon, crazyeights and others) add
# their own items around the hook's, so only games on the default painters can be
# compared with _build_action_menu_items directly.
@pytest.mark.parametrize("game_type", ["pig", "uno", "milebymile", "yahtzee", "farkle"])
def test_default_hook_paints_the_same_items_as_before(game_type):
    game = get_game_class(game_type)()
    users = []
    for index in range(2):
        user = MockUser(f"Player{index + 1}", uuid=f"{game_type}-{index}")
        game.add_player(user.username, user)
        users.append(user)
    game.on_start()

    for player, user in zip(game.players, users):
        # The painters sync dynamic actions (such as an Uno hand) before building.
        game.before_menu_build(player)
        expected = _item_tuples(game._build_action_menu_items(player, user))

        game.rebuild_player_menu(player)
        assert _item_tuples(user.menus["turn_menu"]["items"]) == expected

        game.update_player_menu(player)
        assert _item_tuples(user.menus["turn_menu"]["items"]) == expected


def test_only_grid_kwargs_our_clients_understand_are_forwarded():
    game = get_game_class("pig")()
    user = MockUser("Alice", uuid="grid-1")
    player = game.add_player("Alice", user)
    game.on_start()
    game.build_menu_items = lambda player, user: MenuBuild(
        items=[], grid_kwargs={"grid_enabled": True, "grid_width": 3, "grid_height": 4}
    )

    items, grid_kwargs = game._turn_menu_build(player, user)

    assert items == []
    assert grid_kwargs == {"grid_enabled": True, "grid_width": 3}
