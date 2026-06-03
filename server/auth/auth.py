"""Authentication and session management."""

import hashlib
import hmac
import secrets
import sqlite3
import time
from enum import Enum, auto
from typing import TYPE_CHECKING

from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError, InvalidHashError

from server.core.users.base import TrustLevel


class AuthResult(Enum):
    """Result of an authentication attempt."""

    SUCCESS = auto()
    USER_NOT_FOUND = auto()
    WRONG_PASSWORD = auto()


if TYPE_CHECKING:
    from ..persistence.database import Database, UserRecord


class AuthManager:
    """Handle user authentication and session management.

    Uses Argon2 for password hashing and supports migration from legacy
    SHA-256 hashes on successful login.
    """

    #: Maximum concurrent access sessions kept per user; oldest evicted first.
    _MAX_SESSIONS_PER_USER = 10

    #: Grace window after a refresh token is rotated during which re-presenting
    #: it is treated as a benign client race (idempotent replay of the rotation)
    #: rather than token theft. Tolerates clients that open concurrent
    #: connections or re-send a token before storing its rotated successor.
    _REFRESH_REUSE_GRACE_SECONDS = 30

    def __init__(self, database: "Database"):
        """Initialize the auth manager with a database backend."""
        self._db = database
        self._sessions: dict[str, tuple[str, int]] = {}  # token -> (username, expires_at)
        self._hasher = PasswordHasher()
        # Verified against on the missing-user path so authentication takes
        # constant time whether or not the username exists.
        self._dummy_hash = self._hasher.hash("timing-attack-mitigation")

    def hash_password(self, password: str) -> str:
        """Hash a password using Argon2."""
        return self._hasher.hash(password)

    def _hash_password_sha256(self, password: str) -> str:
        """Legacy SHA-256 hash for migration support."""
        return hashlib.sha256(password.encode()).hexdigest()

    def _is_legacy_hash(self, password_hash: str) -> bool:
        """Check if a hash is a legacy SHA-256 hash (64 hex characters)."""
        return len(password_hash) == 64 and all(
            c in "0123456789abcdef" for c in password_hash.lower()
        )

    def verify_password(self, password: str, password_hash: str) -> bool:
        """Verify a password against its hash (supports both Argon2 and legacy SHA-256)."""
        # Try Argon2 first
        try:
            self._hasher.verify(password_hash, password)
            return True
        except (VerifyMismatchError, InvalidHashError):
            pass

        # Fall back to SHA-256 for legacy hashes
        if self._is_legacy_hash(password_hash):
            return hmac.compare_digest(self._hash_password_sha256(password), password_hash)

        return False

    def authenticate(self, username: str, password: str) -> AuthResult:
        """Authenticate a user.

        Args:
            username: Username to authenticate.
            password: Plaintext password to verify.

        Returns:
            AuthResult indicating success or failure reason.
        """
        user = self._db.get_user(username)
        if not user:
            # Verify against a dummy hash so the missing-user path costs the
            # same Argon2 time as a real one (no enumeration timing oracle).
            self.verify_password(password, self._dummy_hash)
            return AuthResult.USER_NOT_FOUND

        if not self.verify_password(password, user.password_hash):
            return AuthResult.WRONG_PASSWORD

        # Upgrade legacy hash to Argon2 on successful login
        if self._is_legacy_hash(user.password_hash):
            new_hash = self.hash_password(password)
            self._db.update_user_password(username, new_hash)

        return AuthResult.SUCCESS

    def register(self, username: str, password: str, *, approved: bool = False, locale: str = "en") -> bool:
        """Register a new user.

        Args:
            username: Username to create.
            password: Plaintext password.
            approved: Whether the account is pre-approved (skips admin approval).
            locale: Preferred locale.

        Returns:
            True if registration succeeded, False if username taken.
        """
        if self._db.user_exists(username):
            return False

        trust_level = TrustLevel.USER

        password_hash = self.hash_password(password)
        try:
            self._db.create_user(username, password_hash, locale, trust_level, approved)
        except sqlite3.IntegrityError:
            # Two register packets raced past `user_exists`. The UNIQUE
            # constraint (binary + lower(username) index) stops the second
            # one; turn it into a clean "username taken" instead of an
            # unhandled exception that disconnects the client.
            return False

        return True

    def reset_password(self, username: str, new_password: str) -> bool:
        """Reset a user's password.

        Args:
            username: Username to update.
            new_password: New plaintext password.

        Returns:
            True if successful, False if user doesn't exist.
        """
        if not self._db.user_exists(username):
            return False

        password_hash = self.hash_password(new_password)
        self._db.update_user_password(username, password_hash)
        return True

    def get_user(self, username: str) -> "UserRecord | None":
        """Get a user record."""
        return self._db.get_user(username)

    def _prune_expired_sessions(self) -> None:
        """Drop expired access sessions to keep the in-memory table bounded."""
        now = int(time.time())
        expired = [token for token, (_u, exp) in self._sessions.items() if exp <= now]
        for token in expired:
            del self._sessions[token]

    def create_session(self, username: str, ttl_seconds: int) -> tuple[str, int]:
        """Create an access session token for a user.

        Returns:
            (token, expires_at_epoch_seconds)
        """
        token = secrets.token_hex(32)
        expires_at = int(time.time()) + ttl_seconds
        # Bound memory: clear expired entries, then cap sessions per user
        # (evicting the soonest-to-expire) before inserting the new one.
        self._prune_expired_sessions()
        user_tokens = sorted(
            ((t, exp) for t, (u, exp) in self._sessions.items() if u == username),
            key=lambda item: item[1],
        )
        excess = len(user_tokens) - (self._MAX_SESSIONS_PER_USER - 1)
        for token_to_drop, _exp in user_tokens[: max(0, excess)]:
            self._sessions.pop(token_to_drop, None)
        self._sessions[token] = (username, expires_at)
        return token, expires_at

    def validate_session(self, token: str) -> str | None:
        """Validate an access session token."""
        entry = self._sessions.get(token)
        if not entry:
            return None
        username, expires_at = entry
        if expires_at <= int(time.time()):
            self._sessions.pop(token, None)
            return None
        return username

    def invalidate_session(self, token: str) -> None:
        """Invalidate a session token.

        Args:
            token: Session token string.
        """
        self._sessions.pop(token, None)

    def invalidate_user_sessions(self, username: str) -> None:
        """Invalidate all sessions for a user.

        Args:
            username: Username whose sessions should be invalidated.
        """
        to_remove = [t for t, (u, _expires_at) in self._sessions.items() if u == username]
        for token in to_remove:
            del self._sessions[token]

    def create_refresh_token(self, username: str, ttl_seconds: int) -> tuple[str, int]:
        """Create and persist a refresh token."""
        token = secrets.token_hex(32)
        now = int(time.time())
        expires_at = now + ttl_seconds
        self._db.store_refresh_token(username, token, expires_at, now)
        return token, expires_at

    def revoke_user_refresh_tokens(self, username: str) -> None:
        """Revoke all of a user's refresh tokens (e.g. on ban or token reuse)."""
        self._db.revoke_user_refresh_tokens(username, int(time.time()))

    def _replay_rotation_within_grace(
        self,
        record: sqlite3.Row,
        now: int,
        expected_username: str | None,
        access_ttl_seconds: int,
    ) -> tuple[str, str, int, str, int] | None:
        """Idempotently replay a recent rotation for a re-presented token.

        Returns a fresh access session bound to ``record``'s successor refresh
        token (unchanged, not re-rotated) when the rotation happened within
        ``_REFRESH_REUSE_GRACE_SECONDS`` and the successor is still the live tip
        of the chain. Returns ``None`` to signal the caller should treat the
        re-presentation as theft (revoke the family).
        """
        revoked_at = record["revoked_at"]
        if revoked_at is None or now - revoked_at > self._REFRESH_REUSE_GRACE_SECONDS:
            return None

        username = record["username"]
        if expected_username is not None and expected_username.lower() != username.lower():
            return None

        successor = self._db.get_refresh_token(record["replaced_by"])
        if successor is None:
            return None
        # The successor must still be the live tip: not itself rotated, revoked,
        # or expired. If the chain has moved on, this is no longer a simple race.
        if successor["replaced_by"] or successor["revoked_at"] is not None:
            return None
        if successor["expires_at"] <= now:
            return None

        user = self._db.get_user(username)
        if user is None or user.trust_level == TrustLevel.BANNED:
            return None

        access_token, access_expires = self.create_session(username, access_ttl_seconds)
        return username, access_token, access_expires, successor["token"], successor["expires_at"]

    def refresh_session(
        self,
        refresh_token: str,
        access_ttl_seconds: int,
        refresh_ttl_seconds: int,
        *,
        expected_username: str | None = None,
    ) -> tuple[str, str, int, str, int] | None:
        """Rotate refresh token and issue a new access token.

        Returns the new credentials, or ``None`` on any failure: unknown,
        expired, revoked, or reused token; banned user; or a mismatch against
        ``expected_username`` (checked before any rotation occurs).
        """
        record = self._db.get_refresh_token(refresh_token)
        if not record:
            return None

        username = record["username"]
        now = int(time.time())

        # An already-rotated token (replaced_by set) is normally the classic
        # stolen-token signal. But a legitimate client that races its own
        # refresh — concurrent reconnects, or re-sending a token before it has
        # stored the rotated successor — innocently presents the just-rotated
        # token a second time. Honor a short idempotency window: replay the
        # rotation by re-issuing an access session bound to the live successor.
        if record["replaced_by"]:
            replay = self._replay_rotation_within_grace(
                record, now, expected_username, access_ttl_seconds
            )
            if replay is not None:
                return replay
            self.revoke_user_refresh_tokens(username)
            return None
        # Revoked without rotation (logout, family-revoke, expiry sweep): no
        # grace — treat re-presentation as a theft/invalid signal.
        if record["revoked_at"] is not None:
            self.revoke_user_refresh_tokens(username)
            return None
        if record["expires_at"] <= now:
            self._db.revoke_refresh_token(refresh_token, now)
            return None

        user = self._db.get_user(username)
        if user is None or user.trust_level == TrustLevel.BANNED:
            return None
        # Reject a hint mismatch BEFORE rotating, so a wrong-hint request can't
        # burn the token or leak an access session.
        if expected_username is not None and expected_username.lower() != username.lower():
            return None

        new_refresh_token = secrets.token_hex(32)
        new_refresh_expires = now + refresh_ttl_seconds
        self._db.store_refresh_token(username, new_refresh_token, new_refresh_expires, now)
        self._db.revoke_refresh_token(refresh_token, now, replaced_by=new_refresh_token)

        access_token, access_expires = self.create_session(username, access_ttl_seconds)
        return username, access_token, access_expires, new_refresh_token, new_refresh_expires
