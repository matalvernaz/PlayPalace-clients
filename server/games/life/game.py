"""The Game of Life — main game implementation.

Flow summary:

    on_start -> set up track, event deck, tiles, deal per-player path prompt
    _start_turn -> current player's menu shows whatever they're being asked
                   for (spin, choose path, pick career, insurance offer, ...)
    _action_spin -> animate, resolve_landing on destination, set up next
                    prompt or end_turn depending on the space
    retirement -> individual players finish the track and choose Millionaire
                  Estates or Countryside Acres; once everyone has retired,
                  the Estates LIFE-tile bonus is awarded and totals are tallied.

Status readouts use status_box so both desktop and iOS get a navigable
list instead of a single spoken blob. This mirrors the pattern milebymile
uses for its custom status menu.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
import random

from ..base import Game, Player
from ..registry import register_game
from ...game_utils.actions import Action, ActionSet, MenuInput, Visibility
from ...game_utils.bot_helper import BotHelper
from ...game_utils.game_result import GameResult, PlayerResult
from ...game_utils.game_status import GameStatus
from ...messages.localization import Localization
from server.core.ui.keybinds import KeybindState

from . import bot as life_bot
from .options import LifeOptions
from .player import LifePlayer
from .state import (
    BANK_LOAN_REPAYMENT,
    BANK_LOAN_VALUE,
    CANONICAL_CAREERS,
    COLLEGE_LOAN_PRINCIPAL,
    EVENT_DECK,
    EventEffect,
    EventDef,
    HOUSE_DEEDS,
    INSURABLE_TO_TYPE,
    INSURANCE_PREMIUMS,
    LIFE_TILE_VALUES,
    RISK_IT_PRIZE,
    RISK_IT_STAKE,
    RISK_IT_THRESHOLD,
    SALARY_CARDS,
    STOCK_COST,
    STOCK_PAYOUT,
    Space,
    SpaceType,
    build_track,
    filter_events_for_options,
)


def _fmt_money(n: int) -> str:
    """Format a money amount as a comma-separated string without the dollar sign."""
    return f"{n:,}"


@dataclass
@register_game
class GameOfLifeGame(Game):
    """The Game of Life — Milton Bradley's spinner-and-track life sim."""

    players: list[LifePlayer] = field(default_factory=list)
    options: LifeOptions = field(default_factory=LifeOptions)

    # Static board data (rebuilt each game; serialized so reload is clean)
    track: list[Space] = field(default_factory=list)
    event_deck: list[EventDef] = field(default_factory=list)
    event_layout: dict[int, str] = field(default_factory=dict)  # space index -> event key
    career_pool: list[int] = field(default_factory=list)  # indices into CANONICAL_CAREERS
    degree_career_pool: list[int] = field(default_factory=list)
    nondegree_career_pool: list[int] = field(default_factory=list)
    salary_pool: list[int] = field(default_factory=list)
    house_deed_pool: list[int] = field(default_factory=list)
    available_stock_numbers: list[int] = field(default_factory=list)
    life_tile_pool: list[int] = field(default_factory=list)
    estates_tile_values: list[int] = field(default_factory=list)

    # Live game state
    players_finished: list[str] = field(default_factory=list)  # ids that have retired
    game_phase: str = "play"  # "play" | "tally" | "done"

    estates_players: list[str] = field(default_factory=list)  # ids who chose estates

    # Tally animation progress (ticks)
    tally_index: int = 0

    # Per-player pending career offers (player_id -> list of CANONICAL_CAREERS indices)
    career_offers: dict[str, list[int]] = field(default_factory=dict)
    salary_offers: dict[str, list[int]] = field(default_factory=dict)

    # ---------------------------------------------------------------------
    # Metadata
    # ---------------------------------------------------------------------

    @classmethod
    def get_name(cls) -> str:
        return "The Game of Life"

    @classmethod
    def get_type(cls) -> str:
        return "life"

    @classmethod
    def get_category(cls) -> str:
        return "category-board-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 6

    def create_player(self, player_id: str, name: str, is_bot: bool = False) -> LifePlayer:
        return LifePlayer(id=player_id, name=name, is_bot=is_bot)

    # ---------------------------------------------------------------------
    # Start / setup
    # ---------------------------------------------------------------------

    def on_start(self) -> None:
        self.status = GameStatus.PLAYING
        self.game_active = True
        self.game_phase = "play"
        self.players_finished = []
        self.estates_players = []
        self.career_offers = {}
        self.salary_offers = {}

        # Build the board and event deck.
        self.track = build_track(self.options.track_length)
        self.event_deck = filter_events_for_options(
            EVENT_DECK,
            stock_market_enabled=self.options.stock_market,
            insurance_mode=self.options.insurance,
            life_tiles_mode=self.options.life_tiles,
        )
        self._build_event_layout()

        # Career pools.
        self.career_pool = list(range(len(CANONICAL_CAREERS)))
        self.degree_career_pool = [
            i for i, c in enumerate(CANONICAL_CAREERS) if c.degree_required
        ]
        self.nondegree_career_pool = [
            i for i, c in enumerate(CANONICAL_CAREERS) if not c.degree_required
        ]
        self.salary_pool = list(range(len(SALARY_CARDS)))
        self.house_deed_pool = list(range(len(HOUSE_DEEDS)))
        self.available_stock_numbers = list(range(1, 10))

        # Life tile pool (drawn without replacement during the game).
        if self.options.life_tiles == "off":
            self.life_tile_pool = []
            self.estates_tile_values = []
        else:
            self.life_tile_pool = list(LIFE_TILE_VALUES)
            random.shuffle(self.life_tile_pool)  # nosec B311
            self.estates_tile_values = [
                self.life_tile_pool.pop()
                for _ in range(min(4, len(self.life_tile_pool)))
            ]

        # Per-player init.
        for p in self.players:
            p.position = 0
            p.cash = self.options.starting_cash
            p.retired = False
            p.retirement_choice = "none"
            p.awaiting_spin = True
            p.path = "none"
            p.college_loan = 0
            p.career_index = -1
            p.career_key = ""
            p.career_label_key = ""
            p.salary = 0
            p.salary_taxes = 0
            p.salary_card_index = -1
            p.married = False
            p.children = 0
            p.house_key = ""
            p.house_label_key = ""
            p.house_price = 0
            p.house_insurance_cost = 0
            p.has_fire_insurance = False
            p.has_auto_insurance = False
            p.has_life_insurance = False
            p.has_full_insurance = False
            p.stock_number = 0
            p.extra_stock_numbers = []
            p.life_tile_values = []
            p.pending = "path" if self.options.college_path else ""
            p.pending_options = []
            p.pending_event_key = ""
            p.turns_since_college_start = 0

        # The no-college lobby variant deals one random unrestricted career and
        # one random Salary Card, with no debt.
        if not self.options.college_path:
            for p in self.players:
                p.path = "career"
                self._deal_random_career_and_salary(p, allow_degree=True)

        self.set_turn_players(self.get_active_players())
        if self.turn_player_ids:
            opening_spins = [
                random.randint(1, 10)  # nosec B311
                for _ in self.turn_player_ids
            ]
            self.turn_index = max(range(len(opening_spins)), key=opening_spins.__getitem__)
        self.play_music("game_pig/mus.ogg")
        self.broadcast_l("game-life-desc")

        self._start_turn()

    def _build_event_layout(self) -> None:
        """Assign one event key to every EVENT space on the track."""
        event_space_indices = [s.index for s in self.track if s.type == SpaceType.EVENT]
        deck_keys = [e.key for e in self.event_deck]
        if not deck_keys:
            # Shouldn't happen, but keep the game valid.
            self.event_layout = {idx: "taxes" for idx in event_space_indices}
            return

        if self.options.event_layout == "fixed":
            # Deterministic rotation through the deck.
            layout = {}
            for i, idx in enumerate(event_space_indices):
                layout[idx] = deck_keys[i % len(deck_keys)]
            self.event_layout = layout
        else:
            # Shuffle keys across the event spaces.
            shuffled = deck_keys * ((len(event_space_indices) // len(deck_keys)) + 1)
            random.shuffle(shuffled)  # nosec B311
            self.event_layout = {idx: shuffled[i] for i, idx in enumerate(event_space_indices)}

    # ---------------------------------------------------------------------
    # Turn management
    # ---------------------------------------------------------------------

    def _start_turn(self, previous_player: LifePlayer | None = None) -> None:
        player = self.current_player
        if not player:
            self._maybe_advance_phase()
            return
        lp: LifePlayer = player  # type: ignore

        # Skip retired players — advance until we find someone still playing.
        safety = 0
        while lp.retired and safety <= len(self.players):
            self.turn_index = (self.turn_index + 1) % len(self.turn_player_ids)
            player = self.current_player
            lp = player  # type: ignore
            safety += 1
        if safety > len(self.players):
            # Everyone is retired; move on.
            self._maybe_advance_phase()
            return

        user = self.get_user(player)
        if user and getattr(user.preferences, "play_turn_sound", True):
            user.play_sound("game_pig/turn.ogg")

        if lp.retired:
            self.broadcast_l("life-turn-retirement", player=player.name)
        else:
            self.broadcast_l(
                "life-turn-start",
                player=player.name,
                position=lp.position,
                total=len(self.track) - 1,
            )

        if player.is_bot:
            BotHelper.jolt_bot(player, ticks=random.randint(25, 45))

        # Rebuild menus.
        if previous_player is not None:
            self.rebuild_player_menu(player, position=1)
            if previous_player != player:
                self.rebuild_player_menu(previous_player)
        else:
            for p in self.players:
                if p == player:
                    self.rebuild_player_menu(p, position=1)
                else:
                    self.rebuild_player_menu(p)

    def end_turn(self) -> None:
        previous = self.current_player
        lp: LifePlayer | None = previous  # type: ignore
        # Reset transient flags on the player whose turn just ended.
        if lp is not None and not lp.retired:
            lp.awaiting_spin = True
        self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
        self._start_turn(previous_player=previous)

    def _maybe_advance_phase(self) -> None:
        """Move from play to the final LIFE-tile tally."""
        # If everyone's retired, start the endgame.
        if self.game_phase == "play" and self._everyone_retired():
            self._begin_endgame()
            return
        if self.game_phase == "tally":
            # Tally runs itself via scheduled events.
            return

    def _everyone_retired(self) -> bool:
        for p in self.get_active_players():
            if not getattr(p, "retired", False):
                return False
        return True

    # ---------------------------------------------------------------------
    # Action sets & keybinds
    # ---------------------------------------------------------------------

    def create_turn_action_set(self, player: LifePlayer) -> ActionSet:  # type: ignore[override]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        action_set = ActionSet(name="turn")

        # Spin.
        action_set.add(
            Action(
                id="spin",
                label=Localization.get(locale, "life-action-spin"),
                handler="_action_spin",
                is_enabled="_is_spin_enabled",
                is_hidden="_is_spin_hidden",
            )
        )

        # Path fork.
        action_set.add(
            Action(
                id="choose_college",
                label=Localization.get(locale, "life-action-choose-college"),
                handler="_action_choose_college",
                is_enabled="_is_path_enabled",
                is_hidden="_is_path_hidden",
            )
        )
        action_set.add(
            Action(
                id="choose_career_path",
                label=Localization.get(locale, "life-action-choose-career"),
                handler="_action_choose_career_path",
                is_enabled="_is_path_enabled",
                is_hidden="_is_path_hidden",
            )
        )

        # Career picks (up to 3 slots).
        for slot in range(3):
            action_set.add(
                Action(
                    id=f"pick_career_{slot}",
                    label="",  # dynamic
                    handler="_action_pick_career",
                    is_enabled="_is_career_pick_enabled",
                    is_hidden="_is_career_pick_hidden",
                    get_label="_get_career_pick_label",
                )
            )

        for slot in range(3):
            action_set.add(
                Action(
                    id=f"pick_salary_{slot}",
                    label="",
                    handler="_action_pick_salary",
                    is_enabled="_is_salary_pick_enabled",
                    is_hidden="_is_salary_pick_hidden",
                    get_label="_get_salary_pick_label",
                )
            )

        for slot in range(6):
            action_set.add(
                Action(
                    id=f"steal_tile_{slot}",
                    label="",
                    handler="_action_steal_tile",
                    is_enabled="_is_steal_tile_enabled",
                    is_hidden="_is_steal_tile_hidden",
                    get_label="_get_steal_tile_label",
                )
            )

        # Insurance buys (full mode).
        for ins_type in ("fire", "auto", "life"):
            action_set.add(
                Action(
                    id=f"buy_{ins_type}_insurance",
                    label="",  # dynamic
                    handler="_action_buy_insurance",
                    is_enabled="_is_buy_insurance_enabled",
                    is_hidden="_is_buy_insurance_hidden",
                    get_label="_get_buy_insurance_label",
                )
            )
        # Simplified-mode single policy.
        action_set.add(
            Action(
                id="buy_full_insurance",
                label="",
                handler="_action_buy_insurance",
                is_enabled="_is_buy_insurance_enabled",
                is_hidden="_is_buy_insurance_hidden",
                get_label="_get_buy_insurance_label",
            )
        )
        action_set.add(
            Action(
                id="skip_insurance",
                label=Localization.get(locale, "life-action-skip-insurance"),
                handler="_action_skip_insurance",
                is_enabled="_is_insurance_skip_enabled",
                is_hidden="_is_insurance_skip_hidden",
            )
        )

        # Stock actions.
        action_set.add(
            Action(
                id="buy_stock",
                label="",
                handler="_action_buy_stock",
                is_enabled="_is_buy_stock_enabled",
                is_hidden="_is_buy_stock_hidden",
                get_label="_get_buy_stock_label",
                input_request=MenuInput(
                    prompt="life-stock-prompt",
                    options="_stock_number_options",
                    bot_select="_bot_select_stock_number",
                    include_cancel=False,
                ),
            )
        )
        action_set.add(
            Action(
                id="skip_stock",
                label=Localization.get(locale, "life-action-skip-stock"),
                handler="_action_skip_stock",
                is_enabled="_is_stock_skip_enabled",
                is_hidden="_is_stock_skip_hidden",
            )
        )

        # Risk It.
        action_set.add(
            Action(
                id="risk_it",
                label="",
                handler="_action_risk_it",
                is_enabled="_is_risk_it_enabled",
                is_hidden="_is_risk_it_hidden",
                get_label="_get_risk_it_label",
            )
        )
        action_set.add(
            Action(
                id="skip_risk_it",
                label=Localization.get(locale, "life-action-skip-risk-it"),
                handler="_action_skip_risk_it",
                is_enabled="_is_risk_skip_enabled",
                is_hidden="_is_risk_skip_hidden",
            )
        )

        # Retirement.
        action_set.add(
            Action(
                id="choose_estates",
                label=Localization.get(locale, "life-action-choose-estates"),
                handler="_action_choose_estates",
                is_enabled="_is_retirement_enabled",
                is_hidden="_is_retirement_hidden",
            )
        )
        action_set.add(
            Action(
                id="choose_acres",
                label=Localization.get(locale, "life-action-choose-acres"),
                handler="_action_choose_acres",
                is_enabled="_is_retirement_enabled",
                is_hidden="_is_retirement_hidden",
            )
        )

        return action_set

    def create_standard_action_set(self, player: LifePlayer) -> ActionSet:  # type: ignore[override]
        action_set = super().create_standard_action_set(player)
        user = self.get_user(player)
        locale = user.locale if user else "en"

        # Status overrides.
        status_action = Action(
            id="check_status",
            label=Localization.get(locale, "life-action-check-status"),
            handler="_action_check_status",
            is_enabled="_is_check_status_enabled",
            is_hidden="_is_check_status_hidden",
        )
        action_set.add(status_action)
        if status_action.id in action_set._order:
            action_set._order.remove(status_action.id)
        action_set._order.insert(0, status_action.id)

        detailed = Action(
            id="check_status_detailed",
            label=Localization.get(locale, "life-action-detailed-status"),
            handler="_action_check_status_detailed",
            is_enabled="_is_check_status_enabled",
            is_hidden="_is_check_status_hidden",
        )
        action_set.add(detailed)
        if detailed.id in action_set._order:
            action_set._order.remove(detailed.id)
        action_set._order.insert(1, detailed.id)

        # Hide the base check_scores entries — our status menu replaces them.
        for aid in ("check_scores", "check_scores_detailed"):
            existing = action_set.get_action(aid)
            if existing:
                existing.show_in_actions_menu = False

        # Always-available game actions.
        action_set.add(
            Action(
                id="take_loan",
                label=Localization.get(locale, "life-action-take-loan"),
                handler="_action_take_loan",
                is_enabled="_is_take_loan_enabled",
                is_hidden="_is_take_loan_hidden",
            )
        )
        action_set.add(
            Action(
                id="pay_loan",
                label="",
                handler="_action_pay_loan",
                is_enabled="_is_pay_loan_enabled",
                is_hidden="_is_pay_loan_hidden",
                get_label="_get_pay_loan_label",
            )
        )
        return action_set

    def setup_keybinds(self) -> None:
        super().setup_keybinds()

        if "s" in self._keybinds:
            self._keybinds["s"] = []
        if "shift+s" in self._keybinds:
            self._keybinds["shift+s"] = []

        self.define_keybind(
            "s",
            "Check status",
            ["check_status"],
            state=KeybindState.ACTIVE,
            include_spectators=True,
        )
        self.define_keybind(
            "shift+s",
            "Detailed status",
            ["check_status_detailed"],
            state=KeybindState.ACTIVE,
            include_spectators=True,
        )
        self.define_keybind("r", "Spin", ["spin"], state=KeybindState.ACTIVE)
        self.define_keybind("space", "Spin", ["spin"], state=KeybindState.ACTIVE)

    # ---------------------------------------------------------------------
    # Visibility / enabled helpers (turn actions)
    # ---------------------------------------------------------------------

    def _my_turn(self, player: Player) -> bool:
        return self.current_player is player

    def _is_spin_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "life-action-not-playing"
        if self.is_animating:
            return "action-game-in-progress"
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.retired:
            return "life-action-already-retired"
        if lp.pending != "":
            return "life-action-must-spin-first"
        if not lp.awaiting_spin:
            return "life-action-must-spin-first"
        return None

    def _is_spin_hidden(self, player: Player) -> Visibility:
        if self.status != "playing":
            return Visibility.HIDDEN
        if not self._my_turn(player):
            return Visibility.HIDDEN
        lp: LifePlayer = player  # type: ignore
        if lp.retired:
            return Visibility.HIDDEN
        if lp.pending != "" or not lp.awaiting_spin:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_path_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "life-action-not-playing"
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "path":
            return "life-action-must-spin-first"
        return None

    def _is_path_hidden(self, player: Player) -> Visibility:
        if not self._my_turn(player):
            return Visibility.HIDDEN
        lp: LifePlayer = player  # type: ignore
        return Visibility.VISIBLE if lp.pending == "path" else Visibility.HIDDEN

    def _is_career_pick_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "career_pick":
            return "life-action-must-spin-first"
        return None

    def _is_career_pick_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "career_pick":
            return Visibility.HIDDEN
        try:
            slot = int((action_id or "").rsplit("_", 1)[-1])
        except ValueError:
            return Visibility.HIDDEN
        return (
            Visibility.VISIBLE
            if slot < len(self.career_offers.get(lp.id, []))
            else Visibility.HIDDEN
        )

    def _is_slot_visible(self, player: LifePlayer, slot: int) -> bool:
        offers = self.career_offers.get(player.id, [])
        return slot < len(offers)

    def _get_career_pick_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return ""
        offers = self.career_offers.get(lp.id, [])
        if slot >= len(offers):
            return ""
        career = CANONICAL_CAREERS[offers[slot]]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale,
            "life-career-card-line",
            career=Localization.get(locale, career.label_key),
            degree="yes" if career.degree_required else "no",
            salary=_fmt_money(lp.salary),
        )

    def _is_salary_pick_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "salary_pick":
            return "life-action-must-spin-first"
        return None

    def _is_salary_pick_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "salary_pick":
            return Visibility.HIDDEN
        try:
            slot = int((action_id or "").rsplit("_", 1)[-1])
        except ValueError:
            return Visibility.HIDDEN
        return (
            Visibility.VISIBLE
            if slot < len(self.salary_offers.get(lp.id, []))
            else Visibility.HIDDEN
        )

    def _get_salary_pick_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return ""
        offers = self.salary_offers.get(lp.id, [])
        if slot >= len(offers):
            return ""
        card = SALARY_CARDS[offers[slot]]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale,
            "life-salary-card-line",
            salary=_fmt_money(card.salary),
            taxes=_fmt_money(card.taxes),
        )

    def _is_steal_tile_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "steal_tile":
            return "life-action-must-spin-first"
        return None

    def _is_steal_tile_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "steal_tile":
            return Visibility.HIDDEN
        try:
            slot = int((action_id or "").rsplit("_", 1)[-1])
        except ValueError:
            return Visibility.HIDDEN
        return (
            Visibility.VISIBLE
            if slot < len(lp.pending_options)
            else Visibility.HIDDEN
        )

    def _get_steal_tile_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return ""
        if slot >= len(lp.pending_options):
            return ""
        target = self.get_player_by_id(lp.pending_options[slot])
        if not target:
            return ""
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(locale, "life-action-steal-tile", player=target.name)

    # Insurance action visibility / labels.

    def _is_buy_insurance_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if (
            not self._my_turn(player)
            or lp.retired
            or self.options.insurance == "off"
            or lp.pending not in ("", "home_insurance")
        ):
            return Visibility.HIDDEN
        if lp.pending == "" and not lp.awaiting_spin:
            return Visibility.HIDDEN
        if self.options.insurance == "simplified":
            return (
                Visibility.VISIBLE
                if action_id == "buy_full_insurance" and not lp.has_full_insurance
                else Visibility.HIDDEN
            )
        if action_id == "buy_auto_insurance":
            return (
                Visibility.VISIBLE
                if lp.pending == "" and not lp.has_auto_insurance
                else Visibility.HIDDEN
            )
        if action_id == "buy_fire_insurance":
            return (
                Visibility.VISIBLE
                if bool(lp.house_key) and not lp.has_fire_insurance
                else Visibility.HIDDEN
            )
        return Visibility.HIDDEN

    def _is_buy_insurance_enabled(
        self, player: Player, *, action_id: str | None = None
    ) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if action_id == "buy_fire_insurance":
            premium = lp.house_insurance_cost
        elif action_id == "buy_auto_insurance":
            premium = INSURANCE_PREMIUMS["auto"]
        else:
            premium = INSURANCE_PREMIUMS["simplified"]
        if lp.cash < premium:
            return "life-cannot-afford"
        return None

    def _get_buy_insurance_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if action_id == "buy_full_insurance":
            return Localization.get(
                locale, "life-action-buy-insurance", money=_fmt_money(INSURANCE_PREMIUMS["simplified"])
            )
        mapping = {
            "buy_fire_insurance": ("life-action-buy-fire", lp.house_insurance_cost),
            "buy_auto_insurance": ("life-action-buy-auto", INSURANCE_PREMIUMS["auto"]),
        }
        entry = mapping.get(action_id)
        if not entry:
            return ""
        key, premium = entry
        return Localization.get(locale, key, money=_fmt_money(premium))

    def _is_insurance_skip_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        return None

    def _is_insurance_skip_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "home_insurance":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    # Stock action visibility / labels.

    def _is_buy_stock_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.stock_number != 0:
            return "life-stock-already-held"
        if lp.cash < STOCK_COST:
            return "life-cannot-afford"
        return None

    def _is_buy_stock_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if (
            not self._my_turn(player)
            or lp.pending != ""
            or not lp.awaiting_spin
            or lp.retired
            or not self.options.stock_market
            or lp.stock_number != 0
            or not self.available_stock_numbers
        ):
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_buy_stock_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(locale, "life-action-buy-stock", money=_fmt_money(STOCK_COST))

    def _is_stock_skip_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        return None

    def _is_stock_skip_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    # Risk It.

    def _is_risk_it_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.cash < RISK_IT_STAKE:
            return "life-cannot-afford"
        return None

    def _is_risk_it_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "risk_it":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_risk_it_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale, "life-action-risk-it", stake=_fmt_money(RISK_IT_STAKE)
        )

    def _is_risk_skip_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        return None

    def _is_risk_skip_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "risk_it":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    # Retirement.

    def _is_retirement_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        return None

    def _is_retirement_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "retirement":
            return Visibility.HIDDEN
        if self.options.retirement == "safe" and action_id == "choose_estates":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    # Standard actions.

    def _is_check_status_enabled(self, player: Player) -> str | None:
        if self.status != "playing" and self.status != "finished":
            return "life-action-not-playing"
        return None

    def _is_check_status_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN  # keybind + standard menu only

    def _is_pay_loan_enabled(self, player: Player) -> str | None:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        if lp.college_loan <= 0:
            return "life-loan-none"
        if lp.cash < BANK_LOAN_REPAYMENT:
            return "life-loan-cannot-afford"
        return None

    def _is_pay_loan_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if lp.college_loan <= 0:
            return Visibility.HIDDEN
        if self.status != "playing" or not self._my_turn(player) or lp.retired:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_pay_loan_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale, "life-action-pay-loan", money=_fmt_money(BANK_LOAN_REPAYMENT)
        )

    def _is_take_loan_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        lp: LifePlayer = player  # type: ignore
        if lp.retired or self.status != "playing":
            return "life-action-not-playing"
        return None

    def _is_take_loan_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if self.status != "playing" or not self._my_turn(player) or lp.retired:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    # ---------------------------------------------------------------------
    # "You vs player" broadcast helper
    # ---------------------------------------------------------------------

    def _announce(self, player: Player, message_id: str, **kwargs) -> None:
        """Broadcast a localized message with $who=you to player, $who=player to others."""
        for p in self.players:
            user = self.get_user(p)
            if not user:
                continue
            if p is player:
                txt = Localization.get(user.locale, message_id, who="you", **kwargs)
                if hasattr(self, "record_transcript_event"):
                    self.record_transcript_event(p, txt, "table")
                user.speak_l(message_id, "table", who="you", **kwargs)
            else:
                txt = Localization.get(
                    user.locale, message_id, who="player", player=player.name, **kwargs
                )
                if hasattr(self, "record_transcript_event"):
                    self.record_transcript_event(p, txt, "table")
                user.speak_l(message_id, "table", who="player", player=player.name, **kwargs)

    def _announce_lines(
        self, lines: list[tuple[Player, str, dict]]
    ) -> None:
        """Multi-line variant of :meth:`_announce`.

        Several turn outcomes in Life are described as a burst of related
        lines fired from a single handler in one server tick — for example
        a big spin can pass two PAYDAY spaces before landing, producing a
        ``life-pass-payday`` × N + ``life-move`` burst. Each call to
        :meth:`_announce` becomes one ``speak`` packet, and a client whose
        TTS pipeline naïvely interrupts on every new utterance hears only
        the last line. Combining the burst into a single packet lets the
        client speak the lines as one continuous utterance.

        Each entry in ``lines`` is ``(actor, message_id, kwargs)``. Per
        recipient, every line is localized with the same you/player
        perspective swap that :meth:`_announce` applies (``who="you"`` for
        the actor, ``who="player"`` with ``player=<name>`` for everyone
        else), joined with a newline, and emitted as one ``speak`` call.
        Lines about different actors compose correctly — the spin-result
        line is "about" the spinner, while a follow-up stock-paid line is
        "about" the stock holder, and each recipient gets the right
        perspective for each line.

        Args:
            lines: Ordered list of ``(actor, message_id, kwargs)`` tuples.
                Empty list is a no-op.
        """
        if not lines:
            return
        for p in self.players:
            user = self.get_user(p)
            if not user:
                continue
            rendered: list[str] = []
            for actor, message_id, kwargs in lines:
                if p is actor:
                    text = Localization.get(
                        user.locale, message_id, who="you", **kwargs
                    )
                else:
                    text = Localization.get(
                        user.locale,
                        message_id,
                        who="player",
                        player=actor.name,
                        **kwargs,
                    )
                rendered.append(text)
            combined = "\n".join(rendered)
            if hasattr(self, "record_transcript_event"):
                self.record_transcript_event(p, combined, "table")
            user.speak(combined, "table")

    # ---------------------------------------------------------------------
    # Action handlers — spin + movement
    # ---------------------------------------------------------------------

    def _action_spin(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "" or lp.retired or not lp.awaiting_spin:
            return
        lp.awaiting_spin = False
        self.is_animating = True
        self.broadcast_l("life-spinner-spinning")
        self.play_standard_dice_roll_sound()

        value = random.randint(1, 10)  # nosec B311

        # Schedule the announcement shortly after the spin sound, then the movement.
        self.schedule_event(
            "spin_result", {"player_id": player.id, "value": value}, delay_ticks=8
        )

    # ---------------------------------------------------------------------
    # Action handlers — path fork
    # ---------------------------------------------------------------------

    def _action_choose_college(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "path":
            return
        lp.path = "college"
        lp.college_loan = COLLEGE_LOAN_PRINCIPAL
        lp.pending = ""
        self._announce(player, "life-chose-college")
        self._continue_turn_after_stop(player)

    def _action_choose_career_path(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "path":
            return
        lp.path = "career"
        lp.position = next(
            (
                space.index
                for space in self.track
                if space.type == SpaceType.COLLEGE_GRAD
            ),
            0,
        )
        self._deal_random_career_and_salary(lp, allow_degree=False)
        lp.pending = ""
        self._announce(player, "life-chose-career")
        self._announce_career_and_salary(lp)
        self._continue_turn_after_stop(player)

    # ---------------------------------------------------------------------
    # Action handlers — career pick
    # ---------------------------------------------------------------------

    def _action_pick_career(self, player: Player, *args) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "career_pick":
            return
        action_id = args[-1] if args else ""
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return
        offers = self.career_offers.get(lp.id, [])
        if slot >= len(offers):
            return
        context = lp.pending_event_key
        self._assign_career(lp, offers[slot])
        self.career_offers.pop(lp.id, None)
        self._offer_salaries(
            lp,
            count=3 if context == "college" else 2,
            include_current=context == "night_school",
        )
        lp.pending = "salary_pick"

    def _action_pick_salary(self, player: Player, *args) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "salary_pick":
            return
        action_id = args[-1] if args else ""
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return
        offers = self.salary_offers.get(lp.id, [])
        if slot >= len(offers):
            return
        context = lp.pending_event_key
        self._assign_salary(lp, offers[slot])
        self.salary_offers.pop(lp.id, None)
        lp.pending = ""
        lp.pending_event_key = ""
        self._announce_career_and_salary(lp)
        if context == "college":
            self._continue_turn_after_stop(player)
        else:
            self.end_turn()

    def _announce_career_and_salary(self, player: LifePlayer) -> None:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        self._announce(
            player,
            "life-career-chosen",
            career=Localization.get(locale, player.career_label_key),
            salary=_fmt_money(player.salary),
        )
        self._announce(
            player,
            "life-salary-chosen",
            salary=_fmt_money(player.salary),
            taxes=_fmt_money(player.salary_taxes),
        )

    def _offer_careers(
        self,
        player: LifePlayer,
        pool: list[int],
        count: int,
        *,
        include_current: bool = False,
    ) -> None:
        pool_copy = [index for index in pool if index in self.career_pool]
        random.shuffle(pool_copy)  # nosec B311
        picks = pool_copy[: min(count, len(pool_copy))]
        if include_current and player.career_index >= 0:
            picks.insert(0, player.career_index)
        self.career_offers[player.id] = picks

    def _offer_salaries(
        self,
        player: LifePlayer,
        count: int,
        *,
        include_current: bool = False,
    ) -> None:
        pool_copy = list(self.salary_pool)
        random.shuffle(pool_copy)  # nosec B311
        picks = pool_copy[: min(count, len(pool_copy))]
        if include_current and player.salary_card_index >= 0:
            picks.insert(0, player.salary_card_index)
            picks = picks[:3]
        self.salary_offers[player.id] = picks

    def _assign_career(self, player: LifePlayer, career_index: int) -> None:
        if player.career_index == career_index:
            return
        if player.career_index >= 0 and player.career_index not in self.career_pool:
            self.career_pool.append(player.career_index)
        if career_index in self.career_pool:
            self.career_pool.remove(career_index)
        career = CANONICAL_CAREERS[career_index]
        player.career_index = career_index
        player.career_key = career.key
        player.career_label_key = career.label_key

    def _assign_salary(self, player: LifePlayer, salary_index: int) -> None:
        if player.salary_card_index == salary_index:
            return
        if (
            player.salary_card_index >= 0
            and player.salary_card_index not in self.salary_pool
        ):
            self.salary_pool.append(player.salary_card_index)
        if salary_index in self.salary_pool:
            self.salary_pool.remove(salary_index)
        card = SALARY_CARDS[salary_index]
        player.salary_card_index = salary_index
        player.salary = card.salary
        player.salary_taxes = card.taxes

    def _deal_random_career_and_salary(
        self, player: LifePlayer, *, allow_degree: bool
    ) -> None:
        eligible = [
            index
            for index in self.career_pool
            if allow_degree or not CANONICAL_CAREERS[index].degree_required
        ]
        if eligible:
            self._assign_career(player, random.choice(eligible))  # nosec B311
        if self.salary_pool:
            self._assign_salary(player, random.choice(self.salary_pool))  # nosec B311

    # ---------------------------------------------------------------------
    # Action handlers — insurance / stocks / risk it / retirement
    # ---------------------------------------------------------------------

    def _action_buy_insurance(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending not in ("", "home_insurance") or not lp.awaiting_spin:
            return
        was_house_offer = lp.pending == "home_insurance"
        type_map = {
            "buy_fire_insurance": (
                "fire",
                lp.house_insurance_cost,
                "life-bought-fire",
            ),
            "buy_auto_insurance": ("auto", INSURANCE_PREMIUMS["auto"], "life-bought-auto"),
            "buy_full_insurance": (
                "full",
                INSURANCE_PREMIUMS["simplified"],
                "life-bought-insurance",
            ),
        }
        entry = type_map.get(action_id)
        if not entry:
            return
        ins_type, premium, message = entry
        if lp.cash < premium:
            user = self.get_user(player)
            if user:
                user.speak_l("life-insurance-unaffordable", money=_fmt_money(premium))
            return
        if not lp.set_coverage(ins_type):
            user = self.get_user(player)
            if user:
                user.speak_l("life-insurance-already-held")
            return
        lp.cash -= premium
        self._announce(player, message, money=_fmt_money(premium))
        if was_house_offer:
            lp.pending = ""
            self._continue_turn_after_stop(player)
        else:
            self.rebuild_player_menu(player, position=1)

    def _action_skip_insurance(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "home_insurance":
            return
        self._announce(player, "life-skipped-insurance")
        lp.pending = ""
        self._continue_turn_after_stop(player)

    def _action_buy_stock(self, player: Player, *args) -> None:
        lp: LifePlayer = player  # type: ignore
        if (
            lp.pending != ""
            or not lp.awaiting_spin
            or lp.stock_number != 0
            or not self.options.stock_market
        ):
            return
        if len(args) >= 2:
            input_value = args[0]
        else:
            return
        try:
            number = int(str(input_value).strip())
        except ValueError:
            return
        if number not in self.available_stock_numbers:
            return
        if lp.cash < STOCK_COST:
            user = self.get_user(player)
            if user:
                user.speak_l("life-cannot-afford")
            return
        lp.cash -= STOCK_COST
        lp.add_stock(number)
        self.available_stock_numbers.remove(number)
        self._announce(player, "life-stock-bought", number=number, money=_fmt_money(STOCK_COST))
        self.rebuild_player_menu(player, position=1)

    def _stock_number_options(self, player: Player) -> list[str]:
        return [str(number) for number in self.available_stock_numbers]

    def _bot_select_stock_number(self, player: Player, options: list[str]) -> str | None:
        if not options:
            return None
        preferred = life_bot.choose_stock(player)  # type: ignore[arg-type]
        return preferred if preferred in options else options[0]

    def _action_skip_stock(self, player: Player, action_id: str) -> None:
        return

    def _action_risk_it(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "risk_it":
            return
        if lp.cash < RISK_IT_STAKE:
            user = self.get_user(player)
            if user:
                user.speak_l("life-cannot-afford")
            return
        lp.cash -= RISK_IT_STAKE
        self._announce(
            player,
            "life-risk-it-taken",
            stake=_fmt_money(RISK_IT_STAKE),
        )
        # Roll.
        value = random.randint(1, 10)  # nosec B311
        if value >= RISK_IT_THRESHOLD:
            lp.cash += RISK_IT_PRIZE + RISK_IT_STAKE  # get stake back + prize
            self._announce(
                player, "life-risk-it-won", value=value, prize=_fmt_money(RISK_IT_PRIZE)
            )
        else:
            self._announce(
                player, "life-risk-it-lost", value=value, stake=_fmt_money(RISK_IT_STAKE)
            )
        lp.pending = ""
        self.end_turn()

    def _action_skip_risk_it(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "risk_it":
            return
        self._announce(player, "life-risk-it-skipped")
        lp.pending = ""
        self.end_turn()

    def _action_choose_estates(self, player: Player, action_id: str) -> None:
        self._resolve_retirement_choice(player, "estates")

    def _action_choose_acres(self, player: Player, action_id: str) -> None:
        self._resolve_retirement_choice(player, "acres")

    def _resolve_retirement_choice(self, player: Player, choice: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "retirement":
            return
        loan_count = lp.college_loan // BANK_LOAN_VALUE
        if loan_count:
            repayment = loan_count * BANK_LOAN_REPAYMENT
            lp.cash -= repayment
            lp.college_loan = 0
            self._announce(player, "life-retirement-loans-paid", money=_fmt_money(repayment))

        lp.career_index = -1
        lp.career_key = ""
        lp.career_label_key = ""
        lp.salary_card_index = -1
        lp.salary = 0
        lp.salary_taxes = 0
        lp.house_key = ""
        lp.house_label_key = ""
        lp.house_price = 0
        lp.house_insurance_cost = 0
        lp.has_fire_insurance = False
        lp.has_auto_insurance = False
        lp.has_full_insurance = False

        lp.retirement_choice = choice
        lp.pending = ""
        lp.retired = True
        if player.id not in self.players_finished:
            self.players_finished.append(player.id)
        if choice == "acres":
            self._announce(player, "life-chose-acres")
            before = len(lp.life_tile_values)
            tile_awarded = self._grant_life_tile(
                lp,
                silent=True,
                continuation="retire",
            )
            if len(lp.life_tile_values) > before:
                self._announce(player, "life-acres-tile")
            if not tile_awarded:
                self._rebuild_and_continue(player)
                return
        elif choice == "estates":
            self._announce(player, "life-chose-estates")
            self.estates_players.append(player.id)
        else:
            self.broadcast_l("life-retirement-skipped")
        self.end_turn()

    # ---------------------------------------------------------------------
    # Always-available actions (loans and status).
    # ---------------------------------------------------------------------

    def _action_take_loan(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.retired:
            return
        lp.cash += BANK_LOAN_VALUE
        lp.college_loan += BANK_LOAN_VALUE
        self._announce(
            player,
            "life-loan-taken",
            money=_fmt_money(BANK_LOAN_VALUE),
            balance=_fmt_money(lp.college_loan),
        )

    def _action_pay_loan(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if (
            lp.college_loan < BANK_LOAN_VALUE
            or lp.cash < BANK_LOAN_REPAYMENT
            or not self._my_turn(player)
        ):
            return
        lp.cash -= BANK_LOAN_REPAYMENT
        lp.college_loan -= BANK_LOAN_VALUE
        self._announce(
            player,
            "life-loan-paid",
            money=_fmt_money(BANK_LOAN_REPAYMENT),
            remaining=_fmt_money(lp.college_loan),
        )

    def _action_check_status(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        lines: list[str] = []

        # Position
        if lp.retired:
            retire_word = Localization.get(
                locale,
                f"life-retire-{lp.retirement_choice}" if lp.retirement_choice != "none" else "life-retire-safe",
            )
            lines.append(Localization.get(locale, "life-status-space-retired", retirement=retire_word))
        else:
            lines.append(
                Localization.get(
                    locale,
                    "life-status-space",
                    current=lp.position,
                    total=len(self.track) - 1,
                )
            )

        # Career
        if lp.career_key:
            lines.append(
                Localization.get(
                    locale,
                    "life-status-career",
                    career=Localization.get(locale, lp.career_label_key),
                    salary=_fmt_money(lp.salary),
                    taxes=_fmt_money(lp.salary_taxes),
                )
            )
        else:
            lines.append(Localization.get(locale, "life-status-career-none"))

        if lp.house_key:
            lines.append(
                Localization.get(
                    locale,
                    "life-status-house",
                    house=Localization.get(locale, lp.house_label_key),
                )
            )

        # Cash
        lines.append(Localization.get(locale, "life-status-cash", money=_fmt_money(lp.cash)))

        # Life tiles
        tile_count = len(lp.life_tile_values)
        if self.options.life_tiles == "off" or tile_count == 0:
            lines.append(Localization.get(locale, "life-status-tiles-none"))
        elif self.options.life_tiles == "revealed":
            total = sum(lp.life_tile_values)
            lines.append(
                Localization.get(
                    locale, "life-status-tiles-revealed", count=tile_count, money=_fmt_money(total)
                )
            )
        else:
            lines.append(Localization.get(locale, "life-status-tiles-hidden", count=tile_count))

        # Family
        if self.options.family_enabled:
            if lp.married:
                lines.append(
                    Localization.get(locale, "life-status-family-married", kids=lp.children)
                )
            else:
                lines.append(
                    Localization.get(locale, "life-status-family-single", kids=lp.children)
                )

        # Insurance
        if self.options.insurance != "off":
            ins_list = lp.insurance_list()
            if not ins_list:
                lines.append(Localization.get(locale, "life-status-insurance-none"))
            elif ins_list == ["full"]:
                lines.append(Localization.get(locale, "life-status-insurance-single"))
            else:
                pretty = ", ".join(Localization.get(locale, f"life-insurance-{t}") for t in ins_list)
                lines.append(Localization.get(locale, "life-status-insurance-full", list=pretty))

        # Loan
        if lp.college_loan > 0:
            repayment = (
                lp.college_loan // BANK_LOAN_VALUE
            ) * BANK_LOAN_REPAYMENT
            lines.append(
                Localization.get(
                    locale,
                    "life-status-loan",
                    money=_fmt_money(lp.college_loan),
                    repayment=_fmt_money(repayment),
                )
            )
        elif lp.path == "college":
            lines.append(Localization.get(locale, "life-status-loan-none"))

        # Stock
        if self.options.stock_market:
            stock_numbers = lp.owned_stock_numbers()
            if stock_numbers:
                lines.append(
                    Localization.get(
                        locale,
                        "life-status-stock",
                        numbers=", ".join(str(number) for number in stock_numbers),
                        number=", ".join(str(number) for number in stock_numbers),
                    )
                )
            else:
                lines.append(Localization.get(locale, "life-status-stock-none"))

        self.status_box(player, lines)

    def _action_check_status_detailed(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        active = self.get_active_players()
        lines: list[str] = [
            Localization.get(locale, "life-status-detailed-header", count=len(active))
        ]
        for p in active:
            lp: LifePlayer = p  # type: ignore
            career = (
                Localization.get(locale, lp.career_label_key)
                if lp.career_key
                else Localization.get(locale, "life-career-none")
            )
            family = self._format_family(lp, locale)
            self_suffix = Localization.get(locale, "life-status-detailed-self-suffix") if p is player else ""
            lines.append(
                Localization.get(
                    locale,
                    "life-status-detailed-line",
                    player=p.name,
                    self_suffix=self_suffix,
                    position=lp.position,
                    career=career,
                    money=_fmt_money(lp.cash),
                    tiles=len(lp.life_tile_values),
                    family=family,
                )
            )
        self.status_box(player, lines)

    def _format_family(self, lp: LifePlayer, locale: str) -> str:
        if lp.married and lp.children == 0:
            return Localization.get(locale, "life-status-detailed-family-married-0")
        if lp.married:
            return Localization.get(
                locale, "life-status-detailed-family-married-kids", kids=lp.children
            )
        if lp.children == 0:
            return Localization.get(locale, "life-status-detailed-family-single-0")
        return Localization.get(
            locale, "life-status-detailed-family-single-kids", kids=lp.children
        )

    # ---------------------------------------------------------------------
    # Animated event queue (spinner, step, landing resolution)
    # ---------------------------------------------------------------------

    def on_game_event(self, event_type: str, data: dict) -> None:
        if event_type == "spin_result":
            self._handle_spin_result(data)
        elif event_type == "step_move":
            self._handle_step_move(data)
        elif event_type == "resolve_landing":
            self._handle_resolve_landing(data)
        elif event_type == "end_turn":
            self.is_animating = False
            self.end_turn()
        elif event_type == "tally_start":
            self._begin_tally()
        elif event_type == "tally_reveal_tile":
            self._handle_tally_reveal_tile(data)
        elif event_type == "tally_line":
            self._handle_tally_line(data)
        elif event_type == "tally_finish":
            self._handle_tally_finish()

    def _handle_spin_result(self, data: dict) -> None:
        player = self.get_player_by_id(data["player_id"])
        if not player:
            return
        value = int(data["value"])

        # Build the spin-result burst as a single combined announcement.
        # Spin-result is "about" the spinner; any stock payouts are "about"
        # the respective stock holder — _announce_lines applies the correct
        # you/player perspective to each line per recipient.
        lines: list[tuple[Player, str, dict]] = [
            (player, "life-spin-result", {"value": value}),
        ]
        if self.options.stock_market:
            for p in self.get_active_players():
                lp: LifePlayer = p  # type: ignore
                if value in lp.owned_stock_numbers():
                    lp.cash += STOCK_PAYOUT
                    lines.append(
                        (
                            p,
                            "life-stock-paid",
                            {"number": value, "money": _fmt_money(STOCK_PAYOUT)},
                        )
                    )
            if value == 10:
                police = next(
                    (
                        p
                        for p in self.get_active_players()
                        if not getattr(p, "retired", False)
                        and getattr(p, "career_key", "") == "police_officer"
                        and p is not player
                    ),
                    None,
                )
                if police:
                    police_lp: LifePlayer = police  # type: ignore
                    self._pay_amount(player, 5_000)
                    police_lp.cash += 5_000
                    lines.append(
                        (
                            police,
                            "life-police-paid",
                            {"money": _fmt_money(5_000), "spinner": player.name},
                        )
                    )
        self._announce_lines(lines)

        # Schedule movement steps.
        self._schedule_movement(player, value)

    def _schedule_movement(self, player: Player, steps: int) -> None:
        """Schedule step-by-step movement events with sounds, then a landing resolution."""
        lp: LifePlayer = player  # type: ignore
        natural_target = min(lp.position + steps, len(self.track) - 1)
        target = natural_target

        for index in range(lp.position + 1, natural_target + 1):
            if self._is_mandatory_stop(lp, self.track[index]):
                target = index
                break

        occupied = {
            p.position
            for p in self.get_active_players()
            if p is not player and not getattr(p, "retired", False)
        }
        if (
            target == natural_target
            and target in occupied
            and not self._is_mandatory_stop(lp, self.track[target])
        ):
            while target < len(self.track) - 1 and target in occupied:
                target += 1
                if self._is_mandatory_stop(lp, self.track[target]):
                    break

        actual_steps = max(0, target - lp.position)
        base_delay = 6
        step_interval = 4
        next_delay = self.schedule_standard_token_movement_sounds(
            actual_steps,
            start_delay_ticks=base_delay,
            step_interval_ticks=step_interval,
            variant_count=3,
        )
        self.schedule_event(
            "step_move",
            {"player_id": player.id, "target": target, "steps": actual_steps},
            delay_ticks=next_delay,
        )

    def _is_mandatory_stop(self, player: LifePlayer, space: Space) -> bool:
        if (
            space.type == SpaceType.COLLEGE_GRAD
            and player.path == "college"
            and not player.career_key
        ):
            return True
        if space.type == SpaceType.MARRY:
            return self.options.family_enabled
        if space.type == SpaceType.BUY_HOUSE:
            return not player.house_key
        return space.type == SpaceType.FINISH

    def _handle_step_move(self, data: dict) -> None:
        player = self.get_player_by_id(data["player_id"])
        if not player:
            return
        lp: LifePlayer = player  # type: ignore

        old_pos = lp.position
        target = int(data["target"])

        lines: list[tuple[Player, str, dict]] = []

        # Pass-through bonuses: if we cross a PAYDAY space between old_pos
        # (exclusive) and target (inclusive — payouts trigger whether we
        # pass or stop).
        payday_gained = 0
        for idx in range(old_pos + 1, target + 1):
            space = self.track[idx]
            if space.type == SpaceType.PAYDAY and lp.salary > 0:
                earning = lp.salary
                lp.cash += earning
                payday_gained += earning
                # If this is a *passed* payday (not the final landing), announce it.
                if idx != target:
                    lines.append(
                        (player, "life-pass-payday", {"money": _fmt_money(earning)}),
                    )

        lp.position = target
        lines.append((player, "life-move", {"position": target}))

        self._announce_lines(lines)

        # Schedule landing resolution.
        self.schedule_event(
            "resolve_landing", {"player_id": player.id, "payday": payday_gained}, delay_ticks=6
        )

    # ---------------------------------------------------------------------
    # Landing resolution — per SpaceType
    # ---------------------------------------------------------------------

    def _handle_resolve_landing(self, data: dict) -> None:
        player = self.get_player_by_id(data["player_id"])
        if not player:
            return
        lp: LifePlayer = player  # type: ignore

        if lp.pending != "":
            self.is_animating = False
            self._rebuild_and_continue(player)
            return

        space = self.track[lp.position]
        stype = space.type
        end_turn = True
        continue_after_stop = False

        if stype == SpaceType.NORMAL or stype == SpaceType.START:
            pass
        elif stype == SpaceType.PAYDAY:
            if lp.salary > 0:
                self._announce(player, "life-payday", money=_fmt_money(lp.salary))
        elif stype == SpaceType.EVENT:
            self._apply_event(lp, space)
            end_turn = lp.pending == ""
        elif stype == SpaceType.MARRY:
            if self.options.family_enabled:
                if lp.married:
                    self._announce(player, "life-event-already-married")
                else:
                    lp.married = True
                    self._announce(player, "life-event-get-married")
                    self._grant_life_tile(lp, continuation="continue")
            end_turn = False
            continue_after_stop = lp.pending == ""
        elif stype == SpaceType.BABY:
            if self.options.family_enabled:
                if space.event_key == "twins":
                    lp.children += 2
                    self._announce(player, "life-event-twins")
                else:
                    lp.children += 1
                    self._announce(player, "life-event-baby")
                self._grant_life_tile(lp, continuation="end")
                end_turn = lp.pending == ""
        elif stype == SpaceType.RISK_IT:
            if self.options.stock_market and lp.cash >= RISK_IT_STAKE:
                lp.pending = "risk_it"
                self._announce(
                    player,
                    "life-risk-it-offer",
                    stake=_fmt_money(RISK_IT_STAKE),
                    prize=_fmt_money(RISK_IT_PRIZE),
                    target=RISK_IT_THRESHOLD,
                )
                end_turn = False
        elif stype == SpaceType.COLLEGE_GRAD:
            if lp.path == "college" and not lp.career_key:
                self._announce(player, "life-college-graduated")
                self._offer_careers(lp, self.career_pool, count=3)
                lp.pending = "career_pick"
                lp.pending_event_key = "college"
                end_turn = False
            else:
                end_turn = False
                continue_after_stop = True
        elif stype == SpaceType.CAREER_CHANGE:
            self._deal_random_career_and_salary(
                lp,
                allow_degree=lp.path == "college",
            )
            self._announce(player, "life-career-change")
            self._announce_career_and_salary(lp)
        elif stype == SpaceType.NIGHT_SCHOOL:
            pool = (
                self.career_pool if lp.path == "college" else self.nondegree_career_pool
            )
            self._offer_careers(lp, pool, count=2, include_current=True)
            lp.pending = "career_pick"
            lp.pending_event_key = "night_school"
            end_turn = False
            self._announce(player, "life-night-school")
        elif stype == SpaceType.BUY_HOUSE:
            self._buy_house(lp)
            end_turn = False
            if (
                self.options.insurance != "off"
                and not lp.has_fire_insurance
                and not lp.has_full_insurance
            ):
                lp.pending = "home_insurance"
                self._announce(player, "life-home-insurance-offer")
            else:
                continue_after_stop = True
        elif stype == SpaceType.STOCK_ZOOMS:
            if self.options.stock_market and self.available_stock_numbers:
                number = random.choice(self.available_stock_numbers)  # nosec B311
                self.available_stock_numbers.remove(number)
                lp.add_stock(number)
                self._announce(player, "life-stock-zooms", number=number)
        elif stype == SpaceType.STOCK_SLUMPS:
            if self.options.stock_market and lp.owned_stock_numbers():
                number = lp.remove_stock()
                if number:
                    self.available_stock_numbers.append(number)
                    self.available_stock_numbers.sort()
                    self._announce(player, "life-stock-slumps", number=number)
        elif stype == SpaceType.RETIRE_JUNCTION:
            pass
        elif stype == SpaceType.FINISH:
            if self.options.retirement == "none":
                lp.pending = "retirement"
                self.is_animating = False
                self._resolve_retirement_choice(player, "none")
                return
            else:
                lp.pending = "retirement"
                self._announce(player, "life-retirement-reached")
                end_turn = False

        if end_turn:
            self.is_animating = False
            self.end_turn()
        elif continue_after_stop:
            self._continue_turn_after_stop(player)
        else:
            self.is_animating = False
            self._rebuild_and_continue(player)

    def _rebuild_and_continue(self, player: Player) -> None:
        """Rebuild the current player's menu for a pending prompt and continue."""
        self.rebuild_player_menu(player, position=1)
        BotHelper.jolt_bot(player, ticks=random.randint(15, 25))

    def _continue_turn_after_stop(self, player: Player) -> None:
        lp: LifePlayer = player  # type: ignore
        self.is_animating = False
        lp.awaiting_spin = True
        self._rebuild_and_continue(player)

    def _buy_house(self, player: LifePlayer) -> None:
        if not self.house_deed_pool:
            return
        deed_index = random.choice(self.house_deed_pool)  # nosec B311
        self.house_deed_pool.remove(deed_index)
        deed = HOUSE_DEEDS[deed_index]
        self._ensure_cash(player, deed.price)
        player.cash -= deed.price
        player.house_key = deed.key
        player.house_label_key = deed.label_key
        player.house_price = deed.price
        player.house_insurance_cost = deed.insurance_cost
        user = self.get_user(player)
        locale = user.locale if user else "en"
        self._announce(
            player,
            "life-house-bought",
            house=Localization.get(locale, deed.label_key),
            money=_fmt_money(deed.price),
        )

    def _ensure_cash(self, player: LifePlayer, amount: int) -> None:
        if player.cash >= amount:
            return
        shortfall = amount - player.cash
        loan_count = (shortfall + BANK_LOAN_VALUE - 1) // BANK_LOAN_VALUE
        principal = loan_count * BANK_LOAN_VALUE
        player.cash += principal
        player.college_loan += principal
        self._announce(
            player,
            "life-automatic-loan",
            money=_fmt_money(principal),
            balance=_fmt_money(player.college_loan),
        )

    def _pay_amount(self, player: LifePlayer, amount: int) -> None:
        self._ensure_cash(player, amount)
        player.cash -= amount

    def _apply_event(self, lp: LifePlayer, space: Space) -> None:
        event_key = self.event_layout.get(space.index)
        if not event_key:
            return
        event = next((e for e in self.event_deck if e.key == event_key), None)
        if event is None:
            return

        if event.effect == EventEffect.CASH_GAIN:
            lp.cash += event.amount
            self._announce(lp, f"life-event-{event.key}", money=_fmt_money(event.amount))
        elif event.effect == EventEffect.CASH_LOSS:
            self._pay_amount(lp, event.amount)
            self._announce(lp, f"life-event-{event.key}", money=_fmt_money(event.amount))
        elif event.effect in (
            EventEffect.INSURABLE_AUTO,
            EventEffect.INSURABLE_FIRE,
            EventEffect.INSURABLE_LIFE,
        ):
            ins_type = INSURABLE_TO_TYPE[event.effect]
            insured = lp.covers(ins_type)
            if not insured:
                self._pay_amount(lp, event.amount)
            self._announce(
                lp,
                f"life-event-{event.key}",
                money=_fmt_money(event.amount),
                insured="yes" if insured else "no",
            )
        elif event.effect == EventEffect.LIFE_TILE:
            self._grant_life_tile(lp, silent=True, continuation="end")
            self._announce(lp, f"life-event-{event.key}")
        elif event.effect == EventEffect.CAREER_PAYMENT:
            holder = next(
                (
                    p
                    for p in self.get_active_players()
                    if not getattr(p, "retired", False)
                    and getattr(p, "career_key", "") == event.career_key
                ),
                None,
            )
            career = next(
                (c for c in CANONICAL_CAREERS if c.key == event.career_key),
                None,
            )
            user = self.get_user(lp)
            locale = user.locale if user else "en"
            career_name = (
                Localization.get(locale, career.label_key) if career else event.career_key
            )
            if holder is lp:
                self._announce(
                    lp,
                    "life-career-payment-self",
                    career=career_name,
                )
            else:
                self._pay_amount(lp, event.amount)
                if holder:
                    holder_lp: LifePlayer = holder  # type: ignore
                    holder_lp.cash += event.amount
                    self._announce(
                        lp,
                        "life-career-payment-player",
                        career=career_name,
                        money=_fmt_money(event.amount),
                        recipient=holder.name,
                    )
                else:
                    self._announce(
                        lp,
                        "life-career-payment-bank",
                        career=career_name,
                        money=_fmt_money(event.amount),
                    )
        elif event.effect == EventEffect.TAXES:
            accountant = next(
                (
                    p
                    for p in self.get_active_players()
                    if not getattr(p, "retired", False)
                    and getattr(p, "career_key", "") == "accountant"
                ),
                None,
            )
            if accountant is lp:
                self._announce(lp, "life-taxes-self")
            else:
                self._pay_amount(lp, lp.salary_taxes)
                if accountant:
                    accountant_lp: LifePlayer = accountant  # type: ignore
                    accountant_lp.cash += lp.salary_taxes
                    self._announce(
                        lp,
                        "life-taxes-player",
                        money=_fmt_money(lp.salary_taxes),
                        recipient=accountant.name,
                    )
                else:
                    self._announce(
                        lp,
                        "life-taxes-bank",
                        money=_fmt_money(lp.salary_taxes),
                    )
        elif event.effect == EventEffect.LAWSUIT:
            self._resolve_lawsuit(lp, event.amount)

    def _grant_life_tile(
        self,
        lp: LifePlayer,
        *,
        silent: bool = False,
        continuation: str = "end",
    ) -> bool:
        if self.options.life_tiles == "off":
            lp.cash += 30_000
            return True
        if not self.life_tile_pool:
            eligible = [
                p
                for p in self.get_active_players()
                if p is not lp
                and getattr(p, "life_tile_values", [])
                and not (
                    getattr(p, "retired", False)
                    and getattr(p, "retirement_choice", "") == "acres"
                )
            ]
            if not eligible:
                return True
            lp.pending = "steal_tile"
            lp.pending_options = [p.id for p in eligible]
            lp.pending_event_key = continuation
            self._announce(lp, "life-tile-steal-prompt")
            return False
        value = self.life_tile_pool.pop()
        lp.life_tile_values.append(value)
        if silent:
            return True
        if self.options.life_tiles == "revealed":
            self._announce(lp, "life-tile-earned-revealed", money=_fmt_money(value))
        else:
            self._announce(lp, "life-tile-earned-hidden")
        return True

    def _action_steal_tile(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "steal_tile":
            return
        try:
            slot = int(action_id.rsplit("_", 1)[-1])
        except ValueError:
            return
        if slot >= len(lp.pending_options):
            return
        target = self.get_player_by_id(lp.pending_options[slot])
        if not target:
            return
        target_lp: LifePlayer = target  # type: ignore
        if not target_lp.life_tile_values:
            return
        value = random.choice(target_lp.life_tile_values)  # nosec B311
        target_lp.life_tile_values.remove(value)
        lp.life_tile_values.append(value)
        continuation = lp.pending_event_key
        lp.pending = ""
        lp.pending_options = []
        lp.pending_event_key = ""
        self._announce(
            player,
            "life-tile-stolen",
            victim=target.name,
        )
        if continuation == "continue":
            self._continue_turn_after_stop(player)
        else:
            self.end_turn()

    def _resolve_lawsuit(self, lp: LifePlayer, amount: int) -> None:
        """Quick lawsuit: all active players spin, lowest pays highest."""
        self.broadcast_l("life-lawsuit-announce")
        spins = {
            p.id: random.randint(1, 10)  # nosec B311
            for p in self.get_active_players()
            if not getattr(p, "retired", False)
        }
        if len(spins) < 2:
            return
        winner_id = max(spins, key=lambda k: spins[k])
        loser_id = min(spins, key=lambda k: spins[k])
        if winner_id == loser_id:
            return
        winner = self.get_player_by_id(winner_id)
        loser = self.get_player_by_id(loser_id)
        if not winner or not loser:
            return
        wlp: LifePlayer = winner  # type: ignore
        llp: LifePlayer = loser  # type: ignore
        llp.cash -= amount
        wlp.cash += amount
        self.broadcast_l(
            "life-lawsuit-result",
            winner=winner.name,
            loser=loser.name,
            money=_fmt_money(amount),
        )

    # ---------------------------------------------------------------------
    # Endgame — Millionaire Estates reserve tiles + tally
    # ---------------------------------------------------------------------

    def _begin_endgame(self) -> None:
        self.game_phase = "tally"
        estates = [
            self.get_player_by_id(player_id)
            for player_id in self.estates_players
        ]
        estates = [player for player in estates if player is not None]
        if estates and self.estates_tile_values:
            richest_cash = max(getattr(player, "cash", 0) for player in estates)
            winners = [
                player
                for player in estates
                if getattr(player, "cash", 0) == richest_cash
            ]
            awarded = {player.id: 0 for player in winners}
            for index, value in enumerate(self.estates_tile_values):
                winner = winners[index % len(winners)]
                winner_lp: LifePlayer = winner  # type: ignore
                winner_lp.life_tile_values.append(value)
                awarded[winner.id] += 1
            for winner in winners:
                self.broadcast_l(
                    "life-estates-tiles-awarded",
                    player=winner.name,
                    count=awarded[winner.id],
                )
            self.estates_tile_values = []
        self.schedule_event("tally_start", {}, delay_ticks=6)

    def _begin_tally(self) -> None:
        self.broadcast_l("life-end-header")
        self.tally_index = 0
        # Reveal each tile (hidden mode).
        self.schedule_event("tally_reveal_tile", {}, delay_ticks=10)

    def _handle_tally_reveal_tile(self, data: dict) -> None:
        if self.options.life_tiles == "off":
            self.schedule_event("tally_line", {"index": 0}, delay_ticks=4)
            return
        # Iterate through players + their tiles.
        active = list(self.get_active_players())
        # Build a flat list of (player, tile) to reveal one-per-event.
        flat: list[tuple[Player, int]] = []
        for p in active:
            lp: LifePlayer = p  # type: ignore
            for v in lp.life_tile_values:
                flat.append((p, v))
        if self.tally_index >= len(flat):
            self.schedule_event("tally_line", {"index": 0}, delay_ticks=6)
            return
        player, value = flat[self.tally_index]
        self.broadcast_l("life-tile-reveal-line", player=player.name, money=_fmt_money(value))
        self.tally_index += 1
        self.schedule_event("tally_reveal_tile", {}, delay_ticks=6)

    def _handle_tally_line(self, data: dict) -> None:
        active = list(self.get_active_players())
        idx = int(data.get("index", 0))
        if idx >= len(active):
            self.schedule_event("tally_finish", {}, delay_ticks=6)
            return
        p = active[idx]
        lp: LifePlayer = p  # type: ignore
        tile_cash = sum(lp.life_tile_values)
        total = lp.cash + tile_cash
        self.broadcast_l(
            "life-end-cash-line",
            player=p.name,
            cash=_fmt_money(lp.cash),
            tiles=_fmt_money(tile_cash),
            count=len(lp.life_tile_values),
            total=_fmt_money(total),
        )
        self.schedule_event("tally_line", {"index": idx + 1}, delay_ticks=6)

    def _handle_tally_finish(self) -> None:
        totals: dict[str, int] = {}
        for p in self.get_active_players():
            lp: LifePlayer = p  # type: ignore
            totals[p.id] = lp.cash + sum(lp.life_tile_values)
        if not totals:
            self.finish_game()
            return
        top = max(totals.values())
        winners = [pid for pid, v in totals.items() if v == top]
        if len(winners) == 1:
            w = self.get_player_by_id(winners[0])
            if w:
                self.winner = w
                self.play_sound("game_pig/win.ogg")
                self.broadcast_l("life-end-winner", player=w.name, money=_fmt_money(top))
        else:
            names = ", ".join(p.name for p in self.players if p.id in winners)
            self.broadcast_l("life-end-tie", money=_fmt_money(top), players=names)

        self.is_animating = False
        self.game_phase = "done"
        self.finish_game()

    # ---------------------------------------------------------------------
    # Ticking
    # ---------------------------------------------------------------------

    def on_tick(self) -> None:
        super().on_tick()
        self.process_scheduled_events()
        if self.status == "playing":
            BotHelper.on_tick(self)

    # ---------------------------------------------------------------------
    # Bot decisions
    # ---------------------------------------------------------------------

    def bot_think(self, player: LifePlayer) -> str | None:
        """Pick an action id appropriate to the player's current pending state."""
        # Always-on conveniences first.
        if life_bot.should_pay_loan(player):
            return "pay_loan"

        pending = player.pending
        if pending == "":
            return "spin"
        if pending == "path":
            choice = life_bot.choose_path(player)
            return "choose_college" if choice == "college" else "choose_career_path"
        if pending == "career_pick":
            offers = self.career_offers.get(player.id, [])
            if not offers:
                return None
            pick = life_bot.pick_career(offers)
            return f"pick_career_{pick}"
        if pending == "salary_pick":
            offers = self.salary_offers.get(player.id, [])
            if not offers:
                return None
            pick = life_bot.pick_salary(offers)
            return f"pick_salary_{pick}"
        if pending == "steal_tile":
            return "steal_tile_0"
        if pending == "home_insurance":
            available = ["full"] if self.options.insurance == "simplified" else ["fire"]
            choice = life_bot.choose_insurance(player, self, available)
            if choice == "skip":
                return "skip_insurance"
            if choice == "full":
                return "buy_full_insurance"
            return f"buy_{choice}_insurance"
        if pending == "risk_it":
            return "risk_it" if life_bot.choose_risk_it(player) == "risk" else "skip_risk_it"
        if pending == "retirement":
            all_cash = [p.cash for p in self.get_active_players()]
            return (
                "choose_estates"
                if life_bot.choose_retirement(player, all_cash) == "estates"
                else "choose_acres"
            )
        return None

    # ---------------------------------------------------------------------
    # End screen
    # ---------------------------------------------------------------------

    def build_game_result(self) -> GameResult:
        totals: dict[str, int] = {}
        for p in self.get_active_players():
            lp: LifePlayer = p  # type: ignore
            totals[p.id] = lp.cash + sum(lp.life_tile_values)

        winner = getattr(self, "winner", None)

        sorted_players = sorted(
            self.get_active_players(),
            key=lambda p: totals.get(p.id, 0),
            reverse=True,
        )

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
                for p in sorted_players
            ],
            custom_data={
                "winner_name": winner.name if winner else None,
                "totals": {p.name: totals.get(p.id, 0) for p in sorted_players},
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        lines = [Localization.get(locale, "game-final-scores")]
        totals = result.custom_data.get("totals", {})
        for rank, p_result in enumerate(result.player_results, 1):
            total = totals.get(p_result.player_name, 0)
            lines.append(
                Localization.get(
                    locale,
                    "life-end-score",
                    rank=rank,
                    player=p_result.player_name,
                    total=_fmt_money(total),
                )
            )
        return lines
