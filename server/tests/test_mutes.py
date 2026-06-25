"""Tests for the mute moderation primitive (Database mute/unmute/get_active_mute)."""

import pytest

from server.persistence.database import Database


@pytest.fixture
def db(tmp_path):
    database = Database(db_path=tmp_path / "mutes.db")
    database.connect()
    try:
        yield database
    finally:
        database.close()


def test_mute_then_get_active(db):
    record = db.mute_user("Alice", "Admin", "spam", issued_at=100, expires_at=200)
    assert record.username == "Alice"
    assert record.admin_username == "Admin"
    assert record.reason == "spam"
    assert record.expires_at == 200

    active = db.get_active_mute("Alice", now=150)
    assert active is not None
    assert active.id == record.id
    assert active.reason == "spam"


def test_expired_mute_is_not_active(db):
    db.mute_user("Alice", "Admin", "spam", issued_at=100, expires_at=200)
    assert db.get_active_mute("Alice", now=200) is None  # lapses at expires_at
    assert db.get_active_mute("Alice", now=250) is None


def test_permanent_mute_never_expires(db):
    db.mute_user("Alice", "Admin", "", issued_at=100, expires_at=None)
    assert db.get_active_mute("Alice", now=10_000_000) is not None


def test_unmute_removes_mute(db):
    db.mute_user("Alice", "Admin", "", issued_at=100, expires_at=None)
    assert db.unmute_user("Alice") is True
    assert db.get_active_mute("Alice", now=150) is None
    assert db.unmute_user("Alice") is False  # already gone


def test_mute_lookup_and_unmute_are_case_insensitive(db):
    db.mute_user("Alice", "Admin", "", issued_at=100, expires_at=None)
    assert db.get_active_mute("alice", now=150) is not None
    assert db.unmute_user("ALICE") is True
    assert db.get_active_mute("Alice", now=150) is None


def test_remute_replaces_existing(db):
    db.mute_user("Alice", "Admin", "first", issued_at=100, expires_at=200)
    db.mute_user("Alice", "Mod", "second", issued_at=300, expires_at=None)

    active = db.get_active_mute("Alice", now=400)
    assert active is not None
    assert active.admin_username == "Mod"
    assert active.reason == "second"
    assert active.expires_at is None

    cursor = db._get_conn().cursor()
    cursor.execute("SELECT COUNT(*) FROM mutes WHERE lower(username) = lower(?)", ("Alice",))
    assert cursor.fetchone()[0] == 1


def test_get_muted_usernames_lists_active_only(db):
    db.mute_user("Alice", "Admin", "", issued_at=100, expires_at=None)   # permanent
    db.mute_user("Bob", "Admin", "", issued_at=100, expires_at=500)      # timed, active
    db.mute_user("Carol", "Admin", "", issued_at=100, expires_at=200)    # lapses at 200

    assert set(db.get_muted_usernames(now=300)) == {"Alice", "Bob"}
