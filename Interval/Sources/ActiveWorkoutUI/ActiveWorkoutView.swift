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

public struct ActiveWorkoutView: View {
    public init(store: Store<ActiveWorkout, ActiveWorkoutAction>) {
        self.store = store
    }

    let store: Store<ActiveWorkout, ActiveWorkoutAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack {
                    Text(viewStore.state.workoutPlan.intervals.first?.name ?? "No name")
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
        intervals: []
    )

    static var previews: some View {
        ActiveWorkoutView(store: Store<ActiveWorkout, ActiveWorkoutAction>(
            initialState: ActiveWorkout(
                id: UUID(),
                workoutPlan: workoutPlan,
                time: 0.0011,
                status: .initial
            ),
            reducer: activeWorkoutReducer,
            environment: ActiveWorkoutEnvironment(uuid: UUID.init)
        ))
    }
}
