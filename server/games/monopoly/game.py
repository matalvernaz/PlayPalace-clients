"""Monopoly game scaffold wired to generated preset artifacts."""

from __future__ import annotations

from dataclasses import dataclass, field
import random

from ..base import Game, Player, GameOptions
from ..registry import register_game
from ...game_utils.action_guard_mixin import ActionGuardMixin
from ...game_utils.bot_helper import BotHelper
from ...game_utils.actions import Action, ActionSet, Visibility
from ...game_utils.options import MenuOption, option_field
from ...messages.localization import Localization
from ...ui.keybinds import KeybindState
from .presets import (
    DEFAULT_PRESET_ID,
    MonopolyPreset,
    get_available_preset_ids as _catalog_preset_ids,
    get_default_preset_id as _catalog_default_preset_id,
    get_preset as _catalog_get_preset,
)


PRESET_LABEL_KEYS = {
    "classic_standard": "monopoly-preset-classic-standard",
    "junior": "monopoly-preset-junior",
    "cheaters": "monopoly-preset-cheaters",
    "electronic_banking": "monopoly-preset-electronic-banking",
    "voice_banking": "monopoly-preset-voice-banking",
    "sore_losers": "monopoly-preset-sore-losers",
    "speed": "monopoly-preset-speed",
    "builder": "monopoly-preset-builder",
    "city": "monopoly-preset-city",
    "bid_card_game": "monopoly-preset-bid-card-game",
    "deal_card_game": "monopoly-preset-deal-card-game",
    "knockout": "monopoly-preset-knockout",
    "free_parking_jackpot": "monopoly-preset-free-parking-jackpot",
}


@dataclass(frozen=True)
class MonopolySpace:
    """A board space on the classic Monopoly board."""

    index: int
    space_id: str
    name: str
    kind: str
    price: int = 0
    rent: int = 0


CLASSIC_STANDARD_BOARD = [
    MonopolySpace(0, "go", "GO", "start"),
    MonopolySpace(1, "mediterranean_avenue", "Mediterranean Avenue", "property", 60, 2),
    MonopolySpace(2, "community_chest_1", "Community Chest", "community_chest"),
    MonopolySpace(3, "baltic_avenue", "Baltic Avenue", "property", 60, 4),
    MonopolySpace(4, "income_tax", "Income Tax", "tax"),
    MonopolySpace(5, "reading_railroad", "Reading Railroad", "railroad", 200, 25),
    MonopolySpace(6, "oriental_avenue", "Oriental Avenue", "property", 100, 6),
    MonopolySpace(7, "chance_1", "Chance", "chance"),
    MonopolySpace(8, "vermont_avenue", "Vermont Avenue", "property", 100, 6),
    MonopolySpace(9, "connecticut_avenue", "Connecticut Avenue", "property", 120, 8),
    MonopolySpace(10, "jail", "Jail / Just Visiting", "jail"),
    MonopolySpace(11, "st_charles_place", "St. Charles Place", "property", 140, 10),
    MonopolySpace(12, "electric_company", "Electric Company", "utility", 150, 20),
    MonopolySpace(13, "states_avenue", "States Avenue", "property", 140, 10),
    MonopolySpace(14, "virginia_avenue", "Virginia Avenue", "property", 160, 12),
    MonopolySpace(15, "pennsylvania_railroad", "Pennsylvania Railroad", "railroad", 200, 25),
    MonopolySpace(16, "st_james_place", "St. James Place", "property", 180, 14),
    MonopolySpace(17, "community_chest_2", "Community Chest", "community_chest"),
    MonopolySpace(18, "tennessee_avenue", "Tennessee Avenue", "property", 180, 14),
    MonopolySpace(19, "new_york_avenue", "New York Avenue", "property", 200, 16),
    MonopolySpace(20, "free_parking", "Free Parking", "free_parking"),
    MonopolySpace(21, "kentucky_avenue", "Kentucky Avenue", "property", 220, 18),
    MonopolySpace(22, "chance_2", "Chance", "chance"),
    MonopolySpace(23, "indiana_avenue", "Indiana Avenue", "property", 220, 18),
    MonopolySpace(24, "illinois_avenue", "Illinois Avenue", "property", 240, 20),
    MonopolySpace(25, "bo_railroad", "B. & O. Railroad", "railroad", 200, 25),
    MonopolySpace(26, "atlantic_avenue", "Atlantic Avenue", "property", 260, 22),
    MonopolySpace(27, "ventnor_avenue", "Ventnor Avenue", "property", 260, 22),
    MonopolySpace(28, "water_works", "Water Works", "utility", 150, 20),
    MonopolySpace(29, "marvin_gardens", "Marvin Gardens", "property", 280, 24),
    MonopolySpace(30, "go_to_jail", "Go to Jail", "go_to_jail"),
    MonopolySpace(31, "pacific_avenue", "Pacific Avenue", "property", 300, 26),
    MonopolySpace(32, "north_carolina_avenue", "North Carolina Avenue", "property", 300, 26),
    MonopolySpace(33, "community_chest_3", "Community Chest", "community_chest"),
    MonopolySpace(34, "pennsylvania_avenue", "Pennsylvania Avenue", "property", 320, 28),
    MonopolySpace(35, "short_line", "Short Line", "railroad", 200, 25),
    MonopolySpace(36, "chance_3", "Chance", "chance"),
    MonopolySpace(37, "park_place", "Park Place", "property", 350, 35),
    MonopolySpace(38, "luxury_tax", "Luxury Tax", "tax"),
    MonopolySpace(39, "boardwalk", "Boardwalk", "property", 400, 50),
]
SPACE_BY_ID = {space.space_id: space for space in CLASSIC_STANDARD_BOARD}
PURCHASABLE_KINDS = {"property", "railroad", "utility"}
BOARD_SIZE = len(CLASSIC_STANDARD_BOARD)
STARTING_CASH = 1500
PASS_GO_CASH = 200
TAX_AMOUNTS = {"income_tax": 200, "luxury_tax": 100}


@dataclass
class MonopolyPlayer(Player):
    """Player state for Monopoly scaffold."""

    position: int = 0
    cash: int = STARTING_CASH
    owned_space_ids: list[str] = field(default_factory=list)


@dataclass
class MonopolyOptions(GameOptions):
    """Lobby options for Monopoly scaffold."""

    preset_id: str = option_field(
        MenuOption(
            default=DEFAULT_PRESET_ID,
            choices=lambda game, player: game.get_available_preset_ids(),
            value_key="preset",
            choice_labels=PRESET_LABEL_KEYS,
            label="monopoly-set-preset",
            prompt="monopoly-select-preset",
            change_msg="monopoly-option-changed-preset",
        )
    )


@dataclass
@register_game
class MonopolyGame(ActionGuardMixin, Game):
    """Catalog-backed Monopoly scaffold.

    This class intentionally wires preset selection and metadata loading first.
    Gameplay mechanics are added incrementally in later milestones.
    """

    players: list[MonopolyPlayer] = field(default_factory=list)
    options: MonopolyOptions = field(default_factory=MonopolyOptions)

    active_preset_id: str = DEFAULT_PRESET_ID
    active_preset_name: str = ""
    active_family_key: str = ""
    active_edition_ids: list[str] = field(default_factory=list)
    active_anchor_edition_id: str = ""
    property_owners: dict[str, str] = field(default_factory=dict)
    turn_has_rolled: bool = False
    turn_last_roll: list[int] = field(default_factory=list)
    turn_pending_purchase_space_id: str = ""

    @classmethod
    def get_name(cls) -> str:
        return "Monopoly"

    @classmethod
    def get_type(cls) -> str:
        return "monopoly"

    @classmethod
    def get_category(cls) -> str:
        return "category-uncategorized"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 6

    def create_player(
        self, player_id: str, name: str, is_bot: bool = False
    ) -> MonopolyPlayer:
        """Create a Monopoly player."""
        return MonopolyPlayer(id=player_id, name=name, is_bot=is_bot)

    def create_turn_action_set(self, player: MonopolyPlayer) -> ActionSet:
        """Create the turn action set for Monopoly."""
        user = self.get_user(player)
        locale = user.locale if user else "en"

        action_set = ActionSet(name="turn")
        action_set.add(
            Action(
                id="roll_dice",
                label=Localization.get(locale, "monopoly-roll-dice"),
                handler="_action_roll_dice",
                is_enabled="_is_roll_dice_enabled",
                is_hidden="_is_roll_dice_hidden",
            )
        )
        action_set.add(
            Action(
                id="buy_property",
                label=Localization.get(locale, "monopoly-buy-property"),
                handler="_action_buy_property",
                is_enabled="_is_buy_property_enabled",
                is_hidden="_is_buy_property_hidden",
            )
        )
        action_set.add(
            Action(
                id="end_turn",
                label=Localization.get(locale, "monopoly-end-turn"),
                handler="_action_end_turn",
                is_enabled="_is_end_turn_enabled",
                is_hidden="_is_end_turn_hidden",
            )
        )
        return action_set

    def setup_keybinds(self) -> None:
        """Define keybinds for lobby + scaffold status checks."""
        super().setup_keybinds()
        self.define_keybind("r", "Roll dice", ["roll_dice"], state=KeybindState.ACTIVE)
        self.define_keybind("b", "Buy property", ["buy_property"], state=KeybindState.ACTIVE)
        self.define_keybind("e", "End turn", ["end_turn"], state=KeybindState.ACTIVE)
        self.define_keybind(
            "p",
            "Announce current preset",
            ["announce_preset"],
            state=KeybindState.ACTIVE,
            include_spectators=True,
        )

    def create_standard_action_set(self, player: MonopolyPlayer) -> ActionSet:
        """Add preset announcement action to standard action set."""
        action_set = super().create_standard_action_set(player)
        user = self.get_user(player)
        locale = user.locale if user else "en"
        action_set.add(
            Action(
                id="announce_preset",
                label=Localization.get(locale, "monopoly-announce-preset"),
                handler="_action_announce_preset",
                is_enabled="_is_announce_preset_enabled",
                is_hidden="_is_announce_preset_hidden",
            )
        )
        return action_set

    def get_available_preset_ids(self) -> list[str]:
        """Return selectable preset ids from generated catalog artifacts."""
        return _catalog_preset_ids()

    def _fallback_preset(self) -> MonopolyPreset:
        """Return a safe fallback preset if artifacts are missing."""
        fallback_id = _catalog_default_preset_id()
        fallback = _catalog_get_preset(fallback_id)
        if fallback:
            return fallback
        return MonopolyPreset(
            preset_id=DEFAULT_PRESET_ID,
            family_key="classic_and_themed_standard",
            name="Classic and Themed Standard",
            description="Fallback preset when catalog artifacts are unavailable.",
            anchor_edition_id="",
            edition_ids=(),
        )

    def _resolve_selected_preset(self) -> MonopolyPreset:
        """Resolve currently selected lobby preset, applying fallback when needed."""
        selected = _catalog_get_preset(self.options.preset_id)
        if selected:
            return selected
        fallback = self._fallback_preset()
        self.options.preset_id = fallback.preset_id
        return fallback

    def _localize_preset_name(self, locale: str, preset_id: str, fallback: str) -> str:
        """Resolve localized preset label for speech."""
        preset_key = PRESET_LABEL_KEYS.get(preset_id)
        if not preset_key:
            return fallback
        text = Localization.get(locale, preset_key)
        if text == preset_key:
            return fallback
        return text

    def _is_announce_preset_enabled(self, player: Player) -> str | None:
        """Enable preset announcements during active play."""
        return self.guard_game_active()

    def _is_announce_preset_hidden(self, player: Player) -> Visibility:
        """Hide announce action from menus (keybind only)."""
        return Visibility.HIDDEN

    def _action_announce_preset(self, player: Player, action_id: str) -> None:
        """Speak current preset details to one player."""
        user = self.get_user(player)
        if not user:
            return
        preset_name = self._localize_preset_name(
            user.locale, self.active_preset_id, self.active_preset_name
        )
        user.speak_l(
            "monopoly-current-preset",
            preset=preset_name,
            count=len(self.active_edition_ids),
        )

    def _space_at(self, position: int) -> MonopolySpace:
        """Get board space by board index."""
        return CLASSIC_STANDARD_BOARD[position % BOARD_SIZE]

    def _pending_purchase_space(self) -> MonopolySpace | None:
        """Get the currently pending purchasable space for this turn."""
        if not self.turn_pending_purchase_space_id:
            return None
        return SPACE_BY_ID.get(self.turn_pending_purchase_space_id)

    def _can_buy_pending_space(self, player: MonopolyPlayer) -> bool:
        """Return True if the active player can buy pending space now."""
        space = self._pending_purchase_space()
        if not space:
            return False
        if space.kind not in PURCHASABLE_KINDS:
            return False
        if space.space_id in self.property_owners:
            return False
        return player.cash >= space.price > 0

    def _reset_turn_state(self) -> None:
        """Reset transient per-turn state."""
        self.turn_has_rolled = False
        self.turn_last_roll.clear()
        self.turn_pending_purchase_space_id = ""

    def _sync_cash_scores(self) -> None:
        """Mirror player cash into team scores for score actions."""
        if self._team_manager.team_mode != "individual":
            return
        for team in self._team_manager.teams:
            if not team.members:
                continue
            player = self.get_player_by_name(team.members[0])
            team.total_score = player.cash if player else 0
            team.round_score = 0

    def _is_roll_dice_enabled(self, player: Player) -> str | None:
        """Enable roll action for active player before rolling."""
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        if self.turn_has_rolled:
            return "monopoly-already-rolled"
        return None

    def _is_roll_dice_hidden(self, player: Player) -> Visibility:
        """Hide roll once a roll has been made this turn."""
        return self.turn_action_visibility(player, extra_condition=not self.turn_has_rolled)

    def _is_buy_property_enabled(self, player: Player) -> str | None:
        """Enable buy action when current player can buy landed property."""
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        if not self.turn_has_rolled:
            return "monopoly-roll-first"
        mono_player: MonopolyPlayer = player  # type: ignore
        space = self._pending_purchase_space()
        if not space:
            return "monopoly-no-property-to-buy"
        if space.space_id in self.property_owners:
            return "monopoly-property-owned"
        if mono_player.cash < space.price:
            return "monopoly-not-enough-cash"
        return None

    def _is_buy_property_hidden(self, player: Player) -> Visibility:
        """Show buy action only after a roll when a property is pending."""
        return self.turn_action_visibility(
            player,
            extra_condition=self.turn_has_rolled and self._pending_purchase_space() is not None,
        )

    def _is_end_turn_enabled(self, player: Player) -> str | None:
        """Enable end-turn after rolling."""
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        if not self.turn_has_rolled:
            return "monopoly-roll-first"
        return None

    def _is_end_turn_hidden(self, player: Player) -> Visibility:
        """Hide end-turn until player has rolled."""
        return self.turn_action_visibility(player, extra_condition=self.turn_has_rolled)

    def _action_roll_dice(self, player: Player, action_id: str) -> None:
        """Handle rolling and landing logic for classic scaffold."""
        mono_player: MonopolyPlayer = player  # type: ignore

        if self.turn_has_rolled:
            return

        die_1 = random.randint(1, 6)
        die_2 = random.randint(1, 6)
        total = die_1 + die_2

        old_position = mono_player.position
        absolute_position = old_position + total
        mono_player.position = absolute_position % BOARD_SIZE
        passed_go = absolute_position >= BOARD_SIZE
        landed_space = self._space_at(mono_player.position)

        self.turn_has_rolled = True
        self.turn_last_roll = [die_1, die_2]
        self.turn_pending_purchase_space_id = ""

        if passed_go:
            mono_player.cash += PASS_GO_CASH
            self.broadcast_l(
                "monopoly-pass-go",
                player=mono_player.name,
                amount=PASS_GO_CASH,
                cash=mono_player.cash,
            )

        self.broadcast_l(
            "monopoly-roll-result",
            player=mono_player.name,
            die1=die_1,
            die2=die_2,
            total=total,
            space=landed_space.name,
        )

        if landed_space.kind in PURCHASABLE_KINDS:
            owner_id = self.property_owners.get(landed_space.space_id)
            if owner_id is None:
                self.turn_pending_purchase_space_id = landed_space.space_id
                self.broadcast_l(
                    "monopoly-property-available",
                    player=mono_player.name,
                    property=landed_space.name,
                    price=landed_space.price,
                )
            elif owner_id == mono_player.id:
                self.broadcast_l(
                    "monopoly-landed-owned",
                    player=mono_player.name,
                    property=landed_space.name,
                )
            else:
                owner = self.get_player_by_id(owner_id)
                rent_due = landed_space.rent
                paid = min(mono_player.cash, rent_due)
                mono_player.cash -= paid
                if owner and isinstance(owner, MonopolyPlayer):
                    owner.cash += paid
                self.broadcast_l(
                    "monopoly-rent-paid",
                    player=mono_player.name,
                    owner=owner.name if owner else "Bank",
                    amount=paid,
                    property=landed_space.name,
                )
        elif landed_space.space_id in TAX_AMOUNTS:
            tax_due = TAX_AMOUNTS[landed_space.space_id]
            paid = min(mono_player.cash, tax_due)
            mono_player.cash -= paid
            self.broadcast_l(
                "monopoly-tax-paid",
                player=mono_player.name,
                amount=paid,
                tax=landed_space.name,
                cash=mono_player.cash,
            )
        elif landed_space.kind == "go_to_jail":
            jail_space = self._space_at(10)
            mono_player.position = jail_space.index
            self.broadcast_l(
                "monopoly-go-to-jail",
                player=mono_player.name,
                space=jail_space.name,
            )

        self._sync_cash_scores()
        self.rebuild_all_menus()

    def _action_buy_property(self, player: Player, action_id: str) -> None:
        """Buy currently pending property."""
        mono_player: MonopolyPlayer = player  # type: ignore
        space = self._pending_purchase_space()
        if not space:
            return
        if space.space_id in self.property_owners:
            self.turn_pending_purchase_space_id = ""
            return
        if mono_player.cash < space.price:
            return

        mono_player.cash -= space.price
        mono_player.owned_space_ids.append(space.space_id)
        self.property_owners[space.space_id] = mono_player.id
        self.turn_pending_purchase_space_id = ""

        self.broadcast_l(
            "monopoly-property-bought",
            player=mono_player.name,
            property=space.name,
            price=space.price,
            cash=mono_player.cash,
        )

        self._sync_cash_scores()
        self.rebuild_all_menus()

    def _action_end_turn(self, player: Player, action_id: str) -> None:
        """End current player's turn and advance."""
        self._reset_turn_state()
        next_player = self.advance_turn(announce=True)
        if next_player and next_player.is_bot:
            BotHelper.jolt_bot(next_player, ticks=random.randint(8, 14))

    def on_tick(self) -> None:
        """Run per-tick updates (bot actions)."""
        super().on_tick()
        BotHelper.on_tick(self)

    def bot_think(self, player: MonopolyPlayer) -> str | None:
        """Simple scaffold bot logic."""
        if not self.turn_has_rolled:
            return "roll_dice"
        pending_space = self._pending_purchase_space()
        if (
            pending_space
            and self._can_buy_pending_space(player)
            and player.cash - pending_space.price >= 200
        ):
            return "buy_property"
        return "end_turn"

    def on_start(self) -> None:
        """Start scaffold mode using the selected preset metadata."""
        self.status = "playing"
        self.game_active = True
        self.round = 1

        active_players = self.get_active_players()
        self._team_manager.team_mode = "individual"
        self._team_manager.setup_teams([player.name for player in active_players])
        self.set_turn_players(active_players)

        preset = self._resolve_selected_preset()
        self.active_preset_id = preset.preset_id
        self.active_preset_name = preset.name
        self.active_family_key = preset.family_key
        self.active_edition_ids = list(preset.edition_ids)
        self.active_anchor_edition_id = preset.anchor_edition_id
        self.property_owners.clear()
        self._reset_turn_state()

        for player in active_players:
            if isinstance(player, MonopolyPlayer):
                player.position = 0
                player.cash = STARTING_CASH
                player.owned_space_ids.clear()

        self._sync_cash_scores()

        self.broadcast_l(
            "monopoly-scaffold-started",
            preset=preset.name,
            count=len(self.active_edition_ids),
        )

        self.announce_turn(turn_sound="game_pig/turn.ogg")
        BotHelper.jolt_bots(self, ticks=random.randint(12, 20))
        self.rebuild_all_menus()
