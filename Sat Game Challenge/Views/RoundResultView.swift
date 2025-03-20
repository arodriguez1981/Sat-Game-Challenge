//
//  RoundResultView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct RoundResultView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            if let winner = service.roundResult.winner {
                let winnerText = winner == service.localPlayer ? "You win this round" : "Nice try"
                Text(winnerText)
                    .gameStatusStyle()
            } else {
                Text("Round tied")
                    .gameStatusStyle()
            }
            ForEach(service.roundResult.playerResponses, id: \ .player) { result in
                PlayerAnswerView(result: result, isLocalPlayer: result.player == service.localPlayer)
            }
            .padding(.horizontal)
            if service.currentTurn == service.localPlayer {
                Button("Next round") {
                    service.startTurn()
                }
                .buttonStyle(CustomButtonStyle(color: .blue))
            } else {
                Text("Wait your turn")
                    .gameStatusStyle()
            }
        }
    }
}
