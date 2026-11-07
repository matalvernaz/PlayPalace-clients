"""Saved games carry a format marker, and restores accept only the current engine's.

Games saved before the switch to PlayAural's engine still deserialize: missing
fields take defaults and unknown ones are dropped, so the game would come back
silently wrong. Every save records persistence/game_format.py's marker, startup
moves a live table it can't use into retired_tables (kept, never retried), and
restoring a user's saved game rebuilds it before anything is created, rolling
back fully if anything fails afterwards.
"""

from __future__ import annotations

import asyncio
import json
import sqlite3
from types import SimpleNamespace

import pytest

import server.games  # noqa: F401  (registers every game)
from server.core.server import Server
from server.core.tables.table import Table, TableMember
from server.games.pig.game import PigGame
from server.persistence.database import Database
from server.persistence.game_format import GAME_ENGINE_FORMAT
from server.users.bot import Bot
from server.users.test_user import MockUser

# A Pig game as the old engine saved it, trimmed and with the player names
# replaced. PlayAural's engine deserializes it without complaint, which is
# exactly why the marker is needed.
OLD_ENGINE_PIG = json.dumps(
    {
        "players": [],
        "status": "waiting",
        "host": "Host",
        "event_queue": [],
        "is_animating": False,
    }
)


def new_engine_pig_json() -> str:
    game = PigGame()
    game.add_player("Host", MockUser("Host"))
    game.add_player("Robo", Bot("Robo"))
    return game.to_json()


def make_db(tmp_path) -> Database:
    database = Database(tmp_path / "playpalace.db")
    database.connect()
    return database


def insert_live_row(database: Database, table_id: str, game_json: str, game_engine: str) -> None:
    connection = database._get_conn()
    connection.execute(
        "INSERT INTO tables (table_id, game_type, host, members_json, game_json, status, game_engine) VALUES (?, ?, ?, ?, ?, ?, ?)",
        (table_id, "pig", "Host", json.dumps([{"username": "Host", "is_spectator": False}]), game_json, "waiting", game_engine),
    )
    connection.commit()


def row_counts(database: Database, table_id: str) -> tuple[int, int]:
    connection = database._get_conn()
    live = connection.execute("SELECT COUNT(*) FROM tables WHERE table_id = ?", (table_id,)).fetchone()[0]
    retired = connection.execute("SELECT COUNT(*) FROM retired_tables WHERE table_id = ?", (table_id,)).fetchone()[0]
    return live, retired


def server_on(database: Database, tmp_path) -> Server:
    srv = Server(host="127.0.0.1", port=0, db_path=tmp_path / "unused.sqlite")
    srv._db = database
    srv._tables._server = srv
    return srv


# Startup restore of live tables.


def test_startup_retires_a_table_saved_by_the_old_engine(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "old1", OLD_ENGINE_PIG, "")
    srv = server_on(database, tmp_path)

    srv._load_tables()

    assert srv._tables.get_table("old1") is None
    assert row_counts(database, "old1") == (0, 1)
    reason = database._get_conn().execute("SELECT reason FROM retired_tables WHERE table_id = 'old1'").fetchone()[0]
    assert "older game engine" in reason


def test_retired_table_is_not_seen_again_on_the_next_boot_or_save(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "old1", OLD_ENGINE_PIG, "")
    server_on(database, tmp_path)._load_tables()

    second = server_on(database, tmp_path)
    second._load_tables()
    second._save_tables()

    assert second._tables.get_table("old1") is None
    assert row_counts(database, "old1") == (0, 1)


def test_startup_retires_a_game_that_fails_to_load(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "broken", "{not json", GAME_ENGINE_FORMAT)
    srv = server_on(database, tmp_path)

    srv._load_tables()

    assert srv._tables.get_table("broken") is None
    assert row_counts(database, "broken") == (0, 1)


def test_startup_restores_and_registers_a_current_table_with_its_bots(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "new1", new_engine_pig_json(), GAME_ENGINE_FORMAT)
    srv = server_on(database, tmp_path)

    srv._load_tables()

    table = srv._tables.get_table("new1")
    assert table is not None and table.game is not None
    robo = table.game.get_player_by_name("Robo")
    assert robo is not None and table.game.get_user(robo) is not None
    assert row_counts(database, "new1") == (1, 0)


def test_unknown_game_type_is_retired_not_registered(tmp_path, monkeypatch):
    database = make_db(tmp_path)
    insert_live_row(database, "gone", new_engine_pig_json(), GAME_ENGINE_FORMAT)
    monkeypatch.setattr("server.core.server.get_game_class", lambda _game_type: None)
    srv = server_on(database, tmp_path)

    srv._load_tables()

    assert srv._tables.get_table("gone") is None
    assert row_counts(database, "gone") == (0, 1)


# The marker on every save path.


def test_live_save_writes_the_marker_and_survives_a_restart(tmp_path):
    database = make_db(tmp_path)
    table = Table(table_id="t1", game_type="pig", host="Host", members=[TableMember("Host")])
    table.game_json = new_engine_pig_json()
    database.save_all_tables([table])
    database.close()

    reopened = make_db(tmp_path)
    loaded = reopened.load_table("t1")
    assert loaded.game_engine == GAME_ENGINE_FORMAT
    srv = server_on(reopened, tmp_path)
    srv._load_tables()
    assert srv._tables.get_table("t1") is not None


def test_saving_an_existing_row_writes_the_marker_instead_of_resetting_it(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "t1", new_engine_pig_json(), "")
    table = database.load_table("t1")
    database.save_table(table)
    stored = database._get_conn().execute("SELECT game_engine FROM tables WHERE table_id = 't1'").fetchone()[0]
    assert stored == GAME_ENGINE_FORMAT


def test_user_save_records_the_marker(tmp_path):
    database = make_db(tmp_path)
    record = database.save_user_table("Host", "Pig", "pig", new_engine_pig_json(), "[]")
    assert record.game_engine == GAME_ENGINE_FORMAT
    assert database.get_saved_table(record.id).game_engine == GAME_ENGINE_FORMAT
    assert database.get_user_saved_tables("Host")[0].game_engine == GAME_ENGINE_FORMAT


def test_migration_adds_the_marker_to_an_old_database(tmp_path):
    path = tmp_path / "old.db"
    connection = sqlite3.connect(path)
    connection.execute(
        "CREATE TABLE tables (table_id TEXT PRIMARY KEY, game_type TEXT NOT NULL, host TEXT NOT NULL, members_json TEXT NOT NULL, game_json TEXT, status TEXT DEFAULT 'waiting')"
    )
    connection.execute(
        "CREATE TABLE saved_tables (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT NOT NULL, save_name TEXT NOT NULL, game_type TEXT NOT NULL, game_json TEXT NOT NULL, members_json TEXT NOT NULL, saved_at TEXT NOT NULL)"
    )
    connection.execute("INSERT INTO tables VALUES ('old', 'pig', 'Host', '[]', '{}', 'waiting')")
    connection.commit()
    connection.close()

    database = Database(path)
    database.connect()

    for name in ("tables", "saved_tables"):
        columns = [row[1] for row in database._get_conn().execute(f"PRAGMA table_info({name})")]
        assert "game_engine" in columns
    assert database._get_conn().execute("SELECT game_engine FROM tables").fetchone()[0] == ""


# Retiring is all or nothing.


def test_retiring_rolls_back_completely_if_the_delete_fails(tmp_path):
    database = make_db(tmp_path)
    insert_live_row(database, "t1", OLD_ENGINE_PIG, "")
    real_connection = database._get_conn()

    class FailingDelete:
        """Connection stand-in whose DELETE fails, like a crash between the two statements."""

        def __getattr__(self, name):
            return getattr(real_connection, name)

        def __enter__(self):
            real_connection.__enter__()
            return self

        def __exit__(self, *details):
            return real_connection.__exit__(*details)

        def execute(self, sql, *args):
            if sql.lstrip().startswith("DELETE"):
                raise sqlite3.OperationalError("disk I/O error")
            return real_connection.execute(sql, *args)

    database._get_conn = lambda: FailingDelete()
    with pytest.raises(sqlite3.OperationalError):
        database.retire_table("t1", "test")
    database._get_conn = lambda: real_connection

    assert row_counts(database, "t1") == (1, 0)


# Restoring a user's saved game.


def saved_record(game_engine: str, game_json: str | None = None) -> SimpleNamespace:
    return SimpleNamespace(
        id=7,
        game_type="pig",
        members_json=json.dumps([{"username": "Host", "is_bot": False}]),
        game_json=game_json if game_json is not None else new_engine_pig_json(),
        game_engine=game_engine,
    )


class SavedTablesDB:
    def __init__(self, record):
        self.record = record
        self.deleted: list[int] = []

    def get_saved_table(self, save_id):
        return self.record if self.record and self.record.id == save_id else None

    def delete_saved_table(self, save_id):
        self.deleted.append(save_id)


def restoring_server(tmp_path, record) -> tuple[Server, MockUser, dict]:
    srv = Server(host="127.0.0.1", port=0, db_path=tmp_path / "unused.sqlite")
    srv._db = SavedTablesDB(record)
    user = MockUser("Host")
    srv._users = {"Host": user}
    shown = {}
    srv._show_saved_tables_menu = lambda _user: shown.setdefault("saved_menu", True)
    return srv, user, shown


@pytest.mark.parametrize("marker", ["", "playaural-0"])
def test_restoring_an_old_save_creates_nothing_and_keeps_the_save(tmp_path, marker):
    srv, user, shown = restoring_server(tmp_path, saved_record(marker))
    srv._user_states["Host"] = {"menu": "saved_table_actions_menu"}

    asyncio.run(srv._restore_saved_table(user, 7))

    assert srv._tables.find_user_table("Host") is None
    assert srv._tables.get_all_tables() == []
    assert srv._db.deleted == []
    assert srv._user_states["Host"] == {"menu": "saved_table_actions_menu"}
    assert shown.get("saved_menu")


def test_restoring_a_save_that_fails_to_load_creates_nothing(tmp_path):
    srv, user, _ = restoring_server(tmp_path, saved_record(GAME_ENGINE_FORMAT, game_json="{not json"))

    asyncio.run(srv._restore_saved_table(user, 7))

    assert srv._tables.get_all_tables() == []
    assert srv._db.deleted == []


def test_a_failure_after_the_table_exists_is_rolled_back(tmp_path, monkeypatch):
    srv, user, _ = restoring_server(tmp_path, saved_record(GAME_ENGINE_FORMAT))
    srv._user_states["Host"] = {"menu": "saved_table_actions_menu"}

    def explode(self):
        raise RuntimeError("keybinds failed")

    monkeypatch.setattr(PigGame, "setup_keybinds", explode)
    asyncio.run(srv._restore_saved_table(user, 7))

    assert srv._tables.get_all_tables() == []
    assert srv._tables.find_user_table("Host") is None
    assert srv._user_states["Host"] == {"menu": "saved_table_actions_menu"}
    assert srv._db.deleted == []

    # Nothing is left half-done, so a good save restores straight after.
    monkeypatch.undo()
    asyncio.run(srv._restore_saved_table(user, 7))
    assert srv._tables.find_user_table("Host") is not None
    assert srv._db.deleted == [7]
