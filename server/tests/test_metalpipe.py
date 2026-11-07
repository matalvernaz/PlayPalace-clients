"""Tests for the Metal Pipe game."""

from pathlib import Path
import re
from unittest.mock import patch

from ..games.metalpipe.game import BONK_SEQUENCE_ID, MetalPipeGame, MetalPipeOptions
from ..games.registry import GameRegistry
from ..messages.localization import Localization
from ..users.test_user import MockUser


_locales_dir = Path(__file__).resolve().parents[1] / "locales"


def make_game(
    *,
    player_count: int = 3,
    mobile_first: bool = False,
    locale: str = "en",
    **option_overrides,
) -> tuple[MetalPipeGame, list[MockUser]]:
    game = MetalPipeGame(options=MetalPipeOptions(**option_overrides))
    game.setup_keybinds()
    users: list[MockUser] = []
    for index in range(player_count):
        user = MockUser(
            f"Player{index + 1}",
            locale=locale,
            uuid=f"metalpipe-p{index + 1}",
        )
        if mobile_first and index == 0:
            user.client_type = "mobile"
        users.append(user)
        game.add_player(user.username, user)
    game.host = users[0].username
    return game, users


def advance_until(game: MetalPipeGame, condition, max_ticks: int = 500) -> bool:
    for _ in range(max_ticks):
        if condition():
            return True
        game.on_tick()
    return condition()


def test_game_registered_defaults_and_metadata() -> None:
    assert GameRegistry.get("metalpipe") is MetalPipeGame
    game = MetalPipeGame()

    assert game.get_name() == "Metal Pipe"
    assert game.get_type() == "metalpipe"
    assert game.get_category() == "misc"
    assert game.get_min_players() == 2
    assert game.get_max_players() == 8
    assert game.get_supported_leaderboards() == []
    assert game.relevant_preferences == ["brief_announcements"]
    assert game.options.multiple_bonks is False
    assert game.options.allow_self_bonk is True


def test_start_resets_players_and_announces_automatic_mode() -> None:
    game, users = make_game(player_count=2)
    game.players[1].alive = False

    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()

    assert game.status == "playing"
    assert game.game_active is True
    assert all(player.alive for player in game.players)
    assert game.has_active_sequence(sequence_id=BONK_SEQUENCE_ID)
    assert users[0].get_spoken_messages()[0] == (
        "Metal Pipe begins in Single bonk mode. The pipe will choose everything automatically."
    )


def test_single_bonk_other_uses_personal_victim_and_public_messages() -> None:
    game, users = make_game(allow_self_bonk=False)

    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()
        for user in users:
            user.clear_messages()
        assert advance_until(game, lambda: game.bonk_count == 1)

    assert game.players[1].alive is False
    assert users[0].get_last_spoken() == (
        "You swing the metal pipe and hit Player2. Player2 is eliminated."
    )
    assert users[1].get_last_spoken() == (
        "Player1 swings the metal pipe and hits you. You are eliminated."
    )
    assert users[2].get_last_spoken() == (
        "Player1 swings the metal pipe and hits Player2. Player2 is eliminated."
    )

    assert advance_until(game, lambda: game.status == "finished")
    assert game.winner_ids == [game.players[0].id]
    assert game.winner_names == ["Player1"]


def test_single_self_bonk_makes_everyone_else_winners() -> None:
    game, users = make_game()

    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[0].id],
    ):
        game.on_start()
        for user in users:
            user.clear_messages()
        assert advance_until(game, lambda: game.status == "finished")

    assert game.players[0].alive is False
    assert set(game.winner_ids) == {game.players[1].id, game.players[2].id}
    assert (
        users[0].get_spoken_messages()[-1]
        == "Player2 and Player3 win. The metal pipe has spoken."
    )
    assert (
        users[1].get_spoken_messages()[-1]
        == "You win along with Player3. The metal pipe has spoken."
    )
    assert (
        users[2].get_spoken_messages()[-1]
        == "You win along with Player2. The metal pipe has spoken."
    )


def test_multiple_bonks_continues_until_last_standing() -> None:
    game, _ = make_game(multiple_bonks=True)

    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[
            game.players[0].id,
            game.players[1].id,
            game.players[0].id,
            game.players[0].id,
        ],
    ):
        game.on_start()
        assert advance_until(game, lambda: game.status == "finished")

    assert game.bonk_count == 2
    assert game.winner_ids == [game.players[2].id]
    assert [player.alive for player in game.players] == [False, False, True]


def test_touch_standard_actions_include_status_turn_and_table_controls() -> None:
    game, users = make_game(player_count=2, mobile_first=True)
    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()

    action_set = game.create_standard_action_set(game.players[0])
    order = action_set._order
    assert order.index("check_status") < order.index("whose_turn")
    assert order.index("whose_turn") < order.index("whos_at_table")

    game.refresh_menus(game.players[0])
    game.flush_menus()
    visible_ids = [
        item.id
        for item in users[0].menus["turn_menu"]["items"]
        if getattr(item, "id", None)
    ]
    assert "check_status" in visible_ids
    assert "whose_turn" in visible_ids
    assert "whos_at_table" in visible_ids
    assert "check_scores" not in visible_ids
    assert "web_actions_menu" in visible_ids
    assert "web_leave_table" in visible_ids


def test_whose_turn_reports_automatic_phase() -> None:
    game, users = make_game(player_count=2)
    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()

    users[0].clear_messages()
    game.execute_action(game.players[0], "whose_turn")

    assert users[0].get_last_spoken() == (
        "Metal Pipe is resolving automatically. There are 2 players still standing, "
        "and no player has a manual turn."
    )


def test_live_status_box_uses_stable_rows_and_refreshes() -> None:
    game, users = make_game(player_count=2)
    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()

    game.execute_action(game.players[0], "check_status")
    items = users[0].menus["status_box"]["items"]
    assert [item.id for item in items] == [
        "mode",
        "progress",
        "last_bonk",
        "player:metalpipe-p1",
        "player:metalpipe-p2",
    ]
    assert "Bonks resolved: 0" in items[1].text
    assert items[2].text == "The pipe has not landed yet."

    assert advance_until(game, lambda: game.bonk_count == 1)
    game.flush_menus()

    updated_items = users[0].menus["status_box"]["items"]
    assert [item.id for item in updated_items] == [item.id for item in items]
    assert "Bonks resolved: 1" in updated_items[1].text
    assert updated_items[2].text == "Last bonk: Player1 hit Player2."
    assert updated_items[-1].text == "Player2: Eliminated."


def test_brief_announcements_are_per_listener() -> None:
    game, users = make_game(allow_self_bonk=False)
    users[0].preferences.brief_announcements = True

    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()
        for user in users:
            user.clear_messages()
        assert advance_until(game, lambda: game.bonk_count == 1)

    assert users[0].get_last_spoken() == "You hit Player2. Player2 out."
    assert users[1].get_last_spoken() == (
        "Player1 swings the metal pipe and hits you. You are eliminated."
    )


def test_desktop_keybind_can_open_status_without_desktop_action_button() -> None:
    game, users = make_game(player_count=2)
    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()

    game.handle_event(game.players[0], {"type": "keybind", "key": "c"})

    assert "status_box" in users[0].menus
    visible_ids = [
        resolved.action.id for resolved in game.get_all_visible_actions(game.players[0])
    ]
    assert "check_status" not in visible_ids


def test_game_result_and_end_screen_keep_scoreless_winner_data() -> None:
    game, _ = make_game(player_count=2, allow_self_bonk=False)
    with patch(
        "server.games.metalpipe.game.random.choice",
        side_effect=[game.players[0].id, game.players[1].id],
    ):
        game.on_start()
        assert advance_until(game, lambda: game.status == "finished")

    result = game.build_game_result()
    assert result.custom_data["winner_names"] == ["Player1"]
    assert result.custom_data["bonk_count"] == 1
    assert result.custom_data["alive_status"] == {"Player1": True, "Player2": False}
    assert game.format_end_screen(result, "en") == [
        "Metal Pipe results",
        "Winner: Player1.",
        "Player1: Standing",
        "Player2: Eliminated",
    ]


def test_metalpipe_locale_key_and_variable_parity() -> None:
    en_text = (_locales_dir / "en" / "metalpipe.ftl").read_text(encoding="utf-8")
    vi_text = (_locales_dir / "vi" / "metalpipe.ftl").read_text(encoding="utf-8")

    def messages(text: str) -> dict[str, set[str]]:
        result = {}
        current_key = None
        current_lines: list[str] = []
        for line in text.splitlines():
            if line and not line.startswith((" ", "\t")) and "=" in line:
                if current_key is not None:
                    result[current_key] = set(
                        re.findall(
                            r"\{\s*\$([a-zA-Z_][\w-]*)",
                            "\n".join(current_lines),
                        )
                    )
                current_key = line.split("=", 1)[0].strip()
                current_lines = [line]
            elif current_key is not None:
                current_lines.append(line)
        if current_key is not None:
            result[current_key] = set(
                re.findall(r"\{\s*\$([a-zA-Z_][\w-]*)", "\n".join(current_lines))
            )
        return result

    assert messages(en_text) == messages(vi_text)


def test_vietnamese_documentation_uses_in_game_terms() -> None:
    document = (
        Path(__file__).resolve().parents[1]
        / "documentation"
        / "content"
        / "vi"
        / "games"
        / "metalpipe.md"
    ).read_text(encoding="utf-8")

    assert Localization.get("vi", "game-name-metalpipe") in document
    assert "Phang liên hoàn" in document
    assert "Cho phép tự phang" in document
    assert "còn đứng vững" in document
