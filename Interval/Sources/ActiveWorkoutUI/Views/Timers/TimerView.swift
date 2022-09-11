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
                Text("\(formatMilliseconds(viewStore.state.currentIntervalStep.time))")
                    .font(.system(.largeTitle))
            }
        }
    }

    func formatMilliseconds(_ counter: Double) -> String {
        let hours = Int(counter) / 60 / 60
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        let milliseconds = Int(counter * 10) % 10
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%1d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d:%1d", minutes, seconds, milliseconds)
        }
    }
}

// Needed for displaying timer on UI. It may be expensive to handle milliseconds throught store
//class TimerViewModel: ObservableObject {
//    @Published var time: TimeInterval = 0.0
//    private var accumulatedTime: TimeInterval = 0.0
//
//    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>
//
//    private var cancellableSet: Set<AnyCancellable> = []
//    private var timer: AnyCancellable?
//    private var lastTimeStarted = Date()
//    private var currentState = ActiveWorkoutStatus.initial
//
//    init(viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
//        self.viewStore = viewStore
//        viewStore.publisher
//            .sink(receiveValue: { [weak self] state in
//                self?.onStateChanged(state)
//            })
//            .store(in: &cancellableSet)
//    }
//
//    func onStateChanged(_ state: ActiveWorkout) {
//        guard currentState != state.status else { return }
//        accumulatedTime = state.currentIntervalStep.time
//        time = state.currentIntervalStep.time
//        lastTimeStarted = state.currentIntervalStep.lastStartTime
//
//        currentState = state.status
//        switch currentState {
//        case .paused:
//            pauseTimer()
//        case .inProgress:
//            startTimer()
//        case .initial:
//            break
//        }
//    }
//
//    func startTimer() {
//        timer = Timer
//            .publish(every: 0.1, tolerance: 0.1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                let diff = Date().timeIntervalSince1970 - self.lastTimeStarted.timeIntervalSince1970
//                self.time = self.accumulatedTime + diff
//            }
//    }
//
//    func handleTimerEvent() {
//        let diff = Date().timeIntervalSince1970 - self.lastTimeStarted.timeIntervalSince1970
//        time = accumulatedTime + diff
//    }
//
//    func pauseTimer() {
//        timer?.cancel()
//    }
//}
