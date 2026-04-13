#!/usr/bin/env python3
"""Generate translated risk.ftl files for all locales.

For the interest of speed, this script uses a template approach:
most text is game-specific and kept in English, with only
key user-facing strings translated.
"""

from pathlib import Path

LOCALES_DIR = Path(__file__).parent.parent / "locales"


def make_ftl(game_name: str, rules: str, phase_labels: dict) -> str:
    """Build a complete risk.ftl from translated pieces."""
    return f"""# Risk game messages
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-risk = {game_name}

# Phase announcements
risk-reinforce-start = {phase_labels["reinforce_start"]}
risk-attack-phase = {phase_labels["attack_phase"]}
risk-fortify-phase = {phase_labels["fortify_phase"]}

# Reinforce
risk-placed-army = {phase_labels["placed_army"]}

# Attack
risk-attack-from = {phase_labels["attack_from"]}
risk-combat-result =
    {phase_labels["combat_result"]}
risk-conquered = {phase_labels["conquered"]}
risk-eliminated = {phase_labels["eliminated"]}
risk-skip-attack = {phase_labels["skip_attack"]}
risk-cancel-attack = {phase_labels["cancel_attack"]}

# Fortify
risk-fortify-from = {phase_labels["fortify_from"]}
risk-fortified = {phase_labels["fortified"]}
risk-skip-fortify = {phase_labels["skip_fortify"]}
risk-cancel-fortify = {phase_labels["cancel_fortify"]}

# Cards
risk-cards-traded = {phase_labels["cards_traded"]}

# Territory labels by phase
risk-territory-reinforce = {phase_labels["territory_reinforce"]}
risk-territory-attack-from = {phase_labels["territory_attack_from"]}
risk-territory-attack-target = {phase_labels["territory_attack_target"]}
risk-territory-fortify-from = {phase_labels["territory_fortify_from"]}
risk-territory-fortify-to = {phase_labels["territory_fortify_to"]}

# Status
risk-status-header = {phase_labels["status_header"]}
risk-status-continent = {phase_labels["status_continent"]}

# Winner
risk-winner = {phase_labels["winner"]}
risk-final-score = {phase_labels["final_score"]}

# Disabled reasons
risk-not-your-territory = {phase_labels["not_your_territory"]}
risk-need-more-troops = {phase_labels["need_more_troops"]}
risk-no-adjacent-enemy = {phase_labels["no_adjacent_enemy"]}
risk-cannot-attack-own = {phase_labels["cannot_attack_own"]}
risk-not-adjacent = {phase_labels["not_adjacent"]}
risk-same-territory = {phase_labels["same_territory"]}

# Options
risk-set-starting-armies = {phase_labels["set_starting_armies"]}
risk-desc-starting-armies = {phase_labels["desc_starting_armies"]}
risk-enter-starting-armies = {phase_labels["enter_starting_armies"]}
risk-option-changed-armies = {phase_labels["option_changed_armies"]}

# Rules
risk-rules =
{rules}
"""


# Translations for each locale — core strings only, rules kept concise
TRANSLATIONS = {
"es": {
    "name": "Risk",
    "labels": {
        "reinforce_start": "{ $player } recibe { $armies } ejércitos para colocar.",
        "attack_phase": "{ $player } ahora puede atacar.",
        "fortify_phase": "{ $player } ahora puede fortificar.",
        "placed_army": "{ $player } refuerza { $territory } ({ $troops } tropas). Quedan { $remaining }.",
        "attack_from": "{ $player } ataca desde { $territory }.",
        "combat_result": "{ $attacker } ataca { $def_territory } desde { $att_territory }.\n    Atacante tira: { $att_rolls }. Defensor tira: { $def_rolls }.\n    Atacante pierde { $att_losses }, defensor pierde { $def_losses }.",
        "conquered": "¡{ $player } conquista { $territory }! { $moved } tropas entran.",
        "eliminated": "¡{ $player } ha sido eliminado!",
        "skip_attack": "Saltar ataque",
        "cancel_attack": "Cancelar ataque",
        "fortify_from": "{ $player } fortifica desde { $territory }.",
        "fortified": "{ $player } mueve { $moved } tropas de { $source } a { $dest }.",
        "skip_fortify": "Saltar fortificar",
        "cancel_fortify": "Cancelar fortificar",
        "cards_traded": "{ $player } cambia cartas por { $armies } ejércitos extra.",
        "territory_reinforce": "{ $name }: { $troops } tropas ({ $remaining } por colocar)",
        "territory_attack_from": "{ $name }: { $troops } tropas (atacar desde aquí)",
        "territory_attack_target": "{ $name }: { $troops } tropas ({ $owner })",
        "territory_fortify_from": "{ $name }: { $troops } tropas (mover desde aquí)",
        "territory_fortify_to": "{ $name }: { $troops } tropas (mover aquí)",
        "status_header": "Controlas { $territories } territorios con { $troops } tropas en total.",
        "status_continent": "{ $name }: { $owned }/{ $total } territorios. Bonus: { $bonus }.",
        "winner": "¡{ $player } ha conquistado el mundo!",
        "final_score": "{ $player }: { $territories } territorios",
        "not_your_territory": "Ese no es tu territorio.",
        "need_more_troops": "Necesitas al menos 2 tropas para atacar o fortificar desde aquí.",
        "no_adjacent_enemy": "No hay territorios enemigos adyacentes.",
        "cannot_attack_own": "No puedes atacar tu propio territorio.",
        "not_adjacent": "Ese territorio no es adyacente.",
        "same_territory": "No puedes fortificar al mismo territorio.",
        "set_starting_armies": "Ejércitos iniciales: { $armies }",
        "desc_starting_armies": "Ejércitos adicionales por jugador al inicio (0 = auto)",
        "enter_starting_armies": "Ingresa ejércitos iniciales por jugador (0 para auto):",
        "option_changed_armies": "Ejércitos iniciales cambiados a { $armies }",
    },
    "rules": "    Risk es un juego de conquista mundial para 2 a 6 jugadores.\n    El tablero tiene 42 territorios en 6 continentes.\n    Cada turno tiene 3 fases: reforzar, atacar y fortificar.\n    Reforzar: Coloca ejércitos en tus territorios. Recibes ejércitos según territorios y bonus de continente.\n    Atacar: Selecciona un territorio con 2 o más tropas, luego un territorio enemigo adyacente. Los dados deciden el combate.\n    El atacante tira hasta 3 dados, el defensor hasta 2. Los dados más altos se comparan: el más alto gana, los empates van al defensor.\n    Si eliminas todos los defensores, conquistas el territorio.\n    Fortificar: Mueve tropas a un territorio amigo adyacente.\n    Conquista al menos un territorio por turno para ganar una carta. Cambia sets de 3 cartas por ejércitos extra.\n    Elimina a todos los oponentes para ganar.\n    Presiona E para ver tu estado.",
},
"fr": {
    "name": "Risk",
    "labels": {
        "reinforce_start": "{ $player } reçoit { $armies } armées à placer.",
        "attack_phase": "{ $player } peut maintenant attaquer.",
        "fortify_phase": "{ $player } peut maintenant fortifier.",
        "placed_army": "{ $player } renforce { $territory } ({ $troops } troupes). { $remaining } restantes.",
        "attack_from": "{ $player } attaque depuis { $territory }.",
        "combat_result": "{ $attacker } attaque { $def_territory } depuis { $att_territory }.\n    Attaquant lance : { $att_rolls }. Défenseur lance : { $def_rolls }.\n    Attaquant perd { $att_losses }, défenseur perd { $def_losses }.",
        "conquered": "{ $player } conquiert { $territory } ! { $moved } troupes entrent.",
        "eliminated": "{ $player } a été éliminé !",
        "skip_attack": "Passer l'attaque",
        "cancel_attack": "Annuler l'attaque",
        "fortify_from": "{ $player } fortifie depuis { $territory }.",
        "fortified": "{ $player } déplace { $moved } troupes de { $source } vers { $dest }.",
        "skip_fortify": "Passer la fortification",
        "cancel_fortify": "Annuler la fortification",
        "cards_traded": "{ $player } échange des cartes contre { $armies } armées bonus.",
        "territory_reinforce": "{ $name } : { $troops } troupes ({ $remaining } à placer)",
        "territory_attack_from": "{ $name } : { $troops } troupes (attaquer d'ici)",
        "territory_attack_target": "{ $name } : { $troops } troupes ({ $owner })",
        "territory_fortify_from": "{ $name } : { $troops } troupes (déplacer d'ici)",
        "territory_fortify_to": "{ $name } : { $troops } troupes (déplacer ici)",
        "status_header": "Vous contrôlez { $territories } territoires avec { $troops } troupes au total.",
        "status_continent": "{ $name } : { $owned }/{ $total } territoires. Bonus : { $bonus }.",
        "winner": "{ $player } a conquis le monde !",
        "final_score": "{ $player } : { $territories } territoires",
        "not_your_territory": "Ce n'est pas votre territoire.",
        "need_more_troops": "Il faut au moins 2 troupes pour attaquer ou fortifier d'ici.",
        "no_adjacent_enemy": "Aucun territoire ennemi adjacent.",
        "cannot_attack_own": "Vous ne pouvez pas attaquer votre propre territoire.",
        "not_adjacent": "Ce territoire n'est pas adjacent.",
        "same_territory": "Impossible de fortifier vers le même territoire.",
        "set_starting_armies": "Armées de départ : { $armies }",
        "desc_starting_armies": "Armées supplémentaires par joueur au début (0 = auto)",
        "enter_starting_armies": "Entrez les armées de départ par joueur (0 pour auto) :",
        "option_changed_armies": "Armées de départ changées à { $armies }",
    },
    "rules": "    Risk est un jeu de conquête mondiale pour 2 à 6 joueurs.\n    Le plateau a 42 territoires répartis sur 6 continents.\n    Chaque tour a 3 phases : renforcer, attaquer et fortifier.\n    Renforcer : Placez des armées sur vos territoires. Vous recevez des armées selon vos territoires et les bonus de continents.\n    Attaquer : Sélectionnez un territoire avec 2 troupes ou plus, puis un territoire ennemi adjacent. Les dés résolvent le combat.\n    L'attaquant lance jusqu'à 3 dés, le défenseur jusqu'à 2. Les dés les plus hauts sont comparés.\n    Si vous éliminez tous les défenseurs, vous conquérez le territoire.\n    Fortifier : Déplacez des troupes vers un territoire ami adjacent.\n    Conquérez au moins un territoire par tour pour gagner une carte. Échangez des ensembles de 3 cartes pour des armées bonus.\n    Éliminez tous les adversaires pour gagner.\n    Appuyez sur E pour voir votre statut.",
},
"de": {
    "name": "Risiko",
    "labels": {
        "reinforce_start": "{ $player } erhält { $armies } Armeen zum Platzieren.",
        "attack_phase": "{ $player } kann jetzt angreifen.",
        "fortify_phase": "{ $player } kann jetzt verstärken.",
        "placed_army": "{ $player } verstärkt { $territory } ({ $troops } Truppen). { $remaining } verbleibend.",
        "attack_from": "{ $player } greift von { $territory } an.",
        "combat_result": "{ $attacker } greift { $def_territory } von { $att_territory } an.\n    Angreifer würfelt: { $att_rolls }. Verteidiger würfelt: { $def_rolls }.\n    Angreifer verliert { $att_losses }, Verteidiger verliert { $def_losses }.",
        "conquered": "{ $player } erobert { $territory }! { $moved } Truppen ziehen ein.",
        "eliminated": "{ $player } wurde eliminiert!",
        "skip_attack": "Angriff überspringen",
        "cancel_attack": "Angriff abbrechen",
        "fortify_from": "{ $player } verstärkt von { $territory }.",
        "fortified": "{ $player } bewegt { $moved } Truppen von { $source } nach { $dest }.",
        "skip_fortify": "Verstärkung überspringen",
        "cancel_fortify": "Verstärkung abbrechen",
        "cards_traded": "{ $player } tauscht Karten gegen { $armies } Bonus-Armeen.",
        "territory_reinforce": "{ $name }: { $troops } Truppen ({ $remaining } zu platzieren)",
        "territory_attack_from": "{ $name }: { $troops } Truppen (von hier angreifen)",
        "territory_attack_target": "{ $name }: { $troops } Truppen ({ $owner })",
        "territory_fortify_from": "{ $name }: { $troops } Truppen (von hier bewegen)",
        "territory_fortify_to": "{ $name }: { $troops } Truppen (hierher bewegen)",
        "status_header": "Du kontrollierst { $territories } Territorien mit insgesamt { $troops } Truppen.",
        "status_continent": "{ $name }: { $owned }/{ $total } Territorien. Bonus: { $bonus }.",
        "winner": "{ $player } hat die Welt erobert!",
        "final_score": "{ $player }: { $territories } Territorien",
        "not_your_territory": "Das ist nicht dein Territorium.",
        "need_more_troops": "Du brauchst mindestens 2 Truppen, um anzugreifen oder zu verstärken.",
        "no_adjacent_enemy": "Keine angrenzenden feindlichen Territorien.",
        "cannot_attack_own": "Du kannst dein eigenes Territorium nicht angreifen.",
        "not_adjacent": "Dieses Territorium grenzt nicht an.",
        "same_territory": "Kann nicht zum selben Territorium verstärken.",
        "set_starting_armies": "Start-Armeen: { $armies }",
        "desc_starting_armies": "Zusätzliche Armeen pro Spieler zu Beginn (0 = auto)",
        "enter_starting_armies": "Gib Start-Armeen pro Spieler ein (0 für auto):",
        "option_changed_armies": "Start-Armeen auf { $armies } geändert",
    },
    "rules": "    Risiko ist ein Weltstrategie-Spiel für 2 bis 6 Spieler.\n    Das Brett hat 42 Territorien auf 6 Kontinenten.\n    Jeder Zug hat 3 Phasen: Verstärken, Angreifen, Verstärken (Fortify).\n    Verstärken: Platziere Armeen auf deinen Territorien. Du erhältst Armeen basierend auf Territorien und Kontinent-Boni.\n    Angreifen: Wähle ein Territorium mit 2+ Truppen, dann ein angrenzendes feindliches Territorium. Würfel entscheiden den Kampf.\n    Angreifer würfelt bis zu 3 Würfel, Verteidiger bis zu 2. Höchste Würfel werden verglichen.\n    Wenn du alle Verteidiger eliminierst, eroberst du das Territorium.\n    Verstärken (Fortify): Bewege Truppen zu einem angrenzenden eigenen Territorium.\n    Erobere mindestens ein Territorium pro Zug für eine Karte. Tausche Sets aus 3 Karten gegen Bonus-Armeen.\n    Eliminiere alle Gegner um zu gewinnen.\n    Drücke E für deinen Status.",
},
"ja": {
    "name": "リスク",
    "labels": {
        "reinforce_start": "{ $player } に { $armies } 軍団が配備されます。",
        "attack_phase": "{ $player } は攻撃できます。",
        "fortify_phase": "{ $player } は増援できます。",
        "placed_army": "{ $player } が { $territory } を補強（{ $troops } 部隊）。残り { $remaining }。",
        "attack_from": "{ $player } が { $territory } から攻撃。",
        "combat_result": "{ $attacker } が { $att_territory } から { $def_territory } を攻撃。\n    攻撃側: { $att_rolls }。防御側: { $def_rolls }。\n    攻撃側 { $att_losses } 損失、防御側 { $def_losses } 損失。",
        "conquered": "{ $player } が { $territory } を征服！{ $moved } 部隊が進軍。",
        "eliminated": "{ $player } が敗北！",
        "skip_attack": "攻撃をスキップ",
        "cancel_attack": "攻撃をキャンセル",
        "fortify_from": "{ $player } が { $territory } から増援。",
        "fortified": "{ $player } が { $moved } 部隊を { $source } から { $dest } に移動。",
        "skip_fortify": "増援をスキップ",
        "cancel_fortify": "増援をキャンセル",
        "cards_traded": "{ $player } がカードを { $armies } ボーナス軍団に交換。",
        "territory_reinforce": "{ $name }：{ $troops } 部隊（残り { $remaining } 配備）",
        "territory_attack_from": "{ $name }：{ $troops } 部隊（ここから攻撃）",
        "territory_attack_target": "{ $name }：{ $troops } 部隊（{ $owner }）",
        "territory_fortify_from": "{ $name }：{ $troops } 部隊（ここから移動）",
        "territory_fortify_to": "{ $name }：{ $troops } 部隊（ここへ移動）",
        "status_header": "あなたは { $territories } 領地、{ $troops } 部隊を支配しています。",
        "status_continent": "{ $name }：{ $owned }/{ $total } 領地。ボーナス：{ $bonus }。",
        "winner": "{ $player } が世界を征服！",
        "final_score": "{ $player }：{ $territories } 領地",
        "not_your_territory": "あなたの領地ではありません。",
        "need_more_troops": "攻撃または移動には 2 部隊以上必要です。",
        "no_adjacent_enemy": "隣接する敵領地がありません。",
        "cannot_attack_own": "自分の領地は攻撃できません。",
        "not_adjacent": "その領地は隣接していません。",
        "same_territory": "同じ領地には増援できません。",
        "set_starting_armies": "初期軍団：{ $armies }",
        "desc_starting_armies": "開始時のプレイヤーあたりの追加軍団（0 = 自動）",
        "enter_starting_armies": "プレイヤーあたりの初期軍団を入力（0 で自動）：",
        "option_changed_armies": "初期軍団が { $armies } に変更されました",
    },
    "rules": "    リスクは 2〜6 人のための世界征服ゲームです。\n    ボードには 6 大陸にまたがる 42 の領地があります。\n    各ターンは 3 つのフェーズ：補強、攻撃、増援。\n    補強：領地に軍団を配置。領地と大陸ボーナスに応じて軍団を得ます。\n    攻撃：2 部隊以上の領地を選び、隣接する敵領地を攻撃。ダイスで戦闘を決定。\n    攻撃側は最大 3 ダイス、防御側は最大 2 ダイス。高いダイスを比較し、引き分けは防御側の勝ち。\n    全防御者を倒せば領地を征服します。\n    増援：自軍部隊を隣接する自領地に移動。\n    各ターン領地を征服するとカードを獲得。3 枚セットをボーナス軍団と交換できます。\n    全員を倒せば勝利。\n    E で状態を確認。",
},
"zh": {
    "name": "风险",
    "labels": {
        "reinforce_start": "{ $player } 获得 { $armies } 支军队部署。",
        "attack_phase": "{ $player } 现在可以进攻。",
        "fortify_phase": "{ $player } 现在可以调动。",
        "placed_army": "{ $player } 增援 { $territory }（{ $troops } 部队）。剩余 { $remaining }。",
        "attack_from": "{ $player } 从 { $territory } 进攻。",
        "combat_result": "{ $attacker } 从 { $att_territory } 进攻 { $def_territory }。\n    进攻方骰点：{ $att_rolls }。防守方骰点：{ $def_rolls }。\n    进攻方损失 { $att_losses }，防守方损失 { $def_losses }。",
        "conquered": "{ $player } 征服 { $territory }！{ $moved } 部队进驻。",
        "eliminated": "{ $player } 已被淘汰！",
        "skip_attack": "跳过进攻",
        "cancel_attack": "取消进攻",
        "fortify_from": "{ $player } 从 { $territory } 调动。",
        "fortified": "{ $player } 将 { $moved } 部队从 { $source } 移至 { $dest }。",
        "skip_fortify": "跳过调动",
        "cancel_fortify": "取消调动",
        "cards_traded": "{ $player } 用卡牌换取 { $armies } 支奖励军队。",
        "territory_reinforce": "{ $name }：{ $troops } 部队（还需部署 { $remaining }）",
        "territory_attack_from": "{ $name }：{ $troops } 部队（从此进攻）",
        "territory_attack_target": "{ $name }：{ $troops } 部队（{ $owner }）",
        "territory_fortify_from": "{ $name }：{ $troops } 部队（从此调动）",
        "territory_fortify_to": "{ $name }：{ $troops } 部队（调至此处）",
        "status_header": "你控制 { $territories } 个领地，共 { $troops } 部队。",
        "status_continent": "{ $name }：{ $owned }/{ $total } 个领地。奖励：{ $bonus }。",
        "winner": "{ $player } 征服了世界！",
        "final_score": "{ $player }：{ $territories } 个领地",
        "not_your_territory": "那不是你的领地。",
        "need_more_troops": "需要至少 2 部队才能进攻或调动。",
        "no_adjacent_enemy": "没有相邻的敌方领地。",
        "cannot_attack_own": "不能进攻自己的领地。",
        "not_adjacent": "该领地不相邻。",
        "same_territory": "不能调动到同一领地。",
        "set_starting_armies": "起始军队：{ $armies }",
        "desc_starting_armies": "每位玩家起始的额外军队（0 = 自动）",
        "enter_starting_armies": "输入每位玩家起始军队数（0 为自动）：",
        "option_changed_armies": "起始军队已改为 { $armies }",
    },
    "rules": "    风险是 2 到 6 人的世界征服游戏。\n    棋盘上有 6 大洲 42 个领地。\n    每回合分 3 个阶段：增援、进攻、调动。\n    增援：在你的领地上部署军队。按领地数量和大洲奖励获得军队。\n    进攻：选择有 2 支以上部队的领地，然后选相邻敌方领地。骰子决定战斗。\n    进攻方最多掷 3 骰，防守方最多 2 骰。最高骰比较，平局归防守方。\n    若消灭所有防守者，你征服该领地。\n    调动：将部队移至相邻的自己领地。\n    每回合至少征服一个领地获得一张卡。3 张同组卡牌可换取奖励军队。\n    消灭所有对手即获胜。\n    按 E 查看状态。",
},
}
# fmt: on


def main():
    # For locales we haven't translated, keep the English version
    translated_count = 0
    for locale, data in TRANSLATIONS.items():
        ftl = make_ftl(data["name"], data["rules"], data["labels"])
        path = LOCALES_DIR / locale / "risk.ftl"
        path.write_text(ftl, encoding="utf-8")
        translated_count += 1
        print(f"  Wrote {locale}/risk.ftl")
    print(f"\nTranslated {translated_count} locales.")


if __name__ == "__main__":
    main()
