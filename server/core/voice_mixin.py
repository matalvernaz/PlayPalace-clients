"""Server-side voice chat handlers, mixed into Server.

Table voice is server-authoritative: the server mints LiveKit join tokens for
current table members, tracks presence, announces connect/leave to the table
(respecting each listener's ignore list), gates muted users, and tears voice
down when a member leaves the table. The media itself flows client<->SFU; the
game server never carries audio.

Expects the host Server to provide ``_users``, ``_tables``, ``_db``, ``_voice``
(VoiceService) and the voice state initialized in ``Server.__init__``:
``_voice_rate_limiter``, ``_voice_presence_by_user``,
``_voice_join_authorizations_by_user`` and ``_voice_context_resolvers``.
"""

from __future__ import annotations

import asyncio
import time

from ..messages.localization import Localization
from ..voice import VoiceAuthorizationError, VoiceContext

VOICE_CHAT_JOIN_SOUND = "voice_join.ogg"
VOICE_CHAT_LEAVE_SOUND = "voice_leave.ogg"
# A join token authorizes presence only briefly: the client must report
# "connected" within this window of being granted the token.
VOICE_JOIN_AUTHORIZATION_WINDOW_SECONDS = 120


class VoiceMixin:
    # ------------------------------------------------------------------ context

    def _resolve_table_voice_context(self, user, packet: dict) -> VoiceContext:
        """Resolve the caller's table into a VoiceContext, or raise if ineligible."""
        table_id = str(packet.get("context_id") or packet.get("table_id") or "").strip()
        table = (
            self._tables.get_table(table_id)
            if table_id
            else self._tables.find_user_table(user.username)
        )
        if not table:
            raise VoiceAuthorizationError("voice-not-in-context" if table_id else "voice-not-at-table")
        if not any(member.username == user.username for member in table.members):
            raise VoiceAuthorizationError("voice-not-in-context")
        if table_id and table.table_id != table_id:
            raise VoiceAuthorizationError("voice-not-in-context")
        return VoiceContext(
            scope="table",
            context_id=table.table_id,
            room_label=Localization.get(user.locale, "voice-room-table-label", game=table.game_type),
            metadata={"context_id": table.table_id, "scope": "table"},
        )

    # --------------------------------------------------------------------- mute

    def _get_voice_mute_error(self, username: str):
        """Return (message_key, params) if the user is muted, else None."""
        now = int(time.time())
        mute = self._db.get_active_mute(username, now)
        if not mute:
            return None
        if mute.expires_at is None:
            return "voice-muted-permanent", {}
        remaining = mute.expires_at - now
        if remaining < 60:
            return "voice-muted-seconds", {"seconds": str(remaining + 1)}
        return "voice-muted-minutes", {"minutes": str(remaining // 60 + 1)}

    # ----------------------------------------------------- join authorizations

    def _record_voice_join_authorization(self, username: str, *, scope: str, context_id: str) -> None:
        self._voice_join_authorizations_by_user[username] = {
            "scope": scope,
            "context_id": context_id,
            "expires_at": asyncio.get_running_loop().time() + VOICE_JOIN_AUTHORIZATION_WINDOW_SECONDS,
        }

    def _clear_voice_join_authorization(self, username: str) -> None:
        self._voice_join_authorizations_by_user.pop(username, None)

    def _consume_voice_join_authorization(self, username: str, *, scope: str, context_id: str) -> bool:
        auth = self._voice_join_authorizations_by_user.get(username)
        if not auth:
            return False
        expires_at = auth.get("expires_at")
        if not isinstance(expires_at, float) or asyncio.get_running_loop().time() > expires_at:
            self._clear_voice_join_authorization(username)
            return False
        if auth.get("scope") != scope or auth.get("context_id") != context_id:
            return False
        self._clear_voice_join_authorization(username)
        return True

    # ----------------------------------------------------------------- handlers

    async def _handle_voice_join(self, client, packet: dict) -> None:
        user = self._users.get(client.username)
        if not user:
            return
        self._clear_voice_join_authorization(user.username)
        if not self._voice_rate_limiter.try_consume(user.username):
            await self._send_voice_error(user, "voice-rate-limited")
            return
        mute_error = self._get_voice_mute_error(user.username)
        if mute_error:
            key, params = mute_error
            await self._send_voice_error(user, key, **params)
            return
        scope = str(packet.get("scope") or "table").strip().lower()
        resolver = self._voice_context_resolvers.get(scope)
        if not resolver:
            await self._send_voice_error(user, "voice-invalid-context")
            return
        try:
            context = resolver(user, packet)
            response = self._voice.create_join_packet(
                context=context,
                identity=user.uuid,
                display_name=user.username,
                metadata={"username": user.username},
            )
        except VoiceAuthorizationError as error:
            await self._send_voice_error(user, str(error) or "voice-unavailable")
            return
        self._record_voice_join_authorization(
            user.username, scope=context.scope, context_id=context.context_id
        )
        await client.send(response)

    async def _handle_voice_presence(self, client, packet: dict) -> None:
        user = self._users.get(client.username)
        if not user:
            return
        state = str(packet.get("state") or "").strip().lower()
        if state == "connected":
            await self._register_voice_presence(user, packet)
        elif state in ("connection_lost", "disconnected") and self._voice_presence_matches(
            user.username,
            scope=str(packet.get("scope") or "table").strip().lower(),
            context_id=str(packet.get("context_id") or "").strip(),
        ):
            await self._disconnect_user_from_voice(
                user.username,
                message_key="voice-status-connection-lost",
                send_context_closed=False,
            )

    async def _handle_voice_leave(self, client, packet: dict) -> None:
        scope = str(packet.get("scope") or "table").strip().lower()
        context_id = str(packet.get("context_id") or "").strip()
        self._clear_voice_join_authorization(client.username)
        if self._voice_presence_matches(client.username, scope=scope, context_id=context_id):
            await self._disconnect_user_from_voice(
                client.username,
                message_key="voice-status-disconnected",
                send_context_closed=False,
            )
        await client.send({"type": "voice_leave_ack", "scope": scope, "context_id": context_id})

    # ----------------------------------------------------------------- presence

    async def _register_voice_presence(self, user, packet: dict) -> None:
        scope = str(packet.get("scope") or "table").strip().lower()
        context_id = str(packet.get("context_id") or "").strip()
        resolver = self._voice_context_resolvers.get(scope)
        if not resolver:
            return
        try:
            context = resolver(user, packet)
        except VoiceAuthorizationError:
            return
        if context_id and context.context_id != context_id:
            return
        if self._get_voice_mute_error(user.username):
            self._clear_voice_join_authorization(user.username)
            await self._send_voice_context_closed(user, scope=context.scope, context_id=context.context_id)
            return
        if not self._consume_voice_join_authorization(
            user.username, scope=context.scope, context_id=context.context_id
        ):
            return
        existing = self._voice_presence_by_user.get(user.username)
        if existing and existing.get("scope") == context.scope and existing.get("context_id") == context.context_id:
            return
        if existing:
            await self._clear_voice_presence(user.username, "", broadcast=False)
        self._voice_presence_by_user[user.username] = {
            "scope": context.scope,
            "context_id": context.context_id,
        }
        table = self._tables.get_table(context.context_id) if context.scope == "table" else None
        await self._broadcast_voice_presence_event(table, user.username, "voice-status-connected")

    async def _disconnect_user_from_voice(self, username: str, *, message_key: str, send_context_closed: bool = True) -> bool:
        presence = self._voice_presence_by_user.get(username)
        self._clear_voice_join_authorization(username)
        if not presence:
            return False
        user = self._users.get(username)
        scope = str(presence.get("scope") or "table")
        context_id = str(presence.get("context_id") or "")
        table = self._tables.get_table(context_id) if scope == "table" else None
        if send_context_closed and user:
            await self._send_voice_context_closed(user, scope=scope, context_id=context_id)
        await self._clear_voice_presence(username, message_key, table=table)
        return True

    async def _clear_voice_presence(self, username: str, message_key: str, *, table=None, broadcast: bool = True) -> bool:
        self._clear_voice_join_authorization(username)
        presence = self._voice_presence_by_user.pop(username, None)
        if not presence:
            return False
        if table is None and presence.get("scope") == "table":
            table = self._tables.get_table(presence.get("context_id", ""))
        if broadcast and message_key:
            await self._broadcast_voice_presence_event(table, username, message_key)
        return True

    def _voice_presence_matches(self, username: str, *, scope: str, context_id: str) -> bool:
        presence = self._voice_presence_by_user.get(username)
        if not presence:
            return False
        if not context_id:
            return True
        return presence.get("scope") == scope and presence.get("context_id") == context_id

    async def _broadcast_voice_presence_event(self, table, actor_username: str, message_key: str) -> None:
        if not table:
            return
        sound_name = VOICE_CHAT_JOIN_SOUND if message_key == "voice-status-connected" else VOICE_CHAT_LEAVE_SOUND
        for member in table.members:
            member_user = self._users.get(member.username)
            if not member_user or not member_user.approved:
                continue
            # Respect the listener's ignore list: don't surface someone they ignore.
            if member_user.username != actor_username and member_user.preferences.is_ignored(actor_username):
                continue
            member_user.speak_l(message_key, buffer="system", player=actor_username)
            if sound_name:
                member_user.play_sound(sound_name)

    # ------------------------------------------------------------------- output

    async def _send_voice_error(self, user, message_key: str, **params) -> None:
        await user.connection.send({"type": "voice_join_error", "key": message_key})
        user.speak_l(message_key, buffer="system", **params)

    async def _send_voice_context_closed(self, user, *, scope: str, context_id: str) -> None:
        await user.connection.send(
            {"type": "voice_context_closed", "scope": scope, "context_id": context_id}
        )

    # --------------------------------------------------------- lifecycle hooks

    def on_table_member_removed(self, table, username: str, *, voice_reason: str = "voice-status-left-table") -> None:
        """Tear a member out of voice when they leave a table (sync entry point)."""
        try:
            loop = asyncio.get_running_loop()
        except RuntimeError:
            return
        removed_user = self._users.get(username)
        if removed_user:
            loop.create_task(
                self._send_voice_context_closed(removed_user, scope="table", context_id=table.table_id)
            )
        self._clear_voice_join_authorization(username)
        if username not in self._voice_presence_by_user:
            return
        loop.create_task(self._clear_voice_presence(username, voice_reason, table=table))
