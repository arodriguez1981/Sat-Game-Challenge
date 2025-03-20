//
//  MainView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct MainView: View {
    @StateObject private var service: GameService = GameService()
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                switch service.gameStatus {
                case .created:
                    GameCreatedView(service: service)
                case .ready, .uncreated:
                    PreGameView(service: service)
                case .started:
                    GamePlayView(service: service)
                case .over:
                    GameOverView(service: service)
                }
            }
            .frame(maxHeight: .infinity)
            .onChange(of: service.currentTurn, {
                if service.currentTurn == service.localPlayer {
                    let title = "Your Turn!"
                    let body = "It's time to answer the trivia question."
                    service.notificationService.sendNotification(title: title, body: body)
                }
            })
        }
    }
}
