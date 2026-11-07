"""Table management for games."""

from dataclasses import dataclass, field
from typing import TYPE_CHECKING, Any

from mashumaro.mixins.json import DataClassJSONMixin

from server.game_utils.game_status import GameStatus

if TYPE_CHECKING:
    from server.games.base import Game
    from server.users.base import User
    from server.core.tables.manager import TableManager
    from server.core.server import Server
    from server.persistence.database import Database


@dataclass
class TableMember:
    """Member of a table (player or spectator).

    Attributes:
        username: Member username.
        is_spectator: True if spectating.
    """

    username: str
    is_spectator: bool = False


@dataclass
class Table(DataClassJSONMixin):
    """Game table holding members and a game instance.

    Tables track membership and forward events to the game. Role logic
    (player vs spectator) is handled by the game.
    """

    table_id: str
    game_type: str
    host: str
    members: list[TableMember] = field(default_factory=list)
    game_json: str | None = None  # Serialized game state
    status: str = GameStatus.WAITING
    # Game format of the stored game_json (persistence/game_format.py); '' for
    # rows written before the marker existed.
    game_engine: str = ""

    # Not serialized
    _game: "Game | None" = field(default=None, repr=False)
    _users: dict[str, "User"] = field(default_factory=dict, repr=False)
    _manager: "TableManager | None" = field(default=None, repr=False)
    _server: "Server | None" = field(default=None, repr=False)
    _db: "Database | None" = field(default=None, repr=False)

    def __post_init__(self):
        """Initialize non-serialized runtime references."""
        self._game = None
        self._users = {}
        self._manager = None
        self._server = None
        self._db = None
        # PlayAural's engine reads when each member dropped offline, to hold
        # their seat during a reconnect grace period. This server has no such
        # grace period, so it stays empty.
        self._member_offline_since: dict[str, float] = {}

    @property
    def game(self) -> "Game | None":
        """Return the current game instance."""
        return self._game

    @game.setter
    def game(self, value: "Game | None") -> None:
        """Set the game instance and update serialized state."""
        self._game = value
        if value:
            self.game_json = value.to_json()

    def add_member(self, username: str, user: "User", as_spectator: bool = False) -> None:
        """Add a member to the table.

        Args:
            username: Member username.
            user: User instance.
            as_spectator: True to join as spectator.
        """
        # Check if already a member
        for member in self.members:
            if member.username == username:
                return

        self.members.append(TableMember(username=username, is_spectator=as_spectator))
        self._users[username] = user

    def remove_member(self, username: str) -> None:
        """Remove a member from the table."""
        self.members = [m for m in self.members if m.username != username]
        self._users.pop(username, None)

        # Notify the server so it can tear the member out of voice chat.
        server = getattr(self, "_server", None)
        if server is not None:
            server.on_table_member_removed(self, username)

        # Destroy table if it's empty
        if not self.members:
            self.destroy()

    def get_user(self, username: str) -> "User | None":
        """Get a user by username."""
        return self._users.get(username)

    def attach_user(self, username: str, user: "User") -> None:
        """Attach a user to a member (e.g., after deserialization)."""
        self._users[username] = user

    def get_players(self) -> list[TableMember]:
        """Get all non-spectator members."""
        return [m for m in self.members if not m.is_spectator]

    def get_spectators(self) -> list[TableMember]:
        """Get all spectator members."""
        return [m for m in self.members if m.is_spectator]

    @property
    def player_count(self) -> int:
        """Get the number of players (non-spectators)."""
        return len(self.get_players())

    def broadcast(self, text: str, buffer: str = "misc") -> None:
        """Send a message to all members."""
        for username, user in self._users.items():
            user.speak(text, buffer)

    def broadcast_sound(self, name: str, volume: int = 100) -> None:
        """Play a sound for all members."""
        for user in self._users.values():
            user.play_sound(name, volume)

    def on_tick(self) -> None:
        """Called every tick. Forwards to game, then paints dirty menus."""
        if self._game:
            self._game.on_tick()
            self._game.flush_menus()

    def handle_event(self, username: str, event: dict) -> None:
        """Handle an event from a member."""
        if self._game:
            # Find the player
            for player in self._game.players:
                if player.name == username:
                    self._game.handle_event(player, event)
                    break

    def save_game_state(self) -> None:
        """Save the current game state to game_json."""
        if self._game:
            self.game_json = self._game.to_json()

    def can_start(self, min_players: int) -> bool:
        """Check if the game can start."""
        return self.player_count >= min_players

    def destroy(self) -> None:
        """Destroy this table. Called by Game.destroy()."""
        if self._manager:
            self._manager.on_table_destroy(self)

    def save_and_close(self, username: str) -> None:
        """Save game state and close table. Called by game save action."""
        if self._server:
            self._server.on_table_save(self, username)

    def save_game_result(
        self,
        result: Any,
        *,
        rating_updates: dict[str, tuple[float, float]] | None = None,
    ) -> None:
        """Save a game result, and the rating changes the game worked out, to the database."""
        if self._server:
            self._server.on_game_result(result, rating_updates=rating_updates)

    # What PlayAural's game engine expects from its table. Their table also
    # tracks power-restore grace and per-member offline time; this server has
    # neither, so those answers are fixed.

    def is_power_restore_grace_active(self) -> bool:
        """This server has no planned-reboot recovery window."""
        return False

    def has_online_spectator_host(self) -> bool:
        """Return whether the table's host is here, connected, and watching rather than playing."""
        host_member = next((member for member in self.members if member.username == self.host), None)
        if host_member is None or not host_member.is_spectator:
            return False
        table_user = self._users.get(self.host)
        if table_user is None or getattr(table_user, "is_bot", False):
            return False
        if self._server is None:
            return True
        return self._server._users.get(self.host) is table_user

    def reserved_names(self, *, exclude_player_id: str | None = None) -> list[str]:
        """Return every name in use at this table, so a new bot never takes one."""
        from server.game_utils.bot_names import normalize_bot_name

        names = [member.username for member in self.members]
        if self._game:
            for player in self._game.players:
                if getattr(player, "id", None) == exclude_player_id:
                    continue
                names.append(player.name)
                replaced_name = getattr(player, "replaced_human_name", "")
                if replaced_name:
                    names.append(replaced_name)
        return [name for name in names if normalize_bot_name(name)]

    def reset_game(self, *, preserve_scheduled_sounds: bool = True) -> bool:
        """Put the table back in the lobby with a fresh game after one finishes.

        Adapted from PlayAural's Table.reset_game: the same members, roles,
        bots, host and options carry over, players who left during the end of
        the game are dropped, and each player's end-of-game screen stays open
        on top of the new lobby. Returns False when there's nobody left, in
        which case the table is destroyed.
        """
        from server.games.registry import get_game_class
        from server.users.bot import Bot

        old_game = self._game
        if not old_game:
            return False
        game_class = get_game_class(self.game_type)
        if not game_class:
            return False

        # A waiting lobby never owns background audio.
        old_game.stop_replayable_audio(fade_ms=0, play_ambience_outros=False)
        old_options = getattr(old_game, "options", None)
        end_screen_state = None
        if hasattr(old_game, "_export_end_screen_state"):
            end_screen_state = old_game._export_end_screen_state()

        # Drop members who disconnected while the game was ending.
        valid_members = []
        for member in self.members:
            user = self._users.get(member.username)
            if user and (getattr(user, "is_bot", False) or self._server is None or member.username in self._server._users):
                valid_members.append(member)
                continue
            self._users.pop(member.username, None)
        self.members = valid_members

        # Humans come from the member list; bots from the old game.
        active_players = []
        active_spectators = []
        for member in self.members:
            user = self._users.get(member.username)
            if not user:
                continue
            if member.is_spectator:
                active_spectators.append((user.uuid, member.username, user))
            else:
                active_players.append((user.uuid, member.username, user))
        active_bots = []
        for player in old_game.players:
            if not player.is_bot:
                continue
            user = old_game._users.get(player.id)
            if not user:
                continue
            if getattr(player, "replaced_human", False):
                user = Bot(player.name)
            active_bots.append((user.uuid, player.name, player.bot_name_base, user))

        # Keep the host if they're still here, otherwise promote someone.
        old_host = self.host
        host_present = any(name == self.host for _, name, _ in active_players + active_spectators)
        if not host_present:
            candidates = active_players or active_spectators
            if not candidates:
                self.destroy()
                return False
            if self._server:
                candidates = sorted(candidates, key=lambda entry: entry[1] in self._server._users, reverse=True)
            self.host = candidates[0][1]

        # A fresh game with the same options.
        new_game = game_class()
        if old_options is not None and hasattr(new_game, "options"):
            new_game.options = type(new_game.options).from_dict(old_options.to_dict())
        new_game._table = self
        self._game = new_game
        new_game.host = self.host
        new_game.status = "waiting"
        new_game.setup_keybinds()

        def restore_member(uuid_text: str, name: str, user: Any, *, is_spectator: bool) -> None:
            """Reattach a member without replaying join sounds or announcements."""
            restored = new_game.create_player(uuid_text, name, is_bot=False)
            restored.is_spectator = is_spectator
            new_game.players.append(restored)
            new_game.attach_user(restored.id, user)
            new_game.setup_player_actions(restored)

        for uuid_text, name, user in active_players:
            restore_member(uuid_text, name, user, is_spectator=False)
        for uuid_text, name, user in active_spectators:
            restore_member(uuid_text, name, user, is_spectator=True)
        for uuid_text, name, base_name, user in active_bots:
            bot_player = new_game.create_player(uuid_text, name, is_bot=True)
            bot_player.bot_name_base = base_name
            new_game.players.append(bot_player)
            new_game.attach_user(bot_player.id, user)
            new_game.setup_player_actions(bot_player)
        new_game.ensure_bot_display_names()

        if old_host != self.host:
            new_game.broadcast_l("table-new-host-promoted", buffer="system", player=self.host)

        # Only the normal game-over flow keeps the delayed victory sounds.
        if preserve_scheduled_sounds:
            new_game.scheduled_sounds = list(old_game.scheduled_sounds)
            new_game.sound_scheduler_tick = old_game.sound_scheduler_tick
        if hasattr(new_game, "_import_end_screen_state"):
            new_game._import_end_screen_state(end_screen_state)

        # Retire the old game so its ticks and callbacks can't touch the table.
        old_game._destroyed = True
        try:
            old_game.on_discard()
        except Exception:
            import logging

            logging.getLogger("playpalace.tables").exception("Cleanup failed while replacing a finished game")
        old_game.active_audio.clear()

        self.status = "waiting"
        self.game_json = new_game.to_json()
        return True
