"""Risk territory map: 42 territories, 6 continents, adjacency graph."""

from __future__ import annotations

from dataclasses import dataclass, field


@dataclass
class Territory:
    """A territory on the Risk board."""

    id: str
    name: str
    continent: str
    adjacent: list[str] = field(default_factory=list)


@dataclass
class Continent:
    """A continent with bonus armies."""

    id: str
    name: str
    bonus: int
    territory_ids: list[str] = field(default_factory=list)


# ── Continent definitions ──────────────────────────────────────────────

CONTINENTS: dict[str, Continent] = {
    "north_america": Continent(
        id="north_america",
        name="North America",
        bonus=5,
        territory_ids=[
            "alaska", "northwest_territory", "greenland", "alberta",
            "ontario", "quebec", "western_us", "eastern_us", "central_america",
        ],
    ),
    "south_america": Continent(
        id="south_america",
        name="South America",
        bonus=2,
        territory_ids=["venezuela", "peru", "brazil", "argentina"],
    ),
    "europe": Continent(
        id="europe",
        name="Europe",
        bonus=5,
        territory_ids=[
            "iceland", "scandinavia", "great_britain", "northern_europe",
            "western_europe", "southern_europe", "ukraine",
        ],
    ),
    "africa": Continent(
        id="africa",
        name="Africa",
        bonus=3,
        territory_ids=[
            "north_africa", "egypt", "east_africa",
            "congo", "south_africa", "madagascar",
        ],
    ),
    "asia": Continent(
        id="asia",
        name="Asia",
        bonus=7,
        territory_ids=[
            "ural", "siberia", "yakutsk", "kamchatka", "irkutsk",
            "mongolia", "japan", "afghanistan", "china", "india",
            "siam", "middle_east",
        ],
    ),
    "australia": Continent(
        id="australia",
        name="Australia",
        bonus=2,
        territory_ids=[
            "indonesia", "new_guinea", "western_australia", "eastern_australia",
        ],
    ),
}


# ── Territory definitions with adjacency ────────────────────────────────

TERRITORIES: dict[str, Territory] = {
    # ── North America ──
    "alaska": Territory(
        "alaska", "Alaska", "north_america",
        ["northwest_territory", "alberta", "kamchatka"],
    ),
    "northwest_territory": Territory(
        "northwest_territory", "Northwest Territory", "north_america",
        ["alaska", "alberta", "ontario", "greenland"],
    ),
    "greenland": Territory(
        "greenland", "Greenland", "north_america",
        ["northwest_territory", "ontario", "quebec", "iceland"],
    ),
    "alberta": Territory(
        "alberta", "Alberta", "north_america",
        ["alaska", "northwest_territory", "ontario", "western_us"],
    ),
    "ontario": Territory(
        "ontario", "Ontario", "north_america",
        ["alberta", "northwest_territory", "greenland", "quebec",
         "western_us", "eastern_us"],
    ),
    "quebec": Territory(
        "quebec", "Quebec", "north_america",
        ["ontario", "greenland", "eastern_us"],
    ),
    "western_us": Territory(
        "western_us", "Western US", "north_america",
        ["alberta", "ontario", "eastern_us", "central_america"],
    ),
    "eastern_us": Territory(
        "eastern_us", "Eastern US", "north_america",
        ["ontario", "quebec", "western_us", "central_america"],
    ),
    "central_america": Territory(
        "central_america", "Central America", "north_america",
        ["western_us", "eastern_us", "venezuela"],
    ),
    # ── South America ──
    "venezuela": Territory(
        "venezuela", "Venezuela", "south_america",
        ["central_america", "peru", "brazil"],
    ),
    "peru": Territory(
        "peru", "Peru", "south_america",
        ["venezuela", "brazil", "argentina"],
    ),
    "brazil": Territory(
        "brazil", "Brazil", "south_america",
        ["venezuela", "peru", "argentina", "north_africa"],
    ),
    "argentina": Territory(
        "argentina", "Argentina", "south_america",
        ["peru", "brazil"],
    ),
    # ── Europe ──
    "iceland": Territory(
        "iceland", "Iceland", "europe",
        ["greenland", "scandinavia", "great_britain"],
    ),
    "scandinavia": Territory(
        "scandinavia", "Scandinavia", "europe",
        ["iceland", "great_britain", "northern_europe", "ukraine"],
    ),
    "great_britain": Territory(
        "great_britain", "Great Britain", "europe",
        ["iceland", "scandinavia", "northern_europe", "western_europe"],
    ),
    "northern_europe": Territory(
        "northern_europe", "Northern Europe", "europe",
        ["scandinavia", "great_britain", "western_europe",
         "southern_europe", "ukraine"],
    ),
    "western_europe": Territory(
        "western_europe", "Western Europe", "europe",
        ["great_britain", "northern_europe", "southern_europe", "north_africa"],
    ),
    "southern_europe": Territory(
        "southern_europe", "Southern Europe", "europe",
        ["northern_europe", "western_europe", "ukraine",
         "north_africa", "egypt", "middle_east"],
    ),
    "ukraine": Territory(
        "ukraine", "Ukraine", "europe",
        ["scandinavia", "northern_europe", "southern_europe",
         "ural", "afghanistan", "middle_east"],
    ),
    # ── Africa ──
    "north_africa": Territory(
        "north_africa", "North Africa", "africa",
        ["brazil", "western_europe", "southern_europe",
         "egypt", "east_africa", "congo"],
    ),
    "egypt": Territory(
        "egypt", "Egypt", "africa",
        ["north_africa", "southern_europe", "middle_east", "east_africa"],
    ),
    "east_africa": Territory(
        "east_africa", "East Africa", "africa",
        ["north_africa", "egypt", "middle_east",
         "congo", "south_africa", "madagascar"],
    ),
    "congo": Territory(
        "congo", "Congo", "africa",
        ["north_africa", "east_africa", "south_africa"],
    ),
    "south_africa": Territory(
        "south_africa", "South Africa", "africa",
        ["congo", "east_africa", "madagascar"],
    ),
    "madagascar": Territory(
        "madagascar", "Madagascar", "africa",
        ["east_africa", "south_africa"],
    ),
    # ── Asia ──
    "ural": Territory(
        "ural", "Ural", "asia",
        ["ukraine", "siberia", "afghanistan", "china"],
    ),
    "siberia": Territory(
        "siberia", "Siberia", "asia",
        ["ural", "yakutsk", "irkutsk", "mongolia", "china"],
    ),
    "yakutsk": Territory(
        "yakutsk", "Yakutsk", "asia",
        ["siberia", "irkutsk", "kamchatka"],
    ),
    "kamchatka": Territory(
        "kamchatka", "Kamchatka", "asia",
        ["yakutsk", "irkutsk", "mongolia", "japan", "alaska"],
    ),
    "irkutsk": Territory(
        "irkutsk", "Irkutsk", "asia",
        ["siberia", "yakutsk", "kamchatka", "mongolia"],
    ),
    "mongolia": Territory(
        "mongolia", "Mongolia", "asia",
        ["siberia", "irkutsk", "kamchatka", "japan", "china"],
    ),
    "japan": Territory(
        "japan", "Japan", "asia",
        ["kamchatka", "mongolia"],
    ),
    "afghanistan": Territory(
        "afghanistan", "Afghanistan", "asia",
        ["ukraine", "ural", "china", "india", "middle_east"],
    ),
    "china": Territory(
        "china", "China", "asia",
        ["ural", "siberia", "mongolia", "afghanistan", "india", "siam"],
    ),
    "india": Territory(
        "india", "India", "asia",
        ["afghanistan", "china", "siam", "middle_east"],
    ),
    "siam": Territory(
        "siam", "Siam", "asia",
        ["china", "india", "indonesia"],
    ),
    "middle_east": Territory(
        "middle_east", "Middle East", "asia",
        ["ukraine", "afghanistan", "india",
         "southern_europe", "egypt", "east_africa"],
    ),
    # ── Australia ──
    "indonesia": Territory(
        "indonesia", "Indonesia", "australia",
        ["siam", "new_guinea", "western_australia"],
    ),
    "new_guinea": Territory(
        "new_guinea", "New Guinea", "australia",
        ["indonesia", "western_australia", "eastern_australia"],
    ),
    "western_australia": Territory(
        "western_australia", "Western Australia", "australia",
        ["indonesia", "new_guinea", "eastern_australia"],
    ),
    "eastern_australia": Territory(
        "eastern_australia", "Eastern Australia", "australia",
        ["new_guinea", "western_australia"],
    ),
}

# Pre-sorted territory IDs grouped by continent for menu display
TERRITORIES_BY_CONTINENT: list[tuple[str, list[str]]] = [
    (cid, list(c.territory_ids))
    for cid, c in CONTINENTS.items()
]

ALL_TERRITORY_IDS: list[str] = list(TERRITORIES.keys())


def get_adjacent(territory_id: str) -> list[str]:
    """Return IDs of territories adjacent to the given one."""
    t = TERRITORIES.get(territory_id)
    return list(t.adjacent) if t else []


def get_continent(territory_id: str) -> str | None:
    """Return the continent ID for a territory."""
    t = TERRITORIES.get(territory_id)
    return t.continent if t else None


def get_territory_name(territory_id: str) -> str:
    """Return the display name for a territory."""
    t = TERRITORIES.get(territory_id)
    return t.name if t else territory_id


def get_continent_bonus(continent_id: str) -> int:
    """Return the bonus armies for controlling a continent."""
    c = CONTINENTS.get(continent_id)
    return c.bonus if c else 0


def player_controls_continent(
    continent_id: str, player_territories: set[str]
) -> bool:
    """Check if a player controls all territories in a continent."""
    c = CONTINENTS.get(continent_id)
    if not c:
        return False
    return all(tid in player_territories for tid in c.territory_ids)
