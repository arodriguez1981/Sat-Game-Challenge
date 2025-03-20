//
//  TimeInterval+Extensions.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import Foundation

extension TimeInterval {
    func formattedTime() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        let milliseconds = Int((self.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
    }
}
