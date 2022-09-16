//
//  TimerView.swift
//  
//
//  Created by Максим Казаков on 04.09.2022.
//

import SwiftUI
import Combine
import ComposableArchitecture
import ActiveWorkoutCore

struct TimerView<TextView: View>: View {
//    @StateObject var viewModel: TimerViewModel
    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>
    let textView: TextView

    var body: some View {
        ZStack {
            CircleTimerView(percent: 0.0)

            VStack {
                textView
                Text("\(viewStore.state.currentIntervalStep.time.formatMilliseconds())")
                    .font(.system(.largeTitle, design: .monospaced))
            }
        }
    }
}

extension Double {
    func formatSeconds() -> String {
        let hours = Int(self) / 60 / 60
        let minutes = Int(self) / 60 % 60
        let seconds = Int(self) % 60
        let miliseconds = Int(self * 10) % 10
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%1d", hours, minutes, seconds, miliseconds)
        } else {
            return String(format: "%02d:%02d:%1d", minutes, seconds, miliseconds)
        }
    }
}

extension Int {
    func formatMilliseconds() -> String {
        let seconds = self / 1000
        let ms = self % 1000 / 100
        let hours = seconds / 60 / 60
        let minutes = seconds / 60 % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%1d", hours, minutes, seconds, ms)
        } else {
            return String(format: "%02d:%02d:%1d", minutes, seconds, ms)
        }
    }
}
