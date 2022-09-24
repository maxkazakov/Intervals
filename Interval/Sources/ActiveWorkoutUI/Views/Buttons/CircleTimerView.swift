//
//  CircleTimerView.swift
//  
//
//  Created by Максим Казаков on 06.09.2022.
//

import SwiftUI

fileprivate let lineWidth: CGFloat = 20

struct CircleTimerView: View {

    let percent: Double

    var body: some View {
        ZStack {
            Circle()
                .inset(by: lineWidth / 2)
                .trim(from: 0, to: percent)
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .fill(Color.black)
                .rotationEffect(.degrees(-90))
                .aspectRatio(contentMode: .fit)

            Circle()
                .strokeBorder(Color.black.opacity(0.1), lineWidth: lineWidth)
                .rotationEffect(.degrees(-90))
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct CircleTimerView_Previews: PreviewProvider {
    static var previews: some View {

        CircleTimerView(percent: 0.5)
            .frame(width: 200, height: 200)
            .border(.red, width: 1)
    }
}
