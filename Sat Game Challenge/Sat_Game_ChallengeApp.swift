//
//  Sat_Game_ChallengeApp.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI
import Firebase

@main
struct TriviaGameApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
