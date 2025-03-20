//
//  WaitingView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct WaitingView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            if service.roundResult.winner != nil || service.roundResult.playerResponses.count == 2 {
                RoundResultView(service: service)
            } else {
                ForEach(service.roundResult.playerResponses, id: \ .player) { result in
                    PlayerAnswerView(result: result, isLocalPlayer: result.player == service.localPlayer)
                }
                .padding(.horizontal)
                Text("Wait your turn")
                    .gameStatusStyle()
            }
        }
    }
}
