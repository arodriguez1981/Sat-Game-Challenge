//
//  GameCreatedView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct GameCreatedView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            Text("Waiting for opponent")
                .gameStatusStyle()
            Spacer()
            Button("Exit") { service.exitGame() }
                .buttonStyle(CustomButtonStyle(color: .blue))
        }
    }
}
