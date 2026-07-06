"""Tests for the Batch D persistence-robustness changes.

Covers the safe-JSON helper, DiceSet load validation, corrupt-row tolerance
in load_all_tables, and the atomic save_all_tables snapshot.
"""

import pytest

from server.game_utils.dice import DiceSet
from server.persistence.database import Database, _safe_json_load


def test_safe_json_load():
    assert _safe_json_load(None, []) == []
    assert _safe_json_load("", {}) == {}
    assert _safe_json_load("[1, 2]", []) == [1, 2]
    assert _safe_json_load("{not valid", []) == []


def test_diceset_discards_inconsistent_values():
    # Too-short values list -> treated as unrolled (no IndexError on roll).
    assert DiceSet(num_dice=5, sides=6, values=[1, 2, 3]).values == []
    # Out-of-range value -> reset.
    assert DiceSet(num_dice=2, sides=6, values=[7, 1]).values == []
    # Consistent, in-range values preserved.
    assert DiceSet(num_dice=3, sides=6, values=[1, 2, 3]).values == [1, 2, 3]


def test_diceset_filters_out_of_range_indices():
    d = DiceSet(num_dice=3, sides=6, values=[1, 2, 3], kept=[0, 9], locked=[-1, 2])
    assert d.kept == {0}
    assert d.locked == {2}


def test_diceset_bad_load_then_roll_no_indexerror():
    d = DiceSet.from_dict({"num_dice": 5, "sides": 6, "values": [1, 2]})
    assert d.has_rolled is False
    result = d.roll()  # must not IndexError
    assert len(result) == 5


@pytest.fixture
def db(tmp_path):
    database = Database(str(tmp_path / "t.db"))
    database.connect()
    yield database
    database.close()


def test_load_all_tables_skips_corrupt_row(db):
    cur = db._conn.cursor()
    cur.execute(
        "INSERT INTO tables (table_id, game_type, host, members_json, game_json, status) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        ("good1234", "pig", "alice", '[{"username": "alice", "is_spectator": false}]', "{}", "waiting"),
    )
    cur.execute(
        "INSERT INTO tables (table_id, game_type, host, members_json, game_json, status) "
        "VALUES (?, ?, ?, ?, ?, ?)",
        ("bad12345", "pig", "bob", "{not valid json", "{}", "waiting"),
    )
    db._conn.commit()

    ids = {t.table_id for t in db.load_all_tables()}
    assert "good1234" in ids
    assert "bad12345" not in ids


def test_save_all_tables_persists_snapshot(db):
    from server.core.tables.table import Table, TableMember

    table = Table(
        table_id="t1",
        game_type="pig",
        host="alice",
        members=[TableMember(username="alice", is_spectator=False)],
        game_json="{}",
        status="waiting",
    )
    db.save_all_tables([table])

    assert any(t.table_id == "t1" for t in db.load_all_tables())
