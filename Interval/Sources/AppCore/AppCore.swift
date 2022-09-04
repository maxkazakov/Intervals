//
//  AppCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture
import WorkoutPlansListCore

import ActiveWorkoutCore

public struct AppState: Equatable {
    public var workoutPlans: WorkoutPlansList
    public var activeWorkout: ActiveWorkout?

    public init() {
        self.workoutPlans = .init(workoutPlans: [])
    }
}

public struct AppEnvironment {
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public enum AppAction {    
    case workoutPlanList(WorkoutPlansListAction)
    case activeWorkoutAction(ActiveWorkoutAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlansListReducer.pullback(
        state: \.workoutPlans,
        action: /AppAction.workoutPlanList,
        environment: {
            WorkoutPlansListEnvironment(
                workoutPlansStorage: .live,
                mainQueue: .main,
                uuid: $0.uuid
            )
        }
    ),
    activeWorkoutReducer.optional().pullback(state: \.activeWorkout, action: /AppAction.activeWorkoutAction, environment: { ActiveWorkoutEnvironment(uuid: $0.uuid) }),
    startWorkoutReducer
)
.debug()

let startWorkoutReducer = Reducer<AppState, AppAction, AppEnvironment>({ state, action, env in
    switch action {
    case let .workoutPlanList(.workoutPlan(_, action: .startWorkout(workoutPlan))):
        state.activeWorkout = ActiveWorkout(id: env.uuid(), workoutPlan: workoutPlan)
        return .none
    default:
        return .none
    }
})
