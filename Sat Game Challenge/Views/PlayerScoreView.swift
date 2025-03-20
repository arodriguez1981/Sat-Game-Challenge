//
//  PlayerScoreView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct PlayerScoreView: View {
    let playerName: String
    let score: Int
    
    var body: some View {
        VStack {
            Text(playerName).font(.headline).foregroundColor(.white)
            HStack {
                ForEach(0..<3, id: \ .self) { index in
                    Circle().frame(width: 12, height: 12)
                        .foregroundColor(score > index ? .green : .gray)
                }
            }
        }
    }
}
