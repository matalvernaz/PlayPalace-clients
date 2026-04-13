"""Exploding Kittens — main game implementation.

Turn structure:
    - draws_owed = how many cards the current player still has to draw this
      turn (normally 1; raised to 2+ by Attack cards).
    - On their turn, a player may play any number of cards before drawing.
      Some plays end the turn (Skip ends one slice, Attack ends all and
      transfers slices+2 to the next player).
    - Nope-able actions don't fire immediately. They go into `pending_action`
      and a Nope window opens. Each Nope toggles a cancel flag. When the
      window closes, the action either fires or is discarded.

Action visibility is driven by per-player `pending` state and by the
deck/hand contents — see `_is_play_*_hidden` callbacks.
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

from .options import ExplodingKittensOptions
from .player import EKPlayer
from .state import (
    ALL_CAT_TYPES,
    CARD_ATTACK,
    CARD_DEFUSE,
    CARD_EXPLODING_KITTEN,
    CARD_FAVOR,
    CARD_NOPE,
    CARD_SEE_FUTURE,
    CARD_SHUFFLE,
    CARD_SKIP,
    CARD_STREAKING_KITTEN,
    CARD_TYPES,
    build_starting_deck,
    card_label_key,
    hand_count,
    hand_summary,
    is_cat_card,
    remove_one,
)


# Server tick rate (50 ms ticks → 20 per second).
_TICKS_PER_SECOND = 20


@dataclass
@register_game
class ExplodingKittensGame(Game):
    """Exploding Kittens — last one not exploded wins."""

    players: list[EKPlayer] = field(default_factory=list)
    options: ExplodingKittensOptions = field(default_factory=ExplodingKittensOptions)

    deck: list[str] = field(default_factory=list)  # top of deck = index 0
    discard: list[str] = field(default_factory=list)
    draws_owed: int = 1  # current player's remaining draws this turn

    # In-flight cancellable action waiting on a Nope window.
    # Format: {"actor_id": str, "card": str, "params": dict, "cancelled": bool}
    pending_action: dict | None = None
    nope_window_ticks: int = 0

    # Pending eliminate flag — once everyone except one is out, the next
    # tick declares the winner.
    finished_check_pending: bool = False

    @classmethod
    def get_name(cls) -> str:
        return "Exploding Kittens"

    @classmethod
    def get_type(cls) -> str:
        return "explodingkittens"

    @classmethod
    def get_category(cls) -> str:
        return "category-card-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 5

    def create_player(self, player_id: str, name: str, is_bot: bool = False) -> EKPlayer:
        return EKPlayer(id=player_id, name=name, is_bot=is_bot)

    # ------------------------------------------------------------------
    # Setup
    # ------------------------------------------------------------------

    def on_start(self) -> None:
        self.status = "playing"
        self.game_active = True
        rng = random.Random()  # nosec B311
        hands, deck = build_starting_deck(
            player_count=len(self.get_active_players()),
            rng=rng,
            hand_size=self.options.hand_size,
            streaking_kittens=self.options.streaking_kittens,
        )
        self.deck = deck
        self.discard = []
        self.draws_owed = 1
        self.pending_action = None
        self.nope_window_ticks = 0

        for p, hand in zip(self.get_active_players(), hands):
            p.hand = list(hand)
            p.eliminated = False
            p.has_streaking_kitten = False
            p.last_peek = []
            p.pending = ""
            p.pending_card = ""

        self.set_turn_players(self.get_active_players())
        self.play_music("game_pig/mus.ogg")
        self.broadcast_l("game-explodingkittens-desc")
        self._start_turn()

    # ------------------------------------------------------------------
    # Edition helpers
    # ------------------------------------------------------------------

    def _card_name(self, card: str, locale: str) -> str:
        return Localization.get(locale, card_label_key(card, self.options.edition))

    # ------------------------------------------------------------------
    # Turn flow
    # ------------------------------------------------------------------

    def _start_turn(self, previous_player: EKPlayer | None = None) -> None:
        # Skip eliminated players.
        safety = 0
        while True:
            player = self.current_player
            if player is None:
                return
            if not getattr(player, "eliminated", False):
                break
            self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
            safety += 1
            if safety > len(self.players):
                return

        lp: EKPlayer = player  # type: ignore
        self.broadcast_l(
            "ek-turn-start",
            player=player.name,
            remaining=len(self.deck),
            extra_turns=max(0, self.draws_owed - 1),
        )

        user = self.get_user(player)
        if user and getattr(user.preferences, "play_turn_sound", True):
            user.play_sound("game_pig/turn.ogg")

        if player.is_bot:
            BotHelper.jolt_bot(player, ticks=random.randint(20, 40))

        if previous_player is not None and previous_player is not player:
            self.rebuild_player_menu(previous_player)
        for p in self.players:
            self.rebuild_player_menu(p, position=1 if p is player else None)

    def _end_current_turn(self) -> None:
        """Advance to the next non-eliminated player (or a remaining-draws slice)."""
        previous = self.current_player
        lp: EKPlayer | None = previous  # type: ignore
        if lp is not None:
            lp.last_peek = []  # peek info doesn't carry between turns
            lp.pending = ""

        if self.draws_owed > 1:
            # Same player keeps the seat; just decrement and announce.
            self.draws_owed -= 1
            self._start_turn(previous_player=None)
            return

        self.draws_owed = 1
        self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
        self._start_turn(previous_player=previous)

    # ------------------------------------------------------------------
    # Action sets
    # ------------------------------------------------------------------

    def create_turn_action_set(self, player: EKPlayer) -> ActionSet:  # type: ignore[override]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        action_set = ActionSet(name="turn")

        # Draw a card.
        action_set.add(
            Action(
                id="draw",
                label=Localization.get(locale, "ek-action-draw"),
                handler="_action_draw",
                is_enabled="_is_draw_enabled",
                is_hidden="_is_draw_hidden",
            )
        )

        # Single-play action cards.
        for card in (CARD_SKIP, CARD_ATTACK, CARD_SEE_FUTURE, CARD_SHUFFLE):
            action_set.add(
                Action(
                    id=f"play_{card}",
                    label="",
                    handler="_action_play_simple",
                    is_enabled="_is_play_card_enabled",
                    is_hidden="_is_play_card_hidden",
                    get_label="_get_play_card_label",
                )
            )

        # Favor (target prompt).
        action_set.add(
            Action(
                id=f"play_{CARD_FAVOR}",
                label="",
                handler="_action_play_favor",
                is_enabled="_is_play_card_enabled",
                is_hidden="_is_play_card_hidden",
                get_label="_get_play_card_label",
                input_request=MenuInput(
                    prompt="ek-target-prompt",
                    options="_target_options",
                    bot_select="_bot_select_target",
                    include_cancel=True,
                ),
            )
        )

        # Cat pair / trio actions per cat type.
        for cat in ALL_CAT_TYPES:
            action_set.add(
                Action(
                    id=f"play_pair_{cat}",
                    label="",
                    handler="_action_play_cat_pair",
                    is_enabled="_is_play_cat_pair_enabled",
                    is_hidden="_is_play_cat_pair_hidden",
                    get_label="_get_play_cat_pair_label",
                    input_request=MenuInput(
                        prompt="ek-target-prompt",
                        options="_target_options",
                        bot_select="_bot_select_target",
                        include_cancel=True,
                    ),
                )
            )
            action_set.add(
                Action(
                    id=f"play_trio_{cat}",
                    label="",
                    handler="_action_play_cat_trio",
                    is_enabled="_is_play_cat_trio_enabled",
                    is_hidden="_is_play_cat_trio_hidden",
                    get_label="_get_play_cat_trio_label",
                    input_request=MenuInput(
                        prompt="ek-target-prompt",
                        options="_target_options",
                        bot_select="_bot_select_target",
                        include_cancel=True,
                    ),
                )
            )

        # Defuse position prompts (visible only when pending == "defuse_position").
        for slot in ("top", "second", "bottom", "random"):
            action_set.add(
                Action(
                    id=f"defuse_{slot}",
                    label="",
                    handler="_action_defuse_position",
                    is_enabled="_is_defuse_position_enabled",
                    is_hidden="_is_defuse_position_hidden",
                    get_label="_get_defuse_position_label",
                )
            )

        # Cat trio name prompt: list every card type as a candidate.
        for card in CARD_TYPES:
            if card in (CARD_DEFUSE, CARD_EXPLODING_KITTEN, CARD_STREAKING_KITTEN):
                continue
            action_set.add(
                Action(
                    id=f"trio_name_{card}",
                    label="",
                    handler="_action_cat_trio_name",
                    is_enabled="_is_trio_name_enabled",
                    is_hidden="_is_trio_name_hidden",
                    get_label="_get_trio_name_label",
                )
            )

        # Nope window responses.
        action_set.add(
            Action(
                id="play_nope",
                label="",
                handler="_action_play_nope",
                is_enabled="_is_play_nope_enabled",
                is_hidden="_is_play_nope_hidden",
                get_label="_get_play_nope_label",
            )
        )
        action_set.add(
            Action(
                id="skip_nope",
                label=Localization.get(locale, "ek-action-skip-nope"),
                handler="_action_skip_nope",
                is_enabled="_is_skip_nope_enabled",
                is_hidden="_is_skip_nope_hidden",
            )
        )
        return action_set

    def create_standard_action_set(self, player: EKPlayer) -> ActionSet:  # type: ignore[override]
        action_set = super().create_standard_action_set(player)
        user = self.get_user(player)
        locale = user.locale if user else "en"

        status = Action(
            id="check_status",
            label=Localization.get(locale, "ek-status-hand-header", count=0),
            handler="_action_check_status",
            is_enabled="_is_check_status_enabled",
            is_hidden="_is_check_status_hidden",
        )
        action_set.add(status)
        if status.id in action_set._order:
            action_set._order.remove(status.id)
        action_set._order.insert(0, status.id)

        detailed = Action(
            id="check_status_detailed",
            label="Detailed status",
            handler="_action_check_status_detailed",
            is_enabled="_is_check_status_enabled",
            is_hidden="_is_check_status_hidden",
        )
        action_set.add(detailed)
        if detailed.id in action_set._order:
            action_set._order.remove(detailed.id)
        action_set._order.insert(1, detailed.id)

        for aid in ("check_scores", "check_scores_detailed"):
            existing = action_set.get_action(aid)
            if existing:
                existing.show_in_actions_menu = False
        return action_set

    def setup_keybinds(self) -> None:
        super().setup_keybinds()
        if "s" in self._keybinds:
            self._keybinds["s"] = []
        if "shift+s" in self._keybinds:
            self._keybinds["shift+s"] = []
        self.define_keybind(
            "s", "Check status", ["check_status"],
            state=KeybindState.ACTIVE, include_spectators=True,
        )
        self.define_keybind(
            "shift+s", "Detailed status", ["check_status_detailed"],
            state=KeybindState.ACTIVE, include_spectators=True,
        )
        self.define_keybind("space", "Draw a card", ["draw"], state=KeybindState.ACTIVE)
        self.define_keybind("d", "Draw a card", ["draw"], state=KeybindState.ACTIVE)
        self.define_keybind("n", "Play Nope", ["play_nope"], state=KeybindState.ACTIVE)

    # ------------------------------------------------------------------
    # Visibility / enabled helpers
    # ------------------------------------------------------------------

    def _my_turn(self, player: Player) -> bool:
        return self.current_player is player

    def _has_pending_action(self) -> bool:
        return self.pending_action is not None and self.nope_window_ticks > 0

    # Draw.
    def _is_draw_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "ek-action-not-playing"
        if not self._my_turn(player):
            return "ek-action-not-your-turn"
        if self._has_pending_action():
            return "ek-action-must-respond-nope"
        lp: EKPlayer = player  # type: ignore
        if lp.eliminated:
            return "ek-status-eliminated"
        if lp.pending != "":
            return "ek-action-must-respond-nope"
        return None

    def _is_draw_hidden(self, player: Player) -> Visibility:
        if not self._my_turn(player):
            return Visibility.HIDDEN
        lp: EKPlayer = player  # type: ignore
        if lp.eliminated:
            return Visibility.HIDDEN
        if lp.pending != "":
            return Visibility.HIDDEN
        if self._has_pending_action():
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    # Generic play_card visibility.
    def _is_play_card_enabled(self, player: Player) -> str | None:
        return self._is_draw_enabled(player)

    def _is_play_card_hidden(self, player: Player, action_id: str | None = None) -> Visibility:
        if self._is_draw_hidden(player) == Visibility.HIDDEN:
            return Visibility.HIDDEN
        # Hide if player doesn't have the card.
        lp: EKPlayer = player  # type: ignore
        # Resolve which card this action represents from the action id.
        if action_id is None:
            return Visibility.VISIBLE
        if action_id.startswith("play_"):
            card = action_id[len("play_"):]
            return Visibility.VISIBLE if hand_count(lp.hand, card) >= 1 else Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_play_card_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        card = action_id[len("play_"):]
        lp: EKPlayer = player  # type: ignore
        count = hand_count(lp.hand, card)
        name = self._card_name(card, locale)
        if count > 1:
            return f"Play {name} (x{count})"
        return f"Play {name}"

    # Cat pair visibility.
    def _is_play_cat_pair_enabled(self, player: Player) -> str | None:
        return self._is_draw_enabled(player)

    def _is_play_cat_pair_hidden(self, player: Player, action_id: str | None = None) -> Visibility:
        if self._is_draw_hidden(player) == Visibility.HIDDEN:
            return Visibility.HIDDEN
        if action_id is None or not action_id.startswith("play_pair_"):
            return Visibility.VISIBLE
        cat = action_id[len("play_pair_"):]
        lp: EKPlayer = player  # type: ignore
        return Visibility.VISIBLE if hand_count(lp.hand, cat) >= 2 else Visibility.HIDDEN

    def _get_play_cat_pair_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        cat = action_id[len("play_pair_"):]
        return f"Play 2× {self._card_name(cat, locale)}"

    def _is_play_cat_trio_enabled(self, player: Player) -> str | None:
        return self._is_draw_enabled(player)

    def _is_play_cat_trio_hidden(self, player: Player, action_id: str | None = None) -> Visibility:
        if self._is_draw_hidden(player) == Visibility.HIDDEN:
            return Visibility.HIDDEN
        if action_id is None or not action_id.startswith("play_trio_"):
            return Visibility.VISIBLE
        cat = action_id[len("play_trio_"):]
        lp: EKPlayer = player  # type: ignore
        return Visibility.VISIBLE if hand_count(lp.hand, cat) >= 3 else Visibility.HIDDEN

    def _get_play_cat_trio_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        cat = action_id[len("play_trio_"):]
        return f"Play 3× {self._card_name(cat, locale)}"

    # Defuse position.
    def _is_defuse_position_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "ek-action-not-your-turn"
        return None

    def _is_defuse_position_hidden(self, player: Player) -> Visibility:
        lp: EKPlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "defuse_position":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_defuse_position_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        slot = action_id[len("defuse_"):]
        return Localization.get(locale, f"ek-defuse-position-{slot}")

    # Cat trio name.
    def _is_trio_name_enabled(self, player: Player) -> str | None:
        if not self._my_turn(player):
            return "ek-action-not-your-turn"
        return None

    def _is_trio_name_hidden(self, player: Player) -> Visibility:
        lp: EKPlayer = player  # type: ignore
        if not self._my_turn(player) or lp.pending != "cat_trio_name":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_trio_name_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        card = action_id[len("trio_name_"):]
        return self._card_name(card, locale)

    # Nope.
    def _is_play_nope_enabled(self, player: Player) -> str | None:
        if not self._has_pending_action():
            return "ek-action-not-playing"
        if self.pending_action and self.pending_action.get("actor_id") == player.id:
            return "ek-action-not-your-turn"
        return None

    def _is_play_nope_hidden(self, player: Player) -> Visibility:
        if not self._has_pending_action():
            return Visibility.HIDDEN
        if self.pending_action and self.pending_action.get("actor_id") == player.id:
            return Visibility.HIDDEN
        lp: EKPlayer = player  # type: ignore
        if lp.eliminated:
            return Visibility.HIDDEN
        if hand_count(lp.hand, CARD_NOPE) < 1:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_play_nope_label(self, player: Player, action_id: str) -> str:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(
            locale, "ek-action-play-nope", card=self._card_name(CARD_NOPE, locale)
        )

    def _is_skip_nope_enabled(self, player: Player) -> str | None:
        if not self._has_pending_action():
            return "ek-action-not-playing"
        return None

    def _is_skip_nope_hidden(self, player: Player) -> Visibility:
        if not self._has_pending_action():
            return Visibility.HIDDEN
        if self.pending_action and self.pending_action.get("actor_id") == player.id:
            return Visibility.HIDDEN
        lp: EKPlayer = player  # type: ignore
        if lp.eliminated:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_check_status_enabled(self, player: Player) -> str | None:
        if self.status not in ("playing", "finished"):
            return "ek-action-not-playing"
        return None

    def _is_check_status_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    # ------------------------------------------------------------------
    # "You vs player" announce helper
    # ------------------------------------------------------------------

    def _announce(self, actor: Player, message_id: str, **kwargs) -> None:
        for p in self.players:
            user = self.get_user(p)
            if not user:
                continue
            if p is actor:
                user.speak_l(message_id, "table", who="you", **kwargs)
            else:
                user.speak_l(
                    message_id, "table", who="player", player=actor.name, **kwargs
                )

    def _announce_private(self, target: Player, source: Player, message_id: str, **kwargs) -> None:
        """Send a card-detail message only to one specific recipient."""
        user = self.get_user(target)
        if user:
            user.speak_l(
                message_id, "table", who="you", source=source.name, **kwargs
            )

    # ------------------------------------------------------------------
    # Target options (for Favor / cat pair / cat trio)
    # ------------------------------------------------------------------

    def _target_options(self, player: Player) -> list[str]:
        return [
            p.name
            for p in self.get_active_players()
            if p is not player and not getattr(p, "eliminated", False)
        ]

    def _bot_select_target(self, player: Player, options: list[str]) -> str | None:
        """Bot picks the player with the most cards (most likely to have something useful)."""
        candidates = [
            p for p in self.get_active_players()
            if p is not player and not getattr(p, "eliminated", False)
        ]
        if not candidates:
            return None
        candidates.sort(key=lambda p: len(p.hand), reverse=True)  # type: ignore[arg-type]
        return candidates[0].name

    def _resolve_target(self, name: str) -> EKPlayer | None:
        for p in self.get_active_players():
            if p.name == name and not getattr(p, "eliminated", False):
                return p  # type: ignore[return-value]
        return None

    # ------------------------------------------------------------------
    # Action handlers — playing cards
    # ------------------------------------------------------------------

    def _action_play_simple(self, player: Player, action_id: str) -> None:
        """Skip / Attack / See the Future / Shuffle (no target needed)."""
        lp: EKPlayer = player  # type: ignore
        card = action_id[len("play_"):]
        if not remove_one(lp.hand, card):
            return
        self.discard.append(card)
        self._open_pending_action(actor=lp, card=card, params={})

    def _action_play_favor(self, player: Player, *args) -> None:
        lp: EKPlayer = player  # type: ignore
        if len(args) < 2:
            return
        target_name, action_id = args[0], args[1]
        target = self._resolve_target(str(target_name))
        if not target:
            return
        if not remove_one(lp.hand, CARD_FAVOR):
            return
        self.discard.append(CARD_FAVOR)
        self._open_pending_action(actor=lp, card=CARD_FAVOR, params={"target_id": target.id})

    def _action_play_cat_pair(self, player: Player, *args) -> None:
        lp: EKPlayer = player  # type: ignore
        if len(args) < 2:
            return
        target_name, action_id = args[0], args[1]
        cat = action_id[len("play_pair_"):]
        target = self._resolve_target(str(target_name))
        if not target:
            return
        if hand_count(lp.hand, cat) < 2:
            return
        remove_one(lp.hand, cat)
        remove_one(lp.hand, cat)
        self.discard.append(cat)
        self.discard.append(cat)
        self._open_pending_action(
            actor=lp, card=cat, params={"target_id": target.id, "mode": "pair"}
        )

    def _action_play_cat_trio(self, player: Player, *args) -> None:
        lp: EKPlayer = player  # type: ignore
        if len(args) < 2:
            return
        target_name, action_id = args[0], args[1]
        cat = action_id[len("play_trio_"):]
        target = self._resolve_target(str(target_name))
        if not target:
            return
        if hand_count(lp.hand, cat) < 3:
            return
        for _ in range(3):
            remove_one(lp.hand, cat)
            self.discard.append(cat)
        # Defer name prompt until after the Nope window closes successfully.
        self._open_pending_action(
            actor=lp, card=cat, params={"target_id": target.id, "mode": "trio"}
        )

    # ------------------------------------------------------------------
    # Pending action / Nope window
    # ------------------------------------------------------------------

    def _open_pending_action(self, actor: EKPlayer, card: str, params: dict) -> None:
        self.pending_action = {
            "actor_id": actor.id,
            "card": card,
            "params": params,
            "cancelled": False,
        }
        # Announce the play first so the table hears what's happening before
        # being told a Nope window is open against it.
        self._announce_play(actor, card, params)
        self.nope_window_ticks = self.options.nope_window_seconds * _TICKS_PER_SECOND
        user = self.get_user(actor)
        locale = user.locale if user else "en"
        self.broadcast_l(
            "ek-nope-window-open",
            seconds=self.options.nope_window_seconds,
            card=self._card_name(CARD_NOPE, locale),
            original_player=actor.name,
            original_card=self._card_name(card, locale),
        )
        # Refresh menus so Nope buttons appear.
        for p in self.players:
            self.rebuild_player_menu(p)

    def _announce_play(self, actor: EKPlayer, card: str, params: dict) -> None:
        user = self.get_user(actor)
        locale = user.locale if user else "en"
        name = self._card_name(card, locale)
        if card == CARD_SKIP:
            self._announce(actor, "ek-played-skip", card=name)
        elif card == CARD_ATTACK:
            target = self._next_active_player(actor)
            target_name = target.name if target else ""
            self._announce(actor, "ek-played-attack", card=name, target=target_name)
        elif card == CARD_SHUFFLE:
            self._announce(actor, "ek-played-shuffle", card=name)
        elif card == CARD_SEE_FUTURE:
            self._announce(actor, "ek-played-see-future", card=name, count=self.options.peek_count, cards="(hidden until resolved)")
        elif card == CARD_FAVOR:
            target_id = params.get("target_id", "")
            target = self.get_player_by_id(target_id)
            self._announce(actor, "ek-played-favor", card=name, target=target.name if target else "")
        elif is_cat_card(card):
            mode = params.get("mode", "pair")
            target_id = params.get("target_id", "")
            target = self.get_player_by_id(target_id)
            target_name = target.name if target else ""
            if mode == "pair":
                self._announce(actor, "ek-played-cat-pair", card=name, target=target_name)
            else:
                self._announce(actor, "ek-played-cat-trio", card=name, target=target_name)

    def _action_play_nope(self, player: Player, action_id: str) -> None:
        if not self._has_pending_action() or not self.pending_action:
            return
        lp: EKPlayer = player  # type: ignore
        if not remove_one(lp.hand, CARD_NOPE):
            return
        self.discard.append(CARD_NOPE)
        # Toggle the cancel flag and reset the window.
        self.pending_action["cancelled"] = not self.pending_action["cancelled"]
        original_actor = self.get_player_by_id(self.pending_action["actor_id"])
        original_card = self.pending_action["card"]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if self.pending_action["cancelled"]:
            self._announce(
                lp, "ek-noped",
                card=self._card_name(CARD_NOPE, locale),
                original_player=original_actor.name if original_actor else "",
                original_card=self._card_name(original_card, locale),
            )
        else:
            self._announce(
                lp, "ek-yes-noped",
                card=self._card_name(CARD_NOPE, locale),
                original_player=original_actor.name if original_actor else "",
                original_card=self._card_name(original_card, locale),
            )
        self.nope_window_ticks = self.options.nope_window_seconds * _TICKS_PER_SECOND
        for p in self.players:
            self.rebuild_player_menu(p)

    def _action_skip_nope(self, player: Player, action_id: str) -> None:
        # No-op; bots use this to opt out of the Nope window quickly.
        pass

    def _close_nope_window(self) -> None:
        if not self.pending_action:
            self.nope_window_ticks = 0
            return
        action = self.pending_action
        self.pending_action = None
        self.nope_window_ticks = 0
        self.broadcast_l("ek-nope-window-closed")
        if action["cancelled"]:
            for p in self.players:
                self.rebuild_player_menu(p)
            return
        self._resolve_action(action)
        for p in self.players:
            self.rebuild_player_menu(p)

    # ------------------------------------------------------------------
    # Action resolution (after Nope window closes without cancel)
    # ------------------------------------------------------------------

    def _resolve_action(self, action: dict) -> None:
        actor = self.get_player_by_id(action["actor_id"])
        if actor is None:
            return
        lp: EKPlayer = actor  # type: ignore
        card = action["card"]
        params = action.get("params", {})

        if card == CARD_SKIP:
            self._end_current_turn()
        elif card == CARD_ATTACK:
            self._resolve_attack(lp)
        elif card == CARD_SHUFFLE:
            random.shuffle(self.deck)  # nosec B311
        elif card == CARD_SEE_FUTURE:
            self._resolve_see_future(lp)
        elif card == CARD_FAVOR:
            target = self.get_player_by_id(params.get("target_id", ""))
            if target:
                self._resolve_favor(lp, target)
        elif is_cat_card(card):
            target = self.get_player_by_id(params.get("target_id", ""))
            if not target:
                return
            mode = params.get("mode", "pair")
            if mode == "pair":
                self._resolve_cat_pair(lp, target)
            else:
                # Trio — prompt actor for a card name. Stash the target id on
                # pending_card so the name handler knows who to steal from.
                lp.pending = "cat_trio_name"
                lp.pending_card = target.id
                self.rebuild_player_menu(lp, position=1)

    def _resolve_attack(self, actor: EKPlayer) -> None:
        # Transfer (current draws_owed + 2 - 1) = draws_owed + 1 to next player.
        # Spec: "next player takes (your remaining turns) + 2".
        carry = self.draws_owed + 2
        # End attacker's turn block.
        self.draws_owed = 1
        previous = actor
        self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
        # Skip eliminated players.
        safety = 0
        while True:
            cp = self.current_player
            if cp is None:
                return
            if not getattr(cp, "eliminated", False):
                break
            self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
            safety += 1
            if safety > len(self.players):
                return
        self.draws_owed = carry
        self._start_turn(previous_player=previous)

    def _resolve_see_future(self, actor: EKPlayer) -> None:
        peek = self.deck[: self.options.peek_count]
        actor.last_peek = list(peek)
        user = self.get_user(actor)
        if user:
            locale = user.locale
            names = ", ".join(self._card_name(c, locale) for c in peek) or "(empty)"
            user.speak_l(
                "ek-played-see-future",
                "table", who="you",
                card=self._card_name(CARD_SEE_FUTURE, locale),
                count=len(peek),
                cards=names,
            )

    def _resolve_favor(self, actor: EKPlayer, target: EKPlayer) -> None:
        if not target.hand:
            self._announce(actor, "ek-cat-pair-empty", target=target.name)
            return
        # Bot or human: target picks a card to give. For simplicity, target
        # gives a random low-value card (Cat cards first if any, else last
        # card in hand). We don't open another menu prompt to keep flow tight.
        chosen = self._pick_card_to_give(target)
        if chosen is None:
            return
        remove_one(target.hand, chosen)
        actor.hand.append(chosen)
        target_user = self.get_user(target)
        actor_user = self.get_user(actor)
        target_locale = target_user.locale if target_user else "en"
        actor_locale = actor_user.locale if actor_user else "en"
        self._announce(
            target, "ek-favor-given",
            target=actor.name, card=self._card_name(chosen, target_locale)
        )
        if actor_user:
            actor_user.speak_l(
                "ek-favor-received", "table", who="you",
                source=target.name, card=self._card_name(chosen, actor_locale)
            )

    def _pick_card_to_give(self, target: EKPlayer) -> str | None:
        """Pick a card the target would prefer to part with (for Favor / steals)."""
        if not target.hand:
            return None
        # Priority: cat cards (often duplicates), then See/Shuffle, then anything but Defuse/Nope.
        priority = list(ALL_CAT_TYPES) + [CARD_SEE_FUTURE, CARD_SHUFFLE, CARD_FAVOR, CARD_SKIP, CARD_ATTACK]
        for c in priority:
            if c in target.hand:
                return c
        # Fall through — give Nope/Defuse only if that's all they have.
        for c in target.hand:
            if c != CARD_DEFUSE:
                return c
        return target.hand[0]

    def _resolve_cat_pair(self, actor: EKPlayer, target: EKPlayer) -> None:
        if not target.hand:
            self._announce(actor, "ek-cat-pair-empty", target=target.name)
            return
        chosen = random.choice(target.hand)  # nosec B311
        remove_one(target.hand, chosen)
        actor.hand.append(chosen)
        actor_user = self.get_user(actor)
        target_user = self.get_user(target)
        actor_locale = actor_user.locale if actor_user else "en"
        target_locale = target_user.locale if target_user else "en"
        if actor_user:
            actor_user.speak_l(
                "ek-cat-pair-stole", "table", who="you",
                target=target.name, card=self._card_name(chosen, actor_locale)
            )
        if target_user:
            target_user.speak_l(
                "ek-cat-pair-stole-private", "table", who="you",
                source=actor.name, card=self._card_name(chosen, target_locale)
            )
        # Others see only the steal happened.
        for p in self.players:
            if p is actor or p is target:
                continue
            user = self.get_user(p)
            if user:
                user.speak_l(
                    "ek-cat-pair-stole", "table", who="player",
                    player=actor.name, target=target.name, card=""
                )

    def _action_cat_trio_name(self, player: Player, action_id: str) -> None:
        lp: EKPlayer = player  # type: ignore
        if lp.pending != "cat_trio_name":
            return
        named = action_id[len("trio_name_"):]
        # Find the most recent target (we need to remember it across the Nope window).
        # Simplification: walk the discard pile backwards to find the trio target.
        target_id = lp.pending_card  # we'll repurpose this as target_id
        target = self.get_player_by_id(target_id) if target_id else None
        # Fallback: any other active player with the named card.
        if target is None:
            for p in self.get_active_players():
                if p is not lp and not getattr(p, "eliminated", False) and named in p.hand:
                    target = p  # type: ignore[assignment]
                    break
        if target is None:
            return
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if named == CARD_DEFUSE:
            user.speak_l("ek-cat-defuse-not-stealable") if user else None
            lp.pending = ""
            lp.pending_card = ""
            self.rebuild_player_menu(lp, position=1)
            return
        if named in target.hand:
            remove_one(target.hand, named)
            lp.hand.append(named)
            self._announce(
                lp, "ek-cat-trio-success",
                target=target.name, card=self._card_name(named, locale)
            )
        else:
            self._announce(
                lp, "ek-cat-trio-fail",
                target=target.name, card=self._card_name(named, locale)
            )
        lp.pending = ""
        lp.pending_card = ""
        self.rebuild_player_menu(lp, position=1)

    # ------------------------------------------------------------------
    # Drawing
    # ------------------------------------------------------------------

    def _action_draw(self, player: Player, action_id: str) -> None:
        lp: EKPlayer = player  # type: ignore
        if lp.eliminated or lp.pending != "":
            return
        if not self.deck:
            # Reshuffle from discard if we somehow run out (rare).
            if self.discard:
                self.deck = list(self.discard)
                random.shuffle(self.deck)  # nosec B311
                self.discard = []
            else:
                return
        card = self.deck.pop(0)
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if card == CARD_EXPLODING_KITTEN:
            self._handle_exploding_kitten(lp, locale)
        elif card == CARD_STREAKING_KITTEN:
            lp.has_streaking_kitten = True
            lp.hand.append(card)
            self._announce(
                lp, "ek-drew-streaking-kitten", card=self._card_name(card, locale)
            )
            self._end_current_turn()
        else:
            lp.hand.append(card)
            # Personal-only reveal of the actual card.
            if user:
                user.speak_l(
                    "ek-drew-safe", "table", who="you",
                    card=self._card_name(card, locale),
                )
            # Public message (others only know it was a card).
            for p in self.players:
                if p is lp:
                    continue
                u = self.get_user(p)
                if u:
                    u.speak_l(
                        "ek-drew-safe", "table", who="player", player=lp.name, card=""
                    )
            self._end_current_turn()

    def _handle_exploding_kitten(self, lp: EKPlayer, locale: str) -> None:
        ek_name = self._card_name(CARD_EXPLODING_KITTEN, locale)
        defuse_name = self._card_name(CARD_DEFUSE, locale)
        # Streaking Kitten passive — they don't explode while holding it.
        if lp.has_streaking_kitten:
            self._announce(lp, "ek-drew-safe", card=ek_name)
            self.discard.append(CARD_EXPLODING_KITTEN)
            return
        if hand_count(lp.hand, CARD_DEFUSE) >= 1:
            remove_one(lp.hand, CARD_DEFUSE)
            self.discard.append(CARD_DEFUSE)
            self._announce(
                lp, "ek-drew-exploding-survived", card=ek_name, defuse=defuse_name
            )
            # Hold the EK aside; ask the player where to put it.
            lp.pending = "defuse_position"
            lp.pending_card = CARD_EXPLODING_KITTEN
            self.rebuild_player_menu(lp, position=1)
            return
        # Boom.
        self._eliminate(lp, ek_name, defuse_name)

    def _action_defuse_position(self, player: Player, action_id: str) -> None:
        lp: EKPlayer = player  # type: ignore
        if lp.pending != "defuse_position":
            return
        slot = action_id[len("defuse_"):]
        if slot == "top":
            self.deck.insert(0, CARD_EXPLODING_KITTEN)
        elif slot == "second":
            self.deck.insert(min(1, len(self.deck)), CARD_EXPLODING_KITTEN)
        elif slot == "bottom":
            self.deck.append(CARD_EXPLODING_KITTEN)
        elif slot == "random":
            pos = random.randint(0, len(self.deck))  # nosec B311
            self.deck.insert(pos, CARD_EXPLODING_KITTEN)
        user = self.get_user(player)
        locale = user.locale if user else "en"
        self._announce(
            lp, "ek-defuse-tucked",
            card=self._card_name(CARD_EXPLODING_KITTEN, locale),
            where=Localization.get(locale, f"ek-defuse-position-{slot}"),
        )
        lp.pending = ""
        lp.pending_card = ""
        self._end_current_turn()

    def _eliminate(self, lp: EKPlayer, ek_name: str, defuse_name: str) -> None:
        lp.eliminated = True
        self._announce(
            lp, "ek-drew-exploding-no-defuse", card=ek_name, defuse=defuse_name
        )
        # Discard their hand.
        self.discard.extend(lp.hand)
        lp.hand = []
        remaining = sum(
            1 for p in self.get_active_players() if not getattr(p, "eliminated", False)
        )
        self.broadcast_l(
            "ek-eliminated", player=lp.name, remaining=remaining
        )
        if remaining <= 1:
            self.finished_check_pending = True
        else:
            self._end_current_turn()

    # ------------------------------------------------------------------
    # Status readouts
    # ------------------------------------------------------------------

    def _action_check_status(self, player: Player, action_id: str) -> None:
        lp: EKPlayer = player  # type: ignore
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        lines: list[str] = []

        ek_count = sum(1 for c in self.deck if c == CARD_EXPLODING_KITTEN)
        if ek_count > 0:
            lines.append(
                Localization.get(locale, "ek-status-deck-with-kittens",
                                 count=len(self.deck), kittens=ek_count)
            )
        else:
            lines.append(Localization.get(locale, "ek-status-deck", count=len(self.deck)))
        lines.append(Localization.get(locale, "ek-status-discard", count=len(self.discard)))

        if lp.eliminated:
            lines.append(Localization.get(locale, "ek-status-eliminated"))
        else:
            summary = hand_summary(lp.hand)
            lines.append(Localization.get(locale, "ek-status-hand-header", count=len(lp.hand)))
            if not lp.hand:
                lines.append(Localization.get(locale, "ek-status-hand-empty"))
            else:
                for card, count in summary.items():
                    name = self._card_name(card, locale)
                    label = f"{count}× {name}" if count > 1 else name
                    lines.append(Localization.get(locale, "ek-status-hand-card", card=label))

        if self.draws_owed > 1 and self._my_turn(player):
            lines.append(
                Localization.get(locale, "ek-status-extra-turns", count=self.draws_owed - 1)
            )

        if lp.last_peek:
            names = ", ".join(self._card_name(c, locale) for c in lp.last_peek)
            lines.append(Localization.get(locale, "ek-status-future-peek", cards=names))
        else:
            lines.append(Localization.get(locale, "ek-status-future-no-peek"))

        self.status_box(player, lines)

    def _action_check_status_detailed(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        active = [p for p in self.get_active_players()]
        remaining = sum(1 for p in active if not getattr(p, "eliminated", False))
        lines: list[str] = [
            Localization.get(locale, "ek-status-detailed-header", count=remaining)
        ]
        for p in active:
            lp: EKPlayer = p  # type: ignore
            if lp.eliminated:
                lines.append(Localization.get(locale, "ek-status-detailed-out", player=p.name))
                continue
            self_suffix = (
                Localization.get(locale, "ek-status-detailed-self-suffix")
                if p is player else ""
            )
            lines.append(
                Localization.get(
                    locale, "ek-status-detailed-line",
                    player=p.name, self_suffix=self_suffix, hand_count=len(lp.hand),
                )
            )
        self.status_box(player, lines)

    # ------------------------------------------------------------------
    # Tick / Nope window countdown / endgame check
    # ------------------------------------------------------------------

    def on_tick(self) -> None:
        super().on_tick()
        self.process_scheduled_events()
        if self.status != "playing":
            return

        if self._has_pending_action():
            self.nope_window_ticks -= 1
            if self.nope_window_ticks <= 0:
                self._close_nope_window()
                return

        if self.finished_check_pending:
            self.finished_check_pending = False
            self._declare_winner()
            return

        BotHelper.on_tick(self)

    def _declare_winner(self) -> None:
        survivors = [
            p for p in self.get_active_players() if not getattr(p, "eliminated", False)
        ]
        if len(survivors) == 1:
            self.winner = survivors[0]
            self.broadcast_l("ek-winner", player=survivors[0].name)
            self.play_sound("game_pig/win.ogg")
            self.finish_game()
        elif len(survivors) == 0:
            self.finish_game()

    # ------------------------------------------------------------------
    # Bot AI
    # ------------------------------------------------------------------

    def bot_think(self, player: EKPlayer) -> str | None:
        if player.eliminated:
            return None

        # Nope window: bot considers Noping.
        if self._has_pending_action() and self.pending_action:
            actor_id = self.pending_action.get("actor_id", "")
            target_id = self.pending_action.get("params", {}).get("target_id", "")
            if actor_id != player.id and hand_count(player.hand, CARD_NOPE) > 0:
                # Nope if it targets us, or if it's a high-value action.
                card = self.pending_action.get("card", "")
                if target_id == player.id and random.random() < 0.7:  # nosec B311
                    return "play_nope"
                if card == CARD_FAVOR and random.random() < 0.3:  # nosec B311
                    return "play_nope"
            return "skip_nope"

        if not self._my_turn(player):
            return None

        if player.pending == "defuse_position":
            # Put EK on top so the next player explodes (mean but effective).
            return "defuse_top"
        if player.pending == "cat_trio_name":
            # Pick a common card type to name.
            for cand in (CARD_NOPE, CARD_SEE_FUTURE, CARD_SKIP, CARD_ATTACK):
                return f"trio_name_{cand}"
            return None

        # Strategy: if we know top card is dangerous, play Skip/Attack/See/Shuffle.
        top_known = player.last_peek[0] if player.last_peek else None
        if top_known == CARD_EXPLODING_KITTEN:
            if hand_count(player.hand, CARD_SKIP) > 0:
                return "play_skip"
            if hand_count(player.hand, CARD_ATTACK) > 0:
                return "play_attack"
            if hand_count(player.hand, CARD_SHUFFLE) > 0:
                return "play_shuffle"
        # If we have multiple Skips and lots of EKs are coming, occasionally play one.
        ek_density = (
            sum(1 for c in self.deck if c == CARD_EXPLODING_KITTEN) / max(1, len(self.deck))
        )
        if ek_density > 0.2 and hand_count(player.hand, CARD_SKIP) >= 2:
            return "play_skip"
        # Use See the Future if we don't know the top.
        if not player.last_peek and hand_count(player.hand, CARD_SEE_FUTURE) > 0 and random.random() < 0.7:  # nosec B311
            return "play_see-the-future"
        # Use cat pairs if we have them.
        for cat in ALL_CAT_TYPES:
            if hand_count(player.hand, cat) >= 3:
                return f"play_trio_{cat}"
        for cat in ALL_CAT_TYPES:
            if hand_count(player.hand, cat) >= 2:
                return f"play_pair_{cat}"
        # Default: draw.
        return "draw"

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _next_active_player(self, after: EKPlayer) -> EKPlayer | None:
        try:
            idx = self.turn_player_ids.index(after.id)
        except ValueError:
            return None
        n = len(self.turn_player_ids)
        for offset in range(1, n + 1):
            cand_id = self.turn_player_ids[(idx + offset) % n]
            cand = self.get_player_by_id(cand_id)
            if cand and not getattr(cand, "eliminated", False):
                return cand  # type: ignore[return-value]
        return None

    # ------------------------------------------------------------------
    # End screen
    # ------------------------------------------------------------------

    def build_game_result(self) -> GameResult:
        winner = getattr(self, "winner", None)
        # Order: winner first, then eliminated in reverse-elimination order
        # (we don't track elimination order precisely; sort eliminated last).
        sorted_players = sorted(
            self.get_active_players(),
            key=lambda p: (getattr(p, "eliminated", False), p.name),
        )
        return GameResult(
            game_type=self.get_type(),
            timestamp=datetime.now().isoformat(),
            duration_ticks=self.sound_scheduler_tick,
            player_results=[
                PlayerResult(
                    player_id=p.id, player_name=p.name,
                    is_bot=p.is_bot, is_virtual_bot=getattr(p, "is_virtual_bot", False),
                )
                for p in sorted_players
            ],
            custom_data={
                "winner_name": winner.name if winner else None,
                "edition": self.options.edition,
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        lines = [Localization.get(locale, "game-final-scores")]
        for rank, p_result in enumerate(result.player_results, 1):
            # Was this player eliminated?
            p = self.get_player_by_id(p_result.player_id)
            status_key = (
                "ek-end-status-survived"
                if p and not getattr(p, "eliminated", False)
                else "ek-end-status-eliminated"
            )
            status = Localization.get(locale, status_key)
            lines.append(
                Localization.get(
                    locale, "ek-end-score",
                    rank=rank, player=p_result.player_name, status=status,
                )
            )
        return lines
