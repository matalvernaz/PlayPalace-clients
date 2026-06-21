"""Rate limiter for voice chat join attempts."""

import time


class VoiceRateLimiter:
    """Per-user token-bucket limiter for voice join actions.

    Voice joins are pricier than ordinary navigation: each mints a signed media
    token and can trigger table-wide connect/disconnect announcements. The
    bucket keeps normal use responsive while blocking rapid join/leave spam.
    """

    BUCKET_CAPACITY = 2
    REFILL_RATE = 0.25  # one token every 4 seconds

    def __init__(self) -> None:
        self._buckets: dict[str, _VoiceBucket] = {}

    def try_consume(self, username: str) -> bool:
        bucket = self._buckets.get(username)
        if bucket is None:
            bucket = _VoiceBucket(self.BUCKET_CAPACITY)
            self._buckets[username] = bucket

        now = time.monotonic()
        elapsed = now - bucket.last_refill
        bucket.tokens = min(self.BUCKET_CAPACITY, bucket.tokens + elapsed * self.REFILL_RATE)
        bucket.last_refill = now

        if bucket.tokens >= 1.0:
            bucket.tokens -= 1.0
            return True
        return False

    def remove_user(self, username: str) -> None:
        self._buckets.pop(username, None)


class _VoiceBucket:
    __slots__ = ("tokens", "last_refill")

    def __init__(self, capacity: float) -> None:
        self.tokens = capacity
        self.last_refill = time.monotonic()
