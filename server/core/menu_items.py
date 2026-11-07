"""Menu rows that carry structured metadata for our clients.

PlayAural's MenuItem has no metadata, but our clients read it: the iOS app
filters the tables list and the online users list by the host or username in
``meta`` so it can hide people you've ignored without parsing localized text.
"""

from dataclasses import dataclass
from typing import Any

from ..users.base import MenuItem


@dataclass
class MetaMenuItem(MenuItem):
    """A menu row with a ``meta`` dict sent alongside its text and id."""

    meta: dict[str, Any] | None = None

    def to_dict(self, *, locale: str = "en", show_description: bool = False) -> dict[str, Any] | str:
        data = super().to_dict(locale=locale, show_description=show_description)
        if not self.meta:
            return data
        if isinstance(data, str):
            data = {"text": data}
        data["meta"] = self.meta
        return data
