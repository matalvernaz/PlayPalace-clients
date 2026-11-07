# lightturret.ftl for locale cs. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

# Název hry
game-name-lightturret = Světelná věž
# Úvod
lightturret-intro = Light Turret začala! Každý hráč má věž s { $power } silou. Střílej do věže pro získání světla a mincí, ale pokud tvé světlo překročí tvou sílu, jsi vyřazen! Kupuj vylepšení za mince pro zvýšení své síly. Hráč s nejvíce světlem na konci vyhrává!
# Akce
lightturret-shoot = Střelit do věže
lightturret-upgrade = Koupit vylepšení (10 mincí)
lightturret-check-stats = Zkontrolovat statistiky
lightturret-not-enough-coins =
    Nemáte dost mincí! Potřebujete { $need } { $need ->
        [one] minci
        [few] mince
        [many] mince
       *[other] mincí
    }, ale máte jen { $have }.
# Důvody zakázaných akcí
lightturret-you-are-eliminated = Byli jste vyřazeni.
# Statistiky
lightturret-stats-alive = { $player }: { $power } síly, { $light } světla, { $coins } mincí.
lightturret-stats-eliminated = { $player }: vyřazen s { $light } světlem.
# Možnosti
lightturret-set-starting-power = Počáteční síla: { $power }
lightturret-enter-starting-power = Zadejte počáteční sílu:
lightturret-option-changed-power = Počáteční síla nastavena na { $power }.
lightturret-set-max-rounds = Maximum kol: { $rounds }
lightturret-enter-max-rounds = Zadejte maximum kol:
lightturret-option-changed-rounds = Maximum kol nastaveno na { $rounds }.
