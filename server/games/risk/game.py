"""
Risk Game Implementation for PlayPalace v11.

Classic territory conquest game: reinforce, attack, fortify.
2-6 players, 42 territories, dice-based combat.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime
import random
from typing import TYPE_CHECKING

from ..base import Game, Player, GameOptions
from ..registry import register_game
from ...game_utils.action_guard_mixin import ActionGuardMixin
from ...game_utils.round_based_game_mixin import RoundBasedGameMixin
from ...game_utils.actions import Action, ActionSet, Visibility
from ...game_utils.bot_helper import BotHelper
from ...game_utils.game_result import GameResult, PlayerResult
from ...game_utils.options import IntOption, option_field
from ...messages.localization import Localization
from server.core.ui.keybinds import KeybindState

from .territories import (
    TERRITORIES,
    CONTINENTS,
    ALL_TERRITORY_IDS,
    TERRITORIES_BY_CONTINENT,
    get_adjacent,
    get_territory_name,
    get_continent_bonus,
    player_controls_continent,
)

if TYPE_CHECKING:
    from server.core.users.base import User

# Card types for the trade-in system
CARD_TYPES = ["infantry", "cavalry", "artillery"]
TRADE_VALUES = [4, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]


@dataclass
class RiskPlayer(Player):
    """Player state for Risk."""

    color: str = ""
    eliminated: bool = False
    earned_card_this_turn: bool = False


@dataclass
class RiskCard:
    """A Risk territory card."""

    territory_id: str  # "" for wild cards
    card_type: str  # "infantry", "cavalry", "artillery", "wild"


@dataclass
class RiskOptions(GameOptions):
    """Options for Risk game."""

    starting_armies: int = option_field(
        IntOption(
            default=0,
            min_val=0,
            max_val=50,
            value_key="armies",
            label="risk-set-starting-armies",
            prompt="risk-enter-starting-armies",
            change_msg="risk-option-changed-armies",
            description="risk-desc-starting-armies",
        )
    )


PLAYER_COLORS = ["red", "blue", "green", "yellow", "purple", "orange"]


@dataclass
@register_game
class RiskGame(ActionGuardMixin, RoundBasedGameMixin, Game):
    """
    Risk — world conquest.

    Players take turns reinforcing territories, attacking neighbors,
    and fortifying positions. Eliminate all opponents to win.
    """

    players: list[RiskPlayer] = field(default_factory=list)
    options: RiskOptions = field(default_factory=RiskOptions)

    # Territory ownership: territory_id -> player_id
    owners: dict[str, str] = field(default_factory=dict)
    # Troop counts: territory_id -> int
    troops: dict[str, int] = field(default_factory=dict)
    # Cards
    deck: list[RiskCard] = field(default_factory=list)
    hands: dict[str, list[RiskCard]] = field(default_factory=dict)
    trade_count: int = 0

    # Turn phase state
    phase: str = "reinforce"  # reinforce | attack | fortify
    armies_to_place: int = 0
    attacker_id: str = ""
    defender_id: str = ""
    fortify_from: str = ""
    conquered_this_turn: bool = False

    @classmethod
    def get_name(cls) -> str:
        return "Risk"

    @classmethod
    def get_type(cls) -> str:
        return "risk"

    @classmethod
    def get_category(cls) -> str:
        return "category-board-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 6

    def create_player(
        self, player_id: str, name: str, is_bot: bool = False
    ) -> RiskPlayer:
        color = PLAYER_COLORS[len(self.players) % len(PLAYER_COLORS)]
        return RiskPlayer(id=player_id, name=name, is_bot=is_bot, color=color)

    def get_team_mode(self) -> str:
        return "individual"

    # ==========================================================================
    # Helpers
    # ==========================================================================

    def _player_territories(self, player: RiskPlayer) -> list[str]:
        return [tid for tid, pid in self.owners.items() if pid == player.id]

    def _player_territory_set(self, player: RiskPlayer) -> set[str]:
        return {tid for tid, pid in self.owners.items() if pid == player.id}

    def _get_player_by_id(self, player_id: str) -> RiskPlayer | None:
        for p in self.players:
            if p.id == player_id:
                return p
        return None

    def _alive_players(self) -> list[RiskPlayer]:
        return [p for p in self.get_active_players() if not p.eliminated]

    def _calculate_reinforcements(self, player: RiskPlayer) -> int:
        """Calculate armies a player receives at start of turn."""
        territories = self._player_territory_set(player)
        # Base: territories / 3, minimum 3
        base = max(3, len(territories) // 3)
        # Continent bonuses
        bonus = 0
        for cid in CONTINENTS:
            if player_controls_continent(cid, territories):
                bonus += get_continent_bonus(cid)
        return base + bonus

    # ==========================================================================
    # Card system
    # ==========================================================================

    def _build_deck(self) -> None:
        """Build and shuffle the card deck."""
        cards: list[RiskCard] = []
        for i, tid in enumerate(ALL_TERRITORY_IDS):
            cards.append(RiskCard(territory_id=tid, card_type=CARD_TYPES[i % 3]))
        cards.append(RiskCard(territory_id="", card_type="wild"))
        cards.append(RiskCard(territory_id="", card_type="wild"))
        random.shuffle(cards)
        self.deck = cards

    def _draw_card(self, player: RiskPlayer) -> None:
        if not self.deck:
            return
        card = self.deck.pop()
        if player.id not in self.hands:
            self.hands[player.id] = []
        self.hands[player.id].append(card)

    def _get_trade_value(self) -> int:
        idx = min(self.trade_count, len(TRADE_VALUES) - 1)
        return TRADE_VALUES[idx]

    def _find_valid_trade(self, player: RiskPlayer) -> list[int] | None:
        """Find indices of 3 cards that form a valid trade set, or None."""
        hand = self.hands.get(player.id, [])
        if len(hand) < 3:
            return None
        # Try: 3 of same type, or 1 of each, or any with wilds
        wilds = [i for i, c in enumerate(hand) if c.card_type == "wild"]
        by_type: dict[str, list[int]] = {}
        for i, c in enumerate(hand):
            if c.card_type != "wild":
                by_type.setdefault(c.card_type, []).append(i)
        # 3 of a kind
        for indices in by_type.values():
            if len(indices) >= 3:
                return indices[:3]
        # 1 of each
        if len(by_type) >= 3:
            types = list(by_type.keys())[:3]
            return [by_type[t][0] for t in types]
        # Use wilds
        if wilds:
            non_wild = [i for i in range(len(hand)) if i not in wilds]
            if len(wilds) + len(non_wild) >= 3:
                picks = wilds[:] + non_wild[:]
                return picks[:3]
        return None

    def _auto_trade_cards(self, player: RiskPlayer) -> int:
        """Auto-trade cards if possible. Returns bonus armies gained."""
        total_bonus = 0
        while True:
            trade = self._find_valid_trade(player)
            if trade is None:
                break
            hand = self.hands.get(player.id, [])
            if len(hand) <= 5 and total_bonus > 0:
                break  # Only force-trade at 5+ cards
            if len(hand) < 5 and total_bonus == 0:
                break  # Don't auto-trade below 5 unless forced
            bonus = self._get_trade_value()
            self.trade_count += 1
            total_bonus += bonus
            # Remove traded cards (reverse sort to preserve indices)
            for idx in sorted(trade, reverse=True):
                hand.pop(idx)
            self.broadcast_l(
                "risk-cards-traded", player=player.name, armies=bonus
            )
        return total_bonus

    def _force_trade_if_needed(self, player: RiskPlayer) -> int:
        """Force trade if player has 5+ cards. Returns bonus armies."""
        hand = self.hands.get(player.id, [])
        total = 0
        while len(hand) >= 5:
            trade = self._find_valid_trade(player)
            if trade is None:
                break
            bonus = self._get_trade_value()
            self.trade_count += 1
            total += bonus
            for idx in sorted(trade, reverse=True):
                hand.pop(idx)
            self.broadcast_l(
                "risk-cards-traded", player=player.name, armies=bonus
            )
        return total

    # ==========================================================================
    # Combat
    # ==========================================================================

    def _resolve_combat(
        self, attacker_tid: str, defender_tid: str, att_dice: int
    ) -> tuple[int, int]:
        """Resolve one round of combat. Returns (attacker_losses, defender_losses)."""
        def_troops = self.troops.get(defender_tid, 0)
        def_dice = min(2, def_troops)

        att_rolls = sorted(
            [random.randint(1, 6) for _ in range(att_dice)], reverse=True  # nosec B311
        )
        def_rolls = sorted(
            [random.randint(1, 6) for _ in range(def_dice)], reverse=True  # nosec B311
        )

        att_losses = 0
        def_losses = 0
        for a, d in zip(att_rolls, def_rolls):
            if a > d:
                def_losses += 1
            else:
                att_losses += 1

        return att_losses, def_losses, att_rolls, def_rolls

    # ==========================================================================
    # Game lifecycle
    # ==========================================================================

    def on_start(self) -> None:
        active = [p for p in self.players if not p.is_spectator]
        # Assign colors
        for i, p in enumerate(active):
            p.color = PLAYER_COLORS[i % len(PLAYER_COLORS)]
        # Distribute territories randomly
        shuffled = list(ALL_TERRITORY_IDS)
        random.shuffle(shuffled)
        for i, tid in enumerate(shuffled):
            owner = active[i % len(active)]
            self.owners[tid] = owner.id
            self.troops[tid] = 1
        # Place remaining starting armies
        starting = self.options.starting_armies
        if starting == 0:
            # Auto-calculate based on player count
            bases = {2: 40, 3: 35, 4: 30, 5: 25, 6: 20}
            starting = bases.get(len(active), 20)
            # Subtract the 1 troop already placed on each territory
            starting -= len(shuffled) // len(active)
        # Distribute extra armies randomly across owned territories
        for p in active:
            owned = self._player_territories(p)
            for _ in range(max(0, starting)):
                tid = random.choice(owned)  # nosec B311
                self.troops[tid] += 1
        # Init cards
        self._build_deck()
        for p in active:
            self.hands[p.id] = []
        # Start the game
        super().on_start()

    def on_tick(self) -> None:
        super().on_tick()
        BotHelper.on_tick(self)

    def _reset_player_for_game(self, player: RiskPlayer) -> None:
        player.eliminated = False
        player.earned_card_this_turn = False

    def _reset_player_for_turn(self, player: RiskPlayer) -> None:
        player.earned_card_this_turn = False

    def _on_round_end(self) -> None:
        self._start_round()

    def _start_turn(self) -> None:
        """Override to set up reinforce phase at start of each turn."""
        super()._start_turn()
        current = self.current_player
        if current.eliminated:
            self.end_turn()
            return
        # Force trade if 5+ cards
        card_bonus = self._force_trade_if_needed(current)
        # Calculate reinforcements
        reinforcements = self._calculate_reinforcements(current) + card_bonus
        self.phase = "reinforce"
        self.armies_to_place = reinforcements
        self.attacker_id = ""
        self.defender_id = ""
        self.fortify_from = ""
        self.conquered_this_turn = False
        self.broadcast_l(
            "risk-reinforce-start",
            player=current.name,
            armies=reinforcements,
        )
        self.rebuild_all_menus()

    # ==========================================================================
    # Phase transitions
    # ==========================================================================

    def _end_reinforce_phase(self) -> None:
        self.phase = "attack"
        self.broadcast_l("risk-attack-phase", player=self.current_player.name)
        self.rebuild_all_menus()

    def _end_attack_phase(self) -> None:
        # Award a card if conquered at least one territory
        current = self.current_player
        if self.conquered_this_turn:
            self._draw_card(current)
        self.phase = "fortify"
        self.attacker_id = ""
        self.defender_id = ""
        self.broadcast_l("risk-fortify-phase", player=current.name)
        self.rebuild_all_menus()

    def _end_fortify_phase(self) -> None:
        self.phase = "reinforce"
        self.fortify_from = ""
        self.end_turn()

    # ==========================================================================
    # Actions — dynamic labels and visibility
    # ==========================================================================

    def _get_territory_label(self, player: Player, action_id: str) -> str:
        tid = action_id.removeprefix("t_")
        name = get_territory_name(tid)
        troop_count = self.troops.get(tid, 0)
        owner_id = self.owners.get(tid)
        owner = self._get_player_by_id(owner_id) if owner_id else None
        owner_name = owner.name if owner else "Unowned"
        user = self.get_user(player)
        locale = user.locale if user else "en"

        if self.phase == "reinforce":
            return Localization.get(
                locale, "risk-territory-reinforce",
                name=name, troops=troop_count, remaining=self.armies_to_place,
            )
        elif self.phase == "attack":
            if self.attacker_id == "":
                # Selecting attack source
                return Localization.get(
                    locale, "risk-territory-attack-from",
                    name=name, troops=troop_count,
                )
            else:
                # Selecting attack target
                return Localization.get(
                    locale, "risk-territory-attack-target",
                    name=name, troops=troop_count, owner=owner_name,
                )
        elif self.phase == "fortify":
            if self.fortify_from == "":
                return Localization.get(
                    locale, "risk-territory-fortify-from",
                    name=name, troops=troop_count,
                )
            else:
                return Localization.get(
                    locale, "risk-territory-fortify-to",
                    name=name, troops=troop_count,
                )
        return f"{name}: {troop_count} troops ({owner_name})"

    def _is_territory_enabled(
        self, player: Player, *, action_id: str | None = None
    ) -> str | None:
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        if not action_id:
            return "action-not-available"
        tid = action_id.removeprefix("t_")
        current = self.current_player
        pid = current.id

        if self.phase == "reinforce":
            if self.owners.get(tid) != pid:
                return "risk-not-your-territory"
            return None

        elif self.phase == "attack":
            if self.attacker_id == "":
                # Selecting attack source: must own and have 2+ troops
                if self.owners.get(tid) != pid:
                    return "risk-not-your-territory"
                if self.troops.get(tid, 0) < 2:
                    return "risk-need-more-troops"
                # Must have adjacent enemy
                adj = get_adjacent(tid)
                has_enemy = any(self.owners.get(a) != pid for a in adj)
                if not has_enemy:
                    return "risk-no-adjacent-enemy"
                return None
            else:
                # Selecting attack target: must be enemy and adjacent
                if self.owners.get(tid) == pid:
                    return "risk-cannot-attack-own"
                if tid not in get_adjacent(self.attacker_id):
                    return "risk-not-adjacent"
                return None

        elif self.phase == "fortify":
            if self.fortify_from == "":
                if self.owners.get(tid) != pid:
                    return "risk-not-your-territory"
                if self.troops.get(tid, 0) < 2:
                    return "risk-need-more-troops"
                return None
            else:
                if self.owners.get(tid) != pid:
                    return "risk-not-your-territory"
                if tid not in get_adjacent(self.fortify_from):
                    return "risk-not-adjacent"
                if tid == self.fortify_from:
                    return "risk-same-territory"
                return None

        return "action-not-available"

    def _is_territory_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        if self.status != "playing":
            return Visibility.HIDDEN
        if player != self.current_player:
            return Visibility.HIDDEN
        if not action_id:
            return Visibility.HIDDEN
        tid = action_id.removeprefix("t_")
        pid = self.current_player.id

        if self.phase == "reinforce":
            # Show only owned territories
            return Visibility.VISIBLE if self.owners.get(tid) == pid else Visibility.HIDDEN

        elif self.phase == "attack":
            if self.attacker_id == "":
                # Show owned territories with 2+ troops that have adjacent enemies
                if self.owners.get(tid) != pid or self.troops.get(tid, 0) < 2:
                    return Visibility.HIDDEN
                adj = get_adjacent(tid)
                has_enemy = any(self.owners.get(a) != pid for a in adj)
                return Visibility.VISIBLE if has_enemy else Visibility.HIDDEN
            else:
                # Show adjacent enemy territories
                if tid not in get_adjacent(self.attacker_id):
                    return Visibility.HIDDEN
                if self.owners.get(tid) == pid:
                    return Visibility.HIDDEN
                return Visibility.VISIBLE

        elif self.phase == "fortify":
            if self.fortify_from == "":
                # Show owned territories with 2+ troops
                if self.owners.get(tid) != pid or self.troops.get(tid, 0) < 2:
                    return Visibility.HIDDEN
                return Visibility.VISIBLE
            else:
                # Show adjacent owned territories
                if tid not in get_adjacent(self.fortify_from):
                    return Visibility.HIDDEN
                if self.owners.get(tid) != pid:
                    return Visibility.HIDDEN
                if tid == self.fortify_from:
                    return Visibility.HIDDEN
                return Visibility.VISIBLE

        return Visibility.HIDDEN

    def _is_phase_action_enabled(self, player: Player) -> str | None:
        return self.guard_turn_action_enabled(player)

    def _is_skip_attack_hidden(self, player: Player) -> Visibility:
        if player != self.current_player or self.phase != "attack":
            return Visibility.HIDDEN
        if self.attacker_id != "":
            return Visibility.HIDDEN  # Already selected attacker, show cancel instead
        return Visibility.VISIBLE

    def _is_cancel_attack_hidden(self, player: Player) -> Visibility:
        if player != self.current_player or self.phase != "attack":
            return Visibility.HIDDEN
        if self.attacker_id == "":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_skip_fortify_hidden(self, player: Player) -> Visibility:
        if player != self.current_player or self.phase != "fortify":
            return Visibility.HIDDEN
        if self.fortify_from != "":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_cancel_fortify_hidden(self, player: Player) -> Visibility:
        if player != self.current_player or self.phase != "fortify":
            return Visibility.HIDDEN
        if self.fortify_from == "":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_check_status_enabled(self, player: Player) -> str | None:
        return self.guard_game_active()

    def _is_check_status_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN  # Keybind only

    # ==========================================================================
    # Action set and keybinds
    # ==========================================================================

    def create_turn_action_set(self, player: RiskPlayer) -> ActionSet:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        action_set = ActionSet(name="turn")

        # Territory actions (42 territories)
        for cid, tids in TERRITORIES_BY_CONTINENT:
            for tid in tids:
                action_set.add(
                    Action(
                        id=f"t_{tid}",
                        label=get_territory_name(tid),
                        handler="_action_territory",
                        is_enabled="_is_territory_enabled",
                        is_hidden="_is_territory_hidden",
                        get_label="_get_territory_label",
                    )
                )

        # Phase control actions
        action_set.add(
            Action(
                id="skip_attack",
                label=Localization.get(locale, "risk-skip-attack"),
                handler="_action_skip_attack",
                is_enabled="_is_phase_action_enabled",
                is_hidden="_is_skip_attack_hidden",
            )
        )
        action_set.add(
            Action(
                id="cancel_attack",
                label=Localization.get(locale, "risk-cancel-attack"),
                handler="_action_cancel_selection",
                is_enabled="_is_phase_action_enabled",
                is_hidden="_is_cancel_attack_hidden",
            )
        )
        action_set.add(
            Action(
                id="skip_fortify",
                label=Localization.get(locale, "risk-skip-fortify"),
                handler="_action_skip_fortify",
                is_enabled="_is_phase_action_enabled",
                is_hidden="_is_skip_fortify_hidden",
            )
        )
        action_set.add(
            Action(
                id="cancel_fortify",
                label=Localization.get(locale, "risk-cancel-fortify"),
                handler="_action_cancel_selection",
                is_enabled="_is_phase_action_enabled",
                is_hidden="_is_cancel_fortify_hidden",
            )
        )
        # Keybind-only actions
        action_set.add(
            Action(
                id="check_status",
                label="Status",
                handler="_action_check_status",
                is_enabled="_is_check_status_enabled",
                is_hidden="_is_check_status_hidden",
                show_in_actions_menu=False,
            )
        )
        return action_set

    def setup_keybinds(self) -> None:
        super().setup_keybinds()
        self.define_keybind(
            "e", "Check status", ["check_status"], state=KeybindState.ACTIVE
        )

    # ==========================================================================
    # Action handlers
    # ==========================================================================

    def _action_territory(self, player: Player, action_id: str) -> None:
        tid = action_id.removeprefix("t_")
        if self.phase == "reinforce":
            self._do_reinforce(player, tid)
        elif self.phase == "attack":
            self._do_attack(player, tid)
        elif self.phase == "fortify":
            self._do_fortify(player, tid)

    def _do_reinforce(self, player: Player, tid: str) -> None:
        if self.armies_to_place <= 0:
            return
        self.troops[tid] = self.troops.get(tid, 0) + 1
        self.armies_to_place -= 1
        name = get_territory_name(tid)
        self.broadcast_l(
            "risk-placed-army",
            player=player.name,
            territory=name,
            troops=self.troops[tid],
            remaining=self.armies_to_place,
        )
        if self.armies_to_place <= 0:
            self._end_reinforce_phase()
        else:
            self.rebuild_all_menus()

    def _do_attack(self, player: Player, tid: str) -> None:
        current = self.current_player
        if self.attacker_id == "":
            # Selecting attack source
            self.attacker_id = tid
            name = get_territory_name(tid)
            self.broadcast_l("risk-attack-from", player=current.name, territory=name)
            self.rebuild_all_menus()
        else:
            # Executing attack
            att_tid = self.attacker_id
            def_tid = tid
            att_troops = self.troops.get(att_tid, 0)
            att_dice = min(3, att_troops - 1)

            att_losses, def_losses, att_rolls, def_rolls = self._resolve_combat(
                att_tid, def_tid, att_dice
            )

            self.troops[att_tid] -= att_losses
            self.troops[def_tid] -= def_losses

            att_name = get_territory_name(att_tid)
            def_name = get_territory_name(def_tid)
            att_roll_str = ", ".join(str(r) for r in att_rolls)
            def_roll_str = ", ".join(str(r) for r in def_rolls)

            self.broadcast_l(
                "risk-combat-result",
                attacker=current.name,
                att_territory=att_name,
                def_territory=def_name,
                att_rolls=att_roll_str,
                def_rolls=def_roll_str,
                att_losses=att_losses,
                def_losses=def_losses,
            )

            # Check if territory conquered
            if self.troops[def_tid] <= 0:
                # Conquer!
                old_owner_id = self.owners[def_tid]
                old_owner = self._get_player_by_id(old_owner_id)
                self.owners[def_tid] = current.id
                # Move troops in (minimum 1, up to attackers used)
                move_in = att_dice
                self.troops[def_tid] = move_in
                self.troops[att_tid] -= move_in
                self.conquered_this_turn = True

                self.broadcast_l(
                    "risk-conquered",
                    player=current.name,
                    territory=def_name,
                    moved=move_in,
                )

                # Check if old owner is eliminated
                if old_owner and not self._player_territories(old_owner):
                    old_owner.eliminated = True
                    old_owner.is_spectator = True
                    self.broadcast_l("risk-eliminated", player=old_owner.name)
                    # Take their cards
                    taken = self.hands.pop(old_owner.id, [])
                    if taken:
                        self.hands.setdefault(current.id, []).extend(taken)
                        # Force trade if now holding 5+
                        bonus = self._force_trade_if_needed(current)
                        if bonus:
                            self.armies_to_place += bonus

                # Check win condition
                alive = self._alive_players()
                if len(alive) <= 1:
                    self._end_game(alive[0] if alive else current)
                    return

            # Reset attacker selection for next attack
            self.attacker_id = ""
            self.rebuild_all_menus()

    def _do_fortify(self, player: Player, tid: str) -> None:
        if self.fortify_from == "":
            self.fortify_from = tid
            name = get_territory_name(tid)
            self.broadcast_l("risk-fortify-from", player=player.name, territory=name)
            self.rebuild_all_menus()
        else:
            # Move half the troops (at least 1)
            source = self.fortify_from
            source_troops = self.troops.get(source, 0)
            move = max(1, (source_troops - 1) // 2)
            self.troops[source] -= move
            self.troops[tid] = self.troops.get(tid, 0) + move
            src_name = get_territory_name(source)
            dst_name = get_territory_name(tid)
            self.broadcast_l(
                "risk-fortified",
                player=player.name,
                source=src_name,
                dest=dst_name,
                moved=move,
            )
            self._end_fortify_phase()

    def _action_skip_attack(self, player: Player, action_id: str) -> None:
        self._end_attack_phase()

    def _action_skip_fortify(self, player: Player, action_id: str) -> None:
        self._end_fortify_phase()

    def _action_cancel_selection(self, player: Player, action_id: str) -> None:
        if self.phase == "attack":
            self.attacker_id = ""
        elif self.phase == "fortify":
            self.fortify_from = ""
        self.rebuild_all_menus()

    def _action_check_status(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        lines = []
        # Player's territories by continent
        my_territories = self._player_territory_set(player)
        total_troops = sum(self.troops.get(t, 0) for t in my_territories)
        lines.append(
            Localization.get(
                locale, "risk-status-header",
                territories=len(my_territories), troops=total_troops,
            )
        )
        # Continent control
        for cid, continent in CONTINENTS.items():
            owned = sum(1 for t in continent.territory_ids if t in my_territories)
            total = len(continent.territory_ids)
            bonus = continent.bonus if owned == total else 0
            lines.append(
                Localization.get(
                    locale, "risk-status-continent",
                    name=continent.name, owned=owned, total=total, bonus=bonus,
                )
            )
        user.speak(". ".join(lines), buffer="game")

    # ==========================================================================
    # Bot AI
    # ==========================================================================

    def bot_think(self, player: RiskPlayer) -> str | None:
        if player.eliminated:
            return None
        if self.phase == "reinforce":
            return self._bot_reinforce(player)
        elif self.phase == "attack":
            return self._bot_attack(player)
        elif self.phase == "fortify":
            return self._bot_fortify(player)
        return None

    def _bot_reinforce(self, player: RiskPlayer) -> str | None:
        """Reinforce border territories (those with adjacent enemies)."""
        pid = player.id
        owned = self._player_territories(player)
        borders = []
        for tid in owned:
            adj = get_adjacent(tid)
            if any(self.owners.get(a) != pid for a in adj):
                borders.append(tid)
        if not borders:
            borders = owned
        if not borders:
            return None
        # Pick the weakest border territory
        target = min(borders, key=lambda t: self.troops.get(t, 0))
        return f"t_{target}"

    def _bot_attack(self, player: RiskPlayer) -> str | None:
        pid = player.id
        if self.attacker_id == "":
            # Find best attack opportunity
            best_ratio = 0.0
            best_attacker = None
            for tid in self._player_territories(player):
                att_troops = self.troops.get(tid, 0)
                if att_troops < 2:
                    continue
                for adj in get_adjacent(tid):
                    if self.owners.get(adj) == pid:
                        continue
                    def_troops = self.troops.get(adj, 0)
                    ratio = att_troops / max(1, def_troops)
                    if ratio > best_ratio:
                        best_ratio = ratio
                        best_attacker = tid
            if best_ratio >= 1.5 and best_attacker:
                return f"t_{best_attacker}"
            return "skip_attack"
        else:
            # Pick weakest adjacent enemy
            adj_enemies = [
                a for a in get_adjacent(self.attacker_id)
                if self.owners.get(a) != pid
            ]
            if not adj_enemies:
                return "cancel_attack"
            target = min(adj_enemies, key=lambda t: self.troops.get(t, 0))
            return f"t_{target}"

    def _bot_fortify(self, player: RiskPlayer) -> str | None:
        pid = player.id
        if self.fortify_from == "":
            # Find inland territory with most troops to fortify from
            owned = self._player_territories(player)
            best_source = None
            best_score = 0
            for tid in owned:
                troops = self.troops.get(tid, 0)
                if troops < 3:
                    continue
                adj = get_adjacent(tid)
                enemy_adj = sum(1 for a in adj if self.owners.get(a) != pid)
                friendly_adj = sum(1 for a in adj if self.owners.get(a) == pid)
                if friendly_adj == 0:
                    continue
                # Prefer inland territories (fewer enemy neighbors)
                score = troops * (1 + len(adj) - enemy_adj)
                if enemy_adj == 0:
                    score *= 2  # Strongly prefer fully inland
                if score > best_score:
                    best_score = score
                    best_source = tid
            if best_source:
                return f"t_{best_source}"
            return "skip_fortify"
        else:
            # Move to weakest adjacent friendly border territory
            adj_friendly = [
                a for a in get_adjacent(self.fortify_from)
                if self.owners.get(a) == pid and a != self.fortify_from
            ]
            if not adj_friendly:
                return "cancel_fortify"
            borders = [
                a for a in adj_friendly
                if any(self.owners.get(n) != pid for n in get_adjacent(a))
            ]
            targets = borders if borders else adj_friendly
            target = min(targets, key=lambda t: self.troops.get(t, 0))
            return f"t_{target}"

    def _setup_bot_for_turn(self, player: RiskPlayer) -> None:
        BotHelper.jolt_bot(player, ticks=random.randint(8, 15))  # nosec B311

    # ==========================================================================
    # Game end
    # ==========================================================================

    def _end_game(self, winner: RiskPlayer) -> None:
        self.broadcast_l("risk-winner", player=winner.name)
        self.finish_game()

    def build_game_result(self) -> GameResult:
        active = self.get_active_players()
        alive = self._alive_players()
        winner = alive[0] if len(alive) == 1 else None

        scores: dict[str, int] = {}
        for p in active:
            scores[p.name] = len(self._player_territories(p))

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
                for p in active
            ],
            custom_data={
                "winner_name": winner.name if winner else None,
                "final_territories": scores,
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        scores = result.custom_data.get("final_territories", {})
        lines = []
        for name, count in sorted(scores.items(), key=lambda x: -x[1]):
            lines.append(
                Localization.get(
                    locale, "risk-final-score", player=name, territories=count
                )
            )
        winner = result.custom_data.get("winner_name")
        if winner:
            lines.append(
                Localization.get(locale, "risk-winner", player=winner)
            )
        return lines

    def end_turn(self) -> None:
        BotHelper.jolt_bots(self, ticks=random.randint(10, 20))  # nosec B311
        self._on_turn_end()
