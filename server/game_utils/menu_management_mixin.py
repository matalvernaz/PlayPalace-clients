"""Mixin providing menu management functionality for games."""

from collections.abc import Callable, Sequence
from dataclasses import dataclass, field
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from ..games.base import Player, TransientDisplayState
    from server.core.users.base import User
    from .actions import ResolvedAction

from server.core.users.base import MenuItem, EscapeBehavior
from ..messages.localization import Localization

TRANSIENT_DISPLAY_MENU_ID = "transient_display"


@dataclass
class MenuBuild:
    """Turn-menu items for one player, returned by ``build_menu_items``.

    ``grid_kwargs`` carries grid layout for ``show_menu``; only the keys our
    clients understand (``grid_enabled``, ``grid_width``) are forwarded.
    """

    items: list[MenuItem]
    grid_kwargs: dict = field(default_factory=dict)


# Grid layout keys our show_menu accepts. PlayAural games may also send
# grid_height, which our clients have no use for.
_SUPPORTED_GRID_KWARGS = ("grid_enabled", "grid_width")


@dataclass
class StatusBoxBuild:
    """Status-box content with optional grid layout metadata."""

    items: Sequence[str | MenuItem]
    grid_kwargs: dict = field(default_factory=dict)


StatusBoxBuilder = Callable[
    ["Player", "User"], StatusBoxBuild | Sequence[str | MenuItem]
]


@dataclass
class LiveStatusBoxState:
    """Runtime-only builder for an open live status box."""

    box_id: str
    builder: StatusBoxBuilder


class MenuManagementMixin:
    """Build and update turn menus and status boxes.

    Expected Game attributes:
        _destroyed: bool.
        status: str.
        players: list[Player].
        _transient_display_state: dict[str, TransientDisplayState].
        get_user(player) -> User | None.
        get_all_visible_actions(player) -> list[ResolvedAction].
    """

    def _build_action_menu_items(self, player: "Player", user: "User") -> list[MenuItem]:
        """Build menu items from visible actions for a player."""
        items: list[MenuItem] = []
        for resolved in self.get_all_visible_actions(player):
            label = resolved.label
            if not resolved.enabled and resolved.action.show_disabled_label:
                unavailable = Localization.get(user.locale, "visibility-unavailable")
                label = f"{label}; {unavailable}"
            items.append(MenuItem(text=label, id=resolved.action.id, sound=resolved.sound))
        return items

    def build_menu_items(self, player: "Player", user: "User") -> MenuBuild:
        """Hook: build the turn-menu items for ``player``.

        Both the full repaint and the in-place update ask this hook, so an
        override (such as a read-only header row) survives either path. The
        default is one item per visible action, exactly as before the hook.
        """
        return MenuBuild(items=self._build_action_menu_items(player, user))

    def _turn_menu_build(self, player: "Player", user: "User") -> tuple[list[MenuItem], dict]:
        """Return the hook's items and the grid kwargs our clients support."""
        build = self.build_menu_items(player, user)
        grid_kwargs = {
            key: value for key, value in build.grid_kwargs.items() if key in _SUPPORTED_GRID_KWARGS
        }
        return build.items, grid_kwargs

    def _get_transient_display_state(self, player: "Player") -> "TransientDisplayState | None":
        """Return the open transient display state for a player, if any."""
        return self._transient_display_state.get(player.id)

    def _is_transient_display_open(self, player: "Player") -> bool:
        """Return True when a transient display is open for a player."""
        return player.id in self._transient_display_state

    def _show_transient_display(
        self,
        player: "Player",
        *,
        kind: str,
        items: list[MenuItem],
        multiletter: bool,
        path: list[str] | None = None,
        position: int | None = None,
        selection_id: str | None = None,
        grid_kwargs: dict | None = None,
    ) -> None:
        """Show a transient display menu and store its runtime state."""
        user = self.get_user(player)
        if not user:
            return

        from ..games.base import TransientDisplayState

        existing_state = self._transient_display_state.get(player.id)
        positions = existing_state.positions if existing_state else {}
        self._transient_display_state[player.id] = TransientDisplayState(
            kind=kind,
            path=list(path or []),
            positions=positions,
        )
        user.show_menu(
            TRANSIENT_DISPLAY_MENU_ID,
            items,
            multiletter=multiletter,
            escape_behavior=EscapeBehavior.SELECT_LAST,
            position=position,
            selection_id=selection_id,
            **(grid_kwargs or {}),
        )

    def _close_transient_display(
        self,
        player: "Player",
        *,
        speak_key: str | None = None,
        rebuild_menu: bool = True,
    ) -> None:
        """Close a transient display and optionally rebuild the turn menu."""
        user = self.get_user(player)
        if user:
            user.remove_menu(TRANSIENT_DISPLAY_MENU_ID)
            if speak_key:
                user.speak_l(speak_key)
        self._transient_display_state.pop(player.id, None)
        self._live_status_boxes.pop(player.id, None)
        if rebuild_menu:
            self.rebuild_player_menu(player)

    def _handle_transient_display_selection(self, player: "Player", selection_id: str) -> None:
        """Handle a selection from the shared transient display menu."""
        state = self._get_transient_display_state(player)
        if not state:
            return

        if state.kind in ("status_box", "live_status_box"):
            self._close_transient_display(player)
            return

        if state.kind == "game_options":
            handler = getattr(self, "_handle_game_options_display_selection", None)
            if handler:
                handler(player, selection_id)

    def _remember_transient_display_position(self, player: "Player", event: dict) -> None:
        """Remember the user's current position within an open transient display."""
        state = self._get_transient_display_state(player)
        if not state:
            return

        current_path_key = tuple(state.path)
        selection = event.get("selection")
        if isinstance(selection, int) and selection > 0:
            state.positions[current_path_key] = selection
            return

        selection_id = event.get("selection_id")
        if not selection_id:
            return

        user = self.get_user(player)
        if not user:
            return

        current_menus = getattr(user, "_current_menus", None)
        if isinstance(current_menus, dict):
            current_menu = current_menus.get(TRANSIENT_DISPLAY_MENU_ID)
        else:
            menus = getattr(user, "menus", None)
            current_menu = menus.get(TRANSIENT_DISPLAY_MENU_ID) if isinstance(menus, dict) else None
        if not isinstance(current_menu, dict):
            return

        items = current_menu.get("items", [])
        for index, item in enumerate(items, start=1):
            if isinstance(item, dict) and item.get("id") == selection_id:
                state.positions[current_path_key] = index
                return
            if hasattr(item, "id") and getattr(item, "id", None) == selection_id:
                state.positions[current_path_key] = index
                return

    def before_menu_build(self, player: "Player") -> None:
        """Hook: sync dynamic action sets before any menu paint.

        Called at the top of every per-player menu paint, before the
        destroyed/finished early-outs — so action sets are also refreshed
        for bots (whose menus are never rendered but whose action sets
        drive bot decisions). Must be idempotent. Default is a no-op.
        """

    def rebuild_player_menu(self, player: "Player", *, position: int | None = None) -> None:
        """Rebuild the turn menu for a player.

        Args:
            player: The player whose menu to rebuild.
            position: Optional 1-based position to focus on. Use position=1
                to reset focus to the first item. When None, the client
                preserves focus on the previously selected item by ID. This
                causes a stuck-cursor bug when an always-visible action (like
                "view pipe") shifts position as turn actions appear/disappear.
                Pass position=1 in _start_turn for the current player to avoid
                this.
        """
        self.before_menu_build(player)
        if self._destroyed:
            return
        if self.status == "finished":
            return
        if player.id in self._live_status_boxes:
            self._paint_live_status_box(player, focus_id=None)
            return
        if self._is_transient_display_open(player):
            return
        user = self.get_user(player)
        if not user:
            return

        items, grid_kwargs = self._turn_menu_build(player, user)

        help_text = None
        if hasattr(self, "get_help_text"):
            help_text = self.get_help_text(user.locale)
        primary_action_id = None
        if hasattr(self, "get_primary_action_id"):
            primary_action_id = self.get_primary_action_id(player)

        # A queued one-shot focus intent is consumed by this paint.
        selection_id = None
        if position is None:
            selection_id = self._pending_menu_focus.pop(player.id, None)

        user.show_menu(
            "turn_menu",
            items,
            multiletter=False,
            escape_behavior=EscapeBehavior.KEYBIND,
            position=position,
            selection_id=selection_id,
            help_text=help_text,
            primary_action_id=primary_action_id,
            **grid_kwargs,
        )

    def rebuild_all_menus(self) -> None:
        """Rebuild menus for all players."""
        if self._destroyed:
            return
        for player in self.players:
            self.rebuild_player_menu(player)

    def refresh_menus(self, player: "Player | None" = None) -> None:
        """Mark ``player`` (or every player) as needing a menu repaint.

        Recording only — painting happens in :meth:`flush_menus`, which the
        framework calls at the end of ``handle_event`` and once per tick.
        Over-marking is cheap: a repaint costs at most one packet per menu
        that actually changed, and identical repaints are skipped against
        the last-sent state.
        """
        if player is None:
            self._menu_dirty_all = True
        else:
            self._menu_dirty.add(player.id)

    def flush_menus(self) -> None:
        """Paint menus for players marked dirty since the last flush."""
        if self._destroyed:
            return
        if self._menu_dirty_all:
            self._menu_dirty_all = False
            self._menu_dirty.clear()
            self.rebuild_all_menus()
            return
        if not self._menu_dirty:
            return
        dirty = list(self._menu_dirty)
        self._menu_dirty.clear()
        for player_id in dirty:
            player = self.get_player_by_id(player_id)
            if player:
                self.rebuild_player_menu(player)

    def request_menu_focus(self, player: "Player", action_id: str) -> None:
        """Queue a one-shot focus jump to ``action_id`` for ``player``.

        Adapter for the PlayAural menu API. The intent is a single
        per-player slot (last writer wins) consumed by the next turn-menu
        repaint. Requesting focus also marks the player for repaint; no
        separate ``refresh_menus`` call is needed unless other players'
        menus changed too.
        """
        self._pending_menu_focus[player.id] = action_id
        self._menu_dirty.add(player.id)

    def update_player_menu(
        self,
        player: "Player",
        selection_id: str | None = None,
        play_selection_sound: bool = False,
    ) -> None:
        """Update the turn menu for a player, preserving focus position."""
        if self._destroyed:
            return
        if self.status == "finished":
            return
        if self._is_transient_display_open(player):
            return
        user = self.get_user(player)
        if not user:
            return

        items, _grid_kwargs = self._turn_menu_build(player, user)
        user.update_menu(
            "turn_menu", items, selection_id=selection_id, play_selection_sound=play_selection_sound
        )

    def update_all_menus(self) -> None:
        """Update menus for all players, preserving focus position."""
        if self._destroyed:
            return
        for player in self.players:
            self.update_player_menu(player)

    def _normalize_status_box_content(
        self,
        content: StatusBoxBuild | Sequence[str | MenuItem],
        *,
        fallback_id_prefix: str,
    ) -> tuple[list[MenuItem], dict]:
        """Normalize status-box rows and assign stable, unique item ids."""
        if isinstance(content, StatusBoxBuild):
            raw_items = content.items
            grid_kwargs = dict(content.grid_kwargs)
        else:
            raw_items = content
            grid_kwargs = {}

        items: list[MenuItem] = []
        seen_ids: dict[str, int] = {}
        for index, raw_item in enumerate(raw_items):
            if isinstance(raw_item, MenuItem):
                item = MenuItem(
                    text=raw_item.text,
                    id=raw_item.id or f"{fallback_id_prefix}:line:{index}",
                    sound=raw_item.sound,
                )
            else:
                item = MenuItem(
                    text=str(raw_item),
                    id=f"{fallback_id_prefix}:line:{index}",
                )

            seen_count = seen_ids.get(item.id, 0)
            seen_ids[item.id] = seen_count + 1
            if seen_count:
                item.id = f"{item.id}:duplicate:{seen_count}"
            items.append(item)

        return items, grid_kwargs

    def status_box(self, player: "Player", lines: list[str]) -> None:
        """Show a status box (menu with text items) to a player.

        Press Enter on any item to close. No header or close button needed
        since screen readers speak list items and Enter always closes.
        """
        self._live_status_boxes.pop(player.id, None)
        items, grid_kwargs = self._normalize_status_box_content(
            lines,
            fallback_id_prefix="status_box",
        )
        self._show_transient_display(
            player,
            kind="status_box",
            items=items,
            multiletter=False,
            grid_kwargs=grid_kwargs,
        )

    def live_status_box(
        self,
        player: "Player",
        box_id: str,
        builder: StatusBoxBuilder,
        *,
        focus_id: str | None = None,
    ) -> None:
        """Open a status box whose rows repaint when the game marks menus dirty."""
        user = self.get_user(player)
        if not user:
            return

        self._live_status_boxes[player.id] = LiveStatusBoxState(
            box_id=box_id,
            builder=builder,
        )
        self._paint_live_status_box(player, focus_id=focus_id)

    def _paint_live_status_box(
        self,
        player: "Player",
        *,
        focus_id: str | None,
    ) -> None:
        """Paint an open live status box without moving focus on passive updates."""
        state = self._live_status_boxes.get(player.id)
        user = self.get_user(player)
        if not state or not user:
            return

        content = state.builder(player, user)
        items, grid_kwargs = self._normalize_status_box_content(
            content,
            fallback_id_prefix=f"live_status:{state.box_id}",
        )
        self._show_transient_display(
            player,
            kind="live_status_box",
            items=items,
            multiletter=False,
            selection_id=focus_id,
            grid_kwargs=grid_kwargs,
        )
