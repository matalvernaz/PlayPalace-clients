# games.ftl for locale pt. Messages missing here are spoken in English.
# Merged from PlayAural and this server by tools/merge_playaural_locales.py.

game-round-start = Rodada { $round }.
game-round-end = Rodada { $round } concluída.
game-turn-start = É a vez de { $player }.
game-turn-start-you = É a sua vez.
game-turn-start-player = É a vez de { $player }.
game-no-turn = Não é a vez de ninguém no momento.
game-score-line = { $player }: { $score } { $unit }
game-score-line-target = { $player }: { $score }/{ $target } { $unit }
game-score-unit-points =
    { $count ->
        [one] ponto
       *[other] pontos
    }
game-score-unit-chips =
    { $count ->
        [one] ficha
       *[other] fichas
    }
game-score-unit-coins =
    { $count ->
        [one] moeda
       *[other] moedas
    }
game-score-unit-health = vida
game-score-unit-ninetynine-tokens =
    { $count ->
        [one] ficha
       *[other] fichas
    }
game-score-unit-tokens-home =
    { $count ->
        [one] ficha na base
       *[other] fichas na base
    }
game-score-unit-pawns-home =
    { $count ->
        [one] peão em casa
       *[other] peões em casa
    }
game-score-unit-hand-wins =
    { $count ->
        [one] vitória de mão
       *[other] vitórias de mão
    }
game-score-unit-light = luz
game-final-scores-header = Placar final:
game-winner = { $player } venceu!
game-winner-you = Você venceu!
game-winner-score = { $player } venceu com { $score } pontos!
game-tiebreaker = Empate! Rodada de desempate!
game-eliminated = { $player } foi eliminado com { $score } pontos.
game-set-target-score = Pontuação alvo: { $score }
game-enter-target-score = Digite a pontuação alvo:
game-option-changed-target = Pontuação alvo definida para { $score }.
game-set-team-mode = Modo de equipe: { $mode }
game-select-team-mode = Selecionar modo de equipe
game-option-changed-team = Modo de equipe definido para { $mode }.
game-team-mode-individual = Individual
game-team-mode-x-teams-of-y = { $num_teams } equipes de { $team_size }
game-team-name = Equipe { $index }
team-arrangement-started = Organização de equipes iniciada. Revise as equipes, troque membros se necessário e confirme para começar.
team-arrangement-confirm = Confirmar equipes e iniciar
team-arrangement-read = Ler equipes
team-arrangement-select-member-action = Selecionar membro da equipe
team-arrangement-select-member = Selecione um membro da equipe
team-arrangement-select-swap-target = Selecione um jogador para trocar
team-arrangement-swap-member = Escolher alvo para troca
team-arrangement-swap-member-selected = Trocar { $player } com...
team-arrangement-cancel = Cancelar organização de equipes
team-arrangement-line = { $team }: { $members }
team-arrangement-turn-order = Ordem dos turnos: { $players }
team-arrangement-member-option = { $player }, { $team }, { $selected }
team-arrangement-selected = selecionado
team-arrangement-not-selected = não selecionado
team-arrangement-member-selected = { $player } da { $team } selecionado. Escolha um jogador de outra equipe para trocar.
team-arrangement-swapped-player = { $player } trocou { $first } e { $second } entre as equipes.
team-arrangement-swapped-you = Você trocou { $first } e { $second } entre as equipes.
team-arrangement-cancelled = Organização de equipes cancelada.
team-arrangement-cancelled-roster = Organização de equipes cancelada porque a lista de jogadores foi alterada.
team-arrangement-refreshed = A lista de jogadores mudou. A organização de equipes foi atualizada.
team-arrangement-in-progress = Termine ou cancele a organização de equipes primeiro.
team-arrangement-not-active = A organização de equipes não está ativa.
team-arrangement-select-first = Selecione um membro da equipe primeiro.
team-arrangement-player-missing = Esse jogador não está mais disponível para a organização de equipes.
team-arrangement-same-team = Escolha alguém de uma equipe diferente.
team-arrangement-swap-failed = Não foi possível trocar esses membros da equipe.
status-box-closed = Informações de status fechadas.
game-leave = Sair do jogo
round-timer-paused = { $player } pausou o jogo (pressione p para iniciar a próxima rodada).
round-timer-paused-you = Você pausou o jogo (pressione p para iniciar a próxima rodada).
dice-keeping = Mantendo { $value }.
dice-rerolling = Rolar novamente { $value }.
dice-locked = Esse dado está travado e não pode ser alterado.
dice-status-label-locked = { $value } (travado)
dice-status-label-kept = { $value } (mantido)
game-deal-counter = Distribuindo { $current }/{ $total }.
game-you-deal = Você distribui as cartas.
game-player-deals = { $player } distribui as cartas.
card-name = { $rank } de { $suit }
no-cards = Sem cartas
suit-diamonds = ouros
suit-clubs = paus
suit-hearts = copas
suit-spades = espadas
rank-ace = ás
rank-two = 2
rank-three = 3
rank-four = 4
rank-five = 5
rank-six = 6
rank-seven = 7
rank-eight = 8
rank-nine = 9
rank-ten = 10
rank-jack = valete
rank-queen = dama
rank-king = rei
rank-ace-plural = áses
rank-two-plural = 2s
rank-three-plural = 3s
rank-four-plural = 4s
rank-five-plural = 5s
rank-six-plural = 6s
rank-seven-plural = 7s
rank-eight-plural = 8s
rank-nine-plural = 9s
rank-ten-plural = 10s
rank-jack-plural = valetes
rank-queen-plural = damas
rank-king-plural = reis
poker-high-card-with = Carta alta: { $high }, com { $rest }
poker-high-card = Carta alta: { $high }
poker-pair-with = Um par de { $pair }, com { $rest }
poker-pair = Um par de { $pair }
poker-two-pair-with = Dois pares, { $high } e { $low }, com { $kicker }
poker-two-pair = Dois pares, { $high } e { $low }
poker-trips-with = Trinca de { $trips }, com { $rest }
poker-trips = Trinca de { $trips }
poker-straight-high = Sequência alta de { $high }
poker-flush-high-with = Flush alto de { $high }, com { $rest }
poker-full-house = Full House, { $trips } sobre { $pair }
poker-quads-with = Quadra de { $quads }, com { $kicker }
poker-quads = Quadra de { $quads }
poker-royal-flush = Royal Flush
poker-straight-flush-high = Straight Flush alto de { $high }
poker-unknown-hand = Mão desconhecida
game-error-invalid-team-mode = O modo de equipe selecionado não é válido para o número atual de jogadores.
documentation-menu = Documentação
introduction = Introdução
community-rules = Regras da Comunidade
global-keys = Controles Globais
game-rules = Regras do Jogo
changelog = Histórico de Alterações
donation = Doação
document-not-found = Documento não encontrado.
help = Ajuda
# Game Info (Ctrl+I)
game-info = Informações do Jogo
game-info-header = Informações do Jogo Atual
game-info-name = Jogo: { $game }
game-info-players = Jogadores: { $count }
game-info-host = Anfitrião: { $host }
game-info-status = Status: { $status }
game-info-status-waiting = Aguardando no lobby
game-info-status-playing = Em andamento
game-info-options-header = Configurações:
game-info-no-options = Este jogo não possui opções de configuração personalizadas.
# How to Play (Ctrl+F1)
how-to-play = Como Jogar
game-rules-not-available = As regras para { $game } ainda não estão disponíveis.
game-your-turn = Sua vez.
# Exibição de pontuação
game-scores-header = Pontuação Atual:
game-tiebreaker-players = Empate entre { $players }! Rodada de desempate!
round-timer-resumed = Temporizador retomado.
round-timer-countdown = Próxima rodada em { $seconds }...
dice-status-locked = locked
dice-status-kept = kept
# Colors (with gendered forms: m = masculine, f = feminine)
color-black = preto
color-black-m = preto
color-black-f = preta
color-blue = azul
color-blue-m = azul
color-blue-f = azul
color-brown = castanho
color-brown-m = castanho
color-brown-f = castanha
color-gray = cinzento
color-gray-m = cinzento
color-gray-f = cinzenta
color-green = verde
color-green-m = verde
color-green-f = verde
color-indigo = índigo
color-indigo-m = índigo
color-indigo-f = índigo
color-orange = laranja
color-orange-m = laranja
color-orange-f = laranja
color-pink = rosa
color-pink-m = rosa
color-pink-f = rosa
color-purple = roxo
color-purple-m = roxo
color-purple-f = roxa
color-red = vermelho
color-red-m = vermelho
color-red-f = vermelha
color-violet = violeta
color-violet-m = violeta
color-violet-f = violeta
color-white = branco
color-white-m = branco
color-white-f = branca
color-yellow = amarelo
color-yellow-m = amarelo
color-yellow-f = amarela
team-arrangement-swapped = { $first } and { $second } have swapped teams.
contact = Contact
