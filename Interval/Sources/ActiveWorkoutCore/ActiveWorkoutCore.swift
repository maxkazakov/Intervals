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
    public var time: Int = 0 // ms
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
    public var time: Int = 0 // ms
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

import Foundation
public let activeWorkoutReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, env in
    struct TimerID: Hashable {}
    let tickMs: Int = 100

    func startTimer() -> Effect<ActiveWorkoutAction, Never> {
        Effect.timer(
            id: TimerID(),
            every: .milliseconds(tickMs),
            on: env.mainQueue
        )
        .map { _ in .timerTicked }
    }

    switch action {
    case .timerTicked:
        state.time += tickMs
        state.currentIntervalStep.time += tickMs

        switch state.currentIntervalStep.finishType {
        case let .byDuration(seconds):
            if state.currentIntervalStep.time >= Int(seconds) * 1000 {
                return Effect(value: .stepFinished)
            }
        default:
            break
        }
        return .none


    case .start:
        state.status = .inProgress
        return startTimer()
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

        // Restart timer, because next tick can be somewhere between swithing stages
        return .merge([
            .cancel(id: TimerID()),
            startTimer()
        ])
    }
}
