"""Network user implementation for real players."""

import time
from typing import Any, TYPE_CHECKING

from .base import User, MenuItem, EscapeBehavior, TrustLevel, generate_uuid
from .preferences import UserPreferences

if TYPE_CHECKING:
    from ...network.websocket_server import ClientConnection

# Internal marker for a menu position restored from stored menu state rather
# than requested by the caller. Stripped from packets before they reach the
# wire; the flush coalescer must not treat restored positions as explicit
# focus intent.
_STICKY_POSITION_MARKER = "_sticky_position"


def _menu_content(state: dict[str, Any]) -> dict[str, Any]:
    """The fields of a stored menu state that the client renders.

    ``position`` is excluded: it is a one-shot focus directive, not content,
    and a repaint that omits it must still be skippable against a stored
    state that recorded one.
    """
    return {k: v for k, v in state.items() if k != "position"}


class NetworkUser(User):
    """
    Network implementation of User for real players connected via websocket.

    Queues messages to be sent asynchronously by the network layer.
    """

    def __init__(
        self,
        username: str,
        locale: str,
        connection: "ClientConnection",
        uuid: str | None = None,
        preferences: UserPreferences | None = None,
        trust_level: TrustLevel = TrustLevel.USER,
        approved: bool = False,
        fluent_languages: list[str] | None = None,
    ):
        """Initialize a network-backed user session."""
        self._uuid = uuid or generate_uuid()
        self._username = username
        self._locale = locale
        self._connection = connection
        self._preferences = preferences or UserPreferences()
        self._trust_level = trust_level
        self._approved = approved
        self._fluent_languages: list[str] = fluent_languages or []
        self._message_queue: list[dict[str, Any]] = []
        self._connected_at: float = time.time()
        self._client_type: str = ""
        self._platform: str = ""

        # Track current UI state for session resumption
        self._current_menus: dict[str, dict[str, Any]] = {}
        # The menu_id of the last menu packet actually sent; the content-diff
        # skip only applies to repaints of this menu.
        self._last_menu_packet_id: str | None = None
        self._current_editboxes: dict[str, dict[str, Any]] = {}
        self._current_music: dict[str, Any] | None = None

    @property
    def uuid(self) -> str:
        """Return the user's UUID."""
        return self._uuid

    @property
    def username(self) -> str:
        """Return the user's display name."""
        return self._username

    @property
    def locale(self) -> str:
        """Return the user's locale."""
        return self._locale

    def set_locale(self, locale: str) -> None:
        """Set the user's locale."""
        self._locale = locale

    @property
    def trust_level(self) -> TrustLevel:
        """Return the user's trust level."""
        return self._trust_level

    @property
    def approved(self) -> bool:
        """Return True if the user is approved."""
        return self._approved

    def set_approved(self, approved: bool) -> None:
        """Set the user's approval status."""
        self._approved = approved

    def set_trust_level(self, trust_level: TrustLevel) -> None:
        """Set the user's trust level."""
        self._trust_level = trust_level

    @property
    def preferences(self) -> UserPreferences:
        """Return the user's preferences."""
        return self._preferences

    def set_preferences(self, preferences: UserPreferences) -> None:
        """Set the user's preferences."""
        self._preferences = preferences

    @property
    def connection(self) -> "ClientConnection":
        """Return the underlying client connection."""
        return self._connection

    def set_connection(self, connection: "ClientConnection") -> None:
        # A fresh socket has no UI; the next menu paint must go out in full.
        self._last_menu_packet_id = None
        """Update the active client connection."""
        self._connection = connection

    @property
    def client_type(self) -> str:
        """Return the client type (e.g. 'Desktop', 'Web')."""
        return self._client_type

    def set_client_type(self, client_type: str) -> None:
        """Set the client type."""
        self._client_type = client_type

    @property
    def platform(self) -> str:
        """Return the client platform string."""
        return self._platform

    def set_platform(self, platform: str) -> None:
        """Set the client platform string."""
        self._platform = platform

    @property
    def fluent_languages(self) -> list[str]:
        """Return the user's fluent languages."""
        return self._fluent_languages

    def set_fluent_languages(self, languages: list[str]) -> None:
        """Set the user's fluent languages."""
        self._fluent_languages = languages

    def format_time_online(self) -> str:
        """Format the time this user has been connected."""
        elapsed = time.time() - self._connected_at
        minutes = int(elapsed // 60)
        hours = int(elapsed // 3600)
        days = int(elapsed // 86400)
        if hours < 1:
            return f"{max(minutes, 1)}m"
        if hours < 24:
            return f"{hours}h"
        remaining_hours = hours % 24
        return f"{days}d {remaining_hours}h"

    def _queue_packet(self, packet: dict[str, Any]) -> None:
        """Queue a packet to be sent to the client."""
        self._message_queue.append(packet)

    def queue_packet(self, packet: dict[str, Any]) -> None:
        """Public helper to queue a raw packet for delivery."""
        self._queue_packet(packet)

    def get_queued_messages(self) -> list[dict[str, Any]]:
        """Get and clear the message queue, coalescing redundant menu repaints.

        When more than one ``menu`` packet for the same ``menu_id`` is queued
        in a single flush — e.g. an action handler rebuilds a menu and the
        event framework rebuilds it again on the same tick — only the last one
        survives. This collapses double-sends (duplicate screen-reader
        announcements and focus churn) without games having to police their
        own rebuild calls. The batch's most recent explicit focus directive
        (``selection_id`` or a caller-supplied ``position``) is carried onto
        the surviving repaint; positions restored from stored menu state do
        not count as explicit. Non-menu packets, and menus with distinct ids,
        pass through untouched and in order.
        """
        messages = self._message_queue
        self._message_queue = []

        last_menu_index: dict[str, int] = {}
        last_focus: dict[str, dict[str, Any]] = {}
        for i, packet in enumerate(messages):
            if packet.get("type") != "menu":
                continue
            menu_id = packet.get("menu_id")
            if menu_id is None:
                continue
            last_menu_index[menu_id] = i
            if self._has_explicit_focus(packet):
                last_focus[menu_id] = {
                    "selection_id": packet.get("selection_id"),
                    "position": packet.get("position"),
                }

        if not last_menu_index:
            return messages

        coalesced: list[dict[str, Any]] = []
        for i, packet in enumerate(messages):
            if packet.get("type") == "menu":
                menu_id = packet.get("menu_id")
                if menu_id is not None:
                    if last_menu_index[menu_id] != i:
                        continue  # superseded by a later repaint of the same menu
                    focus = last_focus.get(menu_id)
                    if focus is not None and not self._has_explicit_focus(packet):
                        # Carry the batch's latest explicit focus onto the
                        # surviving repaint without mutating the original.
                        packet = {**packet}
                        if focus["selection_id"] is not None:
                            packet["selection_id"] = focus["selection_id"]
                        if focus["position"] is not None:
                            packet["position"] = focus["position"]
                if _STICKY_POSITION_MARKER in packet:
                    packet = {
                        k: v
                        for k, v in packet.items()
                        if k != _STICKY_POSITION_MARKER
                    }
            coalesced.append(packet)
        return coalesced

    @staticmethod
    def _has_explicit_focus(packet: dict[str, Any]) -> bool:
        """Whether a menu packet carries caller-requested focus.

        A position restored from stored menu state (sticky marker) is not
        explicit intent.
        """
        if packet.get("selection_id") is not None:
            return True
        return (
            packet.get("position") is not None
            and not packet.get(_STICKY_POSITION_MARKER)
        )

    def speak(self, text: str, buffer: str = "misc") -> None:
        """Queue a speech message for the client."""
        packet = {"type": "speak", "text": text}
        if buffer != "misc":
            packet["buffer"] = buffer
        self._queue_packet(packet)

    def play_sound(self, name: str, volume: int = 100, pan: int = 0, pitch: int = 100) -> None:
        """Queue a sound effect for the client."""
        self._queue_packet(
            {
                "type": "play_sound",
                "name": name,
                "volume": volume,
                "pan": pan,
                "pitch": pitch,
            }
        )

    def play_music(self, name: str, looping: bool = True) -> None:
        """Start background music for the client."""
        self._current_music = {"name": name, "looping": looping}
        self._queue_packet(
            {
                "type": "play_music",
                "name": name,
                "looping": looping,
            }
        )

    def stop_music(self) -> None:
        """Stop background music for the client."""
        self._current_music = None
        self._queue_packet({"type": "stop_music"})

    def play_ambience(self, loop: str, intro: str = "", outro: str = "") -> None:
        """Play ambient audio for the client."""
        self._queue_packet(
            {
                "type": "play_ambience",
                "intro": intro,
                "loop": loop,
                "outro": outro,
            }
        )

    def stop_ambience(self) -> None:
        """Stop ambient audio for the client."""
        self._queue_packet({"type": "stop_ambience"})

    def _convert_items(self, items: list[str | MenuItem]) -> list[str | dict]:
        """Convert MenuItem objects to dicts for JSON serialization."""
        result = []
        for item in items:
            if isinstance(item, MenuItem):
                result.append(item.to_dict())
            else:
                result.append(item)
        return result

    def show_menu(
        self,
        menu_id: str,
        items: list[str | MenuItem],
        *,
        multiletter: bool = True,
        escape_behavior: EscapeBehavior = EscapeBehavior.KEYBIND,
        position: int | None = None,
        grid_enabled: bool = False,
        grid_width: int = 1,
        play_selection_sound: bool = False,
        help_text: str | None = None,
        primary_action_id: str | None = None,
    ) -> None:
        """Send a menu definition to the client.

        Always sends full config so the client can correctly deduplicate
        and preserve escape behavior across menu switches.
        """
        converted_items = self._convert_items(items)
        previous_menu = self._current_menus.get(menu_id)
        escape_str = escape_behavior.value

        state: dict[str, Any] = {
            "items": converted_items,
            "multiletter_enabled": multiletter,
            "escape_behavior": escape_str,
            "position": position,
            "grid_enabled": grid_enabled,
            "grid_width": grid_width,
            "play_selection_sound": play_selection_sound,
            "help_text": help_text,
            "primary_action_id": primary_action_id,
        }

        # Content-diff skip: a repaint of the menu the client is already
        # displaying, with identical content and no explicit focus directive
        # or sound cue, is a client-side no-op — don't spend a packet on it.
        # Restricted to the menu named by _last_menu_packet_id so a re-show
        # after the client moved to another menu or editbox always goes out
        # in full. Stored state is left untouched so the remembered position
        # survives.
        if (
            position is None
            and not play_selection_sound
            and menu_id == self._last_menu_packet_id
            and previous_menu is not None
            and _menu_content(previous_menu) == _menu_content(state)
        ):
            return

        sticky_position = False
        if position is None and previous_menu:
            previous_position = previous_menu.get("position")
            if isinstance(previous_position, int) and previous_position > 0:
                position = previous_position
                sticky_position = True
        state["position"] = position

        # Store for session resumption
        self._current_menus[menu_id] = state

        packet: dict[str, Any] = {
            "type": "menu",
            "menu_id": menu_id,
            "items": converted_items,
            "multiletter_enabled": multiletter,
            "escape_behavior": escape_str,
            "grid_enabled": grid_enabled,
            "grid_width": grid_width,
        }
        if position is not None:
            # Convert 1-based to 0-based for client
            packet["position"] = position - 1
            if sticky_position:
                packet[_STICKY_POSITION_MARKER] = True
        if play_selection_sound:
            packet["play_selection_sound"] = True
        if help_text is not None:
            packet["help_text"] = help_text
        if primary_action_id is not None:
            packet["primary_action_id"] = primary_action_id
        self._last_menu_packet_id = menu_id
        self._queue_packet(packet)

    def update_menu(
        self,
        menu_id: str,
        items: list[str | MenuItem],
        position: int | None = None,
        selection_id: str | None = None,
        play_selection_sound: bool = False,
    ) -> None:
        """Update an existing menu's items or selection."""
        converted_items = self._convert_items(items)

        previous = self._current_menus.get(menu_id)
        if (
            position is None
            and selection_id is None
            and not play_selection_sound
            and menu_id == self._last_menu_packet_id
            and previous is not None
            and previous.get("items") == converted_items
        ):
            return  # Content-diff skip; see show_menu.

        if menu_id in self._current_menus:
            self._current_menus[menu_id]["items"] = converted_items
            if position is not None:
                self._current_menus[menu_id]["position"] = position
            elif selection_id is not None:
                for i, item in enumerate(items, 1):
                    if isinstance(item, MenuItem) and item.id == selection_id:
                        self._current_menus[menu_id]["position"] = i
                        break

        packet: dict[str, Any] = {
            "type": "menu",
            "menu_id": menu_id,
            "items": converted_items,
        }
        if position is not None:
            packet["position"] = position - 1
        if selection_id is not None:
            packet["selection_id"] = selection_id
        if play_selection_sound:
            packet["play_selection_sound"] = True
        self._last_menu_packet_id = menu_id
        self._queue_packet(packet)

    def remove_menu(self, menu_id: str) -> None:
        """Remove a menu from the client UI."""
        self._current_menus.pop(menu_id, None)
        if self._last_menu_packet_id == menu_id:
            self._last_menu_packet_id = None
        # Send empty menu to clear it
        self._queue_packet(
            {
                "type": "menu",
                "menu_id": menu_id,
                "items": [],
            }
        )

    def show_editbox(
        self,
        input_id: str,
        prompt: str,
        default_value: str = "",
        *,
        multiline: bool = False,
        read_only: bool = False,
        content_format: str = "text",
    ) -> None:
        """Show a text input prompt on the client."""
        self._current_editboxes[input_id] = {
            "prompt": prompt,
            "default_value": default_value,
            "multiline": multiline,
            "read_only": read_only,
            "content_format": content_format,
        }
        packet: dict[str, Any] = {
            "type": "request_input",
            "input_id": input_id,
            "prompt": prompt,
            "default_value": default_value,
            "multiline": multiline,
            "read_only": read_only,
        }
        if content_format != "text":
            packet["content_format"] = content_format
        # The editbox takes the client's screen; the next menu paint must be
        # sent in full even if its content is unchanged.
        self._last_menu_packet_id = None
        self._queue_packet(packet)

    def show_document_editor(
        self,
        dialog_id: str,
        content: str = "",
        content_label: str = "",
        source_content: str | None = None,
        source_label: str | None = None,
        prompt: str = "",
    ) -> None:
        """Open the document editor dialog on the client."""
        packet: dict[str, Any] = {
            "type": "document_editor",
            "dialog_id": dialog_id,
            "content": content,
            "content_label": content_label,
            "prompt": prompt,
        }
        if source_content is not None:
            packet["source_content"] = source_content
            packet["source_label"] = source_label
        # The document editor takes the client's screen; the next menu paint
        # must be sent in full even if its content is unchanged.
        self._last_menu_packet_id = None
        self._queue_packet(packet)

    def remove_editbox(self, input_id: str) -> None:
        """Remove an editbox from the client UI."""
        self._current_editboxes.pop(input_id, None)
        # There's no explicit remove_editbox packet, showing a menu will replace it

    def clear_ui(self) -> None:
        """Clear menus, editboxes, and UI state for the client."""
        self._current_menus.clear()
        self._current_editboxes.clear()
        self._last_menu_packet_id = None
        self._queue_packet({"type": "clear_ui"})
