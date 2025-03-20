//
//  StartGameView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct StartGameView: View {
    @ObservedObject var service: GameService

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Button("Create Game") {
                Task {
                    await service.createGame()
                }
            }
            .buttonStyle(CustomButtonStyle(color: .blue))
            Button("Search games") {
                Task {
                    await service.fetchAvailableGames()
                }
            }
            .buttonStyle(CustomButtonStyle(color: .purple))
            if !service.availableGames.isEmpty {
                GameListView(service: service)
            }
            Spacer()
        }
        .onAppear {
            Task {
                await service.fetchAvailableGames()
            }
        }
    }
}
