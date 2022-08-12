//
//  AppCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import IntervalList
import IntervalCore
import ComposableArchitecture
import WorkoutPlanCore

public struct AppState: Equatable {
    public var workoutPlan: WorkoutPlan

    public init() {
        self.workoutPlan = .default
    }
}

public struct AppEnvironment {
    public init() {}
}

public enum AppAction {
    case workoutPlan(WorkoutPlanAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlanReducer.pullback(state: \.workoutPlan,
                             action: /AppAction.workoutPlan,
                             environment: { _ in
                                 WorkoutPlanEnvironment()
                             })
)
.debug()
