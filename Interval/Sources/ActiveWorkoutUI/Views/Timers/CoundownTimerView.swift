//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 07.09.2022.
//

import SwiftUI
import Combine
import ComposableArchitecture
import ActiveWorkoutCore

struct CountdownTimerView<TextView: View>: View {
    internal init(time: TimeInterval, fullTime: TimeInterval, textView: TextView) {
        self.time = time
        self.fullTime = fullTime
        self.textView = textView

        self.timeLeft = fullTime - time
        self.percent = max(0.0, 1 - time / fullTime)
    }

    let time: TimeInterval
    let fullTime: TimeInterval
    let textView: TextView
    let percent: Double
    let timeLeft: Double

    var body: some View {
        ZStack {
            CircleTimerView(percent: percent)
                .animation(Animation.linear, value: percent)

            VStack {
                textView
                Text("\(formatSeconds(timeLeft))")
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

    func formatSeconds(_ counter: Double) -> String {
        let hours = Int(counter) / 60 / 60
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    let formatter = DateComponentsFormatter()
    func time(_ seconds: Int) -> String {
        if seconds > 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: TimeInterval(seconds))!
    }
}

//class CountdownTimerViewModel: ObservableObject {
//
//    init(time: TimeInterval, fullTime: TimeInterval) {
////        self.viewStore = viewStore
////        self.fullTime = fullTime
////        self.time = time
//
//        self.percent = max(0.0, 1 - time / fullTime)
//    }
//
//    @Published var percent = 1.0
//    @Published var timeLeft = 0.0
//}

// Needed for displaying timer on UI. It may be expensive to handle milliseconds throught store
//class CountdownTimerViewModel: ObservableObject {
//
//    init(fullTime: TimeInterval, viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
//        self.viewStore = viewStore
//        self.timeLeft = fullTime
//        self.fullTime = fullTime
//        viewStore.publisher
//            .sink(receiveValue: { [weak self] state in
//                self?.onStateChanged(state)
//            })
//            .store(in: &cancellableSet)
//    }
//
//    @Published var percent = 1.0
//    @Published var timeLeft: TimeInterval
//
//    let fullTime: TimeInterval
//    private var time: TimeInterval = 0.0
//    private var accumulatedTime: TimeInterval = 0.0
//
//    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>
//
//    private var cancellableSet: Set<AnyCancellable> = []
//    private var timer: AnyCancellable?
//    private var lastTimeStarted = Date()
//    private var currentState = ActiveWorkoutStatus.initial
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
//        self.lastTimeStarted = viewStore.currentIntervalStep.lastStartTime
//        self.time = viewStore.currentIntervalStep.time
//
//        timer = Timer
//            .publish(every: 0.1, tolerance: 0.01, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                self?.handleTimerEvent()
//            }
//    }
//
//    func handleTimerEvent() {
//        let diff = Date().timeIntervalSince1970 - self.lastTimeStarted.timeIntervalSince1970
//        time = accumulatedTime + diff
//        timeLeft = fullTime - time
//        percent = max(0.0, 1 - time / fullTime)
//        if percent == 0.0 {
//            timer?.cancel()
//            viewStore.send(.stepFinished)
//        }
//    }
//
//    func pauseTimer() {
//        timer?.cancel()
//    }
//}
