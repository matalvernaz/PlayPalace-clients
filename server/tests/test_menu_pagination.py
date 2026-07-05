"""Tests for paginated server menus."""

from types import SimpleNamespace

from server.core.administration import AdministrationMixin
from server.core.menu_pagination import (
    DEFAULT_MENU_PAGE_SIZE,
    MENU_PAGE_FIRST,
    MENU_PAGE_LAST,
    MENU_PAGE_NEXT,
    MENU_PAGE_PREVIOUS,
    clamp_page,
    page_for_selection,
    paginate_sequence,
    total_pages_for,
)
from server.core.users.network_user import NetworkUser


class DummyConnection:
    """Minimal stand-in for a websocket connection."""


class _AdminHost(AdministrationMixin):
    """Just enough host to exercise the user-list menu helper."""

    def __init__(self):
        self._user_states = {}

    def _show_main_menu(self, user):  # pragma: no cover - not reached
        pass


def _records(count: int) -> list[SimpleNamespace]:
    return [SimpleNamespace(username=f"user{i:03d}") for i in range(count)]


def test_total_pages_and_clamping():
    assert total_pages_for(0, 100) == 1
    assert total_pages_for(100, 100) == 1
    assert total_pages_for(101, 100) == 2
    assert clamp_page(0, 250, 100) == 1
    assert clamp_page(99, 250, 100) == 3
    assert clamp_page("bogus", 250, 100) == 1


def test_page_for_selection_navigation():
    assert page_for_selection(MENU_PAGE_FIRST, 3, 5) == 1
    assert page_for_selection(MENU_PAGE_PREVIOUS, 3, 5) == 2
    assert page_for_selection(MENU_PAGE_NEXT, 3, 5) == 4
    assert page_for_selection(MENU_PAGE_LAST, 3, 5) == 5
    assert page_for_selection("something_else", 3, 5) is None
    # Out-of-range current pages are clamped before navigating.
    assert page_for_selection(MENU_PAGE_NEXT, 99, 5) == 5


def test_paginate_sequence_bounds():
    data = list(range(150))
    first = paginate_sequence(data, 1)
    assert first.items == data[:DEFAULT_MENU_PAGE_SIZE]
    assert first.total_pages == 2
    assert first.start_index == 1 and first.end_index == 100
    assert first.has_next and not first.has_previous

    second = paginate_sequence(data, 2)
    assert second.items == data[100:]
    assert second.start_index == 101 and second.end_index == 150
    assert second.has_previous and not second.has_next

    clamped = paginate_sequence(data, 99)
    assert clamped.page == 2


def test_user_list_menu_paginates_and_navigates():
    host = _AdminHost()
    viewer = NetworkUser("boss", "en", DummyConnection())
    records = _records(150)

    host._show_user_list_menu(
        viewer, "ban_user_menu", records, "ban", reshow="_show_ban_user_menu"
    )
    packet = viewer.get_queued_messages()[0]
    ids = [item["id"] for item in packet["items"] if isinstance(item, dict)]
    assert ids[0] == "page_summary"
    assert sum(1 for i in ids if i.startswith("ban_")) == 100
    assert MENU_PAGE_NEXT in ids and MENU_PAGE_LAST in ids
    assert MENU_PAGE_FIRST not in ids and MENU_PAGE_PREVIOUS not in ids
    assert ids[-1] == "back"

    state = host._user_states["boss"]
    assert state["page"] == 1 and state["pages"] == 2
    assert state["page_reshow"] == "_show_ban_user_menu"

    # Simulate the router intercept moving to page 2 and re-showing.
    state["page"] = page_for_selection(MENU_PAGE_NEXT, state["page"], state["pages"])
    host._show_user_list_menu(
        viewer, "ban_user_menu", records, "ban", reshow="_show_ban_user_menu"
    )
    packet = viewer.get_queued_messages()[0]
    ids = [item["id"] for item in packet["items"] if isinstance(item, dict)]
    assert sum(1 for i in ids if i.startswith("ban_")) == 50
    assert MENU_PAGE_FIRST in ids and MENU_PAGE_PREVIOUS in ids
    assert MENU_PAGE_NEXT not in ids and MENU_PAGE_LAST not in ids
    assert host._user_states["boss"]["page"] == 2


def test_user_list_menu_short_list_has_no_controls():
    host = _AdminHost()
    viewer = NetworkUser("boss", "en", DummyConnection())

    host._show_user_list_menu(
        viewer, "ban_user_menu", _records(5), "ban", reshow="_show_ban_user_menu"
    )
    packet = viewer.get_queued_messages()[0]
    ids = [item["id"] for item in packet["items"] if isinstance(item, dict)]
    assert ids[0].startswith("ban_")
    assert not any(i.startswith("page_") for i in ids)
