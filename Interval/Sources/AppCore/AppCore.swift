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
        self.workoutPlans = .init(workoutPlans: [])
    }
}

public struct AppEnvironment {
    public init() {}
}

public enum AppAction {    
    case workoutPlanList(WorkoutPlansListAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlansListReducer.pullback(state: \.workoutPlans,
                                     action: /AppAction.workoutPlanList,
                                     environment: { _ in WorkoutPlansListEnvironment.live })
)
.debug()
