//
//  GameTimer.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import Foundation
import Combine

extension GameService {
    // MARK: - Timer Methods
    func startTimer() {
        let startTime = Date()
        timer = Timer.publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    func stopTimer() {
        Task { @MainActor in
            self.elapsedTime = 0
            
        }
        timer?.cancel()
        timer = nil
    }
}
