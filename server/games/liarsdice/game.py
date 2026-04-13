"""Liar's Dice — main game implementation.

Each round all players roll dice secretly. Players take turns either bidding
higher (quantity, face) or calling Liar / Spot On against the previous bid.
On a successful Liar/Spot-on resolution, dice are lost; players are
eliminated at 0 dice; last player standing wins.

The bid prompt is rendered as a list of legal raises so players never have
to know the exact bid-progression rules; the menu only shows valid options.
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

from .options import LiarsDiceOptions
from .player import LiarsDicePlayer
from .state import count_face, enumerate_valid_bids, is_higher_bid


_FACE_KEYS = {
    1: "ld-face-1",
    2: "ld-face-2",
    3: "ld-face-3",
    4: "ld-face-4",
    5: "ld-face-5",
    6: "ld-face-6",
}


def _face_word(face: int, locale: str) -> str:
    return Localization.get(locale, _FACE_KEYS.get(face, "ld-face-1"))


@dataclass
@register_game
class LiarsDiceGame(Game):
    """Liar's Dice — bluffing dice game."""

    players: list[LiarsDicePlayer] = field(default_factory=list)
    options: LiarsDiceOptions = field(default_factory=LiarsDiceOptions)

    # Round state
    round_no: int = 0
    current_bid: tuple[int, int] | None = None  # (quantity, face) or None
    last_bidder_id: str = ""
    awaiting_action: bool = True  # True while waiting for the current player's action

    @classmethod
    def get_name(cls) -> str:
        return "Liar's Dice"

    @classmethod
    def get_type(cls) -> str:
        return "liarsdice"

    @classmethod
    def get_category(cls) -> str:
        return "category-dice-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 6

    def create_player(self, player_id: str, name: str, is_bot: bool = False) -> LiarsDicePlayer:
        return LiarsDicePlayer(id=player_id, name=name, is_bot=is_bot)

    # ------------------------------------------------------------------
    # Setup
    # ------------------------------------------------------------------

    def on_start(self) -> None:
        self.status = "playing"
        self.game_active = True
        for p in self.players:
            p.dice_count = self.options.starting_dice
            p.eliminated = False
            p.dice = []
        self.set_turn_players(self.get_active_players())
        self.play_music("game_pig/mus.ogg")
        self.broadcast_l("game-liarsdice-desc")
        self._begin_round(starter=self.current_player)

    def _begin_round(self, starter: Player | None) -> None:
        self.round_no += 1
        self.current_bid = None
        self.last_bidder_id = ""
        # Roll for everyone.
        for p in self.players:
            lp: LiarsDicePlayer = p  # type: ignore
            if lp.eliminated or lp.dice_count <= 0:
                lp.dice = []
                continue
            lp.dice = [random.randint(1, 6) for _ in range(lp.dice_count)]  # nosec B311
        total = sum(p.dice_count for p in self.get_active_players() if not getattr(p, "eliminated", False))
        self.broadcast_l("ld-round-start", round=self.round_no, total=total)
        # Tell each player privately what they rolled.
        for p in self.players:
            user = self.get_user(p)
            lp = p  # type: ignore
            if not user or lp.eliminated:
                continue
            dice_str = ", ".join(str(d) for d in sorted(lp.dice))
            counts = self._counts_summary(lp.dice)
            user.speak_l("ld-your-roll", dice=dice_str)
            user.speak_l("ld-your-counts", counts=counts)
        # Start the round at `starter`, or the previous current_player if none.
        if starter is not None:
            try:
                self.turn_index = self.turn_player_ids.index(starter.id)
            except ValueError:
                pass
        self._start_turn()

    def _counts_summary(self, dice: list[int]) -> str:
        counts = {face: 0 for face in range(1, 7)}
        for d in dice:
            counts[d] += 1
        parts = [f"{counts[face]} {face}s" for face in range(1, 7) if counts[face] > 0]
        return ", ".join(parts) if parts else "none"

    # ------------------------------------------------------------------
    # Turn flow
    # ------------------------------------------------------------------

    def _start_turn(self, previous_player: Player | None = None) -> None:
        # Skip eliminated players.
        safety = 0
        while True:
            player = self.current_player
            if player is None:
                return
            lp: LiarsDicePlayer = player  # type: ignore
            if not lp.eliminated and lp.dice_count > 0:
                break
            self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
            safety += 1
            if safety > len(self.players):
                return

        user = self.get_user(player)
        locale = user.locale if user else "en"
        bid_state = (
            Localization.get(
                locale, "ld-current-bid",
                quantity=self.current_bid[0],
                face=_face_word(self.current_bid[1], locale),
            )
            if self.current_bid is not None
            else Localization.get(locale, "ld-no-bid-yet")
        )
        self.broadcast_l("ld-turn-start", player=player.name, bid_state=bid_state)
        if user and getattr(user.preferences, "play_turn_sound", True):
            user.play_sound("game_pig/turn.ogg")

        if player.is_bot:
            BotHelper.jolt_bot(player, ticks=random.randint(20, 40))

        if previous_player is not None and previous_player is not player:
            self.rebuild_player_menu(previous_player)
        for p in self.players:
            self.rebuild_player_menu(p, position=1 if p is player else None)

    def _end_turn(self) -> None:
        previous = self.current_player
        self.turn_index = (self.turn_index + 1) % max(1, len(self.turn_player_ids))
        self._start_turn(previous_player=previous)

    # ------------------------------------------------------------------
    # Action sets
    # ------------------------------------------------------------------

    def create_turn_action_set(self, player: LiarsDicePlayer) -> ActionSet:  # type: ignore[override]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        action_set = ActionSet(name="turn")

        action_set.add(
            Action(
                id="bid",
                label=Localization.get(locale, "ld-action-bid"),
                handler="_action_bid",
                is_enabled="_is_bid_enabled",
                is_hidden="_is_bid_hidden",
                input_request=MenuInput(
                    prompt="ld-bid-prompt",
                    options="_bid_options",
                    bot_select="_bot_select_bid",
                    include_cancel=True,
                ),
            )
        )
        action_set.add(
            Action(
                id="call_liar",
                label=Localization.get(locale, "ld-action-call-liar"),
                handler="_action_call_liar",
                is_enabled="_is_call_enabled",
                is_hidden="_is_call_hidden",
            )
        )
        action_set.add(
            Action(
                id="call_spot_on",
                label=Localization.get(locale, "ld-action-call-spot-on"),
                handler="_action_call_spot_on",
                is_enabled="_is_call_enabled",
                is_hidden="_is_spot_on_hidden",
            )
        )
        return action_set

    def create_standard_action_set(self, player: LiarsDicePlayer) -> ActionSet:  # type: ignore[override]
        action_set = super().create_standard_action_set(player)
        user = self.get_user(player)
        locale = user.locale if user else "en"

        status = Action(
            id="check_status", label="Check status",
            handler="_action_check_status",
            is_enabled="_is_check_status_enabled",
            is_hidden="_is_check_status_hidden",
        )
        action_set.add(status)
        if status.id in action_set._order:
            action_set._order.remove(status.id)
        action_set._order.insert(0, status.id)

        detailed = Action(
            id="check_status_detailed", label="Detailed status",
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
        self.define_keybind("b", "Make a bid", ["bid"], state=KeybindState.ACTIVE)
        self.define_keybind("l", "Call Liar", ["call_liar"], state=KeybindState.ACTIVE)

    # ------------------------------------------------------------------
    # Visibility / enabled
    # ------------------------------------------------------------------

    def _my_turn(self, player: Player) -> bool:
        return self.current_player is player

    def _is_bid_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "ld-action-not-playing"
        if not self._my_turn(player):
            return "ld-action-not-your-turn"
        return None

    def _is_bid_hidden(self, player: Player) -> Visibility:
        if not self._my_turn(player):
            return Visibility.HIDDEN
        lp: LiarsDicePlayer = player  # type: ignore
        if lp.eliminated:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_call_enabled(self, player: Player) -> str | None:
        if self.status != "playing":
            return "ld-action-not-playing"
        if not self._my_turn(player):
            return "ld-action-not-your-turn"
        if self.current_bid is None:
            return "ld-action-no-bid-to-call"
        return None

    def _is_call_hidden(self, player: Player) -> Visibility:
        if not self._my_turn(player) or self.current_bid is None:
            return Visibility.HIDDEN
        lp: LiarsDicePlayer = player  # type: ignore
        if lp.eliminated:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_spot_on_hidden(self, player: Player) -> Visibility:
        if not self.options.spot_on:
            return Visibility.HIDDEN
        return self._is_call_hidden(player)

    def _is_check_status_enabled(self, player: Player) -> str | None:
        if self.status not in ("playing", "finished"):
            return "ld-action-not-playing"
        return None

    def _is_check_status_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    # ------------------------------------------------------------------
    # Bid menu options + bot bid selection
    # ------------------------------------------------------------------

    def _total_dice_on_table(self) -> int:
        return sum(p.dice_count for p in self.get_active_players() if not getattr(p, "eliminated", False))

    def _bid_options(self, player: Player) -> list[str]:
        user = self.get_user(player)
        locale = user.locale if user else "en"
        bids = enumerate_valid_bids(
            current=self.current_bid,
            total_dice=self._total_dice_on_table(),
            wild_ones=self.options.wild_ones,
        )
        return [
            Localization.get(locale, "ld-bid-option", quantity=q, face=_face_word(f, locale))
            for q, f in bids
        ]

    def _bot_select_bid(self, player: Player, options: list[str]) -> str | None:
        if not options:
            return None
        lp: LiarsDicePlayer = player  # type: ignore
        # Bots favor low-quantity safe bids, taking into account their own dice.
        bids = enumerate_valid_bids(
            current=self.current_bid,
            total_dice=self._total_dice_on_table(),
            wild_ones=self.options.wild_ones,
        )
        if not bids:
            return options[0]
        # For each candidate, estimate probability the bid is true.
        # Known: own dice. Unknown: opponent dice (assume uniform).
        my_counts = {f: count_face(lp.dice, f, self.options.wild_ones) for f in range(1, 7)}
        opponent_dice = self._total_dice_on_table() - lp.dice_count
        # Probability that any one opponent die counts toward face f:
        # face 1 (no wild): 1/6
        # face 2..6 (with wild): 2/6 (the face itself + wild 1s)
        # face 1 (with wild on, but bid is on 1s): 1/6
        # face 2..6 (no wild option): 1/6
        def per_die_prob(face: int) -> float:
            if not self.options.wild_ones:
                return 1 / 6
            if face == 1:
                return 1 / 6
            return 2 / 6

        # Choose the highest-quantity bid where expected count >= bid quantity
        # (i.e., we're betting on average outcomes).
        best = bids[0]
        for q, f in bids:
            mine = my_counts[f]
            expected_others = opponent_dice * per_die_prob(f)
            expected_total = mine + expected_others
            if expected_total + 0.5 >= q:
                best = (q, f)
            else:
                break
        # Sometimes the bot should challenge instead (handled in bot_think).
        # Translate (q, f) back into the option string.
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(locale, "ld-bid-option", quantity=best[0], face=_face_word(best[1], locale))

    # ------------------------------------------------------------------
    # Action handlers
    # ------------------------------------------------------------------

    def _action_bid(self, player: Player, *args) -> None:
        if len(args) < 2:
            return
        choice, action_id = args[0], args[1]
        bid = self._parse_bid_choice(player, str(choice))
        if bid is None:
            return
        if not is_higher_bid(bid, self.current_bid, self.options.wild_ones):
            return
        self.current_bid = bid
        self.last_bidder_id = player.id
        user = self.get_user(player)
        locale = user.locale if user else "en"
        self._announce(player, "ld-bid-made", quantity=bid[0], face=_face_word(bid[1], locale))
        self._end_turn()

    def _parse_bid_choice(self, player: Player, choice: str) -> tuple[int, int] | None:
        # The bid choice was rendered via locale so reverse-lookup by enumerating again.
        user = self.get_user(player)
        locale = user.locale if user else "en"
        bids = enumerate_valid_bids(
            current=self.current_bid,
            total_dice=self._total_dice_on_table(),
            wild_ones=self.options.wild_ones,
        )
        for q, f in bids:
            rendered = Localization.get(locale, "ld-bid-option", quantity=q, face=_face_word(f, locale))
            if rendered == choice:
                return (q, f)
        return None

    def _action_call_liar(self, player: Player, action_id: str) -> None:
        if self.current_bid is None:
            return
        target = self.get_player_by_id(self.last_bidder_id)
        if target is None:
            return
        user = self.get_user(player)
        locale = user.locale if user else "en"
        q, f = self.current_bid
        self._announce(
            player, "ld-call-liar",
            target=target.name, quantity=q, face=_face_word(f, locale),
        )
        self._resolve_reveal(challenger=player, mode="liar")

    def _action_call_spot_on(self, player: Player, action_id: str) -> None:
        if self.current_bid is None or not self.options.spot_on:
            return
        target = self.get_player_by_id(self.last_bidder_id)
        if target is None:
            return
        user = self.get_user(player)
        locale = user.locale if user else "en"
        q, f = self.current_bid
        self._announce(
            player, "ld-call-spot-on",
            target=target.name, quantity=q, face=_face_word(f, locale),
        )
        self._resolve_reveal(challenger=player, mode="spot_on")

    # ------------------------------------------------------------------
    # Reveal / dice loss / round transition
    # ------------------------------------------------------------------

    def _resolve_reveal(self, challenger: Player, mode: str) -> None:
        if self.current_bid is None:
            return
        q, f = self.current_bid
        bidder = self.get_player_by_id(self.last_bidder_id)
        if bidder is None:
            return
        user = self.get_user(challenger)
        locale = user.locale if user else "en"
        face_word = _face_word(f, locale)
        self.broadcast_l("ld-reveal-header", face=face_word)
        for p in self.get_active_players():
            lp: LiarsDicePlayer = p  # type: ignore
            if lp.eliminated:
                continue
            dice_str = ", ".join(str(d) for d in sorted(lp.dice))
            self.broadcast_l("ld-reveal-line", player=p.name, dice=dice_str or "(none)")
        # Total count of f across all dice with wilds rule.
        wild = self.options.wild_ones
        total = 0
        for p in self.get_active_players():
            lp = p  # type: ignore
            if lp.eliminated:
                continue
            total += count_face(lp.dice, f, wild)
        if wild and f != 1:
            self.broadcast_l(
                "ld-actual-count", face=face_word, count=total, quantity=q
            )
        else:
            self.broadcast_l(
                "ld-actual-count-no-wild", face=face_word, count=total, quantity=q
            )

        loser: LiarsDicePlayer
        loss = 1
        if mode == "liar":
            if total >= q:
                # Bid was honest; challenger loses.
                self.broadcast_l("ld-liar-caller-loses", caller=challenger.name)
                loser = challenger  # type: ignore[assignment]
            else:
                # Bid was a lie; bidder loses.
                self.broadcast_l("ld-liar-bidder-loses", bidder=bidder.name)
                loser = bidder  # type: ignore[assignment]
            self._lose_dice([loser], 1)
        else:  # spot_on
            if total == q:
                # Spot on — every other player loses 1.
                self.broadcast_l("ld-spot-on-correct", caller=challenger.name)
                others = [
                    p for p in self.get_active_players()
                    if p is not challenger and not getattr(p, "eliminated", False)
                ]
                self._lose_dice(others, 1)
                loser = challenger  # type: ignore[assignment]  # used only for next-starter logic
                # Spot-on caller starts next round.
            else:
                self.broadcast_l("ld-spot-on-wrong", caller=challenger.name)
                loser = challenger  # type: ignore[assignment]
                self._lose_dice([loser], 2)

        # Check eliminations + game end.
        if self._check_game_end():
            return

        # Loser of the round starts the next round (or the spot-on caller on success).
        starter = loser if not loser.eliminated else self._next_living_after(loser)
        self._begin_round(starter=starter)

    def _lose_dice(self, players: list[Player], count: int) -> None:
        for p in players:
            lp: LiarsDicePlayer = p  # type: ignore
            if lp.eliminated:
                continue
            lp.dice_count = max(0, lp.dice_count - count)
            remaining = lp.dice_count
            if count > 1:
                self._announce(p, "ld-lost-dice-multi", count=count, remaining=remaining)
            else:
                self._announce(p, "ld-lost-die", remaining=remaining)
            if lp.dice_count <= 0:
                lp.eliminated = True
                survivors = sum(
                    1 for q in self.get_active_players() if not getattr(q, "eliminated", False)
                )
                self.broadcast_l(
                    "ld-eliminated", player=p.name, remaining=survivors,
                )

    def _check_game_end(self) -> bool:
        survivors = [
            p for p in self.get_active_players() if not getattr(p, "eliminated", False)
        ]
        if len(survivors) <= 1:
            if survivors:
                self.winner = survivors[0]
                self.broadcast_l("ld-winner", player=survivors[0].name)
                self.play_sound("game_pig/win.ogg")
            self.finish_game()
            return True
        return False

    def _next_living_after(self, player: Player) -> Player | None:
        try:
            idx = self.turn_player_ids.index(player.id)
        except ValueError:
            return None
        n = len(self.turn_player_ids)
        for offset in range(1, n + 1):
            cand = self.get_player_by_id(self.turn_player_ids[(idx + offset) % n])
            if cand and not getattr(cand, "eliminated", False):
                return cand
        return None

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

    # ------------------------------------------------------------------
    # Status readouts
    # ------------------------------------------------------------------

    def _action_check_status(self, player: Player, action_id: str) -> None:
        lp: LiarsDicePlayer = player  # type: ignore
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        lines: list[str] = [
            Localization.get(locale, "ld-status-round", round=self.round_no)
        ]
        if lp.eliminated:
            lines.append(Localization.get(locale, "ld-status-no-dice"))
        else:
            dice_str = ", ".join(str(d) for d in sorted(lp.dice))
            lines.append(Localization.get(locale, "ld-status-your-dice", dice=dice_str))
            lines.append(
                Localization.get(locale, "ld-status-your-counts", counts=self._counts_summary(lp.dice))
            )
        if self.current_bid is not None:
            q, f = self.current_bid
            lines.append(
                Localization.get(
                    locale, "ld-status-current-bid",
                    quantity=q, face=_face_word(f, locale),
                )
            )
        else:
            lines.append(Localization.get(locale, "ld-status-no-bid"))
        lines.append(Localization.get(locale, "ld-status-table-total", total=self._total_dice_on_table()))
        self.status_box(player, lines)

    def _action_check_status_detailed(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if not user:
            return
        locale = user.locale
        active = list(self.get_active_players())
        survivors = sum(1 for p in active if not getattr(p, "eliminated", False))
        lines: list[str] = [
            Localization.get(locale, "ld-status-detailed-header", count=survivors)
        ]
        for p in active:
            lp: LiarsDicePlayer = p  # type: ignore
            if lp.eliminated:
                lines.append(Localization.get(locale, "ld-status-detailed-out", player=p.name))
                continue
            self_suffix = (
                Localization.get(locale, "ld-status-detailed-self-suffix")
                if p is player else ""
            )
            lines.append(
                Localization.get(
                    locale, "ld-status-detailed-line",
                    player=p.name, self_suffix=self_suffix, dice=lp.dice_count,
                )
            )
        self.status_box(player, lines)

    # ------------------------------------------------------------------
    # Tick
    # ------------------------------------------------------------------

    def on_tick(self) -> None:
        super().on_tick()
        self.process_scheduled_events()
        if self.status == "playing":
            BotHelper.on_tick(self)

    # ------------------------------------------------------------------
    # Bot AI
    # ------------------------------------------------------------------

    def bot_think(self, player: LiarsDicePlayer) -> str | None:
        if player.eliminated:
            return None
        if not self._my_turn(player):
            return None
        if self.current_bid is None:
            # Open the round with a low bid based on our own counts.
            return "bid"
        # Decide whether to challenge or raise based on probability.
        q, f = self.current_bid
        mine = count_face(player.dice, f, self.options.wild_ones)
        opponent_dice = self._total_dice_on_table() - player.dice_count
        if self.options.wild_ones and f != 1:
            per_die = 2 / 6
        else:
            per_die = 1 / 6
        expected_others = opponent_dice * per_die
        expected_total = mine + expected_others
        # If the bid is well above expected, call Liar.
        if q > expected_total + 1.5:
            return "call_liar"
        # If wildly improbable, call Liar with high confidence.
        if q > expected_total + 3:
            return "call_liar"
        # Spot On is rarely right — only attempt when confident.
        if self.options.spot_on and abs(q - expected_total) < 0.4 and random.random() < 0.05:  # nosec B311
            return "call_spot_on"
        return "bid"

    # ------------------------------------------------------------------
    # End screen
    # ------------------------------------------------------------------

    def build_game_result(self) -> GameResult:
        winner = getattr(self, "winner", None)
        sorted_players = sorted(
            self.get_active_players(),
            key=lambda p: (getattr(p, "eliminated", False), -getattr(p, "dice_count", 0)),
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
                "rounds_played": self.round_no,
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        lines = [Localization.get(locale, "game-final-scores")]
        for rank, p_result in enumerate(result.player_results, 1):
            p = self.get_player_by_id(p_result.player_id)
            dice = getattr(p, "dice_count", 0) if p else 0
            lines.append(
                f"{rank}. {p_result.player_name}: { 'eliminated' if dice == 0 else f'{dice} dice' }"
            )
        return lines
