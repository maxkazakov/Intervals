//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 06.09.2022.
//

import SwiftUI

struct CircleTimerView: View {
    internal init(percent: Double) {
        self.percent = percent
        print("CircleTimerView init", percent)
    }


    let percent: Double

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: percent)
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .fill(Color.black)
                .rotationEffect(.degrees(-90))

            Circle()
                .stroke(Color.black.opacity(0.1), lineWidth: 20)
                .rotationEffect(.degrees(-90))
        }
        .padding(.horizontal, 32)
    }
}
