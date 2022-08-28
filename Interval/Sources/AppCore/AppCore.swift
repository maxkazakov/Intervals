//
//  AppCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture
import WorkoutPlansListCore
import WorkoutPlansStorage

public struct AppState: Equatable {
    public var workoutPlans: WorkoutPlansList

    public init() {
        self.workoutPlans = .default
    }
}

public struct AppEnvironment {

    var workoutPlansStorage: WorkoutPlansStorage
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        workoutPlansStorage: WorkoutPlansStorage,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.workoutPlansStorage = workoutPlansStorage
        self.mainQueue = mainQueue
    }
}

public enum AppAction {
    case workoutPlanList(WorkoutPlansListAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlansListReducer.pullback(state: \.workoutPlans, action: /AppAction.workoutPlanList, environment: { _ in WorkoutPlansListEnvironment() }),
    Reducer { state, action, env in
        switch action {
        case .workoutPlanList:
            return env.workoutPlansStorage.store(state.workoutPlans.workoutPlans)
                .throttle(for: 1, scheduler: env.mainQueue, latest: true)
                .fireAndForget()
        }
    }
)
.debug()
