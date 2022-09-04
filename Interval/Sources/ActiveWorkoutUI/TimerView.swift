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

struct TimerView: View {
    @StateObject var viewModel: TimerViewModel

    var body: some View {
        Text("\(formatMilliseconds(viewModel.time))")
            .font(.system(.largeTitle))
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
class TimerViewModel: ObservableObject {
    @Published var time: TimeInterval = 0.0
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

    init(viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
        self.viewStore = viewStore
        self.time = viewStore.time
        viewStore.publisher
            .sink(receiveValue: { [weak self] state in
                self?.currentState = state.status
            })
            .store(in: &cancellableSet)
    }

    func startTimer() {
        self.lastTimeStarted = viewStore.state.lastTimeStarted
        self.accumulatedTime = viewStore.time

        timer = Timer
            .publish(every: 0.1, tolerance: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                let diff = Date().timeIntervalSince1970 - self.lastTimeStarted.timeIntervalSince1970
                self.time = self.accumulatedTime + diff
            }
    }

    func pauseTimer() {
        self.time = viewStore.time
        timer?.cancel()
    }
}
