//
//  PlayerAnswerView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct PlayerAnswerView: View {
    let result: PlayerResponse
    let isLocalPlayer: Bool
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 5) {
            Text(isLocalPlayer ? "You" : "Opponent")
                .font(.headline)
                .foregroundColor(.white)
            Spacer()
            Text(result.answer)
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 8).fill(result.isCorrect ? Color.green : Color.purple))
            Spacer()
            Text(result.isCorrect ? "✅" : "❌")
            Spacer()
            Text(result.time.formattedTime())
                .font(.subheadline)
                .foregroundColor(.yellow)
        }
        .padding(.all, 8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.5)))
    }
}
