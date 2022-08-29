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

public struct WorkoutPlan: Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var intervals: IdentifiedArrayOf<Interval> = []
    public var editingIntervalId: Interval.Id?

    public init(id: UUID, name: String, intervals: IdentifiedArrayOf<Interval>) {
        self.id = id
        self.name = name
        self.intervals = intervals
    }
}

public struct WorkoutPlanEnvironment {
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public extension WorkoutPlanEnvironment {
    static let live = WorkoutPlanEnvironment(uuid: UUID.init)
}

public enum WorkoutPlanAction: Equatable {
    case nameChanged(String)
    case addNewInterval
    case removeIntervals(indices: IndexSet)
    case moveIntervals(fromOffsets: IndexSet, toOffset: Int)

    case interval(id: Interval.Id, action: IntervalAction)

    case startEditInterval(id: Interval.Id)
    case finishEditInterval

    case copyInterval(Interval)
}

public let workoutPlanReducer = Reducer<WorkoutPlan, WorkoutPlanAction, WorkoutPlanEnvironment> { state, action, env in
    switch action {
    case let .nameChanged(newName):
        state.name = newName
        return .none

    case .addNewInterval:
        let newInterval = Interval.init(id: Interval.ID(env.uuid()), name: "Interval", finishType: .byTappingButton)
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
        guard let idx = state.intervals.index(id: interval.id) else {
            return .none
        }
        var newInterval = interval
        newInterval.id = Interval.ID(env.uuid())
        newInterval.name = interval.name + " copy"
        state.intervals.insert(newInterval, at: idx + 1)
        return .none
        
    case .interval:
        return .none
    }
}.combined(with: intervalReducer.forEach(
    state: \.intervals,
    action: /WorkoutPlanAction.interval(id:action:),
    environment: { _ in IntervalEnvironment() }
))
