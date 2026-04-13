"""The Game of Life — main game implementation.

Flow summary:

    on_start -> set up track, event deck, tiles, deal per-player path prompt
    _start_turn -> current player's menu shows whatever they're being asked
                   for (spin, choose path, pick career, insurance offer, ...)
    _action_spin -> animate, resolve_landing on destination, set up next
                    prompt or end_turn depending on the space
    retirement -> individual players finish the track, retire, and stop
                  taking turns; once everyone has retired, the game runs
                  the Millionaire Estates spin-off (if any) and tallies.

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
from ...messages.localization import Localization
from server.core.ui.keybinds import KeybindState

from . import bot as life_bot
from .options import LifeOptions
from .player import LifePlayer
from .state import (
    ACRES_BONUS,
    CANONICAL_CAREERS,
    COLLEGE_LOAN_INTEREST,
    COLLEGE_LOAN_PRINCIPAL,
    EVENT_DECK,
    ESTATES_LOSER_PENALTY,
    ESTATES_WINNER_MULTIPLIER,
    EventEffect,
    EventDef,
    INSURABLE_TO_TYPE,
    INSURANCE_PREMIUMS,
    LIFE_TILE_VALUES,
    PAYDAY_PER_CHILD,
    RISK_IT_PRIZE,
    RISK_IT_STAKE,
    RISK_IT_THRESHOLD,
    STOCK_COST,
    STOCK_PAYOUT,
    Space,
    SpaceType,
    TRACK_LENGTHS,
    build_track,
    filter_events_for_options,
)


# How long college players take before they "graduate" and draw career cards.
# We trigger the draw when they pass their first COLLEGE_GRAD space; this
# counter is only used as a safety net.
_COLLEGE_TURN_FALLBACK = 4


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
    life_tile_pool: list[int] = field(default_factory=list)

    # Live game state
    players_finished: list[str] = field(default_factory=list)  # ids that have retired
    game_phase: str = "play"  # "play" | "estates_spin" | "tally" | "done"

    # Estates spin-off state
    estates_players: list[str] = field(default_factory=list)  # ids who chose estates
    estates_results: dict[str, int] = field(default_factory=dict)  # id -> spin
    estates_index: int = 0

    # Tally animation progress (ticks)
    tally_index: int = 0

    # Per-player pending career offers (player_id -> list of CANONICAL_CAREERS indices)
    career_offers: dict[str, list[int]] = field(default_factory=dict)

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
        return 1

    @classmethod
    def get_max_players(cls) -> int:
        return 6

    def create_player(self, player_id: str, name: str, is_bot: bool = False) -> LifePlayer:
        return LifePlayer(id=player_id, name=name, is_bot=is_bot)

    # ---------------------------------------------------------------------
    # Start / setup
    # ---------------------------------------------------------------------

    def on_start(self) -> None:
        self.status = "playing"
        self.game_active = True
        self.game_phase = "play"

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

        # Life tile pool (drawn without replacement during the game).
        if self.options.life_tiles == "off":
            self.life_tile_pool = []
        else:
            self.life_tile_pool = list(LIFE_TILE_VALUES)
            random.shuffle(self.life_tile_pool)  # nosec B311

        # Per-player init.
        for p in self.players:
            p.position = 0
            p.cash = self.options.starting_cash
            p.retired = False
            p.retirement_choice = "none"
            p.awaiting_spin = True
            p.path = "none"
            p.college_loan = 0
            p.career_key = ""
            p.career_label_key = ""
            p.salary = 0
            p.married = False
            p.children = 0
            p.has_fire_insurance = False
            p.has_auto_insurance = False
            p.has_life_insurance = False
            p.has_full_insurance = False
            p.stock_number = 0
            p.life_tile_values = []
            p.pending = "path" if self.options.college_path else "career_pick_noncollege"
            p.pending_options = []
            p.pending_event_key = ""
            p.turns_since_college_start = 0

        # If college path is off, every player gets a 2-card non-degree draw.
        if not self.options.college_path:
            for p in self.players:
                self._offer_careers(p, self.nondegree_career_pool, count=2)
                p.pending = "career_pick"

        self.set_turn_players(self.get_active_players())
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
        """Move from 'play' through 'estates_spin' and 'tally' to 'done'."""
        # If everyone's retired, start the endgame.
        if self.game_phase == "play" and self._everyone_retired():
            self._begin_endgame()
            return
        if self.game_phase == "estates_spin":
            # Estates spin runs itself via scheduled events.
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
                id="pay_loan",
                label="",
                handler="_action_pay_loan",
                is_enabled="_is_pay_loan_enabled",
                is_hidden="_is_pay_loan_hidden",
                get_label="_get_pay_loan_label",
            )
        )
        action_set.add(
            Action(
                id="sell_stock",
                label=Localization.get(locale, "life-action-sell-stock"),
                handler="_action_sell_stock",
                is_enabled="_is_sell_stock_enabled",
                is_hidden="_is_sell_stock_hidden",
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
        return None

    def _is_spin_hidden(self, player: Player) -> Visibility:
        if self.status != "playing":
            return Visibility.HIDDEN
        if not self._my_turn(player):
            return Visibility.HIDDEN
        lp: LifePlayer = player  # type: ignore
        if lp.retired:
            return Visibility.HIDDEN
        if lp.pending != "":
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

    def _is_career_pick_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "career_pick":
            return Visibility.HIDDEN
        # Extract slot index from the action id we're being asked about.
        # (The base action framework calls this per-action; the slot is read
        # from the action id itself.)
        return Visibility.VISIBLE

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
            salary=_fmt_money(career.salary),
            degree="yes" if career.degree_required else "no",
        )

    # Insurance action visibility / labels.

    def _is_buy_insurance_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "insurance":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_buy_insurance_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "life-action-not-your-turn"
        return None

    def _get_buy_insurance_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if action_id == "buy_full_insurance":
            return Localization.get(
                locale, "life-action-buy-insurance", money=_fmt_money(INSURANCE_PREMIUMS["simplified"])
            )
        mapping = {
            "buy_fire_insurance": ("life-action-buy-fire", INSURANCE_PREMIUMS["fire"]),
            "buy_auto_insurance": ("life-action-buy-auto", INSURANCE_PREMIUMS["auto"]),
            "buy_life_insurance": ("life-action-buy-life", INSURANCE_PREMIUMS["life"]),
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
        if not self._my_turn(player) or lp.pending != "insurance":
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
        if not self._my_turn(player) or lp.pending != "stock":
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
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "stock":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

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

    def _is_retirement_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "retirement":
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
        if lp.college_loan <= 0:
            return "life-loan-none"
        if lp.cash < min(lp.college_loan, 10_000):
            return "life-loan-cannot-afford"
        return None

    def _is_pay_loan_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if lp.college_loan <= 0:
            return Visibility.HIDDEN
        if self.status != "playing":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_pay_loan_label(self, player: Player, action_id: str) -> str:
        lp: LifePlayer = player  # type: ignore
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale, "life-action-pay-loan", money=_fmt_money(lp.college_loan)
        )

    def _is_sell_stock_enabled(self, player: Player) -> str | None:
        lp: LifePlayer = player  # type: ignore
        if lp.stock_number == 0:
            return "life-stock-already-held"
        return None

    def _is_sell_stock_hidden(self, player: Player) -> Visibility:
        lp: LifePlayer = player  # type: ignore
        if lp.stock_number == 0:
            return Visibility.HIDDEN
        if self.status != "playing":
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

    # ---------------------------------------------------------------------
    # Action handlers — spin + movement
    # ---------------------------------------------------------------------

    def _action_spin(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "" or lp.retired:
            return
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
        self.end_turn()

    def _action_choose_career_path(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "path":
            return
        lp.path = "career"
        self._announce(player, "life-chose-career")
        self._offer_careers(lp, self.nondegree_career_pool, count=2)
        lp.pending = "career_pick"

    # ---------------------------------------------------------------------
    # Action handlers — career pick
    # ---------------------------------------------------------------------

    def _action_pick_career(self, player: Player, *args) -> None:
        """Handle career pick. Called with (player, action_id)."""
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
        career = CANONICAL_CAREERS[offers[slot]]
        lp.career_key = career.key
        lp.career_label_key = career.label_key
        lp.salary = career.salary
        lp.pending = ""
        self.career_offers.pop(lp.id, None)

        user = self.get_user(player)
        locale = user.locale if user else "en"
        self._announce(
            player,
            "life-career-chosen",
            career=Localization.get(locale, career.label_key),
            salary=_fmt_money(career.salary),
        )
        self.end_turn()

    def _offer_careers(
        self, player: LifePlayer, pool: list[int], count: int
    ) -> None:
        pool_copy = list(pool)
        random.shuffle(pool_copy)  # nosec B311
        picks = pool_copy[: min(count, len(pool_copy))]
        self.career_offers[player.id] = picks

    # ---------------------------------------------------------------------
    # Action handlers — insurance / stocks / risk it / retirement
    # ---------------------------------------------------------------------

    def _action_buy_insurance(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "insurance":
            return
        type_map = {
            "buy_fire_insurance": ("fire", INSURANCE_PREMIUMS["fire"], "life-bought-fire"),
            "buy_auto_insurance": ("auto", INSURANCE_PREMIUMS["auto"], "life-bought-auto"),
            "buy_life_insurance": ("life", INSURANCE_PREMIUMS["life"], "life-bought-life"),
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
        lp.pending = ""
        self.end_turn()

    def _action_skip_insurance(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "insurance":
            return
        self._announce(player, "life-skipped-insurance")
        lp.pending = ""
        self.end_turn()

    def _action_buy_stock(self, player: Player, *args) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "stock":
            return
        if len(args) < 1:
            return
        # args is (input_value, action_id) when input_request is set.
        if len(args) >= 2:
            input_value = args[0]
        else:
            return
        try:
            number = int(str(input_value).strip())
        except ValueError:
            return
        if not (1 <= number <= 10):
            return
        if lp.cash < STOCK_COST:
            user = self.get_user(player)
            if user:
                user.speak_l("life-cannot-afford")
            return
        lp.cash -= STOCK_COST
        lp.stock_number = number
        self._announce(player, "life-stock-bought", number=number, money=_fmt_money(STOCK_COST))
        lp.pending = ""
        self.end_turn()

    def _stock_number_options(self, player: Player) -> list[str]:
        return [str(i) for i in range(1, 11)]

    def _bot_select_stock_number(self, player: Player, options: list[str]) -> str | None:
        lp: LifePlayer = player  # type: ignore
        return life_bot.choose_stock(lp) if life_bot.choose_stock(lp) != "skip" else options[0]

    def _action_skip_stock(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.pending != "stock":
            return
        self._announce(player, "life-stock-skipped")
        lp.pending = ""
        self.end_turn()

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
        lp.retirement_choice = choice
        lp.pending = ""
        lp.retired = True
        if player.id not in self.players_finished:
            self.players_finished.append(player.id)
        if choice == "acres":
            self._announce(player, "life-chose-acres")
        else:
            self._announce(player, "life-chose-estates")
            self.estates_players.append(player.id)
        self.end_turn()

    # ---------------------------------------------------------------------
    # Always-available actions (loan, stock sell, status).
    # ---------------------------------------------------------------------

    def _action_pay_loan(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.college_loan <= 0:
            return
        pay = min(lp.college_loan, lp.cash)
        if pay <= 0:
            return
        lp.cash -= pay
        lp.college_loan -= pay
        if lp.college_loan == 0:
            self._announce(player, "life-loan-paid", money=_fmt_money(pay))
        else:
            self._announce(
                player,
                "life-loan-partial",
                money=_fmt_money(pay),
                remaining=_fmt_money(lp.college_loan),
            )

    def _action_sell_stock(self, player: Player, action_id: str) -> None:
        lp: LifePlayer = player  # type: ignore
        if lp.stock_number == 0:
            return
        refund = STOCK_COST  # sell back at cost
        lp.cash += refund
        lp.stock_number = 0
        self._announce(player, "life-stock-sold", money=_fmt_money(refund))

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
                )
            )
        else:
            lines.append(Localization.get(locale, "life-status-career-none"))

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
            lines.append(Localization.get(locale, "life-status-loan", money=_fmt_money(lp.college_loan)))
        elif lp.path == "college":
            lines.append(Localization.get(locale, "life-status-loan-none"))

        # Stock
        if self.options.stock_market:
            if lp.stock_number:
                lines.append(Localization.get(locale, "life-status-stock", number=lp.stock_number))
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
        elif event_type == "estates_spin":
            self._handle_estates_spin(data)
        elif event_type == "estates_resolve":
            self._handle_estates_resolve()
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
        self._announce(player, "life-spin-result", value=value)

        # Any opponent holding this stock number gets paid.
        if self.options.stock_market:
            for p in self.get_active_players():
                lp: LifePlayer = p  # type: ignore
                if lp.stock_number == value:
                    lp.cash += STOCK_PAYOUT
                    self._announce(
                        p,
                        "life-stock-paid",
                        number=value,
                        money=_fmt_money(STOCK_PAYOUT),
                    )

        # Schedule movement steps.
        self._schedule_movement(player, value)

    def _schedule_movement(self, player: Player, steps: int) -> None:
        """Schedule step-by-step movement events with sounds, then a landing resolution."""
        lp: LifePlayer = player  # type: ignore
        base_delay = 6
        step_interval = 4
        # Use the standard token-movement scheduler for per-step sounds.
        next_delay = self.schedule_standard_token_movement_sounds(
            steps,
            start_delay_ticks=base_delay,
            step_interval_ticks=step_interval,
            variant_count=3,
        )
        # After all steps, jump the player to the final position in one event.
        target = min(lp.position + steps, len(self.track) - 1)
        self.schedule_event(
            "step_move",
            {"player_id": player.id, "target": target, "steps": steps},
            delay_ticks=next_delay,
        )

    def _handle_step_move(self, data: dict) -> None:
        player = self.get_player_by_id(data["player_id"])
        if not player:
            return
        lp: LifePlayer = player  # type: ignore

        old_pos = lp.position
        target = int(data["target"])

        # Pass-through bonuses: if we cross a PAYDAY space between old_pos (exclusive)
        # and target (inclusive — payouts trigger whether we pass or stop).
        payday_gained = 0
        for idx in range(old_pos + 1, target + 1):
            space = self.track[idx]
            if space.type == SpaceType.PAYDAY and lp.salary > 0:
                bonus = 0
                if self.options.family_enabled and lp.children > 0:
                    bonus = PAYDAY_PER_CHILD * lp.children
                earning = lp.salary + bonus
                lp.cash += earning
                payday_gained += earning
                # If this is a *passed* payday (not the final landing), announce it.
                if idx != target:
                    self._announce(
                        player, "life-pass-payday", money=_fmt_money(earning)
                    )

        lp.position = target
        self._announce(player, "life-move", position=target)

        # College auto-grad: if a college-path player passes/lands on the first
        # COLLEGE_GRAD space, draw career cards.
        if lp.path == "college" and lp.career_key == "":
            for idx in range(old_pos + 1, target + 1):
                if self.track[idx].type == SpaceType.COLLEGE_GRAD:
                    self._college_graduate(lp)
                    break
            # Safety net if the track has no grad space.
            lp.turns_since_college_start += 1

        # Schedule landing resolution.
        self.schedule_event(
            "resolve_landing", {"player_id": player.id, "payday": payday_gained}, delay_ticks=6
        )

    def _college_graduate(self, lp: LifePlayer) -> None:
        self._announce_player(lp, "life-college-graduated")
        self._offer_careers(lp, self.career_pool, count=3)
        # Defer the prompt — the player will get it right after their move resolution.
        lp.pending = "career_pick"

    def _announce_player(self, lp: LifePlayer, message_id: str, **kwargs) -> None:
        """_announce that works when we already have the LifePlayer subclass."""
        self._announce(lp, message_id, **kwargs)

    # ---------------------------------------------------------------------
    # Landing resolution — per SpaceType
    # ---------------------------------------------------------------------

    def _handle_resolve_landing(self, data: dict) -> None:
        player = self.get_player_by_id(data["player_id"])
        if not player:
            return
        lp: LifePlayer = player  # type: ignore

        # If the player was already given a pending prompt (e.g. career pick
        # from college graduation), skip landing resolution and let them pick.
        if lp.pending != "":
            self.is_animating = False
            self._rebuild_and_continue(player)
            return

        space = self.track[lp.position]
        stype = space.type
        locale = (self.get_user(player).locale if self.get_user(player) else "en")

        end_turn = True
        if stype == SpaceType.NORMAL or stype == SpaceType.START:
            # Nothing happens.
            pass
        elif stype == SpaceType.PAYDAY:
            # Already collected during pass-through; just announce the landing.
            if lp.salary > 0:
                bonus = PAYDAY_PER_CHILD * lp.children if (self.options.family_enabled and lp.children > 0) else 0
                salary = lp.salary
                total = salary + bonus
                if bonus > 0:
                    self._announce(
                        player,
                        "life-payday-with-kids",
                        money=_fmt_money(total),
                        salary=_fmt_money(salary),
                        bonus=_fmt_money(bonus),
                        kids=lp.children,
                    )
                else:
                    self._announce(player, "life-payday", money=_fmt_money(total))
        elif stype == SpaceType.EVENT:
            self._apply_event(lp, space)
        elif stype == SpaceType.MARRY:
            if self.options.family_enabled:
                if lp.married:
                    self._announce(player, "life-event-already-married")
                else:
                    lp.married = True
                    self._announce(player, "life-event-get-married")
        elif stype == SpaceType.BABY:
            if self.options.family_enabled:
                if not lp.married:
                    self._announce(player, "life-event-baby-needs-marriage")
                else:
                    roll = random.randint(1, 10)  # nosec B311
                    if roll == 10:
                        lp.children += 2
                        self._announce(player, "life-event-twins")
                    elif roll % 2 == 0:
                        lp.children += 1
                        self._announce(player, "life-event-baby-girl")
                    else:
                        lp.children += 1
                        self._announce(player, "life-event-baby-boy")
        elif stype == SpaceType.INSURANCE:
            if self.options.insurance != "off":
                lp.pending = "insurance"
                self._announce(player, "life-insurance-offer")
                end_turn = False
        elif stype == SpaceType.STOCK:
            if self.options.stock_market and lp.stock_number == 0 and lp.cash >= STOCK_COST:
                lp.pending = "stock"
                self._announce(player, "life-stock-offer")
                end_turn = False
            else:
                # No prompt — just a flavor announcement.
                self._announce(player, "life-stock-offer")
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
            # Already handled during step_move via pending; fall through.
            pass
        elif stype == SpaceType.CAREER_CHANGE:
            # Offer a fresh career draw.
            pool = (
                self.career_pool if lp.path == "college" else self.nondegree_career_pool
            )
            self._offer_careers(lp, pool, count=2)
            lp.pending = "career_pick"
            end_turn = False
        elif stype == SpaceType.RETIRE_JUNCTION:
            if self.options.retirement == "none":
                # Treat as immediate finish.
                lp.retired = True
                if player.id not in self.players_finished:
                    self.players_finished.append(player.id)
                self.broadcast_l("life-retirement-skipped")
            else:
                lp.pending = "retirement"
                self._announce(player, "life-retirement-reached")
                end_turn = False
        elif stype == SpaceType.FINISH:
            # Force retirement choice if they haven't already retired.
            if self.options.retirement == "none":
                lp.retired = True
                if player.id not in self.players_finished:
                    self.players_finished.append(player.id)
            else:
                lp.pending = "retirement"
                self._announce(player, "life-retirement-reached")
                end_turn = False

        if end_turn:
            self.is_animating = False
            self.end_turn()
        else:
            # We need a menu rebuild so the pending actions appear.
            self.is_animating = False
            self._rebuild_and_continue(player)

    def _rebuild_and_continue(self, player: Player) -> None:
        """Rebuild the current player's menu for a pending prompt and continue."""
        self.rebuild_player_menu(player, position=1)
        # If it's a bot, they'll act on their next tick via bot_think.
        BotHelper.jolt_bot(player, ticks=random.randint(15, 25))

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
            lp.cash -= event.amount
            self._announce(lp, f"life-event-{event.key}", money=_fmt_money(event.amount))
        elif event.effect in (
            EventEffect.INSURABLE_AUTO,
            EventEffect.INSURABLE_FIRE,
            EventEffect.INSURABLE_LIFE,
        ):
            ins_type = INSURABLE_TO_TYPE[event.effect]
            insured = lp.covers(ins_type)
            if not insured:
                lp.cash -= event.amount
            self._announce(
                lp,
                f"life-event-{event.key}",
                money=_fmt_money(event.amount),
                insured="yes" if insured else "no",
            )
        elif event.effect == EventEffect.LIFE_TILE:
            # The event's own message ("...earns a Life tile") is the user-facing
            # announcement; _grant_life_tile runs silently when triggered by an event.
            self._grant_life_tile(lp, silent=True)
            self._announce(lp, f"life-event-{event.key}")
        elif event.effect == EventEffect.LAWSUIT:
            self._resolve_lawsuit(lp, event.amount)

    def _grant_life_tile(self, lp: LifePlayer, silent: bool = False) -> None:
        if self.options.life_tiles == "off":
            # Life tiles disabled: give cash instead.
            lp.cash += 30_000
            return
        if not self.life_tile_pool:
            # Refill pool if exhausted.
            self.life_tile_pool = list(LIFE_TILE_VALUES)
            random.shuffle(self.life_tile_pool)  # nosec B311
        value = self.life_tile_pool.pop()
        lp.life_tile_values.append(value)
        if silent:
            return
        if self.options.life_tiles == "revealed":
            self._announce(lp, "life-tile-earned-revealed", money=_fmt_money(value))
        else:
            self._announce(lp, "life-tile-earned-hidden")

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
    # Endgame — Millionaire Estates spin-off + tally
    # ---------------------------------------------------------------------

    def _begin_endgame(self) -> None:
        if self.options.retirement == "classic" and self.estates_players:
            self.game_phase = "estates_spin"
            self.estates_index = 0
            self.is_animating = True
            self.broadcast_l("life-estates-spin-header")
            self.schedule_event("estates_spin", {}, delay_ticks=8)
        else:
            self.game_phase = "tally"
            self.schedule_event("tally_start", {}, delay_ticks=6)

    def _handle_estates_spin(self, data: dict) -> None:
        if self.estates_index >= len(self.estates_players):
            # Resolve after final spin.
            self.schedule_event("estates_resolve", {}, delay_ticks=6)
            return
        pid = self.estates_players[self.estates_index]
        player = self.get_player_by_id(pid)
        if not player:
            self.estates_index += 1
            self.schedule_event("estates_spin", {}, delay_ticks=4)
            return
        value = random.randint(1, 10)  # nosec B311
        self.estates_results[pid] = value
        self.play_standard_dice_roll_sound()
        self.broadcast_l("life-estates-spin", player=player.name, value=value)
        self.estates_index += 1
        self.schedule_event("estates_spin", {}, delay_ticks=10)

    def _handle_estates_resolve(self) -> None:
        if not self.estates_results:
            self.schedule_event("tally_start", {}, delay_ticks=4)
            return
        highest = max(self.estates_results.values())
        winners = [pid for pid, v in self.estates_results.items() if v == highest]
        for pid, v in self.estates_results.items():
            player = self.get_player_by_id(pid)
            if not player:
                continue
            lp: LifePlayer = player  # type: ignore
            if pid in winners:
                lp.cash *= ESTATES_WINNER_MULTIPLIER
            else:
                lp.cash -= ESTATES_LOSER_PENALTY
        if len(winners) == 1:
            winner = self.get_player_by_id(winners[0])
            if winner:
                wlp: LifePlayer = winner  # type: ignore
                self.broadcast_l(
                    "life-estates-winner", player=winner.name, money=_fmt_money(wlp.cash)
                )
        else:
            winner_names = ", ".join(
                (p.name for p in self.players if p.id in winners)
            )
            self.broadcast_l("life-estates-tie", players=winner_names)

        for pid, v in self.estates_results.items():
            if pid in winners:
                continue
            player = self.get_player_by_id(pid)
            if not player:
                continue
            lp = player  # type: ignore
            self.broadcast_l(
                "life-estates-loser",
                player=player.name,
                money=_fmt_money(ESTATES_LOSER_PENALTY),
                remaining=_fmt_money(lp.cash),
            )

        self.game_phase = "tally"
        self.schedule_event("tally_start", {}, delay_ticks=8)

    def _begin_tally(self) -> None:
        # Countryside Acres bonus for safe-path retirees.
        for p in self.get_active_players():
            lp: LifePlayer = p  # type: ignore
            if lp.retirement_choice == "acres" or (
                self.options.retirement == "safe" and lp.retired
            ):
                lp.cash += ACRES_BONUS
                self._announce(p, "life-acres-bonus", money=_fmt_money(ACRES_BONUS))

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
            pick = life_bot.pick_career(
                [(i, CANONICAL_CAREERS[c].salary) for i, c in enumerate(offers)]
            )
            return f"pick_career_{pick}"
        if pending == "insurance":
            available: list[str] = []
            mode = self.options.insurance
            if mode == "full":
                for t in ("fire", "auto", "life"):
                    if not player.covers(t):
                        available.append(t)
            elif mode == "simplified":
                if not player.has_full_insurance:
                    available.append("full")
            choice = life_bot.choose_insurance(player, self, available)
            if choice == "skip":
                return "skip_insurance"
            if choice == "full":
                return "buy_full_insurance"
            return f"buy_{choice}_insurance"
        if pending == "stock":
            choice = life_bot.choose_stock(player)
            if choice == "skip":
                return "skip_stock"
            return "buy_stock"
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
