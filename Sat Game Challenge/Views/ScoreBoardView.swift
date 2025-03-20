//
//  ScoreBoardView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        HStack {
            PlayerScoreView(playerName: "You", score: service.getPlayerScore(service.localPlayer))
            Spacer()
            PlayerScoreView(playerName: "Opponent", score: service.getPlayerScore(service.getOpponent()))
        }
        .padding(.horizontal, 32)
        .padding(.top, 32)
    }
}
