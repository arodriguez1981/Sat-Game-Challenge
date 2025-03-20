//
//  BackgroundView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.5), Color.yellow.opacity(0.5), Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                       startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)
    }
}
