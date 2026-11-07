"""S reads each of our games' real score; it used to read 0 points for everyone."""

from __future__ import annotations

import random

from server.games.mancala.game import MancalaGame
from server.games.numberchain.game import NumberChainGame
from server.games.risk.game import RiskGame
from server.games.trouble.game import TroubleGame
from server.game_utils.parcheesi import TokenZone
from server.users.test_user import MockUser


def started(game_class, *names):
    game = game_class()
    users = {}
    for name in names:
        users[name] = MockUser(name)
        game.add_player(name, users[name])
    game.on_start()
    return game, users


def score_lines(game, name, users):
    user = users[name]
    user.messages.clear()
    game._action_check_scores(game.get_player_by_name(name), "check_scores")
    return user.get_spoken_messages()


def test_mancala_reads_the_stones_in_each_store():
    game, users = started(MancalaGame, "Alice", "Bob")
    game.board[game._store_idx(0)] = 7
    game.board[game._store_idx(1)] = 3
    text = " ".join(score_lines(game, "Alice", users))
    assert "7" in text and "3" in text


def test_risk_reads_territories_held():
    random.seed(3)
    game, users = started(RiskGame, "Alice", "Bob")
    alice = game.get_player_by_name("Alice")
    bob = game.get_player_by_name("Bob")
    for number, territory in enumerate(list(game.owners)):
        game.owners[territory] = alice.id if number < 30 else bob.id
    text = " ".join(score_lines(game, "Alice", users))
    assert "Alice: 30 territories" in text and "Bob: 12 territories" in text
    assert "0 points" not in text


def test_trouble_reads_tokens_finished():
    game, users = started(TroubleGame, "Alice", "Bob")
    alice = game.get_player_by_name("Alice")
    alice.tokens[0].zone = TokenZone.FINISHED
    alice.tokens[1].zone = TokenZone.FINISHED
    text = " ".join(score_lines(game, "Alice", users))
    assert "2 tokens finished" in text


def test_number_chain_has_no_score_to_read():
    game, users = started(NumberChainGame, "Alice", "Bob")
    alice = game.get_player_by_name("Alice")
    assert game._is_check_scores_enabled(alice) == "action-not-available"
