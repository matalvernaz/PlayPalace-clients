"""Number Chain — sequential tile placement on a 4x8 grid."""

from __future__ import annotations

import logging
import random
from dataclasses import dataclass, field

log = logging.getLogger(__name__)

from ..base import Game, Player, GameOptions
from ..registry import register_game
from ...game_utils.actions import Action, ActionSet, Visibility
from ...game_utils.options import MenuOption, option_field
from ...game_utils.bot_helper import BotHelper
from ...game_utils.game_result import GameResult, PlayerResult
from ...messages.localization import Localization
from server.core.ui.keybinds import KeybindState
from server.core.users.bot import Bot
from server.core.users.base import MenuItem, EscapeBehavior
from .bot import bot_think
from .moves import apply_move, generate_legal_moves, has_any_legal_move
from .state import (
    COLS,
    MAX_NUMBER,
    NUM_CELLS,
    NumberChainState,
    build_initial_state,
    index_to_rc,
    opponent_num,
    required_next_number,
)


BOT_DIFFICULTY_CHOICES = ["random", "simple"]
BOT_DIFFICULTY_LABELS = {
    "random": "numberchain-difficulty-random",
    "simple": "numberchain-difficulty-simple",
}


@dataclass
class NumberChainOptions(GameOptions):
    bot_difficulty: str = option_field(
        MenuOption(
            default="simple",
            choices=BOT_DIFFICULTY_CHOICES,
            choice_labels=BOT_DIFFICULTY_LABELS,
            value_key="bot_difficulty",
            label="numberchain-option-bot-difficulty",
            prompt="numberchain-option-select-bot-difficulty",
            change_msg="numberchain-option-changed-bot-difficulty",
        )
    )


@dataclass
class NumberChainPlayer(Player):
    player_num: int = 0  # 1 or 2


@register_game
@dataclass
class NumberChainGame(Game):
    """Number Chain — players build a shared 1-2-...-8-1-2 chain on a 4x8 grid."""

    players: list[NumberChainPlayer] = field(default_factory=list)
    options: NumberChainOptions = field(default_factory=NumberChainOptions)
    game_state: NumberChainState = field(default_factory=NumberChainState)

    @classmethod
    def get_name(cls) -> str:
        return "Number Chain"

    @classmethod
    def get_type(cls) -> str:
        return "numberchain"

    @classmethod
    def get_category(cls) -> str:
        return "category-board-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 2

    def create_player(
        self, player_id: str, name: str, is_bot: bool = False
    ) -> NumberChainPlayer:
        return NumberChainPlayer(id=player_id, name=name, is_bot=is_bot)

    def _player_locale(self, player: Player) -> str:
        user = self.get_user(player)
        return user.locale if user else "en"

    def _get_player_by_num(self, num: int) -> NumberChainPlayer | None:
        for p in self.players:
            if isinstance(p, NumberChainPlayer) and p.player_num == num:
                return p
        return None

    # ------------------------------------------------------------------ #
    # Action set
    # ------------------------------------------------------------------ #

    def create_turn_action_set(self, player: NumberChainPlayer) -> ActionSet:
        action_set = ActionSet(name="turn")
        locale = self._player_locale(player)

        for idx in range(NUM_CELLS):
            action_set.add(
                Action(
                    id=f"sq_{idx}",
                    label="",
                    handler="_action_square_click",
                    is_enabled="_is_square_enabled",
                    is_hidden="_is_square_hidden",
                    get_label="_get_square_label",
                    get_sound="_get_square_sound",
                    show_in_actions_menu=False,
                    show_disabled_label=False,
                )
            )

        # Info actions are surfaced via keybinds only; they don't clutter
        # the on-screen action list.
        local_actions = [
            Action(
                id="check_status",
                label=Localization.get(locale, "numberchain-check-status"),
                handler="_action_check_status",
                is_enabled="_is_info_enabled",
                is_hidden="_is_always_hidden",
            ),
            Action(
                id="check_inventory",
                label=Localization.get(locale, "numberchain-check-inventory"),
                handler="_action_check_inventory",
                is_enabled="_is_info_enabled",
                is_hidden="_is_always_hidden",
            ),
            Action(
                id="check_required",
                label=Localization.get(locale, "numberchain-check-required"),
                handler="_action_check_required",
                is_enabled="_is_info_enabled",
                is_hidden="_is_always_hidden",
            ),
        ]
        for action in reversed(local_actions):
            action_set.add(action)
            if action.id in action_set._order:
                action_set._order.remove(action.id)
            action_set._order.insert(0, action.id)

        for action_id in ("check_scores", "check_scores_detailed"):
            existing = action_set.get_action(action_id)
            if existing:
                existing.show_in_actions_menu = False

        return action_set

    def setup_keybinds(self) -> None:
        super().setup_keybinds()

        # Clear any base-class bindings on letters we want to reuse so the
        # game-specific shortcuts take precedence.
        if "s" in self._keybinds:
            self._keybinds["s"] = []

        self.define_keybind(
            "e", "Status", ["check_status"],
            state=KeybindState.ACTIVE, include_spectators=True,
        )
        self.define_keybind(
            "i", "Inventory", ["check_inventory"],
            state=KeybindState.ACTIVE, include_spectators=True,
        )
        self.define_keybind(
            "n", "Next number", ["check_required"],
            state=KeybindState.ACTIVE, include_spectators=True,
        )

    # ------------------------------------------------------------------ #
    # Grid menu rendering
    # ------------------------------------------------------------------ #

    def rebuild_player_menu(
        self,
        player: Player,
        *,
        position: int | None = None,
        play_selection_sound: bool = False,
    ) -> None:
        if self._destroyed or self.status == "finished":
            return
        if player.id in self._status_box_open:
            return
        user = self.get_user(player)
        if not user:
            return

        grid_items, other_items = self._build_menu_items(player, user)
        use_grid = len(grid_items) == NUM_CELLS

        user.show_menu(
            "turn_menu",
            grid_items + other_items,
            multiletter=False,
            escape_behavior=EscapeBehavior.KEYBIND,
            position=position,
            grid_enabled=use_grid,
            grid_width=COLS if use_grid else 1,
            play_selection_sound=play_selection_sound,
        )

    def update_player_menu(
        self,
        player: Player,
        selection_id: str | None = None,
        play_selection_sound: bool = False,
    ) -> None:
        if self._destroyed or self.status == "finished":
            return
        if player.id in self._status_box_open:
            return
        user = self.get_user(player)
        if not user:
            return

        grid_items, other_items = self._build_menu_items(player, user)

        user.update_menu(
            "turn_menu",
            grid_items + other_items,
            selection_id=selection_id,
            play_selection_sound=play_selection_sound,
        )

    def _build_menu_items(
        self, player: Player, user
    ) -> tuple[list[MenuItem], list[MenuItem]]:
        grid_items: list[MenuItem] = []
        other_items: list[MenuItem] = []
        for resolved in self.get_all_visible_actions(player):
            label = resolved.label
            if not resolved.enabled and resolved.action.show_disabled_label:
                unavailable = Localization.get(user.locale, "visibility-unavailable")
                label = f"{label}; {unavailable}"
            item = MenuItem(text=label, id=resolved.action.id, sound=resolved.sound)
            if resolved.action.id.startswith("sq_"):
                grid_items.append(item)
            else:
                other_items.append(item)
        return grid_items, other_items

    # ------------------------------------------------------------------ #
    # Lifecycle
    # ------------------------------------------------------------------ #

    def on_start(self) -> None:
        self.status = "playing"
        self.game_active = True
        self.round = 1

        active_players = [p for p in self.players if not p.is_spectator]
        self.set_turn_players(active_players, reset_index=True)

        self._team_manager.team_mode = "individual"
        self._team_manager.setup_teams([p.name for p in active_players])

        if random.random() < 0.5:  # nosec B311
            active_players[0].player_num = 1
            active_players[1].player_num = 2
        else:
            active_players[0].player_num = 2
            active_players[1].player_num = 1

        self.game_state = build_initial_state()

        p1 = self._get_player_by_num(1)
        p2 = self._get_player_by_num(2)
        first = p1
        self.current_player = first

        self.broadcast_l(
            "numberchain-game-started",
            p1=p1.name if p1 else "?",
            p2=p2.name if p2 else "?",
            first=first.name if first else "?",
        )

        BotHelper.jolt_bots(self, ticks=random.randint(4, 8))
        self.rebuild_all_menus()

    def on_tick(self) -> None:
        super().on_tick()
        self.process_scheduled_sounds()
        if not self.game_active:
            return
        BotHelper.on_tick(self)

    def bot_think(self, player: NumberChainPlayer) -> str | None:
        return bot_think(self, player)

    # ------------------------------------------------------------------ #
    # Square click → place tile
    # ------------------------------------------------------------------ #

    def _action_square_click(self, player: Player, action_id: str) -> None:
        if not isinstance(player, NumberChainPlayer):
            return
        gs = self.game_state
        if gs.current_player_num != player.player_num:
            return

        try:
            sq_idx = int(action_id.split("_")[1])
        except (ValueError, IndexError):
            return

        user = self.get_user(player)

        legal = [
            m for m in generate_legal_moves(gs, player.player_num) if m.index == sq_idx
        ]
        if not legal:
            if user:
                user.speak_l("numberchain-illegal-move")
            return

        self._apply_and_announce(player, legal[0])

    def _apply_and_announce(self, player: NumberChainPlayer, move) -> None:
        gs = self.game_state
        pnum = player.player_num

        apply_move(gs, move, pnum)
        row, col = index_to_rc(move.index)

        self.broadcast_personal_l(
            player,
            "numberchain-place-you",
            "numberchain-place-other",
            number=move.number,
            row=row + 1,
            col=col + 1,
        )
        self.broadcast_sound("game_squares/step1.ogg")

        opp = opponent_num(pnum)
        gs.current_player_num = opp
        opp_player = self._get_player_by_num(opp)
        if opp_player:
            self.current_player = opp_player

        if not has_any_legal_move(gs, opp):
            self._handle_win(player)
            return

        self.announce_turn()
        BotHelper.jolt_bots(self, ticks=random.randint(3, 6))
        self.rebuild_all_menus()

    # ------------------------------------------------------------------ #
    # Win
    # ------------------------------------------------------------------ #

    def _handle_win(self, winner: NumberChainPlayer) -> None:
        self.broadcast_l("numberchain-wins", player=winner.name)
        self.broadcast_sound("game_pig/win.ogg")
        self._winner = winner
        self.finish_game()

    def build_game_result(self) -> GameResult:
        from datetime import datetime

        winner = getattr(self, "_winner", None)
        p1 = self._get_player_by_num(1)
        p2 = self._get_player_by_num(2)

        return GameResult(
            game_type=self.get_type(),
            timestamp=datetime.now().isoformat(),
            duration_ticks=self.sound_scheduler_tick,
            player_results=[
                PlayerResult(
                    player_id=p.id,
                    player_name=p.name,
                    is_bot=p.is_bot,
                    is_virtual_bot=getattr(p, "is_virtual_bot", False),
                )
                for p in self.players
                if not p.is_spectator
            ],
            custom_data={
                "winner_name": winner.name if winner else None,
                "p1_name": p1.name if p1 else "?",
                "p2_name": p2.name if p2 else "?",
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        d = result.custom_data
        return [
            Localization.get(
                locale,
                "numberchain-final",
                winner=d.get("winner_name") or "?",
            )
        ]

    # ------------------------------------------------------------------ #
    # Info actions
    # ------------------------------------------------------------------ #

    def _action_check_status(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        gs = self.game_state
        current = self._get_player_by_num(gs.current_player_num)
        user.speak_l(
            "numberchain-status",
            current=current.name if current else "?",
            required=required_next_number(gs),
        )

    def _action_check_inventory(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        if not isinstance(player, NumberChainPlayer):
            return
        gs = self.game_state
        parts = [
            f"{n}×{gs.inventory[player.player_num][n]}"
            for n in range(1, MAX_NUMBER + 1)
        ]
        user.speak_l("numberchain-inventory", inventory=", ".join(parts))

    def _action_check_required(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        gs = self.game_state
        user.speak_l("numberchain-required", required=required_next_number(gs))

    # ------------------------------------------------------------------ #
    # Leave handling
    # ------------------------------------------------------------------ #

    def _perform_leave_game(self, player: Player) -> None:
        if self.status == "playing" and not player.is_bot:
            player.is_bot = True
            self._users.pop(player.id, None)
            bot_user = Bot(player.name, uuid=player.id)
            self.attach_user(player.id, bot_user)
            self.broadcast_l("player-replaced-by-bot", player=player.name)

            has_humans = any(not p.is_bot for p in self.players)
            if not has_humans:
                self.destroy()
                return

            self.rebuild_all_menus()
            return

        self.players = [p for p in self.players if p.id != player.id]
        self.player_action_sets.pop(player.id, None)
        self._users.pop(player.id, None)
        self.broadcast_l("table-left", player=player.name)

        has_humans = any(not p.is_bot for p in self.players)
        if not has_humans:
            self.destroy()
            return

    # ------------------------------------------------------------------ #
    # Visibility / enabled / label / sound callbacks
    # ------------------------------------------------------------------ #

    def _is_square_enabled(self, player: Player, action_id: str) -> str | None:
        if self.status != "playing":
            return "action-not-playing"
        if not isinstance(player, NumberChainPlayer):
            return "action-not-available"
        gs = self.game_state
        if gs.current_player_num != player.player_num:
            return "action-not-your-turn"
        return None

    def _is_square_hidden(self, player: Player, action_id: str) -> Visibility:
        if self.status != "playing":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_square_label(self, player: Player, action_id: str) -> str:
        try:
            sq_idx = int(action_id.split("_")[1])
        except (ValueError, IndexError):
            return ""

        gs = self.game_state
        locale = self._player_locale(player)
        row, col = index_to_rc(sq_idx)
        number = gs.numbers[sq_idx]
        owner_num = gs.owners[sq_idx]

        if number == 0:
            return Localization.get(
                locale,
                "numberchain-sq-empty",
                row=row + 1,
                col=col + 1,
            )

        if isinstance(player, NumberChainPlayer) and owner_num == player.player_num:
            return Localization.get(
                locale,
                "numberchain-sq-own",
                row=row + 1,
                col=col + 1,
                number=number,
            )

        owner = self._get_player_by_num(owner_num)
        return Localization.get(
            locale,
            "numberchain-sq-opponent",
            row=row + 1,
            col=col + 1,
            number=number,
            owner=owner.name if owner else "?",
        )

    def _get_square_sound(self, player: Player, action_id: str) -> str | None:
        try:
            sq_idx = int(action_id.split("_")[1])
        except (ValueError, IndexError):
            return None
        gs = self.game_state
        if gs.numbers[sq_idx] == 0:
            return None
        is_own = (
            isinstance(player, NumberChainPlayer)
            and gs.owners[sq_idx] == player.player_num
        )
        if is_own:
            return "game_squares/token1.ogg"
        return "game_squares/token7.ogg"

    def _is_info_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "action-not-playing"
        return None

    def _is_check_scores_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    def _is_check_scores_detailed_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    def _is_always_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN
