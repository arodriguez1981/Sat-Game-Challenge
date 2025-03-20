//
//  Button+Extensions.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct CustomButtonStyle: ButtonStyle {
    var color: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding().frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 15).fill(color))
            .foregroundColor(.white).shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
            .padding(.horizontal, 32)
    }
}
