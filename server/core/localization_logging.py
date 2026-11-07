"""Log missing messages and formatting errors from the localization engine, once each.

PlayAural's localization returns a missing message's id, or a message with a
placeholder where a variable didn't fit, without saying anything. Those are
exactly the bugs players hear as raw ids, and on this server the log is how
they get found. This wraps two of its class methods to log each distinct
problem once, so a menu that repaints every tick can't flood the log.
"""

from __future__ import annotations

import logging

from ..messages.localization import Localization

LOG = logging.getLogger("playpalace.localization")

_already_logged: set[tuple] = set()
_installed = False


def _log_once(key: tuple, message: str, *args) -> None:
    if key in _already_logged:
        return
    _already_logged.add(key)
    # Error level: the server's log only keeps errors, and these are bugs a
    # player hears as raw ids.
    LOG.error(message, *args)


def install() -> None:
    """Wrap the engine's lookups with logging. Safe to call more than once."""
    global _installed
    if _installed:
        return
    _installed = True

    original_get = Localization.get.__func__

    def get(cls, locale: str, message_id: str, **kwargs) -> str:
        result = original_get(cls, locale, message_id, **kwargs)
        if result == message_id and not cls.has_message(locale, message_id):
            _log_once(("missing", message_id), "Missing localization message %r (locale %s)", message_id, locale)
        return result

    def format_from_bundle(cls, locale: str, message_id: str, kwargs: dict) -> str | None:
        # The engine's own _format_from_bundle, unchanged except that the
        # formatting errors it discards are logged. Formatting twice to see
        # them would double the cost of every menu row.
        bundle = cls._get_bundle(locale)
        base_id, _, attribute = message_id.partition(".")
        try:
            message = bundle.get_message(base_id)
        except KeyError:
            return None
        if message is None:
            return None
        pattern = message.attributes.get(attribute) if attribute else message.value
        if pattern is None:
            return None
        result, errors = bundle.format_pattern(pattern, kwargs)
        for error in errors:
            _log_once(("format", locale, message_id, str(error)), "Failed to format message %r (locale %s): %s", message_id, locale, error)
        for char in cls._BIDI_CHARS:
            result = result.replace(char, "")
        return result

    Localization.get = classmethod(get)
    Localization._format_from_bundle = classmethod(format_from_bundle)
