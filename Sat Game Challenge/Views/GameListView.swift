//
//  GameListView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct GameListView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        List(service.availableGames, id: \ .id) { game in
            Button(game.name) {
                Task {
                    await service.joinGame(gameId: game.id)
                }
            }
            .buttonStyle(CustomButtonStyle(color: .green))
        }
        .listStyle(PlainListStyle())
    }
}
