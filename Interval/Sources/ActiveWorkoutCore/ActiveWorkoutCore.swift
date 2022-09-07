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
    public let finishType: FinishType
    public let intervalId: Interval.Id
}

public struct CurrentWorkoutIntervalStep: Equatable {
    public init(workoutIntervalStep: WorkoutIntervalStep) {
        self.workoutIntervalStep = workoutIntervalStep
    }
    public var lastStartTime: Date = Date()
    public var time: TimeInterval = 0
    public let workoutIntervalStep: WorkoutIntervalStep
}

public struct ActiveWorkout: Identifiable, Equatable {
    public init(
        id: UUID,
        workoutPlan: WorkoutPlan,
        time: TimeInterval = 0.0,
        status: ActiveWorkoutStatus = .initial,
        intervalSteps: [WorkoutIntervalStep],
        currentIntervalStep: WorkoutIntervalStep
    ) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.time = time
        self.status = status
        self.intervalSteps = intervalSteps
        self.currentIntervalStep = CurrentWorkoutIntervalStep(workoutIntervalStep: currentIntervalStep)
    }

    public var id: UUID
    public let workoutPlan: WorkoutPlan
    public var time: TimeInterval = 0.0
    public var lastStartTime = Date()
    public var status: ActiveWorkoutStatus
    public var intervalSteps: [WorkoutIntervalStep]
    public var currentIntervalStep: CurrentWorkoutIntervalStep
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
        state.currentIntervalStep.time += timePassed
        state.status = .paused
        return .none
    case .stop:
        let timePassed = Date().timeIntervalSince1970 - state.lastStartTime.timeIntervalSince1970
        state.time += timePassed
        state.currentIntervalStep.time += timePassed
        state.status = .paused
        return .none

    case .stepFinished:
        let timePassed = Date().timeIntervalSince1970 - state.lastStartTime.timeIntervalSince1970
        state.time += timePassed
        state.currentIntervalStep.time += timePassed

        let idx = state.intervalSteps.firstIndex(of: state.currentIntervalStep.workoutIntervalStep)!
        if idx == state.intervalSteps.count {
            return Effect(value: .stop)
        }

        let nextStep = state.intervalSteps[idx + 1]
        state.currentIntervalStep = CurrentWorkoutIntervalStep(workoutIntervalStep: nextStep)
        return .none
    }
}
