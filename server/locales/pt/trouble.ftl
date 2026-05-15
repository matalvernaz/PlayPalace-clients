# Trouble — pt
game-name-trouble = Trouble

trouble-rules =
    Trouble é um jogo de corrida da família Parcheesi.
    Cada jogador começa com as suas peças na Casa.
    No teu turno, dispara o dado e move uma das tuas peças.
    Por padrão precisas tirar um 6 para libertar uma peça da Casa para a pista.
    Por padrão, tirar um 6 também concede um turno extra.
    As peças avançam no sentido horário pela pista partilhada até à zona de chegada.
    Cair sobre a peça de um adversário envia-a de volta para a sua Casa, exceto se a casa estiver protegida.
    Quando todas as tuas peças chegam à meta, ganhas.
    No modo equipa, a tua equipa ganha quando todos os companheiros terminam.
    Usa as teclas 1 a 6 para escolher uma peça a mover, ou R para lançar.
    Carrega E para ouvir o estado completo do tabuleiro a qualquer momento.

trouble-action-roll = Disparar o dado
trouble-action-move-token = Mover peça { $token }
trouble-action-check-board = Ver tabuleiro

trouble-token-label-home = Peça { $token }: na Casa
trouble-token-label-track = Peça { $token }: casa { $position } da pista
trouble-token-label-finish-lane = Peça { $token }: corredor de chegada { $position } de { $total }
trouble-token-label-finished = Peça { $token }: terminada

trouble-rolled = { $player } tirou um { $roll }.
trouble-leave-home = { $player } liberta a peça { $token } para a pista.
trouble-advance-track = { $player } move a peça { $token } para a casa { $position }.
trouble-enter-finish-lane = { $player } leva a peça { $token } para o corredor de chegada.
trouble-advance-finish-lane =
    { $player } avança a peça { $token } para a casa { $position } de { $total } do corredor de chegada.
trouble-token-finished = A peça { $token } de { $player } chega à meta.
trouble-bump =
    A peça { $token } de { $player } manda a peça { $opp_token } de { $opponent } de volta para Casa.
trouble-no-legal-move = { $player } não tem jogadas válidas. O turno passa.
trouble-extra-turn = { $player } ganha um turno extra pelo 6.

trouble-winner = { $player } vence! Todas as peças na meta.
trouble-team-winner = A equipa { $team } vence! Todos os companheiros terminaram.
trouble-final-standing = { $player }: { $finished } peças na meta de { $total }.

trouble-turn-summary =
    Tens { $own_home } na Casa, { $own_track } na pista, { $own_finished } na meta.
    Adversários: { $opponents }.
trouble-opponent-summary = { $name }: { $home } casa, { $track } pista, { $finished } meta

trouble-board-status =
    As tuas peças: { $own_tokens }.
    Peças adversárias: { $opp_tokens }.

trouble-reason-not-rolled = Dispara primeiro o dado.
trouble-reason-already-rolled = Já disparaste. Escolhe uma peça para mover.
trouble-reason-no-legal-moves = Sem jogadas legais para este lançamento.
trouble-reason-token-home-needs-six = Esta peça está na Casa. Precisas de um 6 para libertá-la.
trouble-reason-token-home-needs-any = Esta peça está na Casa. Qualquer lançamento liberta.
trouble-reason-token-home-no-qualifying-roll =
    Esta peça está na Casa e o teu lançamento não basta para libertá-la.
trouble-reason-token-finished = Esta peça já terminou.
trouble-reason-overshoot-wastes = Esta peça não pode mover { $roll } casas sem ultrapassar a meta.
trouble-reason-blocked = Este movimento está bloqueado.

trouble-option-track-size = Tamanho da pista: { $track_size } casas
trouble-option-select-track-size = Seleciona o número de casas da pista.
trouble-option-changed-track-size = Pista definida em { $track_size } casas.
trouble-option-desc-track-size = Número de casas na pista partilhada.

trouble-option-tokens-per-player = Peças por jogador: { $tokens }
trouble-option-enter-tokens-per-player = Introduz peças por jogador (2 a 6):
trouble-option-changed-tokens-per-player = Peças por jogador definidas em { $tokens }.
trouble-option-desc-tokens-per-player = Número de peças que cada jogador leva à meta.

trouble-option-extra-turn-on-six = Turno extra ao tirar 6: { $enabled }
trouble-option-changed-extra-turn-on-six = Turno extra ao 6 { $enabled ->
    [on] ativado.
    [off] desativado.
   *[other] atualizado.
}
trouble-option-desc-extra-turn-on-six =
    Ativo: um 6 concede um turno extra (regra clássica Hasbro).

trouble-option-six-to-leave-home = Exigir 6 para sair da Casa: { $enabled }
trouble-option-changed-six-to-leave-home = Seis para sair da Casa { $enabled ->
    [on] ativado.
    [off] desativado.
   *[other] atualizado.
}
trouble-option-desc-six-to-leave-home =
    Ativo: o jogador precisa de um 6 para libertar uma peça da Casa. Desativo: qualquer lançamento liberta.

trouble-option-safe-spaces = Casas seguras: { $mode }
trouble-option-select-safe-spaces = Seleciona o modo de casas seguras.
trouble-option-changed-safe-spaces = Casas seguras definidas em { $mode }.
trouble-option-desc-safe-spaces = Define se as peças podem ser protegidas dos choques.

trouble-safe-mode-none = Nenhuma
trouble-safe-mode-home-stretch = Só na reta final
trouble-safe-mode-every-seventh = A cada 7 casas

trouble-option-finish-behavior = Meta: { $mode }
trouble-option-select-finish-behavior = Seleciona o comportamento de chegada.
trouble-option-changed-finish-behavior = Comportamento de meta definido em { $mode }.
trouble-option-desc-finish-behavior = Como lidar com um lançamento que passa da meta.

trouble-finish-mode-exact = Lançamento exato necessário
trouble-finish-mode-bounce = Excesso ressalta
trouble-finish-mode-allow = Excesso permitido

trouble-option-bot-difficulty = Dificuldade do bot: { $level }
trouble-option-select-bot-difficulty = Seleciona a dificuldade do bot.
trouble-option-changed-bot-difficulty = Dificuldade do bot definida em { $level }.
trouble-option-desc-bot-difficulty = Força dos bots integrados.

trouble-bot-difficulty-naive = Ingénuo
trouble-bot-difficulty-greedy = Ganancioso

trouble-option-preset = Predefinição: { $preset }
trouble-option-select-preset = Escolhe uma variante. O anfitrião pode ajustar regras individuais depois.
trouble-option-changed-preset = Predefinição aplicada: { $preset }.
trouble-option-desc-preset = Conjuntos de opções predefinidos para variantes comuns.

trouble-preset-classic = Clássico Hasbro
trouble-preset-fast = Rápido
trouble-preset-brutal = Brutal
trouble-preset-custom = Personalizado
