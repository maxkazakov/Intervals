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
                TimerView(viewModel: TimerViewModel(viewStore: viewStore))

                VStack {
                    Spacer()
                    StartStopButton(state: mapStatusToButton(viewStore.state.status),
                                    onStart: { viewStore.send(.start) },
                                    onPause: { viewStore.send(.pause) })
                }
                .padding()
            }
            .background(Color.yellow.ignoresSafeArea())
        }
    }

    func mapStatusToButton(_ status: ActiveWorkoutStatus) -> StartStopButtonState {
        switch status {
        case .initial: return .stopped
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
