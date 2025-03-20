//
//  TimerView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI
struct TimerView: View {
    let time: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black)
                .frame(width: 230, height: 80)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 4))
            Text(time).font(.system(size: 40, weight: .bold, design: .monospaced)).foregroundColor(.red)
        }
    }
}
