"""Tests for the Batch A auth/session hardening.

Covers: ban revoking credentials, refresh-token reuse detection, the
expected-username pre-rotation check, session pruning/capping, the
missing-user timing path, and trusted-proxy gating of forwarded headers.
"""

import pytest

from server.auth.auth import AuthManager, AuthResult
from server.core.users.base import TrustLevel
from server.network.websocket_server import WebSocketServer
from server.persistence.database import Database


@pytest.fixture
def auth(tmp_path):
    db = Database(str(tmp_path / "auth.db"))
    db.connect()
    manager = AuthManager(db)
    yield manager, db
    db.close()


def _make_user(manager, db, username, *, trust=TrustLevel.USER):
    db.create_user(username, manager.hash_password("pw"), "en", trust, True)


async def test_missing_user_returns_not_found(auth):
    manager, _db = auth
    assert await manager.authenticate("ghost", "whatever") is AuthResult.USER_NOT_FOUND


def test_banned_user_cannot_refresh(auth):
    manager, db = auth
    _make_user(manager, db, "bob")
    token, _ = manager.create_refresh_token("bob", 3600)
    db.update_user_trust_level("bob", TrustLevel.BANNED)
    assert manager.refresh_session(token, 3600, 86400) is None


def test_refresh_token_reuse_within_grace_replays(auth):
    manager, db = auth
    _make_user(manager, db, "carol")
    token, _ = manager.create_refresh_token("carol", 3600)

    result = manager.refresh_session(token, 3600, 86400)
    assert result is not None
    new_token = result[3]

    # Re-presenting the just-rotated token within the grace window is a benign
    # client race: replay the rotation, handing back the SAME live successor and
    # a usable access session rather than revoking the family.
    replay = manager.refresh_session(token, 3600, 86400)
    assert replay is not None
    assert replay[0] == "carol"
    assert replay[3] == new_token
    assert manager.validate_session(replay[1]) == "carol"

    # The successor is untouched and can still be rotated for real afterwards.
    assert manager.refresh_session(new_token, 3600, 86400) is not None


def test_refresh_token_reuse_outside_grace_revokes_family(auth):
    manager, db = auth
    # Negative grace forces every rotated-token replay onto the theft path.
    manager._REFRESH_REUSE_GRACE_SECONDS = -1
    _make_user(manager, db, "carol")
    token, _ = manager.create_refresh_token("carol", 3600)

    result = manager.refresh_session(token, 3600, 86400)
    assert result is not None
    new_token = result[3]

    # Outside the grace window, replaying the already-rotated token is the
    # stolen-token signal: it must fail AND revoke the whole family, including
    # the freshly minted successor.
    assert manager.refresh_session(token, 3600, 86400) is None
    assert manager.refresh_session(new_token, 3600, 86400) is None


def test_expected_username_mismatch_does_not_rotate(auth):
    manager, db = auth
    _make_user(manager, db, "dave")
    token, _ = manager.create_refresh_token("dave", 3600)

    # Wrong hint is rejected before rotation, so the token is not burned.
    assert manager.refresh_session(token, 3600, 86400, expected_username="eve") is None
    assert manager.refresh_session(token, 3600, 86400, expected_username="dave") is not None


def test_session_cap_per_user(auth):
    manager, db = auth
    _make_user(manager, db, "frank")
    tokens = [
        manager.create_session("frank", 3600)[0]
        for _ in range(manager._MAX_SESSIONS_PER_USER + 5)
    ]
    live = [t for t in tokens if manager.validate_session(t) == "frank"]
    assert len(live) <= manager._MAX_SESSIONS_PER_USER
    # The most recent session is always retained.
    assert manager.validate_session(tokens[-1]) == "frank"


def test_expired_sessions_pruned_on_create(auth):
    manager, db = auth
    _make_user(manager, db, "gina")
    stale, _ = manager.create_session("gina", -10)  # already expired
    assert stale in manager._sessions
    manager.create_session("gina", 3600)  # prune runs before insert
    assert stale not in manager._sessions


@pytest.mark.parametrize(
    "ip,trusted",
    [
        ("10.0.0.5", True),
        ("172.18.0.4", True),
        ("127.0.0.1", True),
        ("8.8.8.8", False),
        ("8.8.4.4", False),
        ("not-an-ip", False),
    ],
)
def test_trusted_proxy_classification(ip, trusted):
    assert WebSocketServer._is_trusted_proxy(ip) is trusted
