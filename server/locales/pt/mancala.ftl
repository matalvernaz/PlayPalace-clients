# Mancala game messages — pt
# Note: Common messages like round-start, turn-start are in games.ftl

# Game info
game-name-mancala = Mancala

# Actions
mancala-pit-label = Cova { $pit }: { $stones } pedras

# Game events
mancala-sow = { $player } semeia { $stones } pedras da cova { $pit }
mancala-capture = { $player } captura { $captured } pedras!
mancala-extra-turn = Última pedra no depósito! { $player } joga novamente.
mancala-winner = { $player } vence com { $score } pedras!
mancala-draw = Empate! Ambos jogadores têm { $score } pedras.

# Board status
mancala-board-status =
    Suas covas: { $own_pits }. Seu depósito: { $own_store }. Covas do oponente: { $opp_pits }. Depósito do oponente: { $opp_store }.

# Options
mancala-set-stones = Pedras por cova: { $stones }
mancala-desc-stones = Número de pedras em cada cova no início
mancala-enter-stones = Digite o número de pedras iniciais por cova:
mancala-option-changed-stones = Pedras iniciais alteradas para { $stones }

# Disabled reasons
mancala-pit-empty = Essa cova está vazia.

# Rules
mancala-rules =
    Mancala é um jogo de covas e pedras para dois jogadores.
    Cada jogador tem 6 covas e um depósito.
    No seu turno, escolha uma de suas covas para semear.
    As pedras são colocadas uma a uma em cada cova ao redor do tabuleiro, incluindo seu depósito mas pulando o do oponente.
    Se a última pedra cair no seu depósito, você joga novamente.
    Se a última pedra cair numa cova vazia do seu lado, você captura essa pedra e todas as da cova oposta.
    O jogo termina quando um lado está completamente vazio.
    O jogador com mais pedras vence.
    Use as teclas 1 a 6 para escolher uma cova. Pressione E para verificar o tabuleiro.

# End screen
mancala-final-score = { $player }: { $score } pedras
