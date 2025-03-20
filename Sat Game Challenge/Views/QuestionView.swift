//
//  QuestionView.swift
//  Sat Game Challenge
//
//  Created by Alex on 3/19/25.
//
import SwiftUI

struct QuestionView: View {
    @ObservedObject var service: GameService
    
    var body: some View {
        VStack {
            Text(service.currentQuestion ?? "Loading...")
                .questionStyle()
            ForEach(service.answerOptions, id: \ .self) { option in
                AnswerButton(option: option, action: {
                    service.submitAnswer(answer: option)
                })
            }
            .padding(.horizontal)
            TimerView(time: service.formattedTime())
        }
    }
}
