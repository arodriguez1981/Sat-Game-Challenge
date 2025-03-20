//
//  GameRoundManager.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import Foundation
import FirebaseDatabase

extension GameService {
    // MARK: - Round Results
    func evaluateRoundResult(round: Int) {
        guard let gameId = gameId else {
            self.roundResult = RoundResult(winner: nil, playerResponses: [])
            return
        }
        let gameRef = dbRef.child("games").child(gameId)
        gameRef.child("roundResults").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            let playerResponses = self.parsePlayerResponses(from: snapshot, for: round)
            let winner = self.determineRoundWinner(from: playerResponses)
            
            Task { @MainActor in
                self.roundResult = RoundResult(winner: winner, playerResponses: playerResponses)
            }
        }
    }
    
    private func parsePlayerResponse(from response: DataSnapshot) -> PlayerResponse? {
        guard let data = response.value as? [String: Any],
              let roundNumber = data["round"] as? Int,
              let player = data["player"] as? String,
              let answer = data["answer"] as? String,
              let isCorrect = data["correct"] as? Bool,
              let time = data["time"] as? TimeInterval else {
            return nil
        }
        return PlayerResponse(player: player, answer: answer, isCorrect: isCorrect, time: time, round: roundNumber)
    }

    private func parsePlayerResponses(from snapshot: DataSnapshot, for round: Int) -> [PlayerResponse] {
        let responses = snapshot.children.allObjects as? [DataSnapshot] ?? []
        return responses.compactMap { response in
            guard let playerResponse = parsePlayerResponse(from: response),
                  playerResponse.round == round else {
                return nil
            }
            return playerResponse
        }
    }

    private func parseAllRoundResponses(from snapshot: DataSnapshot) -> [Int: [PlayerResponse]] {
        let responses = snapshot.children.allObjects as? [DataSnapshot] ?? []
        var roundsDict: [Int: [PlayerResponse]] = [:]
        
        for response in responses {
            if let playerResponse = parsePlayerResponse(from: response) {
                let roundNumber = playerResponse.round
                if roundsDict[roundNumber] != nil {
                    roundsDict[roundNumber]?.append(playerResponse)
                } else {
                    roundsDict[roundNumber] = [playerResponse]
                }
            }
        }
        return roundsDict
    }
    
    private func determineRoundWinner(from playerResponses: [PlayerResponse]) -> String? {
        guard playerResponses.count == 2 else { return nil }
        let player1 = playerResponses[0]
        let player2 = playerResponses[1]
        
        if player1.isCorrect && !player2.isCorrect {
            return player1.player
        } else if !player1.isCorrect && player2.isCorrect {
            return player2.player
        } else if player1.isCorrect && player2.isCorrect {
            return player1.time < player2.time ? player1.player : player2.player
        }
        return nil
    }
    
    func fetchAllRoundResults() {
        guard let gameId = gameId else { return }
        let gameRef = dbRef.child("games").child(gameId)
        gameRef.child("roundResults").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            let roundsDict = self.parseAllRoundResponses(from: snapshot)
            self.allRoundResults = self.calculateAllRoundResults(from: roundsDict)
        }
    }
    
    private func calculateAllRoundResults(from roundsDict: [Int: [PlayerResponse]]) -> [RoundResult] {
        var allRoundResults: [RoundResult] = []
        for (_, playerResponses) in roundsDict {
            guard playerResponses.count == 2 else {
                allRoundResults.append(RoundResult(winner: nil, playerResponses: playerResponses))
                continue
            }
            
            let winner = determineRoundWinner(from: playerResponses)
            allRoundResults.append(RoundResult(winner: winner, playerResponses: playerResponses))
        }
        return allRoundResults
    }
}
