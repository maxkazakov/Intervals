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
    public var previousTickTime = Date()
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
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var now: () -> Date

    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        now: @escaping () -> Date
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.now = now
    }
}

public enum ActiveWorkoutAction: Equatable {
    case start
    case pause
    case stop
    case stepFinished

    case timerTicked
}

public let activeWorkoutReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, env in
    struct TimerID: Hashable {}

    func moveTime(state: inout ActiveWorkout, env: ActiveWorkoutEnvironment) {
        let now = env.now()

        let timePassed = now.timeIntervalSince1970 - state.previousTickTime.timeIntervalSince1970
        print("timePassed", timePassed)
        state.time += timePassed
        state.currentIntervalStep.time += timePassed
        state.previousTickTime = now
    }

    switch action {
    case .timerTicked:
        moveTime(state: &state, env: env)
        return .none

    case .start:
        let now = env.now()
        state.previousTickTime = now
        state.status = .inProgress

        return Effect.timer(
            id: TimerID(),
            every: 1.0,
            tolerance: 0.02,
            on: env.mainQueue
        )
        .map { _ in .timerTicked }

    case .pause:
        state.status = .paused
        return .cancel(id: TimerID())

    case .stop:
        state.status = .paused
        return .cancel(id: TimerID())

    case .stepFinished:
        state.currentIntervalStep.isFinished = true
        let nextIdx = state.currentIntervalIdx + 1
        if nextIdx == state.intervalSteps.count {
            return Effect(value: .stop)
        }
        state.currentIntervalIdx = nextIdx

        return .none
    }
}
