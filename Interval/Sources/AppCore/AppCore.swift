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
import IdentifiedCollections

public struct AppState: Equatable {
    public var workoutPlans: IdentifiedArrayOf<WorkoutPlan>

    public init() {
        self.workoutPlans = [.default, { var a = WorkoutPlan.default; a.id = UUID(); return a }()]
    }
}

public struct AppEnvironment {
    public init() {}
}

public enum AppAction {
    case workoutPlan(id: UUID, action: WorkoutPlanAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlanReducer.forEach(state: \.workoutPlans, action: /AppAction.workoutPlan, environment: { _ in WorkoutPlanEnvironment() })
)
.debug()
