"""Tests for the Batch C lifecycle/concurrency hardening.

Focused on the table-tick isolation, which is the highest-value change: one
game raising in on_tick must not abort the whole server tick (which also
flushes queued messages and persists state).
"""

from server.core.tables.manager import TableManager


class _FakeTable:
    def __init__(self, table_id, members=("alice",), raise_on_tick=False):
        self.table_id = table_id
        self.members = list(members)
        self._raise = raise_on_tick
        self.ticked = 0
        self.destroyed = False

    def on_tick(self):
        if self._raise:
            raise RuntimeError("boom")
        self.ticked += 1

    def destroy(self):
        self.destroyed = True


def test_on_tick_isolates_failing_table():
    mgr = TableManager()
    bad = _FakeTable("bad", raise_on_tick=True)
    good = _FakeTable("good")
    mgr._tables = {"bad": bad, "good": good}

    mgr.on_tick()  # must not raise despite bad.on_tick raising

    assert good.ticked == 1  # the healthy table still ticked


def test_on_tick_destroys_empty_table():
    mgr = TableManager()
    empty = _FakeTable("empty", members=())
    mgr._tables = {"empty": empty}

    mgr.on_tick()

    assert empty.destroyed is True
