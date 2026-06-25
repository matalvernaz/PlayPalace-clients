"""Tests for the voice join rate limiter (token bucket)."""

import server.auth.voice_rate_limit as rl
from server.auth.voice_rate_limit import VoiceRateLimiter


def test_allows_up_to_capacity_then_denies(monkeypatch):
    monkeypatch.setattr(rl.time, "monotonic", lambda: 1000.0)  # freeze time
    limiter = VoiceRateLimiter()
    assert limiter.try_consume("alice") is True
    assert limiter.try_consume("alice") is True   # BUCKET_CAPACITY == 2
    assert limiter.try_consume("alice") is False  # exhausted, no refill yet


def test_refills_over_time(monkeypatch):
    now = [1000.0]
    monkeypatch.setattr(rl.time, "monotonic", lambda: now[0])
    limiter = VoiceRateLimiter()
    assert limiter.try_consume("alice") is True
    assert limiter.try_consume("alice") is True
    assert limiter.try_consume("alice") is False

    now[0] += 4.0  # REFILL_RATE 0.25/s -> exactly one token in 4s
    assert limiter.try_consume("alice") is True
    assert limiter.try_consume("alice") is False


def test_buckets_are_per_user(monkeypatch):
    monkeypatch.setattr(rl.time, "monotonic", lambda: 1000.0)
    limiter = VoiceRateLimiter()
    assert limiter.try_consume("alice") is True
    assert limiter.try_consume("bob") is True  # bob has his own bucket


def test_remove_user_resets_bucket(monkeypatch):
    monkeypatch.setattr(rl.time, "monotonic", lambda: 1000.0)
    limiter = VoiceRateLimiter()
    limiter.try_consume("alice")
    limiter.try_consume("alice")
    assert limiter.try_consume("alice") is False
    limiter.remove_user("alice")
    assert limiter.try_consume("alice") is True  # fresh bucket
