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
import Foundation

struct CountdownTimerView: View {
    @StateObject var viewModel: CountdownTimerViewModel

    private var remainingDuration: RemainingDurationProvider<Double> {
        { currentPercent in
            currentPercent * viewModel.fullTime
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
                Text("\(formatSeconds(viewModel.timeLeft))")
                    .font(.system(.largeTitle))
            }
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
}

class CountdownTimerViewModel: ObservableObject {

    @Published var percent = 1.0
    @Published var timeLeft: TimeInterval = 0.0
    @Published var isPaused = false

    let name: String
    let fullTime: TimeInterval
    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>

    private var currentState = ActiveWorkoutStatus.initial
    private var cancellableSet: Set<AnyCancellable> = []

    init(fullTime: TimeInterval, viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>) {
        self.viewStore = viewStore
        self.fullTime = fullTime
        self.name = viewStore.currentIntervalStep.name
        self.percent = 1.0

        viewStore.publisher
            .sink(receiveValue: { [weak self] state in
                self?.onStateChanged(state)
            })
            .store(in: &cancellableSet)
    }

    func onStateChanged(_ state: ActiveWorkout) {
        self.timeLeft = fullTime - state.currentIntervalStep.time

        guard currentState != state.status else { return }
        defer { currentState = state.status }

        isPaused = state.status == .paused

        switch state.status {
        case .inProgress:
            DispatchQueue.main.async {
                withAnimation(Animation.linear(duration: self.fullTime)) {
                    self.percent = 0.0
                }
            }
        default:
            break
        }

    }
}

public struct StoppableAnimationModifier<Value: VectorArithmetic>: AnimatableModifier {
    @Binding var binding: Value
    @Binding var paused: Bool

    public var animatableData: Value  {
        didSet {
            print("animatableData", animatableData)
        }
    }

    public init(binding: Binding<Value>,
                paused: Binding<Bool>) {
        _binding = binding
        _paused = paused
        animatableData = binding.wrappedValue
    }

    public func body(content: Content) -> some View {
        content
            .onChange(of: paused) { isPaused in
                if isPaused {
                    withAnimation(.instant) {
                        binding = animatableData // the magic happens here
                    }
                }
            }
    }
}
