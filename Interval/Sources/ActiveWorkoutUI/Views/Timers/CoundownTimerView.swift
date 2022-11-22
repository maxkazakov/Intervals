//
//  CountdownTimerView.swift
//  
//
//  Created by Максим Казаков on 07.09.2022.
//

import SwiftUI
import Combine
import ComposableArchitecture
import ActiveWorkoutCore
import Foundation

struct CountdownTimerView: View {
    @StateObject var viewModel: CountdownTimerViewModel

    private var remainingDuration: RemainingDurationProvider<Double> {
        { currentPercent in
            let remainDuration = currentPercent * (Double(viewModel.fullTime) / 1000)
            return remainDuration
        }
    }
    
    private let animation: AnimationWithDurationProvider = { duration in
            .linear(duration: duration)
    }

    var body: some View {
        ZStack {
            CircleTimerView(percent: viewModel.percent)
                .pausableAnimation(binding: $viewModel.percent,
                                   targetValue: 0.0,
                                   remainingDuration: remainingDuration,
                                   animation: animation,
                                   paused: $viewModel.isPaused)

            VStack {
                Text(viewModel.name).font(.title2)
                Text("\(viewModel.timeLeft.formatMilliseconds())")
                    .font(.system(.largeTitle, design: .monospaced))
            }
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

class CountdownTimerViewModel: ObservableObject {

    @Published var percent = 1.0
    @Published var timeLeft: Int = 0
    @Published var isPaused = false

    let name: String
    let fullTime: Int
    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>

    private var currentState = ActiveWorkoutStatus.initial
    private var cancellableSet: Set<AnyCancellable> = []

    init(fullTime: Int, viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
        self.viewStore = viewStore
        self.fullTime = fullTime
        self.name = viewStore.currentIntervalStep.name
        self.percent = 1.0
    }

    var isAppeared = false
    func onAppear() {
        guard !isAppeared else { return }

        viewStore.publisher
            .sink(receiveValue: { [weak self] state in
                self?.onStateChanged(state)
            })
            .store(in: &cancellableSet)
    }

    var animationStarted = false
    func onStateChanged(_ state: ActiveWorkout) {
        self.timeLeft = fullTime - state.currentIntervalStep.time        

        guard currentState != state.status else { return }
        defer { currentState = state.status }

        isPaused = state.status == .paused

        if state.status == .inProgress, !animationStarted {
            animationStarted = true
            withAnimation(Animation.linear(duration: Double(self.fullTime) / 1000)) {
                self.percent = 0.0
            }
        }
    }
}
