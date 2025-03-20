//
//  AnswerButton.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

struct AnswerButton: View {
    let option: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(option)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.green))
                .foregroundColor(.white)
                .shadow(radius: 5)
                .scaleEffect(1.05)
                .animation(.spring(), value: option)
        }
    }
}
