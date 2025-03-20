//
//  PreGameView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct PreGameView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        if !service.playerInvited.isEmpty {
            if service.currentTurn == service.localPlayer {
                Button("Start") {
                    Task {
                        service.startGame()
                    }
                }
                .buttonStyle(CustomButtonStyle(color: .blue))
            } else {
                WaitingView(service: service)
            }
            
        } else {
            StartGameView(service: service)
        }
    }
}
