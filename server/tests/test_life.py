"""Rules-contract and integration tests for the 1991 Game of Life port."""

from collections import Counter
import random

from server.core.users.bot import Bot
from server.core.users.test_user import MockUser
from server.games.life import bot as life_bot
from server.games.life.game import GameOfLifeGame
from server.games.life.player import LifePlayer
from server.games.life.state import (
    BANK_LOAN_REPAYMENT,
    BANK_LOAN_VALUE,
    CANONICAL_CAREERS,
    COLLEGE_LOAN_PRINCIPAL,
    EVENT_DECK,
    HOUSE_DEEDS,
    LIFE_TILE_VALUES,
    SALARY_CARDS,
    STOCK_COST,
    STOCK_PAYOUT,
    EventEffect,
    Space,
    SpaceType,
    TRACK_LENGTHS,
    build_track,
)


def make_game(*, college_path: bool = True) -> GameOfLifeGame:
    game = GameOfLifeGame()
    game.options.college_path = college_path
    game.add_player("Alice", MockUser("Alice"))
    game.add_player("Bob", MockUser("Bob"))
    game.on_start()
    return game


def make_current(game: GameOfLifeGame, player: LifePlayer) -> None:
    game.turn_index = game.turn_player_ids.index(player.id)


def scheduled_step_target(game: GameOfLifeGame) -> int:
    return next(
        data["target"]
        for _, event_type, data in reversed(game.event_queue)
        if event_type == "step_move"
    )


class TestOfficialComponents:
    def test_metadata_and_player_count(self):
        assert GameOfLifeGame.get_type() == "life"
        assert GameOfLifeGame.get_min_players() == 2
        assert GameOfLifeGame.get_max_players() == 6

    def test_default_track_uses_145_space_classic_route(self):
        game = GameOfLifeGame()
        assert game.options.track_length == "long"
        assert TRACK_LENGTHS["long"] == 145
        track = build_track(game.options.track_length)
        assert len(track) == 145
        assert track[0].type == SpaceType.START
        assert track[-1].type == SpaceType.FINISH

    def test_track_contains_all_rule_bearing_stop_spaces(self):
        types = {space.type for space in build_track("long")}
        assert {
            SpaceType.COLLEGE_GRAD,
            SpaceType.MARRY,
            SpaceType.BUY_HOUSE,
            SpaceType.NIGHT_SCHOOL,
            SpaceType.STOCK_ZOOMS,
            SpaceType.STOCK_SLUMPS,
            SpaceType.FINISH,
        } <= types
        assert SpaceType.RETIRE_JUNCTION not in types

    def test_baby_spaces_include_one_twins_space(self):
        babies = [
            space
            for space in build_track("long")
            if space.type == SpaceType.BABY
        ]
        assert len(babies) == 3
        assert [space.event_key for space in babies].count("twins") == 1

    def test_career_deck_matches_1991_set(self):
        assert {career.key for career in CANONICAL_CAREERS} == {
            "artist",
            "superstar",
            "teacher",
            "travel_agent",
            "athlete",
            "police_officer",
            "salesperson",
            "doctor",
            "accountant",
        }
        assert {
            career.key
            for career in CANONICAL_CAREERS
            if career.degree_required
        } == {"teacher", "doctor", "accountant"}

    def test_salary_cards_match_1991_set(self):
        assert [card.salary for card in SALARY_CARDS] == list(
            range(20_000, 110_000, 10_000)
        )
        assert [card.taxes for card in SALARY_CARDS] == list(
            range(5_000, 50_000, 5_000)
        )

    def test_house_deeds_match_1991_prices_and_premiums(self):
        assert [
            (deed.price, deed.insurance_cost)
            for deed in HOUSE_DEEDS
        ] == [
            (40_000, 10_000),
            (60_000, 15_000),
            (80_000, 20_000),
            (100_000, 25_000),
            (120_000, 30_000),
            (140_000, 35_000),
            (160_000, 40_000),
            (180_000, 45_000),
            (200_000, 50_000),
        ]

    def test_life_tiles_match_1991_distribution(self):
        assert len(LIFE_TILE_VALUES) == 25
        assert Counter(LIFE_TILE_VALUES) == Counter(
            {
                50_000: 7,
                100_000: 6,
                150_000: 5,
                200_000: 4,
                250_000: 3,
            }
        )

    def test_setup_reserves_four_life_tiles(self):
        game = make_game()
        assert len(game.estates_tile_values) == 4
        assert len(game.life_tile_pool) == 21
        assert sorted(game.estates_tile_values + game.life_tile_pool) == sorted(
            LIFE_TILE_VALUES
        )


class TestStartingPaths:
    def test_college_costs_two_loan_notes_and_player_spins_same_turn(self):
        game = make_game()
        player = game.current_player
        assert isinstance(player, LifePlayer)

        game._action_choose_college(player, "choose_college")

        assert player.path == "college"
        assert player.college_loan == COLLEGE_LOAN_PRINCIPAL == 40_000
        assert player.pending == ""
        assert player.awaiting_spin
        assert game.current_player is player

    def test_career_path_deals_one_random_nondegree_career_and_salary(self):
        game = make_game()
        player = game.current_player
        assert isinstance(player, LifePlayer)

        game._action_choose_career_path(player, "choose_career_path")

        career = CANONICAL_CAREERS[player.career_index]
        assert not career.degree_required
        assert player.salary_card_index >= 0
        assert player.salary in range(20_000, 110_000, 10_000)
        assert player.college_loan == 0
        assert player.pending == ""
        assert player.awaiting_spin
        assert game.current_player is player
        grad = next(
            space.index
            for space in game.track
            if space.type == SpaceType.COLLEGE_GRAD
        )
        assert player.position == grad

    def test_college_job_search_offers_three_careers_then_three_salaries(self):
        game = make_game()
        player = game.current_player
        assert isinstance(player, LifePlayer)
        player.path = "college"
        player.pending = ""
        player.position = next(
            space.index
            for space in game.track
            if space.type == SpaceType.COLLEGE_GRAD
        )

        game._handle_resolve_landing({"player_id": player.id})
        assert player.pending == "career_pick"
        assert len(game.career_offers[player.id]) == 3

        game._action_pick_career(player, "pick_career_0")
        assert player.pending == "salary_pick"
        assert len(game.salary_offers[player.id]) == 3

        game._action_pick_salary(player, "pick_salary_0")
        assert player.career_index >= 0
        assert player.salary_card_index >= 0
        assert player.pending == ""
        assert player.awaiting_spin
        assert game.current_player is player

    def test_no_college_variant_deals_cards_without_prompt(self):
        game = make_game(college_path=False)
        for player in game.players:
            assert player.path == "career"
            assert player.career_index >= 0
            assert player.salary_card_index >= 0
            assert player.pending == ""


class TestMovementAndStops:
    def test_college_graduation_is_a_mandatory_stop(self):
        game = make_game()
        player = game.players[0]
        make_current(game, player)
        player.path = "college"
        player.pending = ""
        player.position = 0

        game._schedule_movement(player, 50)

        grad = next(
            space.index
            for space in game.track
            if space.type == SpaceType.COLLEGE_GRAD
        )
        assert scheduled_step_target(game) == grad

    def test_marriage_and_house_are_mandatory_stops(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = ""
        marriage = next(
            space.index for space in game.track if space.type == SpaceType.MARRY
        )
        house = next(
            space.index
            for space in game.track
            if space.type == SpaceType.BUY_HOUSE
        )

        player.position = marriage - 2
        game._schedule_movement(player, 10)
        assert scheduled_step_target(game) == marriage

        game.event_queue.clear()
        player.married = True
        player.position = marriage
        game._schedule_movement(player, 10)
        assert scheduled_step_target(game) == house

    def test_occupied_ordinary_space_moves_to_next_open_space(self):
        game = make_game(college_path=False)
        player, other = game.players
        make_current(game, player)
        player.pending = ""
        start = next(
            space.index
            for space in game.track
            if space.type == SpaceType.PAYDAY
        )
        player.position = start
        target = start + 1
        while game.track[target].type != SpaceType.NORMAL:
            target += 1
        other.position = target

        game._schedule_movement(player, target - start)

        assert scheduled_step_target(game) == target + 1

    def test_payday_is_collected_when_passed_or_landed_on(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.salary = 60_000
        player.cash = 0
        payday = next(
            space.index for space in game.track if space.type == SpaceType.PAYDAY
        )
        player.position = payday - 2

        game._handle_step_move({"player_id": player.id, "target": payday + 1})

        assert player.cash == 60_000

    def test_get_married_awards_tile_and_allows_another_spin(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = ""
        player.position = next(
            space.index for space in game.track if space.type == SpaceType.MARRY
        )
        before = len(player.life_tile_values)

        game._handle_resolve_landing({"player_id": player.id})

        assert player.married
        assert len(player.life_tile_values) == before + 1
        assert player.awaiting_spin
        assert game.current_player is player

    def test_baby_and_twins_add_pegs_and_life_tiles(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        babies = [
            space for space in game.track if space.type == SpaceType.BABY
        ]

        player.position = babies[0].index
        game._handle_resolve_landing({"player_id": player.id})
        assert player.children == 1
        assert len(player.life_tile_values) == 1

        make_current(game, player)
        player.pending = ""
        player.position = next(
            space.index for space in babies if space.event_key == "twins"
        )
        game._handle_resolve_landing({"player_id": player.id})
        assert player.children == 3
        assert len(player.life_tile_values) == 2


class TestMoneyCardsAndProperty:
    def test_buy_house_is_mandatory_and_auto_borrows_shortfall(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = ""
        player.cash = 10_000
        player.position = next(
            space.index
            for space in game.track
            if space.type == SpaceType.BUY_HOUSE
        )

        game._handle_resolve_landing({"player_id": player.id})

        assert player.house_key
        assert player.house_price in {deed.price for deed in HOUSE_DEEDS}
        assert player.cash >= 0
        assert player.college_loan % BANK_LOAN_VALUE == 0
        assert player.pending == "home_insurance"

    def test_homeowners_insurance_uses_house_deed_premium(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = "home_insurance"
        player.awaiting_spin = True
        player.house_key = "victorian"
        player.house_insurance_cost = 50_000
        player.cash = 100_000

        game._action_buy_insurance(player, "buy_fire_insurance")

        assert player.has_fire_insurance
        assert player.cash == 50_000
        assert player.pending == ""
        assert player.awaiting_spin

    def test_stock_numbers_are_one_through_nine_and_cost_50000(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = ""
        player.awaiting_spin = True
        player.cash = 100_000

        assert game._stock_number_options(player) == [
            str(number) for number in range(1, 10)
        ]
        game._action_buy_stock(player, "3", "buy_stock")

        assert player.stock_number == 3
        assert player.cash == 100_000 - STOCK_COST
        assert 3 not in game.available_stock_numbers
        assert game.current_player is player

    def test_stock_pays_on_any_players_matching_spin(self):
        game = make_game(college_path=False)
        owner, spinner = game.players
        owner.stock_number = 5
        owner.cash = 0

        game._handle_spin_result({"player_id": spinner.id, "value": 5})

        assert owner.cash == STOCK_PAYOUT

    def test_police_officer_collects_5000_when_opponent_spins_ten(self):
        game = make_game(college_path=False)
        police, spinner = game.players
        police.career_key = "police_officer"
        police.cash = 0
        spinner.cash = 20_000

        game._handle_spin_result({"player_id": spinner.id, "value": 10})

        assert police.cash == 5_000
        assert spinner.cash == 15_000

    def test_bank_loans_issue_20000_and_repay_for_25000(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.cash = 100_000
        player.college_loan = 0

        game._action_take_loan(player, "take_loan")
        assert player.cash == 120_000
        assert player.college_loan == BANK_LOAN_VALUE

        game._action_pay_loan(player, "pay_loan")
        assert player.cash == 120_000 - BANK_LOAN_REPAYMENT
        assert player.college_loan == 0

    def test_career_space_pays_card_holder_or_bank(self):
        game = make_game(college_path=False)
        payer, artist = game.players
        payer.career_key = "teacher"
        artist.career_key = "artist"
        payer.cash = 100_000
        artist.cash = 0
        event = next(
            event
            for event in EVENT_DECK
            if event.effect == EventEffect.CAREER_PAYMENT
            and event.career_key == "artist"
        )
        space = Space(10, SpaceType.EVENT)
        game.event_layout[10] = event.key

        game._apply_event(payer, space)

        assert payer.cash == 100_000 - event.amount
        assert artist.cash == event.amount

    def test_taxes_due_uses_salary_card_and_pays_accountant(self):
        game = make_game(college_path=False)
        payer, accountant = game.players
        payer.salary_taxes = 35_000
        payer.cash = 100_000
        accountant.career_key = "accountant"
        accountant.cash = 0
        space = Space(11, SpaceType.EVENT)
        game.event_layout[11] = "taxes"

        game._apply_event(payer, space)

        assert payer.cash == 65_000
        assert accountant.cash == 35_000


class TestLifeTilesAndRetirement:
    def test_empty_draw_pile_steals_instead_of_refilling(self):
        game = make_game(college_path=False)
        player, victim = game.players
        make_current(game, player)
        game.life_tile_pool = []
        player.life_tile_values = []
        victim.life_tile_values = [150_000]

        completed = game._grant_life_tile(player)

        assert not completed
        assert player.pending == "steal_tile"
        assert player.pending_options == [victim.id]
        assert game.life_tile_pool == []

        game._action_steal_tile(player, "steal_tile_0")
        assert player.life_tile_values == [150_000]
        assert victim.life_tile_values == []

    def test_countryside_acres_awards_one_protected_tile_and_retires(self):
        game = make_game(college_path=False)
        player = game.players[0]
        make_current(game, player)
        player.pending = "retirement"
        player.college_loan = 40_000
        player.cash = 200_000
        before = len(player.life_tile_values)

        game._resolve_retirement_choice(player, "acres")

        assert player.retired
        assert player.retirement_choice == "acres"
        assert player.cash == 150_000
        assert player.college_loan == 0
        assert len(player.life_tile_values) == before + 1
        assert player.career_key == ""
        assert player.salary == 0

    def test_acres_tiles_cannot_be_stolen(self):
        game = make_game(college_path=False)
        player, acres_player = game.players
        make_current(game, player)
        game.life_tile_pool = []
        acres_player.retired = True
        acres_player.retirement_choice = "acres"
        acres_player.life_tile_values = [250_000]

        assert game._grant_life_tile(player)
        assert player.pending == ""
        assert acres_player.life_tile_values == [250_000]

    def test_richest_estates_retiree_gets_four_reserved_tiles(self):
        game = make_game(college_path=False)
        richer, poorer = game.players
        richer.retired = True
        poorer.retired = True
        richer.retirement_choice = "estates"
        poorer.retirement_choice = "estates"
        richer.cash = 500_000
        poorer.cash = 400_000
        richer.life_tile_values = []
        poorer.life_tile_values = []
        game.estates_players = [richer.id, poorer.id]
        game.estates_tile_values = [50_000, 100_000, 150_000, 250_000]

        game._begin_endgame()

        assert richer.life_tile_values == [50_000, 100_000, 150_000, 250_000]
        assert poorer.life_tile_values == []
        assert game.estates_tile_values == []

    def test_estates_cash_tie_splits_four_tiles(self):
        game = make_game(college_path=False)
        first, second = game.players
        for player in (first, second):
            player.retired = True
            player.retirement_choice = "estates"
            player.cash = 500_000
            player.life_tile_values = []
        game.estates_players = [first.id, second.id]
        game.estates_tile_values = [50_000, 100_000, 150_000, 250_000]

        game._begin_endgame()

        assert len(first.life_tile_values) == 2
        assert len(second.life_tile_values) == 2


class TestPersistenceAndBots:
    def test_round_trip_preserves_official_card_state(self):
        game = make_game(college_path=False)
        player = game.players[0]
        player.house_key = "victorian"
        player.house_label_key = "life-house-victorian"
        player.house_price = 200_000
        player.house_insurance_cost = 50_000
        player.has_fire_insurance = True
        player.stock_number = 7
        player.extra_stock_numbers = [2]
        player.life_tile_values = [50_000, 250_000]

        loaded = GameOfLifeGame.from_json(game.to_json())
        loaded_player = loaded.players[0]

        assert loaded_player.house_key == "victorian"
        assert loaded_player.house_insurance_cost == 50_000
        assert loaded_player.has_fire_insurance
        assert loaded_player.owned_stock_numbers() == [7, 2]
        assert loaded_player.life_tile_values == [50_000, 250_000]
        assert len(loaded.track) == 145

    def test_bot_loan_rule_uses_25000_repayment(self):
        player = LifePlayer(
            id="bot",
            name="Bot",
            is_bot=True,
            cash=75_000,
            college_loan=20_000,
        )
        assert life_bot.should_pay_loan(player)
        player.cash = 74_999
        assert not life_bot.should_pay_loan(player)

    def test_two_bots_complete_classic_game_with_reload(self):
        random.seed(42)
        game = GameOfLifeGame()
        first_user = Bot("Bot1")
        second_user = Bot("Bot2")
        game.add_player("Bot1", first_user)
        game.add_player("Bot2", second_user)
        game.on_start()

        for tick in range(120_000):
            if not game.game_active:
                break
            if tick and tick % 4_000 == 0:
                game = GameOfLifeGame.from_json(game.to_json())
                game.attach_user("Bot1", first_user)
                game.attach_user("Bot2", second_user)
                game.rebuild_runtime_state()
                for player in game.players:
                    game.setup_player_actions(player)
            game.on_tick()

        assert not game.game_active
        assert all(player.retired for player in game.players)
