"""
Mancala Game Implementation for PlayPalace v11.

Classic African pit-and-stone game (Kalah variant).
Two players, six pits each, sow and capture stones.
"""

from dataclasses import dataclass, field
from datetime import datetime
import random

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


# Board layout (14 positions):
#   Indices 0-5:   Player 0's pits (left to right)
#   Index 6:       Player 0's store
#   Indices 7-12:  Player 1's pits (left to right from their perspective)
#   Index 13:      Player 1's store
#
# Sowing goes counter-clockwise (increasing index, wrapping at 14).
# Skip opponent's store during sowing.
# Opposite pit of board index i (pits only): 12 - i.

P0_STORE = 6
P1_STORE = 13
NUM_PITS = 6


@dataclass
class MancalaPlayer(Player):
    """Player state for Mancala."""

    pass


@dataclass
class MancalaOptions(GameOptions):
    """Options for Mancala game."""

    stones_per_pit: int = option_field(
        IntOption(
            default=4,
            min_val=1,
            max_val=8,
            value_key="stones",
            label="mancala-set-stones",
            prompt="mancala-enter-stones",
            change_msg="mancala-option-changed-stones",
            description="mancala-desc-stones",
        )
    )


@dataclass
@register_game
class MancalaGame(ActionGuardMixin, RoundBasedGameMixin, Game):
    """
    Mancala (Kalah variant).

    Each player has 6 pits and a store. On your turn, pick a pit on
    your side, sow its stones counter-clockwise. Land in your store
    for an extra turn. Land in an empty pit on your side to capture
    the opposite pit's stones. Game ends when one side is empty.
    """

    players: list[MancalaPlayer] = field(default_factory=list)
    options: MancalaOptions = field(default_factory=MancalaOptions)
    board: list[int] = field(default_factory=lambda: [0] * 14)

    @classmethod
    def get_name(cls) -> str:
        return "Mancala"

    @classmethod
    def get_type(cls) -> str:
        return "mancala"

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
    ) -> MancalaPlayer:
        return MancalaPlayer(id=player_id, name=name, is_bot=is_bot)

    def get_team_mode(self) -> str:
        return "individual"

    # ==========================================================================
    # Board helpers
    # ==========================================================================

    def _player_index(self, player: MancalaPlayer) -> int:
        """Get 0 or 1 for the player's side of the board."""
        active = self.get_active_players()
        for i, p in enumerate(active):
            if p.id == player.id:
                return i
        return 0

    def _pit_board_idx(self, player_idx: int, pit: int) -> int:
        """Convert player index (0/1) and pit number (0-5) to board index."""
        return player_idx * 7 + pit

    def _store_idx(self, player_idx: int) -> int:
        return P0_STORE if player_idx == 0 else P1_STORE

    def _own_pits(self, player_idx: int) -> range:
        return range(player_idx * 7, player_idx * 7 + NUM_PITS)

    def _side_empty(self, player_idx: int) -> bool:
        return all(self.board[i] == 0 for i in self._own_pits(player_idx))

    # ==========================================================================
    # Sowing logic
    # ==========================================================================

    def _sow(self, player_idx: int, pit: int) -> tuple[bool, int]:
        """Sow stones from the given pit. Returns (extra_turn, captured)."""
        board_idx = self._pit_board_idx(player_idx, pit)
        stones = self.board[board_idx]
        self.board[board_idx] = 0

        skip_store = P1_STORE if player_idx == 0 else P0_STORE
        own_store = self._store_idx(player_idx)
        own_pits = self._own_pits(player_idx)

        current = board_idx
        for _ in range(stones):
            current = (current + 1) % 14
            if current == skip_store:
                current = (current + 1) % 14
            self.board[current] += 1

        extra_turn = current == own_store

        captured = 0
        if current in own_pits and self.board[current] == 1:
            opposite = 12 - current
            if self.board[opposite] > 0:
                captured = self.board[opposite] + 1
                self.board[own_store] += captured
                self.board[current] = 0
                self.board[opposite] = 0

        return extra_turn, captured

    def _simulate_sow(self, player_idx: int, pit: int) -> tuple[bool, int]:
        """Simulate sowing without modifying the board."""
        saved = self.board[:]
        result = self._sow(player_idx, pit)
        self.board = saved
        return result

    def _collect_remaining(self) -> None:
        """Move all remaining pit stones to respective stores (game end)."""
        for i in range(0, NUM_PITS):
            self.board[P0_STORE] += self.board[i]
            self.board[i] = 0
        for i in range(7, 7 + NUM_PITS):
            self.board[P1_STORE] += self.board[i]
            self.board[i] = 0

    # ==========================================================================
    # Board description for speech
    # ==========================================================================

    def _describe_board(self, player: MancalaPlayer, locale: str) -> str:
        """Build a speech-friendly board description from the player's perspective."""
        player_idx = self._player_index(player)
        opp_idx = 1 - player_idx

        own_pits = [
            str(self.board[self._pit_board_idx(player_idx, p)]) for p in range(NUM_PITS)
        ]
        own_store = self.board[self._store_idx(player_idx)]
        opp_pits = [
            str(self.board[self._pit_board_idx(opp_idx, p)]) for p in range(NUM_PITS)
        ]
        opp_store = self.board[self._store_idx(opp_idx)]

        return Localization.get(
            locale,
            "mancala-board-status",
            own_pits=", ".join(own_pits),
            own_store=own_store,
            opp_pits=", ".join(opp_pits),
            opp_store=opp_store,
        )

    # ==========================================================================
    # Game lifecycle
    # ==========================================================================

    def on_start(self) -> None:
        stones = self.options.stones_per_pit
        self.board = [0] * 14
        for i in range(NUM_PITS):
            self.board[i] = stones
            self.board[7 + i] = stones
        super().on_start()

    def on_tick(self) -> None:
        super().on_tick()
        BotHelper.on_tick(self)

    def _reset_player_for_game(self, player: MancalaPlayer) -> None:
        pass

    def _reset_player_for_turn(self, player: MancalaPlayer) -> None:
        pass

    def _on_round_end(self) -> None:
        # Mancala has no rounds — turns continue until the board empties.
        # Just start a new cycle through the turn order.
        self._start_round()

    # ==========================================================================
    # Actions — pit selection
    # ==========================================================================

    def _is_pit_enabled(
        self, player: Player, *, action_id: str | None = None
    ) -> str | None:
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        if action_id:
            pit = int(action_id.split("_")[1])
            player_idx = self._player_index(player)
            board_idx = self._pit_board_idx(player_idx, pit)
            if self.board[board_idx] == 0:
                return "mancala-pit-empty"
        return None

    def _is_pit_hidden(self, player: Player) -> Visibility:
        return self.turn_action_visibility(player)

    def _get_pit_label(self, player: Player, action_id: str) -> str:
        pit = int(action_id.split("_")[1])
        player_idx = self._player_index(player)
        board_idx = self._pit_board_idx(player_idx, pit)
        stones = self.board[board_idx]
        user = self.get_user(player)
        locale = user.locale if user else "en"
        return Localization.get(locale, "mancala-pit-label", pit=pit + 1, stones=stones)

    # ==========================================================================
    # Actions — check board (keybind-only)
    # ==========================================================================

    def _is_check_board_enabled(self, player: Player) -> str | None:
        return self.guard_game_active()

    def _is_check_board_hidden(self, player: Player) -> Visibility:
        return Visibility.HIDDEN

    # ==========================================================================
    # Action set and keybinds
    # ==========================================================================

    def create_turn_action_set(self, player: MancalaPlayer) -> ActionSet:
        user = self.get_user(player)
        locale = user.locale if user else "en"

        action_set = ActionSet(name="turn")
        for pit in range(NUM_PITS):
            action_set.add(
                Action(
                    id=f"pit_{pit}",
                    label=Localization.get(
                        locale, "mancala-pit-label", pit=pit + 1, stones=0
                    ),
                    handler="_action_sow",
                    is_enabled="_is_pit_enabled",
                    is_hidden="_is_pit_hidden",
                    get_label="_get_pit_label",
                )
            )
        action_set.add(
            Action(
                id="check_board",
                label="Check board",
                handler="_action_check_board",
                is_enabled="_is_check_board_enabled",
                is_hidden="_is_check_board_hidden",
                show_in_actions_menu=False,
            )
        )
        return action_set

    def setup_keybinds(self) -> None:
        super().setup_keybinds()
        for pit in range(NUM_PITS):
            self.define_keybind(
                str(pit + 1),
                f"Sow from pit {pit + 1}",
                [f"pit_{pit}"],
                state=KeybindState.ACTIVE,
            )
        self.define_keybind(
            "e", "Check board", ["check_board"], state=KeybindState.ACTIVE
        )

    # ==========================================================================
    # Action handlers
    # ==========================================================================

    def _action_sow(self, player: Player, action_id: str) -> None:
        pit = int(action_id.split("_")[1])
        player_idx = self._player_index(player)
        stones = self.board[self._pit_board_idx(player_idx, pit)]

        self.broadcast_l(
            "mancala-sow", player=player.name, pit=pit + 1, stones=stones
        )

        extra_turn, captured = self._sow(player_idx, pit)

        if captured > 0:
            self.broadcast_l(
                "mancala-capture", player=player.name, captured=captured
            )

        # Check game end
        if self._side_empty(0) or self._side_empty(1):
            self._collect_remaining()
            self._end_game()
            return

        if extra_turn:
            self.broadcast_l("mancala-extra-turn", player=player.name)
            BotHelper.jolt_bots(self, ticks=random.randint(15, 25))  # nosec B311
            self._start_turn()
        else:
            self.end_turn()

    def _action_check_board(self, player: Player, action_id: str) -> None:
        user = self.get_user(player)
        if user:
            desc = self._describe_board(player, user.locale)
            user.speak(desc, buffer="game")

    # ==========================================================================
    # Bot AI
    # ==========================================================================

    def bot_think(self, player: MancalaPlayer) -> str | None:
        player_idx = self._player_index(player)
        best_pit = None
        best_score = -1.0

        for pit in range(NUM_PITS):
            board_idx = self._pit_board_idx(player_idx, pit)
            if self.board[board_idx] == 0:
                continue

            extra_turn, captured = self._simulate_sow(player_idx, pit)

            score = float(captured)
            if extra_turn:
                score += 10.0
            # Slight preference for rightmost pits (closer to store)
            score += pit * 0.1

            if score > best_score:
                best_score = score
                best_pit = pit

        if best_pit is not None:
            return f"pit_{best_pit}"
        return None

    def _setup_bot_for_turn(self, player: MancalaPlayer) -> None:
        BotHelper.jolt_bot(player, ticks=random.randint(10, 20))  # nosec B311

    # ==========================================================================
    # Game end
    # ==========================================================================

    def _end_game(self) -> None:
        active = self.get_active_players()
        p0_score = self.board[P0_STORE]
        p1_score = self.board[P1_STORE]

        if p0_score > p1_score:
            winner = active[0]
            self.broadcast_l("mancala-winner", player=winner.name, score=p0_score)
        elif p1_score > p0_score:
            winner = active[1]
            self.broadcast_l("mancala-winner", player=winner.name, score=p1_score)
        else:
            self.broadcast_l("mancala-draw", score=p0_score)

        self.finish_game()

    # ==========================================================================
    # Game result
    # ==========================================================================

    def build_game_result(self) -> GameResult:
        active = self.get_active_players()
        p0_score = self.board[P0_STORE]
        p1_score = self.board[P1_STORE]

        scores = {}
        if len(active) >= 2:
            scores[active[0].name] = p0_score
            scores[active[1].name] = p1_score

        winner_name = None
        winner_score = 0
        if p0_score > p1_score and len(active) >= 1:
            winner_name = active[0].name
            winner_score = p0_score
        elif p1_score > p0_score and len(active) >= 2:
            winner_name = active[1].name
            winner_score = p1_score

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
                "winner_name": winner_name,
                "winner_score": winner_score,
                "final_scores": scores,
                "stones_per_pit": self.options.stones_per_pit,
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        scores = result.custom_data.get("final_scores", {})
        lines = []
        for name, score in scores.items():
            lines.append(
                Localization.get(locale, "mancala-final-score", player=name, score=score)
            )
        winner = result.custom_data.get("winner_name")
        if winner:
            lines.append(
                Localization.get(
                    locale,
                    "mancala-winner",
                    player=winner,
                    score=result.custom_data.get("winner_score", 0),
                )
            )
        else:
            lines.append(
                Localization.get(
                    locale,
                    "mancala-draw",
                    score=result.custom_data.get("winner_score", 0),
                )
            )
        return lines

    def end_turn(self) -> None:
        BotHelper.jolt_bots(self, ticks=random.randint(15, 25))  # nosec B311
        self._on_turn_end()
