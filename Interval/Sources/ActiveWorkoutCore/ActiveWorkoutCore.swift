//
//  ActiveWorkoutCore.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import SwiftUI
import ComposableArchitecture
import WorkoutPlanCore
import IntervalCore

public enum ActiveWorkoutStatus: Equatable {
    case initial
    case inProgress
    case paused
}

public struct WorkoutIntervalStep: Equatable {
    public init(id: UUID, name: String, finishType: FinishType, intervalId: Interval.Id) {
        self.id = id
        self.name = name
        self.finishType = finishType
        self.intervalId = intervalId
    }

    let id: UUID
    public var name: String
    let finishType: FinishType
    let intervalId: Interval.Id
}

public struct ActiveWorkout: Identifiable, Equatable {
    public init(id: UUID,
                workoutPlan: WorkoutPlan,
                time: TimeInterval = 0.0,
                status: ActiveWorkoutStatus = .initial,
                intervalSteps: [WorkoutIntervalStep],
                currentIntervalStep: WorkoutIntervalStep?
    ) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.time = time
        self.status = status
        self.intervalSteps = intervalSteps
        self.currentIntervalStep = currentIntervalStep
    }

    public var id: UUID
    public let workoutPlan: WorkoutPlan
    public var time: TimeInterval = 0.0
    public var lastTimeStarted = Date()
    public var status: ActiveWorkoutStatus
    public var intervalSteps: [WorkoutIntervalStep]
    public var currentIntervalStep: WorkoutIntervalStep?
}

public struct ActiveWorkoutEnvironment {
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public enum ActiveWorkoutAction: Equatable {
    case start
    case pause
    case stop
}

public let activeWorkoutReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, env in
    switch action {
    case .start:
        state.lastTimeStarted = Date()
        state.status = .inProgress
        return .none
    case .pause:
        state.time += Date().timeIntervalSince1970 - state.lastTimeStarted.timeIntervalSince1970
        state.status = .paused
        return .none
    case .stop:
        state.time += Date().timeIntervalSince1970 - state.lastTimeStarted.timeIntervalSince1970
        state.status = .paused
        return .none
    }
}
