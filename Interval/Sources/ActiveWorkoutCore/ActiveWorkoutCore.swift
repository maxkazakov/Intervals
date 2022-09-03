//
//  ActiveWorkoutCore.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import SwiftUI
import ComposableArchitecture
import WorkoutPlanCore

public enum ActiveWorkoutStatus {
    case initial
    case inProgress
    case paused
}

public struct ActiveWorkout: Identifiable, Equatable {
    public init(id: UUID, workoutPlan: WorkoutPlan, time: TimeInterval = 0.0, status: ActiveWorkoutStatus = .initial) {
        self.id = id
        self.workoutPlan = workoutPlan
        self.time = time
        self.status = status
    }

    public var id: UUID
    public let workoutPlan: WorkoutPlan
    public var time: TimeInterval = 0.0
    public var status: ActiveWorkoutStatus
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

public let workoutPlanReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment> { state, action, env in
    switch action {
    case .start:
        return .none
    case .pause:
        return .none
    case .stop:
        return .none
    }
}
