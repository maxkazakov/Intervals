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
    @StateObject var viewModel: CountdownTimerViewModel
    let textView: TextView

    var body: some View {
        ZStack {
            CircleTimerView(percent: viewModel.time / viewModel.fullTime)

            VStack {
                textView
                Text("\(formatMilliseconds(viewModel.time))")
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
class CountdownTimerViewModel: ObservableObject {

    init(fullTime: TimeInterval, viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
        self.viewStore = viewStore
        self.fullTime = fullTime
        viewStore.publisher
            .sink(receiveValue: { [weak self] state in
                self?.currentState = state.status
            })
            .store(in: &cancellableSet)
    }

    @Published var timeLeft: TimeInterval = 0.0
    @Published var time: TimeInterval = 0.0
    let fullTime: TimeInterval
    private var accumulatedTime: TimeInterval = 0.0

    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>

    private var cancellableSet: Set<AnyCancellable> = []
    private var timer: AnyCancellable?
    private var lastTimeStarted = Date()
    private var currentState = ActiveWorkoutStatus.initial {
        didSet {
            guard oldValue != currentState else { return }
            switch currentState {
            case .paused:
                pauseTimer()
            case .inProgress:
                startTimer()
            case .initial:
                break
            }
        }
    }

    func startTimer() {
        self.lastTimeStarted = viewStore.currentIntervalStep.lastStartTime
        self.time = viewStore.currentIntervalStep.time

        timer = Timer
            .publish(every: 0.1, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.handleTimerEvent()
            }
    }

    func handleTimerEvent() {
        let diff = Date().timeIntervalSince1970 - self.lastTimeStarted.timeIntervalSince1970
        time = accumulatedTime + diff
        timeLeft = fullTime - time
        if timeLeft <= 0.0 {
            viewStore.send(.stepFinished)
        }
    }

    func pauseTimer() {
        time = viewStore.currentIntervalStep.time
        timeLeft = fullTime - time

        timer?.cancel()
    }
}
