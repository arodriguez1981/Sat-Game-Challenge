//
//  GamePlayView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct GamePlayView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            ScoreboardView(service: service)
            Spacer()
            if service.currentTurn == service.localPlayer && service.turnStarted {
                QuestionView(service: service)
            } else {
                WaitingView(service: service)
            }
            Spacer()
        }
    }
}
