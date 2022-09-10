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
    public let id: UUID
    public var name: String
    public let finishType: FinishType
    public let intervalId: Interval.Id

    public var lastStartTime: Date = Date()
    public var time: TimeInterval = 0
    public var isFinished = false
}

public struct ActiveWorkout: Identifiable, Equatable {
    public init(
        id: UUID,
        workoutPlan: WorkoutPlan,
        intervalSteps: [WorkoutIntervalStep]
    ) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.intervalSteps = intervalSteps
    }

    public var id: UUID
    public let workoutPlan: WorkoutPlan
    public var time: TimeInterval = 0.0
    public var lastStartTime = Date()
    public var status: ActiveWorkoutStatus = .initial
    public var intervalSteps: [WorkoutIntervalStep]
    public var currentIntervalIdx: Int = 0

    public var currentIntervalStep: WorkoutIntervalStep {
        get {
            intervalSteps[currentIntervalIdx]
        }
        set {
            intervalSteps[currentIntervalIdx] = newValue
        }
    }
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
    case stepFinished
}

public let activeWorkoutReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, env in
    switch action {

    case .start:
        let now = Date()
        state.lastStartTime = now
        state.currentIntervalStep.lastStartTime = now
        state.status = .inProgress
        return .none

    case .pause:
        let timePassed = Date().timeIntervalSince1970 - state.lastStartTime.timeIntervalSince1970
        state.time += timePassed

        let timePassedForStep = Date().timeIntervalSince1970 - state.currentIntervalStep.lastStartTime.timeIntervalSince1970
        state.currentIntervalStep.time += timePassedForStep

        state.status = .paused
        return .none

    case .stop:
        if state.status == .inProgress {
            let timePassed = Date().timeIntervalSince1970 - state.lastStartTime.timeIntervalSince1970
            state.time += timePassed

            let timePassedForStep = Date().timeIntervalSince1970 - state.currentIntervalStep.lastStartTime.timeIntervalSince1970
            state.currentIntervalStep.time += timePassedForStep
            state.status = .paused
        }

        return .none

    case .stepFinished:
        let now = Date()
        let timePassed = now.timeIntervalSince1970 - state.lastStartTime.timeIntervalSince1970
        state.time += timePassed

        let timePassedForStep = Date().timeIntervalSince1970 - state.currentIntervalStep.lastStartTime.timeIntervalSince1970
        state.currentIntervalStep.time += timePassedForStep
        state.currentIntervalStep.isFinished = true

        let nextIdx = state.currentIntervalIdx + 1
        if nextIdx == state.intervalSteps.count {
            return Effect(value: .stop)
        }
        state.currentIntervalIdx = nextIdx
        state.currentIntervalStep.lastStartTime = now

        return .none
    }
}
