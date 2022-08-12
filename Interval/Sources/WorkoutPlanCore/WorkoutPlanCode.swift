//
//  File.swift
//  
//
//  Created by Максим Казаков on 12.08.2022.
//

import SwiftUI
import IntervalCore
import ComposableArchitecture

public struct WorkoutPlan: Equatable {
    public var name: String
    public var intervals: [Interval]

    public init(name: String, intervals: [Interval]) {
        self.name = name
        self.intervals = intervals
    }
}

public struct WorkoutPlanEnvironment {
    public init() {}
}

public enum WorkoutPlanAction {
    case nameChanged(String)
    case addNewInterval(Interval)
    case removeInterval(indices: Set<Int>)
}

public let workoutPlanReducer = Reducer<WorkoutPlan, WorkoutPlanAction, WorkoutPlanEnvironment> { state, action, _ in
    switch action {
    case let .nameChanged(newName):
        state.name = newName
        return .none

    case let .addNewInterval(newInterval):
        state.intervals.append(newInterval)
        return .none

    case let .removeInterval(indices):
        indices.forEach { state.intervals.remove(at: $0) }
        return .none
    }
}
