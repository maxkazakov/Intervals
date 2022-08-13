//
//  File.swift
//  
//
//  Created by Максим Казаков on 12.08.2022.
//

import SwiftUI
import IntervalCore
import ComposableArchitecture
import IdentifiedCollections

public struct WorkoutPlan: Equatable {
    public var name: String
    public var intervals: IdentifiedArrayOf<Interval> = []
    public var editingIntervalId: Interval.Id?

    public init(name: String, intervals: IdentifiedArrayOf<Interval>) {
        self.name = name
        self.intervals = intervals
    }

    public static let `default` = WorkoutPlan(
        name: "Workout Plan 1",
        intervals: [
            .make(with: "Warm up", and: .byDuration(seconds: 60 * 5)),
            .make(with: "Workout", and: .byDistance(meters: 1000))
        ]
    )
}

public struct WorkoutPlanEnvironment {
    public init() {}
}

public enum WorkoutPlanAction {
    case nameChanged(String)
    case addNewInterval
    case removeIntervals(indices: IndexSet)
    case moveIntervals(fromOffsets: IndexSet, toOffset: Int)

    case interval(id: Interval.Id, action: IntervalAction)

    case startEditInterval(id: Interval.Id)
    case finishEditInterval

    case copyInterval(Interval)
}

public let workoutPlanReducer = Reducer<WorkoutPlan, WorkoutPlanAction, WorkoutPlanEnvironment> { state, action, _ in
    switch action {
    case let .nameChanged(newName):
        state.name = newName
        return .none

    case .addNewInterval:
        let newInterval = Interval.make(with: "Interval", and: .byTappingButton)
        state.intervals.append(newInterval)
        return .none

    case let .removeIntervals(indices):
        indices.forEach { state.intervals.remove(at: $0) }
        return .none

    case let .moveIntervals(fromOffsets, toOffset):
        state.intervals.move(fromOffsets: fromOffsets, toOffset: toOffset)
        return .none

    case let .startEditInterval(intervalId):
        state.editingIntervalId = intervalId
        return .none

    case .finishEditInterval:
        state.editingIntervalId = nil
        return .none

    case let .copyInterval(interval):
        var newInterval = interval
        newInterval.id = .init()
        state.intervals.append(newInterval)
        return .none
        
    case .interval:
        return .none
    }
}.combined(with: intervalReducer.forEach(
    state: \.intervals,
    action: /WorkoutPlanAction.interval(id:action:),
    environment: { _ in IntervalEnvironment() }
))
