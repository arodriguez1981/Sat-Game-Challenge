//
//  Text+Extensions.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//

import SwiftUI

extension Text {
    func gameStatusStyle() -> some View {
        self.font(.title).fontWeight(.bold).foregroundColor(.white)
            .padding().background(RoundedRectangle(cornerRadius: 15).fill(Color.purple.opacity(0.8)))
            .shadow(radius: 5)
    }
    
    func questionStyle() -> some View {
        self.font(.title).fontWeight(.bold).foregroundColor(.white)
            .padding().background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.8)))
            .shadow(radius: 5)
    }
}
