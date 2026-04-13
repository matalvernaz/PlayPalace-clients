"""Player state for The Game of Life."""

from dataclasses import dataclass, field

from ..base import Player


@dataclass
class LifePlayer(Player):
    """Per-player state.

    All fields are serialized. Runtime-only client state (menu focus, etc.)
    is handled by the base Game class.
    """

    # Position / phase
    position: int = 0
    retired: bool = False
    retirement_choice: str = "none"  # "none" | "estates" | "acres"
    awaiting_spin: bool = True  # True when it is this player's turn to spin

    # Path
    path: str = "none"  # "none" | "college" | "career"
    college_loan: int = 0  # remaining balance

    # Career
    career_key: str = ""  # empty until a career is chosen; see CANONICAL_CAREERS
    career_label_key: str = ""
    salary: int = 0

    # Cash
    cash: int = 0

    # Family
    married: bool = False
    children: int = 0

    # Insurance
    has_fire_insurance: bool = False
    has_auto_insurance: bool = False
    has_life_insurance: bool = False
    has_full_insurance: bool = False  # simplified mode

    # Stocks
    stock_number: int = 0  # 0 means no stock held

    # Life tiles — a list of cash values (hidden from player until reveal).
    life_tile_values: list[int] = field(default_factory=list)

    # Pending flow state — these are serializable "what is the player being
    # asked right now?" flags so that mid-turn prompts survive a reload.
    pending: str = ""  # "" | "path" | "career_pick" | "insurance" | "stock" | "risk_it" | "retirement"
    pending_options: list[str] = field(default_factory=list)  # serialized options for the pending prompt
    pending_event_key: str = ""  # the space event that triggered the prompt (if any)

    # Turn bookkeeping
    turns_since_college_start: int = 0  # used to auto-draw careers for college grads

    # ---- Derived helpers ---------------------------------------------------

    def any_insurance(self) -> bool:
        return (
            self.has_fire_insurance
            or self.has_auto_insurance
            or self.has_life_insurance
            or self.has_full_insurance
        )

    def insurance_list(self) -> list[str]:
        """Return a stable-ordered list of insurance type keys this player holds."""
        out: list[str] = []
        if self.has_full_insurance:
            return ["full"]
        if self.has_fire_insurance:
            out.append("fire")
        if self.has_auto_insurance:
            out.append("auto")
        if self.has_life_insurance:
            out.append("life")
        return out

    def covers(self, insurable_type: str) -> bool:
        """True if the player is insured against the given type (fire/auto/life)."""
        if self.has_full_insurance:
            return True
        if insurable_type == "fire":
            return self.has_fire_insurance
        if insurable_type == "auto":
            return self.has_auto_insurance
        if insurable_type == "life":
            return self.has_life_insurance
        return False

    def set_coverage(self, insurable_type: str) -> bool:
        """Set coverage for a type. Returns True if it was newly set, False if already held."""
        if insurable_type == "full":
            if self.has_full_insurance:
                return False
            self.has_full_insurance = True
            return True
        if self.covers(insurable_type):
            return False
        if insurable_type == "fire":
            self.has_fire_insurance = True
        elif insurable_type == "auto":
            self.has_auto_insurance = True
        elif insurable_type == "life":
            self.has_life_insurance = True
        else:
            return False
        return True
