"""Tests for Monopoly scaffold and preset wiring."""

from server.games.monopoly.game import (
    MonopolyGame,
    MonopolyOptions,
    STARTING_CASH,
    PASS_GO_CASH,
)
from server.games.monopoly.presets import (
    DEFAULT_PRESET_ID,
    get_available_preset_ids,
    get_default_preset_id,
    get_preset,
)
from server.games.registry import get_game_class
from server.users.test_user import MockUser


def _create_two_player_game(options: MonopolyOptions | None = None) -> MonopolyGame:
    """Create a Monopoly game with two human players."""
    game = MonopolyGame(options=options or MonopolyOptions())
    host_user = MockUser("Host")
    guest_user = MockUser("Guest")
    game.add_player("Host", host_user)
    game.add_player("Guest", guest_user)
    game.host = "Host"
    return game


def _start_two_player_game(options: MonopolyOptions | None = None) -> MonopolyGame:
    """Create and start a two player Monopoly game."""
    game = _create_two_player_game(options)
    game.on_start()
    return game


def test_monopoly_game_creation():
    game = MonopolyGame()
    assert game.get_name() == "Monopoly"
    assert game.get_name_key() == "game-name-monopoly"
    assert game.get_type() == "monopoly"
    assert game.get_category() == "category-uncategorized"
    assert game.get_min_players() == 2
    assert game.get_max_players() == 6
    assert game.options.preset_id == DEFAULT_PRESET_ID


def test_monopoly_registered():
    assert get_game_class("monopoly") is MonopolyGame


def test_monopoly_preset_catalog_includes_classic():
    preset_ids = get_available_preset_ids()
    assert DEFAULT_PRESET_ID in preset_ids

    default_preset = get_preset(get_default_preset_id())
    assert default_preset is not None
    assert default_preset.edition_count > 0


def test_monopoly_options_present_catalog_preset_choices():
    game = _create_two_player_game()
    host_player = game.players[0]
    options_action_set = game.get_action_set(host_player, "options")
    assert options_action_set is not None

    set_preset_action = options_action_set.get_action("set_preset_id")
    assert set_preset_action is not None

    menu_options = game._get_menu_options_for_action(set_preset_action, host_player)
    assert menu_options is not None
    assert DEFAULT_PRESET_ID in menu_options


def test_monopoly_on_start_uses_selected_preset():
    game = _start_two_player_game(MonopolyOptions(preset_id="junior"))

    assert game.status == "playing"
    assert game.game_active is True
    assert game.active_preset_id == "junior"
    assert game.active_preset_name
    assert game.active_edition_ids
    assert len(game.team_manager.teams) == 2


def test_monopoly_on_start_falls_back_to_default_preset():
    game = _start_two_player_game(MonopolyOptions(preset_id="not-a-real-preset"))

    assert game.active_preset_id == get_default_preset_id()
    assert game.options.preset_id == get_default_preset_id()


def test_monopoly_on_start_initializes_cash_positions_and_scores():
    game = _start_two_player_game()

    assert game.current_player is not None
    assert game.current_player.name == "Host"
    assert game.turn_has_rolled is False
    assert game.turn_pending_purchase_space_id == ""
    assert len(game.property_owners) == 0

    for player in game.players:
        assert player.position == 0
        assert player.cash == STARTING_CASH
        assert player.owned_space_ids == []

    assert len(game.team_manager.teams) == 2
    assert sorted(team.total_score for team in game.team_manager.teams) == [
        STARTING_CASH,
        STARTING_CASH,
    ]


def test_monopoly_roll_sets_pending_property_when_unowned(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None

    rolls = iter([1, 2])  # total = 3 -> Baltic Avenue
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")

    assert host.position == 3
    assert game.turn_has_rolled is True
    assert game.turn_pending_purchase_space_id == "baltic_avenue"
    assert host.cash == STARTING_CASH


def test_monopoly_buy_property_deducts_cash_and_assigns_owner(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None

    rolls = iter([1, 2])  # total = 3 -> Baltic Avenue ($60)
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")
    game.execute_action(host, "buy_property")

    assert game.property_owners["baltic_avenue"] == host.id
    assert host.cash == STARTING_CASH - 60
    assert "baltic_avenue" in host.owned_space_ids
    assert game.turn_pending_purchase_space_id == ""


def test_monopoly_end_turn_advances_and_resets_turn_state(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None

    rolls = iter([1, 2])
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))
    game.execute_action(host, "roll_dice")
    assert game.turn_has_rolled is True

    game.execute_action(host, "end_turn")

    assert game.current_player is not None
    assert game.current_player.name == "Guest"
    assert game.turn_has_rolled is False
    assert game.turn_last_roll == []
    assert game.turn_pending_purchase_space_id == ""


def test_monopoly_pass_go_awards_cash(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None
    host.position = 39

    rolls = iter([1, 1])  # total = 2 -> wraps around
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")

    assert host.position == 1
    assert host.cash == STARTING_CASH + PASS_GO_CASH


def test_monopoly_rent_transfers_cash_to_owner(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None

    # Host lands on Baltic (3), buys it, then ends turn.
    # Guest lands on Baltic and pays rent (4).
    rolls = iter([1, 2, 1, 2])
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")
    game.execute_action(host, "buy_property")
    game.execute_action(host, "end_turn")

    guest = game.current_player
    assert guest is not None
    game.execute_action(guest, "roll_dice")

    assert host.cash == STARTING_CASH - 60 + 4
    assert guest.cash == STARTING_CASH - 4


def test_monopoly_income_tax_space_deducts_cash(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None

    rolls = iter([2, 2])  # total = 4 -> Income Tax
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")

    assert host.position == 4
    assert host.cash == STARTING_CASH - 200
    assert game.turn_pending_purchase_space_id == ""


def test_monopoly_go_to_jail_space_moves_player_to_jail(monkeypatch):
    game = _start_two_player_game()
    host = game.current_player
    assert host is not None
    host.position = 28

    rolls = iter([1, 1])  # total = 2 -> Go to Jail
    monkeypatch.setattr("server.games.monopoly.game.random.randint", lambda a, b: next(rolls))

    game.execute_action(host, "roll_dice")

    assert host.position == 10
    assert game.turn_pending_purchase_space_id == ""
