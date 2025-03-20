//
//  GameNetworkManager.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import Foundation
import FirebaseDatabase

extension GameService {
    // MARK: - Network Methods
    internal func listenForUpdates() {
        guard let gameId = gameId else { return }
        let gameRef = dbRef.child("games").child(gameId)
        
        gameRef.observe(.value) { [weak self] snapshot in
            guard let self = self,
                  let gameData = snapshot.value as? [String: Any] else { return }
            
            if let winnerData = gameData["winner"], let _ = winnerData as? String? {
                self.handleGameOver(gameData: gameData)
            } else {
                self.handleGameUpdate(gameData: gameData)
            }
        }
    }
    
    private func handleGameOver(gameData: [String: Any]) {
        self.scores = gameData["scores"] as? [String: Int] ?? [:]
        self.gameStatus = .over
        fetchAllRoundResults()
    }
    
    private func handleGameUpdate(gameData: [String: Any]) {
        guard let turn = gameData["turn"] as? String,
              let rounds = gameData["rounds"] as? [[String: Any]],
              let playerHost = gameData["playerHost"] as? String,
              let playerInvited = gameData["playerInvited"] as? String,
              let currentRoundIndex = gameData["currentRound"] as? Int,
              currentRoundIndex < rounds.count else { return }
        
        self.evaluateRoundResult(round: self.currentRoundIndex)
        let currentRound = rounds[currentRoundIndex]
        
        if self.gameStatus != .started {
            self.playerHost = playerHost
            self.playerInvited = playerInvited
            if !playerInvited.isEmpty && turn == playerHost && self.localPlayer == playerHost && currentRoundIndex == 0 {
                self.gameStatus = .ready
                let title = "Player 2 has joined"
                let body = "You can now start the game!"
                
                self.notificationService.sendNotification(title: title, body: body)
            }
        }
        
        self.currentTurn = turn
        self.currentQuestion = currentRound["question"] as? String
        self.answerOptions = currentRound["options"] as? [String] ?? []
        self.correctAnswer = currentRound["correctAnswer"] as? String
        self.scores = gameData["scores"] as? [String: Int] ?? [:]
    }
}
