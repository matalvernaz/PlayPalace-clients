"""Trouble game implementation for PlayPalace v11.

A Parcheesi-family race game. Each player races tokens from Home, around
a shared track, and into a private finish lane. Classic Hasbro rules are
the default; almost every rule is a host-selectable pre-game option.

State-reading is modeled on Mancala: each turn starts with a personal,
per-perspective summary of where everyone's tokens are. A Check Board
action (E key) gives the full detail on demand.
"""

from dataclasses import dataclass, field
from datetime import datetime
import random

from ..base import Game, Player
from ..registry import register_game
from ...game_utils.action_guard_mixin import ActionGuardMixin
from ...game_utils.actions import Action, ActionSet, Visibility
from ...game_utils.bot_helper import BotHelper
from ...game_utils.game_result import GameResult, PlayerResult
from ...game_utils.options import (
    BoolOption,
    GameOptions,
    MenuOption,
    TeamModeOption,
    option_field,
)
from ...game_utils.parcheesi import (
    FinishMode,
    MovementEngine,
    SeatGeometry,
    Token,
    TokenZone,
    every_nth_safe_positions,
    home_stretch_safe_positions,
)
from ...game_utils.round_based_game_mixin import RoundBasedGameMixin
from ...game_utils.teams import TeamManager
from ...messages.localization import Localization
from server.core.ui.keybinds import KeybindState

from .bot import bot_think
from .presets import PRESETS, PRESET_KEYS, apply_preset, matching_preset_id


# ==========================================================================
# Option choice lists and locale-label maps
# ==========================================================================

TRACK_SIZE_CHOICES = ["20", "24", "28", "32", "36", "40"]
TRACK_SIZE_LABELS = {s: s for s in TRACK_SIZE_CHOICES}

TOKENS_PER_PLAYER_CHOICES = ["2", "3", "4", "5", "6"]
TOKENS_PER_PLAYER_LABELS = {s: s for s in TOKENS_PER_PLAYER_CHOICES}

SAFE_SPACES_CHOICES = ["none", "home_stretch", "every_seventh"]
SAFE_SPACES_LABELS = {
    "none": "trouble-safe-mode-none",
    "home_stretch": "trouble-safe-mode-home-stretch",
    "every_seventh": "trouble-safe-mode-every-seventh",
}

FINISH_BEHAVIOR_CHOICES = ["exact", "bounce", "allow"]
FINISH_BEHAVIOR_LABELS = {
    "exact": "trouble-finish-mode-exact",
    "bounce": "trouble-finish-mode-bounce",
    "allow": "trouble-finish-mode-allow",
}

BOT_DIFFICULTY_CHOICES = ["naive", "greedy"]
BOT_DIFFICULTY_LABELS = {
    "naive": "trouble-bot-difficulty-naive",
    "greedy": "trouble-bot-difficulty-greedy",
}

# "custom" is included so the host can see when they've overridden a preset.
PRESET_CHOICES = ["custom", "classic", "fast", "brutal"]
PRESET_LABELS = {
    "custom": "trouble-preset-custom",
    "classic": "trouble-preset-classic",
    "fast": "trouble-preset-fast",
    "brutal": "trouble-preset-brutal",
}

FINISH_MODE_BY_OPTION: dict[str, FinishMode] = {
    "exact": FinishMode.EXACT,
    "bounce": FinishMode.BOUNCE,
    "allow": FinishMode.ALLOW,
}

FINISH_LANE_LENGTH = 4  # Private finish lane is four spaces; not customizable.


# ==========================================================================
# Player & options dataclasses
# ==========================================================================


@dataclass
class TroublePlayer(Player):
    """Player state for Trouble."""

    seat_index: int = 0
    tokens: list[Token] = field(default_factory=list)
    # Per-turn: 0 means "hasn't rolled this turn yet".
    last_roll: int = 0
    # Token numbers (1-based) that have a legal move given last_roll.
    legal_move_tokens: list[int] = field(default_factory=list)


@dataclass
class TroubleOptions(GameOptions):
    """Options for Trouble — every rule below is host-configurable."""

    preset: str = option_field(
        MenuOption(
            default="classic",
            value_key="preset",
            choices=PRESET_CHOICES,
            choice_labels=PRESET_LABELS,
            label="trouble-option-preset",
            prompt="trouble-option-select-preset",
            change_msg="trouble-option-changed-preset",
            description="trouble-option-desc-preset",
        )
    )
    team_mode: str = option_field(
        TeamModeOption(
            default="individual",
            value_key="mode",
            choices=lambda g, p: TeamManager.get_all_team_modes(2, 4),
            label="game-set-team-mode",
            prompt="game-select-team-mode",
            change_msg="game-option-changed-team",
        )
    )
    track_size: str = option_field(
        MenuOption(
            default="28",
            value_key="track_size",
            choices=TRACK_SIZE_CHOICES,
            choice_labels=TRACK_SIZE_LABELS,
            label="trouble-option-track-size",
            prompt="trouble-option-select-track-size",
            change_msg="trouble-option-changed-track-size",
            description="trouble-option-desc-track-size",
        )
    )
    tokens_per_player: str = option_field(
        MenuOption(
            default="4",
            value_key="tokens",
            choices=TOKENS_PER_PLAYER_CHOICES,
            choice_labels=TOKENS_PER_PLAYER_LABELS,
            label="trouble-option-tokens-per-player",
            prompt="trouble-option-enter-tokens-per-player",
            change_msg="trouble-option-changed-tokens-per-player",
            description="trouble-option-desc-tokens-per-player",
        )
    )
    extra_turn_on_six: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="trouble-option-extra-turn-on-six",
            change_msg="trouble-option-changed-extra-turn-on-six",
            description="trouble-option-desc-extra-turn-on-six",
        )
    )
    six_to_leave_home: bool = option_field(
        BoolOption(
            default=True,
            value_key="enabled",
            label="trouble-option-six-to-leave-home",
            change_msg="trouble-option-changed-six-to-leave-home",
            description="trouble-option-desc-six-to-leave-home",
        )
    )
    safe_spaces: str = option_field(
        MenuOption(
            default="none",
            value_key="mode",
            choices=SAFE_SPACES_CHOICES,
            choice_labels=SAFE_SPACES_LABELS,
            label="trouble-option-safe-spaces",
            prompt="trouble-option-select-safe-spaces",
            change_msg="trouble-option-changed-safe-spaces",
            description="trouble-option-desc-safe-spaces",
        )
    )
    finish_behavior: str = option_field(
        MenuOption(
            default="exact",
            value_key="mode",
            choices=FINISH_BEHAVIOR_CHOICES,
            choice_labels=FINISH_BEHAVIOR_LABELS,
            label="trouble-option-finish-behavior",
            prompt="trouble-option-select-finish-behavior",
            change_msg="trouble-option-changed-finish-behavior",
            description="trouble-option-desc-finish-behavior",
        )
    )
    bot_difficulty: str = option_field(
        MenuOption(
            default="greedy",
            value_key="level",
            choices=BOT_DIFFICULTY_CHOICES,
            choice_labels=BOT_DIFFICULTY_LABELS,
            label="trouble-option-bot-difficulty",
            prompt="trouble-option-select-bot-difficulty",
            change_msg="trouble-option-changed-bot-difficulty",
            description="trouble-option-desc-bot-difficulty",
        )
    )


# ==========================================================================
# Game
# ==========================================================================


@dataclass
@register_game
class TroubleGame(ActionGuardMixin, RoundBasedGameMixin, Game):
    """Trouble: a Parcheesi-family race game."""

    players: list[TroublePlayer] = field(default_factory=list)
    options: TroubleOptions = field(default_factory=TroubleOptions)

    # ---------------- Registration ----------------

    @classmethod
    def get_name(cls) -> str:
        return "Trouble"

    @classmethod
    def get_type(cls) -> str:
        return "trouble"

    @classmethod
    def get_category(cls) -> str:
        return "category-board-games"

    @classmethod
    def get_min_players(cls) -> int:
        return 2

    @classmethod
    def get_max_players(cls) -> int:
        return 4

    def create_player(
        self, player_id: str, name: str, is_bot: bool = False
    ) -> TroublePlayer:
        return TroublePlayer(id=player_id, name=name, is_bot=is_bot)

    def get_team_mode(self) -> str:
        return self.options.team_mode

    # ---------------- Derived configuration ----------------

    @property
    def track_length(self) -> int:
        return int(self.options.track_size)

    @property
    def tokens_per_player(self) -> int:
        return int(self.options.tokens_per_player)

    def _seat_geometries(self) -> list[SeatGeometry]:
        """Build seat geometries for the current player count and track size."""
        return SeatGeometry.all_seats(
            num_seats=max(1, len(self.get_active_players())),
            track_length=self.track_length,
        )

    def _safe_positions(self, seat_geoms: list[SeatGeometry]) -> frozenset[int]:
        mode = self.options.safe_spaces
        if mode == "home_stretch":
            return home_stretch_safe_positions(seat_geoms)
        if mode == "every_seventh":
            return every_nth_safe_positions(self.track_length, n=7)
        return frozenset()

    def _build_engine(self) -> MovementEngine:
        seat_geoms = self._seat_geometries()
        return MovementEngine(
            track_length=self.track_length,
            finish_lane_length=FINISH_LANE_LENGTH,
            seat_geometries=seat_geoms,
            finish_mode=FINISH_MODE_BY_OPTION[self.options.finish_behavior],
            safe_positions=self._safe_positions(seat_geoms),
        )

    # ---------------- Lifecycle ----------------

    def on_start(self) -> None:
        active = self.get_active_players()
        # Assign seat indices in turn order
        for i, player in enumerate(active):
            player.seat_index = i
            player.tokens = [
                Token(token_number=n + 1, zone=TokenZone.HOME, position=0)
                for n in range(self.tokens_per_player)
            ]
            player.last_roll = 0
            player.legal_move_tokens = []
        super().on_start()

    def on_tick(self) -> None:
        super().on_tick()
        BotHelper.on_tick(self)

    def _reset_player_for_game(self, player: TroublePlayer) -> None:
        pass

    def _reset_player_for_turn(self, player: TroublePlayer) -> None:
        player.last_roll = 0
        player.legal_move_tokens = []

    def _on_round_end(self) -> None:
        # Trouble has no discrete rounds — each turn is a turn, forever.
        self._start_round()

    def _start_turn(self) -> None:
        """Override: after the generic turn-start announcement, push each
        player a terse personal board summary so they always hear state."""
        super()._start_turn()
        if self.status != "playing":
            return
        for p in self.get_active_players():
            user = self.get_user(p)
            if user is None:
                continue
            user.speak(self._describe_turn_summary(p, user.locale), buffer="game")

    def _setup_bot_for_turn(self, player: TroublePlayer) -> None:
        BotHelper.jolt_bot(player, ticks=random.randint(10, 20))  # nosec B311

    # ---------------- Keybinds and actions ----------------

    def setup_keybinds(self) -> None:
        super().setup_keybinds()
        self.define_keybind(
            "r",
            "Pop the die",
            ["roll"],
            state=KeybindState.ACTIVE,
        )
        self.define_keybind(
            "e",
            "Check board",
            ["check_board"],
            state=KeybindState.ACTIVE,
        )
        for token_number in range(1, self.tokens_per_player + 1):
            self.define_keybind(
                str(token_number),
                f"Move token {token_number}",
                [f"move_token_{token_number}"],
                state=KeybindState.ACTIVE,
            )

    def create_turn_action_set(self, player: TroublePlayer) -> ActionSet:
        user = self.get_user(player)
        locale = user.locale if user else "en"

        action_set = ActionSet(name="turn")
        action_set.add(
            Action(
                id="roll",
                label=Localization.get(locale, "trouble-action-roll"),
                handler="_action_roll",
                is_enabled="_is_roll_enabled",
                is_hidden="_is_roll_hidden",
            )
        )
        for token_number in range(1, self.tokens_per_player + 1):
            action_set.add(
                Action(
                    id=f"move_token_{token_number}",
                    label=Localization.get(
                        locale,
                        "trouble-action-move-token",
                        token=token_number,
                    ),
                    handler="_action_move_token",
                    is_enabled="_is_move_token_enabled",
                    is_hidden="_is_move_token_hidden",
                    get_label="_get_token_label",
                )
            )
        action_set.add(
            Action(
                id="check_board",
                label=Localization.get(locale, "trouble-action-check-board"),
                handler="_action_check_board",
                is_enabled="_is_check_board_enabled",
                is_hidden="_is_check_board_hidden",
            )
        )
        return action_set

    # ---------------- Enabled/hidden predicates ----------------

    def _is_roll_enabled(self, player: Player) -> str | None:
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        assert isinstance(player, TroublePlayer)
        if player.last_roll != 0:
            return "trouble-reason-already-rolled"
        return None

    def _is_roll_hidden(self, player: Player) -> Visibility:
        vis = self.turn_action_visibility(player)
        if vis != Visibility.VISIBLE:
            return vis
        assert isinstance(player, TroublePlayer)
        return Visibility.HIDDEN if player.last_roll != 0 else Visibility.VISIBLE

    def _is_move_token_enabled(
        self, player: Player, *, action_id: str | None = None
    ) -> str | None:
        error = self.guard_turn_action_enabled(player)
        if error:
            return error
        assert isinstance(player, TroublePlayer)
        if player.last_roll == 0:
            return "trouble-reason-not-rolled"
        if action_id is None:
            return None
        token_number = int(action_id.split("_")[-1])
        if token_number not in player.legal_move_tokens:
            token = self._token(player, token_number)
            if token is None:
                return "trouble-reason-blocked"
            if token.zone == TokenZone.FINISHED:
                return "trouble-reason-token-finished"
            if token.zone == TokenZone.HOME:
                if self.options.six_to_leave_home:
                    return "trouble-reason-token-home-needs-six"
                return "trouble-reason-token-home-no-qualifying-roll"
            return "trouble-reason-blocked"
        return None

    def _is_move_token_hidden(
        self, player: Player, *, action_id: str | None = None
    ) -> Visibility:
        vis = self.turn_action_visibility(player)
        if vis != Visibility.VISIBLE:
            return vis
        assert isinstance(player, TroublePlayer)
        if player.last_roll == 0:
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _is_check_board_enabled(self, player: Player) -> str | None:
        return self.guard_game_active()

    def _is_check_board_hidden(self, player: Player) -> Visibility:
        if self.status != "playing":
            return Visibility.HIDDEN
        return Visibility.VISIBLE

    def _get_token_label(self, player: Player, action_id: str) -> str:
        assert isinstance(player, TroublePlayer)
        token_number = int(action_id.split("_")[-1])
        token = self._token(player, token_number)
        user = self.get_user(player)
        locale = user.locale if user else "en"
        if token is None:
            return Localization.get(
                locale, "trouble-token-label-home", token=token_number
            )
        return self._format_token_label(token, locale)

    def _format_token_label(self, token: Token, locale: str) -> str:
        if token.zone == TokenZone.HOME:
            return Localization.get(
                locale, "trouble-token-label-home", token=token.token_number
            )
        if token.zone == TokenZone.TRACK:
            return Localization.get(
                locale,
                "trouble-token-label-track",
                token=token.token_number,
                position=token.position + 1,  # 1-based for speech
            )
        if token.zone == TokenZone.FINISH_LANE:
            return Localization.get(
                locale,
                "trouble-token-label-finish-lane",
                token=token.token_number,
                position=token.position,
                total=FINISH_LANE_LENGTH,
            )
        return Localization.get(
            locale, "trouble-token-label-finished", token=token.token_number
        )

    # ---------------- Action handlers ----------------

    def _action_roll(self, player: Player, action_id: str) -> None:
        del action_id
        assert isinstance(player, TroublePlayer)
        roll = random.randint(1, 6)  # nosec B311
        player.last_roll = roll
        self.broadcast_l("trouble-rolled", player=player.name, roll=roll)

        # Compute which tokens can legally move with this roll.
        legal = self._compute_legal_move_tokens(player, roll)
        player.legal_move_tokens = legal

        if not legal:
            self.broadcast_l("trouble-no-legal-move", player=player.name)
            # Classic Hasbro rule: a 6 still grants another turn even when
            # the rolled player has no legal move to make with it.
            gave_extra_turn = self.options.extra_turn_on_six and roll == 6
            self._end_turn_after_move(player, gave_extra_turn=gave_extra_turn)
            return

        # If there's exactly one legal move, auto-apply it — consistent with
        # how blind-first games usually handle forced moves (no tedious menu).
        if len(legal) == 1:
            self._perform_move(player, legal[0])
            return

        # Multiple legal moves — update menus so the player can pick.
        self.update_all_menus()
        if player.is_bot:
            BotHelper.jolt_bot(player, ticks=random.randint(10, 20))  # nosec B311

    def _action_move_token(self, player: Player, action_id: str) -> None:
        assert isinstance(player, TroublePlayer)
        if player.last_roll == 0:
            return
        token_number = int(action_id.split("_")[-1])
        if token_number not in player.legal_move_tokens:
            return
        self._perform_move(player, token_number)

    def _action_check_board(self, player: Player, action_id: str) -> None:
        del action_id
        user = self.get_user(player)
        if user is None:
            return
        desc = self._describe_full_board(player, user.locale)
        user.speak(desc, buffer="game")

    # ---------------- Move execution ----------------

    def _perform_move(self, player: TroublePlayer, token_number: int) -> None:
        """Apply the legal move for `token_number` on player's current roll,
        narrate the outcome, then advance the turn (with extra-turn
        handling) or end the game if someone just finished."""
        token = self._token(player, token_number)
        assert token is not None
        engine = self._build_engine()
        opponent_tokens = self._opponent_tokens_for_seat(player.seat_index)
        roll = player.last_roll
        result = engine.simulate_move(
            seat_index=player.seat_index,
            token=token,
            roll=roll,
            opponent_tokens=opponent_tokens,
            six_to_leave_home=self.options.six_to_leave_home,
        )
        if not result.legal:
            # Shouldn't happen — legal_move_tokens was computed by the same
            # engine. If it does, swallow safely instead of crashing.
            return

        # Apply result to our token
        prev_zone = token.zone
        engine.apply_move(token, result)

        # Handle bump: reset the bumped token to Home.
        bumped_info: tuple[TroublePlayer, Token] | None = None
        if (
            result.bumped_owner_seat is not None
            and result.bumped_token_number is not None
        ):
            bumped_player = self._player_by_seat(result.bumped_owner_seat)
            if bumped_player is not None:
                bumped_token = self._token(
                    bumped_player, result.bumped_token_number
                )
                if bumped_token is not None:
                    bumped_token.zone = TokenZone.HOME
                    bumped_token.position = 0
                    bumped_info = (bumped_player, bumped_token)

        # Broadcast the move.
        self._announce_move(
            player=player,
            token=token,
            prev_zone=prev_zone,
            bumped_info=bumped_info,
        )

        # Detect win: all of this player's tokens finished.
        if self._player_has_finished_all(player):
            game_over = self._maybe_announce_end_game(player)
            if game_over:
                return
            # In team mode, the whole team may not have finished yet, so
            # fall through and end the turn normally.

        # Reset roll; advance to next turn (extra turn on 6 if enabled).
        gave_extra_turn = (
            self.options.extra_turn_on_six and roll == 6
        )
        self._end_turn_after_move(player, gave_extra_turn=gave_extra_turn)

    def _announce_move(
        self,
        *,
        player: TroublePlayer,
        token: Token,
        prev_zone: TokenZone,
        bumped_info: tuple[TroublePlayer, Token] | None,
    ) -> None:
        if prev_zone == TokenZone.HOME and token.zone == TokenZone.TRACK:
            self.broadcast_l(
                "trouble-leave-home",
                player=player.name,
                token=token.token_number,
            )
        elif token.zone == TokenZone.TRACK:
            self.broadcast_l(
                "trouble-advance-track",
                player=player.name,
                token=token.token_number,
                position=token.position + 1,  # 1-based
            )
        elif token.zone == TokenZone.FINISH_LANE:
            if prev_zone == TokenZone.TRACK:
                self.broadcast_l(
                    "trouble-enter-finish-lane",
                    player=player.name,
                    token=token.token_number,
                )
            else:
                self.broadcast_l(
                    "trouble-advance-finish-lane",
                    player=player.name,
                    token=token.token_number,
                    position=token.position,
                    total=FINISH_LANE_LENGTH,
                )
        elif token.zone == TokenZone.FINISHED:
            self.broadcast_l(
                "trouble-token-finished",
                player=player.name,
                token=token.token_number,
            )

        if bumped_info is not None:
            bumped_player, bumped_token = bumped_info
            self.broadcast_l(
                "trouble-bump",
                player=player.name,
                token=token.token_number,
                opponent=bumped_player.name,
                opp_token=bumped_token.token_number,
            )

    def _end_turn_after_move(
        self, player: TroublePlayer, *, gave_extra_turn: bool
    ) -> None:
        player.last_roll = 0
        player.legal_move_tokens = []
        if gave_extra_turn:
            self.broadcast_l("trouble-extra-turn", player=player.name)
            BotHelper.jolt_bots(self, ticks=random.randint(15, 25))  # nosec B311
            self._start_turn()
        else:
            self.end_turn()

    def end_turn(self) -> None:
        BotHelper.jolt_bots(self, ticks=random.randint(15, 25))  # nosec B311
        self._on_turn_end()

    # ---------------- Legal-move computation ----------------

    def _compute_legal_move_tokens(
        self, player: TroublePlayer, roll: int
    ) -> list[int]:
        engine = self._build_engine()
        opponent_tokens = self._opponent_tokens_for_seat(player.seat_index)
        legal: list[int] = []
        for token in player.tokens:
            result = engine.simulate_move(
                seat_index=player.seat_index,
                token=token,
                roll=roll,
                opponent_tokens=opponent_tokens,
                six_to_leave_home=self.options.six_to_leave_home,
            )
            if result.legal:
                legal.append(token.token_number)
        return legal

    # ---------------- End game ----------------

    def _player_has_finished_all(self, player: TroublePlayer) -> bool:
        return all(t.zone == TokenZone.FINISHED for t in player.tokens)

    def _maybe_announce_end_game(self, last_player: TroublePlayer) -> bool:
        """Broadcast end-of-game/personal-finish messages. Returns True if
        the game is over, False if play continues (team mode, partner
        still has tokens out)."""
        if self.options.team_mode == "individual":
            self.broadcast_l("trouble-winner", player=last_player.name)
            self.finish_game()
            return True

        winning_team = self._check_team_victory()
        if winning_team is not None:
            self.broadcast_l("trouble-team-winner", team=winning_team)
            self.finish_game()
            return True

        # Team play continues: announce this player's personal completion
        # as informative context and keep the game going.
        self.broadcast_l(
            "trouble-final-standing",
            player=last_player.name,
            finished=self.tokens_per_player,
            total=self.tokens_per_player,
        )
        return False

    def _check_team_victory(self) -> str | None:
        """Return the team name that has finished, or None."""
        for team in self._team_manager.teams:
            if not team.members:
                continue
            all_finished = True
            for member_name in team.members:
                p = self._player_by_name(member_name)
                if p is None or not self._player_has_finished_all(p):
                    all_finished = False
                    break
            if all_finished:
                return self._team_manager.get_team_name(team)
        return None

    # ---------------- Speech — board descriptions ----------------

    def _describe_turn_summary(
        self, viewer: TroublePlayer, locale: str
    ) -> str:
        own = viewer
        own_home = sum(1 for t in own.tokens if t.zone == TokenZone.HOME)
        own_track = sum(
            1
            for t in own.tokens
            if t.zone in (TokenZone.TRACK, TokenZone.FINISH_LANE)
        )
        own_finished = sum(
            1 for t in own.tokens if t.zone == TokenZone.FINISHED
        )

        opponent_strs: list[str] = []
        for p in self.get_active_players():
            if p is own:
                continue
            home = sum(1 for t in p.tokens if t.zone == TokenZone.HOME)
            track = sum(
                1
                for t in p.tokens
                if t.zone in (TokenZone.TRACK, TokenZone.FINISH_LANE)
            )
            finished = sum(1 for t in p.tokens if t.zone == TokenZone.FINISHED)
            opponent_strs.append(
                Localization.get(
                    locale,
                    "trouble-opponent-summary",
                    name=p.name,
                    home=home,
                    track=track,
                    finished=finished,
                )
            )
        return Localization.get(
            locale,
            "trouble-turn-summary",
            own_home=own_home,
            own_track=own_track,
            own_finished=own_finished,
            opponents="; ".join(opponent_strs) if opponent_strs else "none",
        )

    def _describe_full_board(self, viewer: TroublePlayer, locale: str) -> str:
        own_descs = [self._format_token_label(t, locale) for t in viewer.tokens]
        opp_descs: list[str] = []
        for p in self.get_active_players():
            if p is viewer:
                continue
            for t in p.tokens:
                opp_descs.append(
                    f"{p.name} {self._format_token_label(t, locale)}"
                )
        return Localization.get(
            locale,
            "trouble-board-status",
            own_tokens="; ".join(own_descs),
            opp_tokens="; ".join(opp_descs) if opp_descs else "none",
        )

    # ---------------- Helpers ----------------

    def _token(
        self, player: TroublePlayer, token_number: int
    ) -> Token | None:
        for t in player.tokens:
            if t.token_number == token_number:
                return t
        return None

    def _opponent_tokens_for_seat(
        self, seat_index: int
    ) -> list[tuple[int, Token]]:
        """All tokens on the board tagged with their owner's seat_index."""
        out: list[tuple[int, Token]] = []
        for p in self.get_active_players():
            if p.seat_index == seat_index:
                continue
            for t in p.tokens:
                out.append((p.seat_index, t))
        return out

    def _player_by_seat(self, seat_index: int) -> TroublePlayer | None:
        for p in self.get_active_players():
            if p.seat_index == seat_index:
                return p
        return None

    def _player_by_name(self, name: str) -> TroublePlayer | None:
        for p in self.get_active_players():
            if p.name == name:
                return p
        return None

    # ---------------- Bot ----------------

    def bot_think(self, player: TroublePlayer) -> str | None:
        return bot_think(self, player)

    # ---------------- Preset / option application ----------------

    def apply_preset_to_options(self, preset_id: str) -> bool:
        """Apply a preset's values to self.options. Returns True on success.

        Called by the options-handling layer when the host selects a preset.
        After applying, the preset field stays at preset_id (even if a later
        override would make it a "custom" match; see recompute_preset_tag).
        """
        if preset_id == "custom":
            return False
        ok = apply_preset(self.options, preset_id)
        if ok:
            self.options.preset = preset_id
        return ok

    def recompute_preset_tag(self) -> None:
        """Refresh self.options.preset based on current option values.

        If the current options exactly match a preset, set preset to that id.
        Otherwise set preset to 'custom'. Call after any individual option
        change to keep the preset tag honest.
        """
        matched = matching_preset_id(self.options)
        self.options.preset = matched if matched is not None else "custom"

    # ---------------- Game result ----------------

    def build_game_result(self) -> GameResult:
        active = self.get_active_players()
        standings: dict[str, int] = {}
        for p in active:
            finished = sum(1 for t in p.tokens if t.zone == TokenZone.FINISHED)
            standings[p.name] = finished
        winner_name: str | None = None
        top = -1
        for name, count in standings.items():
            if count > top:
                top = count
                winner_name = name
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
                "standings": standings,
                "track_size": self.track_length,
                "tokens_per_player": self.tokens_per_player,
                "preset": self.options.preset,
                "team_mode": self.options.team_mode,
            },
        )

    def format_end_screen(self, result: GameResult, locale: str) -> list[str]:
        lines: list[str] = []
        standings = result.custom_data.get("standings", {})
        for name, count in standings.items():
            lines.append(
                Localization.get(
                    locale,
                    "trouble-final-standing",
                    player=name,
                    finished=count,
                    total=self.tokens_per_player,
                )
            )
        winner = result.custom_data.get("winner_name")
        if winner:
            lines.append(
                Localization.get(locale, "trouble-winner", player=winner)
            )
        return lines
