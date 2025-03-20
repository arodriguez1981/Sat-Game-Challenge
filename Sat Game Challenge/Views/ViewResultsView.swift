//
//  ViewResultsView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
import SwiftUI

struct ViewResultsView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            Text("Round results")
                .font(.title)
                .bold()
                .padding()
            
            List(service.allRoundResults.indices, id: \.self) { index in
                let roundResult = service.allRoundResults[index]
                
                VStack(alignment: .leading) {
                    Text("Ronda \(index + 1)")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    if let winner = roundResult.winner {
                        let winnerText = winner == service.localPlayer ? "You win this round" : "Nice try"
                        Text("Winner: \(winnerText)")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.green)
                    } else {
                        Text("Tied or incomplete")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                    ForEach(roundResult.playerResponses, id: \ .player) { result in
                        PlayerAnswerView(result: result, isLocalPlayer: result.player == service.localPlayer)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity)
                .listStyle(PlainListStyle())
            }
        }
    }
}
