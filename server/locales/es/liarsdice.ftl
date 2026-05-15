# Liar's Dice — es
# Cada jugador tiene un cubilete con dados; las apuestas se hacen sobre el total
# de una cara en toda la mesa. Los 1 son comodines salvo cuando apuestas a 1s.

game-name-liarsdice = Liar's Dice
game-liarsdice-desc = Cada jugador tira sus dados en secreto bajo el cubilete. Por turnos, las apuestas crecen sobre el total de una cara en toda la mesa — o canta "¡Mentira!" si no te crees la última apuesta. Pierdes un dado si te equivocas. Gana el último con dados.

liarsdice-rules =
    Liar's Dice es un juego de farol con dados, de 2 a 6 jugadores.
    Cada jugador empieza con 5 dados en un cubilete. Al inicio de cada ronda, todos tiran en secreto.
    Por turnos hacéis apuestas sobre el total de una cara en toda la mesa — por ejemplo, "tres 4" significa que hay al menos tres 4 cuando se descubran los cubiletes.
    Cada apuesta nueva debe ser más alta que la anterior: misma cara con mayor cantidad, o cara mayor con cantidad igual o mayor.
    Los 1 son comodines — cuentan para cualquier apuesta salvo si la apuesta es sobre 1s.
    Pasar a apostar a 1s reduce la cantidad a la mitad (redondeando hacia arriba). Volver de 1s a otra cara exige más del doble de la cantidad anterior.
    En vez de apostar puedes cantar "¡Mentira!" para retar la apuesta anterior. Se descubren los cubiletes: si la apuesta era correcta, el retador pierde un dado; si no, el apostador pierde un dado.
    Con Spot On activado puedes cantar "Spot On" para apostar a que la apuesta es exactamente correcta. Si aciertas, todos los demás pierden un dado; si fallas, pierdes dos dados.
    Quedas eliminado al llegar a cero dados. Gana quien aún tenga dados.
    Pulsa S para revisar la mesa.

ld-set-starting-dice = Dados iniciales por jugador: { $dice }
ld-desc-starting-dice = Con cuántos dados empieza cada jugador. Por defecto 5. Más dados = partidas más largas y más margen para el farol.
ld-prompt-starting-dice = Introduce los dados iniciales (3 a 8)
ld-option-changed-starting-dice = Dados iniciales fijados en { $dice }.

ld-toggle-wild-ones = Los 1 son comodines: { $enabled }
ld-desc-wild-ones = Cuando está activado, los 1 cuentan para cualquier apuesta que no sea de 1s. Apostar a 1s desactiva los comodines en esa apuesta. Apagado hace el juego puramente de probabilidad, sin comodín.
ld-option-changed-wild-ones = 1 comodines { $enabled }.

ld-toggle-spot-on = Cantar Spot On activado: { $enabled }
ld-desc-spot-on = Cuando está activado, además de "Mentira", puedes cantar "Spot On" apostando a que la cantidad es exactamente la apostada. Si aciertas, los demás pierden un dado. Si fallas, pierdes dos. Alto riesgo, alta recompensa.
ld-option-changed-spot-on = Spot On { $enabled }.

ld-round-start = Empieza la ronda { $round }. Dados totales en la mesa: { $total }. Todos tiran.
ld-your-roll = Tus dados esta ronda: { $dice }.
ld-your-counts = Tus cuentas: { $counts }.
ld-turn-start = Turno de { $player }. { $bid_state }
ld-no-bid-yet = Sin apuesta — abre la ronda.
ld-current-bid = Apuesta actual: { $quantity } { $face }.

ld-action-bid = Hacer una apuesta
ld-action-call-liar = Cantar Mentira
ld-action-call-spot-on = Cantar Spot On
ld-bid-prompt = Elige tu apuesta.
ld-bid-option = { $quantity } { $face }
ld-bid-made = { $who ->
    [you] Apuestas { $quantity } { $face }.
    *[player] { $player } apuesta { $quantity } { $face }.
}

ld-call-liar = { $who ->
    [you] Cantas Mentira sobre la apuesta de { $target } de { $quantity } { $face }.
    *[player] { $player } canta Mentira sobre la apuesta de { $target } de { $quantity } { $face }.
}
ld-call-spot-on = { $who ->
    [you] Cantas Spot On a la apuesta de { $target } de { $quantity } { $face }.
    *[player] { $player } canta Spot On a la apuesta de { $target } de { $quantity } { $face }.
}
ld-reveal-header = ¡Cubiletes arriba! Contando los { $face } en la mesa.
ld-reveal-line = { $player } sacó: { $dice }.
ld-actual-count = Cantidad real de { $face } (con 1 comodines): { $count }. La apuesta era { $quantity }.
ld-actual-count-no-wild = Cantidad real de { $face } (sin comodines): { $count }. La apuesta era { $quantity }.

ld-liar-bidder-loses = { $bidder } sobreapostó — pierde un dado.
ld-liar-caller-loses = La apuesta era honesta — { $caller } pierde un dado.
ld-spot-on-correct = ¡Spot On! { $caller } acertó exactamente — los demás pierden un dado.
ld-spot-on-wrong = No es spot on. { $caller } pierde dos dados.

ld-lost-die = { $who ->
    [you] Pierdes un dado. Ahora tienes { $remaining } { $remaining ->
        [one] dado
        *[other] dados
    }.
    *[player] { $player } pierde un dado. Ahora tiene { $remaining }.
}
ld-lost-dice-multi = { $who ->
    [you] Pierdes { $count } dados. Ahora tienes { $remaining } { $remaining ->
        [one] dado
        *[other] dados
    }.
    *[player] { $player } pierde { $count } dados. Ahora tiene { $remaining }.
}
ld-eliminated = ¡{ $player } se queda sin dados y queda eliminado! Quedan { $remaining } { $remaining ->
    [one] jugador
    *[other] jugadores
}.
ld-winner = ¡{ $player } es el último con dados — gana!

ld-status-round = Ronda { $round }.
ld-status-your-dice = Tus dados: { $dice }.
ld-status-your-counts = Tus cuentas: { $counts }.
ld-status-no-dice = No tienes dados — estás eliminado.
ld-status-current-bid = Apuesta actual: { $quantity } { $face }.
ld-status-no-bid = Sin apuesta en esta ronda.
ld-status-table-total = Dados totales en la mesa: { $total }.
ld-status-detailed-header = Estado detallado — quedan { $count } jugadores.
ld-status-detailed-line = { $player }{ $self_suffix }: { $dice } { $dice ->
    [one] dado
    *[other] dados
}.
ld-status-detailed-out = { $player }: eliminado.
ld-status-detailed-self-suffix = {" "}(tú)

ld-face-1 = unos
ld-face-2 = doses
ld-face-3 = treses
ld-face-4 = cuatros
ld-face-5 = cincos
ld-face-6 = seises

ld-action-not-your-turn = No es tu turno.
ld-action-not-playing = La partida no está en curso.
ld-action-no-bid-to-call = Aún no hay apuesta que retar.
ld-action-eliminated = Estás eliminado.
