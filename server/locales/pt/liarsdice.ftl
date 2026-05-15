# Liar's Dice — pt
game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Cada jogador lança seus dados em segredo sob o copo. À vez, sobe-se a aposta sobre o total de uma face em toda a mesa — ou grita-se "Mentira!" se não acreditar na última aposta. Errar custa um dado. Vence o último com dados.

liarsdice-rules =
    Liar's Dice é um jogo de blefe com dados para 2 a 6 jogadores.
    Cada jogador começa com 5 dados no copo. No início de cada ronda, todos lançam em segredo.
    À vez, fazem-se apostas sobre o total de uma face em todos os dados — por exemplo, "três 4" significa que há pelo menos três 4 quando todos os copos forem revelados.
    Cada nova aposta deve ser mais alta: mesma face com maior quantidade, ou face mais alta com quantidade igual ou superior.
    Os 1 são curingas — contam para qualquer aposta exceto quando se aposta em 1s.
    Trocar para uma aposta em 1s reduz a quantidade pela metade (arredondada para cima). Voltar de 1s para uma face normal exige mais do dobro da quantidade anterior.
    Em vez de apostar, podes gritar "Mentira!" para contestar a última aposta. Todos os copos para cima: se a aposta estava certa, quem contestou perde um dado; caso contrário, quem apostou perde um dado.
    Com Spot On ativado podes gritar "Spot On" apostando que a aposta é exatamente correta. Se acertares, todos os outros perdem um dado; se não, perdes dois.
    Eliminado ao chegar a zero dados. Vence quem ainda tiver dados.
    Carrega S para verificar a mesa.

ld-set-starting-dice = Dados iniciais por jogador: { $dice }
ld-desc-starting-dice = Quantos dados cada jogador começa. Padrão 5. Mais dados = partidas mais longas e mais espaço para blefar.
ld-prompt-starting-dice = Introduz os dados iniciais (3 a 8)
ld-option-changed-starting-dice = Dados iniciais definidos para { $dice }.

ld-toggle-wild-ones = 1 são curingas: { $enabled }
ld-desc-wild-ones = Ativo: 1 contam para qualquer aposta não em 1s. Apostar em 1s desativa os curingas nessa aposta. Desativo, o jogo é pura probabilidade sem curinga.
ld-option-changed-wild-ones = Curingas 1 { $enabled }.

ld-toggle-spot-on = Chamada Spot On ativa: { $enabled }
ld-desc-spot-on = Ativo: além de "Mentira", podes chamar "Spot On" apostando que a aposta é exatamente correta. Se acertares, os outros perdem um dado. Se errares, perdes dois. Alto risco, alta recompensa.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Ronda { $round } começa. Total de dados na mesa: { $total }. Todos lançam.
ld-your-roll = Os teus dados nesta ronda: { $dice }.
ld-your-counts = Os teus contagens: { $counts }.
ld-turn-start = Vez de { $player }. { $bid_state }
ld-no-bid-yet = Sem aposta — abre a ronda.
ld-current-bid = Aposta atual: { $quantity } { $face }.

ld-action-bid = Fazer uma aposta
ld-action-call-liar = Chamar Mentira
ld-action-call-spot-on = Chamar Spot On
ld-bid-prompt = Escolhe a tua aposta.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Apostas { $quantity } { $face }.
    *[player] { $player } aposta { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Chamas Mentira na aposta de { $target } de { $quantity } { $face }.
    *[player] { $player } chama Mentira na aposta de { $target } de { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Chamas Spot On na aposta de { $target } de { $quantity } { $face }.
    *[player] { $player } chama Spot On na aposta de { $target } de { $quantity } { $face }.
}
ld-reveal-header = Copos para cima! A contar os { $face } na mesa.
ld-reveal-line = { $player } tirou: { $dice }.
ld-actual-count = Contagem real de { $face } (com 1 curingas): { $count }. A aposta era { $quantity }.
ld-actual-count-no-wild = Contagem real de { $face } (sem curingas): { $count }. A aposta era { $quantity }.

ld-liar-bidder-loses = { $bidder } apostou demais — perde um dado.
ld-liar-caller-loses = A aposta era honesta — { $caller } perde um dado.
ld-spot-on-correct = Spot on! { $caller } acertou exatamente — todos os outros perdem um dado.
ld-spot-on-wrong = Não é spot on. { $caller } perde dois dados.

ld-lost-die = { $who ->
    [you] Perdes um dado. Ficas com { $remaining } { $remaining ->
        [one] dado
        *[other] dados
    }.
    *[player] { $player } perde um dado. Fica com { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Perdes { $count } dados. Ficas com { $remaining } { $remaining ->
        [one] dado
        *[other] dados
    }.
    *[player] { $player } perde { $count } dados. Fica com { $remaining }.
}
ld-eliminated = { $player } está sem dados e é eliminado! Restam { $remaining } { $remaining ->
    [one] jogador
    *[other] jogadores
}.
ld-winner = { $player } é o último com dados — vence!

ld-status-round = Ronda { $round }.
ld-status-your-dice = Os teus dados: { $dice }.
ld-status-your-counts = As tuas contagens: { $counts }.
ld-status-no-dice = Não tens dados — foste eliminado.
ld-status-current-bid = Aposta atual: { $quantity } { $face }.
ld-status-no-bid = Sem aposta nesta ronda.
ld-status-table-total = Total de dados na mesa: { $total }.
ld-status-detailed-header = Estado detalhado — { $count } jogadores restantes.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] dado
    *[other] dados
}.
ld-status-detailed-out = { $player }: eliminado.
ld-status-detailed-self-suffix = {" "}(tu)

ld-face-1 = uns
ld-face-2 = duques
ld-face-3 = ternos
ld-face-4 = quatros
ld-face-5 = quinas
ld-face-6 = seias

ld-action-not-your-turn = Não é a tua vez.
ld-action-not-playing = O jogo não está em curso.
ld-action-no-bid-to-call = Sem aposta para contestar.
ld-action-eliminated = Estás eliminado.
