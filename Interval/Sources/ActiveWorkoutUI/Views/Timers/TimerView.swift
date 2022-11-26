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

struct TimerView<IntervalNameView: View>: View {
    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>
    let nameView: IntervalNameView

    var body: some View {
        ZStack {
            CircleTimerView(percent: 0.0)

            VStack {
                nameView
                Text("\(viewStore.state.currentIntervalStep.time.formatMilliseconds())")
                    .font(.system(.largeTitle, design: .monospaced))
            }
        }
    }
}
