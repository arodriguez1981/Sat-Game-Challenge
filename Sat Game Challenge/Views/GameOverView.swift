//
//  GameOverView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI
struct GameOverView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        let winner = service.getWinner()
        VStack {
            Text(winner == service.localPlayer ? "You win" : "Game over")
                .gameStatusStyle()
            Spacer()
            ViewResultsView(service: service)
            Spacer()
            Button("Close") { service.closeGame() }
                .buttonStyle(CustomButtonStyle(color: .blue))
        }
    }
}
