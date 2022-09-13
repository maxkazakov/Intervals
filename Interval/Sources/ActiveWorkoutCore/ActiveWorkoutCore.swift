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


    switch action {
    // Why I don't use state.time += now() - lastTick time date instead of stupid state.time += 1:
    // because tolerance of miliseconds ruins displaying seconds. E.g. if passed time is 3.1 and remaining is 1.9, I will show on view "00:01" ms, but I want to show "00:02".
    // That means I have to round to nearest seconds. It's looks silly
    case .timerTicked:
        state.time += 1
        state.currentIntervalStep.time += 1

        switch state.currentIntervalStep.finishType {
        case let .byDuration(seconds):
            if state.currentIntervalStep.time >= TimeInterval(seconds) {
                return Effect(value: .stepFinished)
            }
        default:
            break
        }
        return .none

    case .start:
        state.status = .inProgress
        return Effect.timer(
            id: TimerID(),
            every: 1.0,
            on: env.mainQueue
        )
        .map { _ in .timerTicked }

    case .pause:
        // I stop timer here, that means that if real time passed is 2.9 seconds, I tracked only 2 tick what is 2 seconds.
        // It's not a big problem for logic. But coutdown timer animation will show exact 2.9 and when interval continues the countdown view will finish its animation earlier than interval itself
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

        // Restart timer, because next tick can be somewhere between swithing stages
        return .merge([
            .cancel(id: TimerID()),
            Effect.timer(
                id: TimerID(),
                every: 1.0,
                on: env.mainQueue
            )
            .map { _ in .timerTicked }
        ])
    }
}
