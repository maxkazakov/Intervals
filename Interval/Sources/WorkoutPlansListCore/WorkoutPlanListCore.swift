//
//  WorkoutPlanListCore.swift
//  
//
//  Created by Максим Казаков on 22.08.2022.
//

import Foundation

import SwiftUI
import IntervalList
import IntervalCore
import ComposableArchitecture
import WorkoutPlanCore
import IdentifiedCollections

public struct WorkoutPlansList: Equatable {
    public var workoutPlans: IdentifiedArrayOf<WorkoutPlan>

    public init(workoutPlans: IdentifiedArrayOf<WorkoutPlan>) {
        self.workoutPlans = workoutPlans
    }

    public static let `default` = WorkoutPlansList(workoutPlans: [.default])
}

public struct WorkoutPlansListEnvironment {
    public init() {}
}

public enum WorkoutPlansListAction {
    case workoutPlan(id: UUID, action: WorkoutPlanAction)
}

public let workoutPlansListReducer = Reducer<WorkoutPlansList, WorkoutPlansListAction, WorkoutPlansListEnvironment>.combine(
    workoutPlanReducer.forEach(state: \.workoutPlans, action: /WorkoutPlansListAction.workoutPlan, environment: { _ in WorkoutPlanEnvironment() })
)
    .debug()
