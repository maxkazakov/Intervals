//
//  File.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import AppCore
import ActiveWorkoutUI
import WorkoutPlansListUI
import ComposableArchitecture


public struct AppView: View {
    let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
        IfLetStore(
            self.store.scope(state: \.activeWorkout, action: { .activeWorkoutAction($0) }),
            then: {
                ActiveWorkoutView(store: $0)
            },
            else: {
                WorkoutPlanListView(store: store.scope(state: \.workoutPlans, action: AppAction.workoutPlanList))
            }
        )
    }
}

