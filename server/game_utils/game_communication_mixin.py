"""Mixin providing communication helpers for games."""

from typing import TYPE_CHECKING, Callable

if TYPE_CHECKING:
    from ..games.base import Game, Player
    from server.core.users.base import User

from ..gender import Gender, normalize_gender
from ..messages.localization import Localization


class GameCommunicationMixin:
    """Provide message broadcasting and localization helpers.

    Expected Game attributes:
        players: list[Player].
        get_user(player) -> User | None.
    """

    def broadcast(self, text: str, buffer: str = "table", exclude: "Player | None" = None) -> None:
        """Send a message to all players, optionally excluding one."""
        for player in self.players:
            if player is exclude:
                continue
            if hasattr(self, "record_transcript_event"):
                self.record_transcript_event(player, text, buffer)
            user = self.get_user(player)
            if user:
                user.speak(text, buffer)

    def broadcast_l(
        self,
        message_id: str,
        buffer: str = "table",
        exclude: "Player | None" = None,
        **kwargs,
    ) -> None:
        """Send a localized message to all players (each in their own locale)."""
        for player in self.players:
            if player is exclude:
                continue
            user = self.get_user(player)
            locale = user.locale if user else "en"
            # Resolve once per listener so the transcript and the spoken line agree.
            resolved = self._resolve_broadcast_kwargs(locale, kwargs)
            localized = Localization.get(locale, message_id, **resolved)
            if hasattr(self, "record_transcript_event"):
                self.record_transcript_event(player, localized, buffer)
            if user:
                user.speak_l(message_id, buffer, **resolved)

    def broadcast_personal_l(
        self,
        player: "Player",
        personal_message_id: str,
        others_message_id: str,
        buffer: str = "table",
        **kwargs,
    ) -> None:
        """
        Send a personalized message to one player and a different message to everyone else.

        The player receives personal_message_id, while all other players receive
        others_message_id with an additional player=player.name argument.

        Args:
            player: The player who gets the personal message.
            personal_message_id: Message ID for the player (e.g., "you-rolled").
            others_message_id: Message ID for everyone else (e.g., "player-rolled").
            buffer: Audio buffer for speech.
            **kwargs: Additional arguments passed to all speak_l calls.
        """
        user = self.get_user(player)
        locale = user.locale if user else "en"
        personal_kwargs = self._resolve_broadcast_kwargs(locale, kwargs)
        personal_text = Localization.get(locale, personal_message_id, **personal_kwargs)
        if hasattr(self, "record_transcript_event"):
            self.record_transcript_event(player, personal_text, buffer)
        if user:
            user.speak_l(personal_message_id, buffer, **personal_kwargs)

        for p in self.players:
            if p is player:
                continue
            u = self.get_user(p)
            locale = u.locale if u else "en"
            others_kwargs = self._resolve_broadcast_kwargs(locale, {**kwargs, "player": player})
            others_text = Localization.get(locale, others_message_id, **others_kwargs)
            if hasattr(self, "record_transcript_event"):
                self.record_transcript_event(p, others_text, buffer)
            if u:
                u.speak_l(others_message_id, buffer, **others_kwargs)

    def get_player_gender(self, player: "Player") -> Gender:
        """Return the account gender for a seat.

        Our accounts have no gender field yet, so humans and bots alike are
        unspecified and messages use the neutral forms ("their", "they").
        """
        user = self.get_user(player)
        if user is not None and not player.is_bot:
            return normalize_gender(getattr(user, "gender", None))
        return Gender.UNSPECIFIED

    def _resolve_broadcast_kwargs(self, locale: str, kwargs: dict) -> dict:
        """Resolve per-locale values and add player gender selectors.

        Ported from PlayAural's gender-aware localization. Callable values are
        evaluated once for this listener's locale. A value that is a seat, or
        uniquely names one, gains a sibling <name>_gender selector for
        GENDER_TERM; an explicit gender argument always wins.
        """
        resolved = {name: value(locale) if callable(value) else value for name, value in kwargs.items()}
        players_by_name: dict[str, list["Player"]] = {}
        for seat in self.players:
            players_by_name.setdefault(seat.name, []).append(seat)

        for name, value in list(resolved.items()):
            matched_player = None
            if any(value is seat for seat in self.players):
                matched_player = value
                resolved[name] = value.name
            elif isinstance(value, str):
                candidates = players_by_name.get(value, [])
                if len(candidates) == 1:
                    matched_player = candidates[0]
                elif candidates:
                    resolved.setdefault(f"{name}_gender", Gender.UNSPECIFIED.selector)
            if matched_player is not None:
                resolved.setdefault(f"{name}_gender", self.get_player_gender(matched_player).selector)
        return resolved

    def label_l(self, message_id: str) -> Callable[["Game", "Player"], str]:
        """
        Create a localized label callable for use in action definitions.

        Usage:
            self.define_action("roll", label=self.label_l("pig-roll"), ...)
        """

        def get_label(game: "Game", player: "Player") -> str:
            """Resolve a localized label for the player's locale."""
            user = game.get_user(player)
            locale = user.locale if user else "en"
            return Localization.get(locale, message_id)

        return get_label
