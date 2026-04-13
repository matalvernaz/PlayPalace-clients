"""Game implementations."""

from .base import Game
from .registry import GameRegistry, register_game, get_game_class

# Import all games to trigger registration.
# Order within each category determines display order in the lobby menu
# (categories themselves are sorted alphabetically; games within a category
# appear in registration order). Keep related games adjacent here.

# --- Dice / luck games ---
from .pig.game import PigGame
from .threes.game import ThreesGame
from .farkle.game import FarkleGame
from .yahtzee.game import YahtzeeGame
from .tradeoff.game import TradeoffGame
from .tossup.game import TossUpGame
from .midnight.game import MidnightGame
from .leftrightcenter.game import LeftRightCenterGame
from .liarsdice.game import LiarsDiceGame

# --- Card games ---
from .scopa.game import ScopaGame
from .crazyeights.game import CrazyEightsGame
from .ninetynine.game import NinetyNineGame
from .nine.game import NineGame
from .milebymile.game import MileByMileGame
from .explodingkittens.game import ExplodingKittensGame
from .blackjack.game import BlackjackGame
from .twentyone import TwentyOneGame

# --- Poker family ---
from .fivecarddraw.game import FiveCardDrawGame
from .holdem.game import HoldemGame

# --- Board games — race/track first, then strategy/abstract ---
from .ludo.game import LudoGame
from .sorry.game import SorryGame
from .trouble.game import TroubleGame
from .snakesandladders.game import SnakesAndLaddersGame
from .life.game import GameOfLifeGame
from .chess.game import ChessGame
from .backgammon.game import BackgammonGame
from .senet.game import SenetGame
from .mancala.game import MancalaGame
from .risk.game import RiskGame

# --- RB Play Center ---
from .lightturret.game import LightTurretGame
from .chaosbear.game import ChaosBearGame

# --- Adventure ---
from .pirates.game import PiratesGame
from .ageofheroes.game import AgeOfHeroesGame

# --- Party ---
from .humanitycards.game import HumanityCardsGame

# --- Uncategorized ---
from .rollingballs.game import RollingBallsGame
from .metalpipe.game import MetalPipeGame

# --- PlayAural games ---
from .battleship.game import BattleshipGame
from .coup.game import CoupGame
from .dominos.game import DominosGame
from .lastcard.game import LastCardGame
from .pusoydos.game import PusoyDosGame

__all__ = [
    "Game",
    "GameRegistry",
    "register_game",
    "get_game_class",
    "PigGame",
    "ThreesGame",
    "FarkleGame",
    "YahtzeeGame",
    "TradeoffGame",
    "TossUpGame",
    "MidnightGame",
    "LeftRightCenterGame",
    "LiarsDiceGame",
    "ScopaGame",
    "CrazyEightsGame",
    "NinetyNineGame",
    "NineGame",
    "MileByMileGame",
    "ExplodingKittensGame",
    "BlackjackGame",
    "TwentyOneGame",
    "FiveCardDrawGame",
    "HoldemGame",
    "LudoGame",
    "SorryGame",
    "TroubleGame",
    "SnakesAndLaddersGame",
    "GameOfLifeGame",
    "ChessGame",
    "BackgammonGame",
    "SenetGame",
    "MancalaGame",
    "RiskGame",
    "LightTurretGame",
    "ChaosBearGame",
    "PiratesGame",
    "AgeOfHeroesGame",
    "HumanityCardsGame",
    "RollingBallsGame",
    "MetalPipeGame",
    "BattleshipGame",
    "CoupGame",
    "DominosGame",
    "LastCardGame",
    "PusoyDosGame",
]
