//
//  ActiveWorkoutView.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import SwiftUI
import Combine
import ComposableArchitecture

import ActiveWorkoutCore
import WorkoutPlanCore
import IntervalCore

public struct ActiveWorkoutView: View {
    public init(store: Store<ActiveWorkout, ActiveWorkoutAction>) {
        self.store = store
    }

    let store: Store<ActiveWorkout, ActiveWorkoutAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {

                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.15)
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .fill(Color.black)
                        .rotationEffect(.degrees(-90))

                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 20)
                        .rotationEffect(.degrees(-90))
                }
                .padding(.horizontal, 32)

                VStack {
                    Text(viewStore.state.workoutPlan.intervals.first?.name ?? "No name")
                        .font(.title2)
                    TimerView(viewModel: TimerViewModel(viewStore: viewStore))
                }

                VStack {
                    if viewStore.state.status != .initial {
                        HStack {
                            StopButton(onStop: { viewStore.send(.stop) })
                            Spacer()
                            if let pauseButtonState = mapStatusToButton(viewStore.state.status) {
                                PauseResumeButton(state: pauseButtonState,
                                                  onStart: { viewStore.send(.start) },
                                                  onPause: { viewStore.send(.pause) })
                            }
                        }
                        Spacer()
                    } else {
                        Spacer()
                        HStack {
                            Spacer()
                            StartButton(onStart: { viewStore.send(.start) })
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .background(Color.yellow.ignoresSafeArea())
        }
    }

    func mapStatusToButton(_ status: ActiveWorkoutStatus) -> PauseResumeButtonState? {
        switch status {
        case .initial: return nil
        case .inProgress: return .playing
        case .paused: return .paused
        }
    }
}

struct ActiveWorkoutView_Previews: PreviewProvider {
    static let workoutPlan = WorkoutPlan(
        id: UUID(),
        name: "Running",
        intervals: [
            Interval(
                id: Interval.Id(),
                name: "Running",
                finishType: .byDuration(seconds: 60),
                recoveryInfo: RecoveryInfo(finishType: .byTappingButton, isEnabled: false),
                repeatCount: 2,
                pulseRange: nil,
                paceRange: nil
            )
        ]
    )

    static var previews: some View {
        ActiveWorkoutView(store: Store<ActiveWorkout, ActiveWorkoutAction>(
            initialState: ActiveWorkout(
                id: UUID(),
                workoutPlan: workoutPlan,
                time: 0.0011,
                status: .inProgress
            ),
            reducer: activeWorkoutReducer,
            environment: ActiveWorkoutEnvironment(uuid: UUID.init)
        ))
    }
}
