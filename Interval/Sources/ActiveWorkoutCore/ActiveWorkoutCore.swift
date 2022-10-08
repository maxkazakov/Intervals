//
//  ActiveWorkoutCore.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import SwiftUI
import IntervalCore
import WorkoutPlanCore
import LocationAccessCore
import LocationTracker

import ComposableArchitecture
import ComposableCoreLocation

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
    public var fullDistance: Double = 0.0 // meters
    public var isFinished = false
}

public struct WorkoutPreparationStatus: Equatable {
    public var locationStatus: LocationAccess = .initial

    public var isPrepared: Bool {
        locationStatus == .authorized
    }
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
    public var fullDistance: Double = 0.0
    public var status: ActiveWorkoutStatus = .initial
    public var intervalSteps: [WorkoutIntervalStep]
    public var currentIntervalIdx: Int = 0
    public var preparationStatus = WorkoutPreparationStatus()
    public var locationTracker = LocationTracker(lastLocation: nil, currentSpeed: 0.0)

    public var currentIntervalStep: WorkoutIntervalStep {
        get { intervalSteps[currentIntervalIdx] }
        set { intervalSteps[currentIntervalIdx] = newValue }
    }
}

public struct ActiveWorkoutEnvironment {
    var uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var now: () -> Date
    var locationManager: LocationManager

    public init(
        uuid: @escaping () -> UUID,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        now: @escaping () -> Date,
        locationManager: LocationManager
    ) {
        self.uuid = uuid
        self.mainQueue = mainQueue
        self.now = now
        self.locationManager = locationManager
    }
}

public enum ActiveWorkoutAction: Equatable {
    case onAppear
    case start
    case pause
    case stop
    case stepFinished

    case timerTicked

    case locationAccess(LocationAccessAction)
    case locationTracker(LocationTrackerAction)
}

public let activeWorkoutReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment>(
    { state, action, env in
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

        case .onAppear:
            return env.locationManager.set(
                activityType: .fitness,
                allowsBackgroundLocationUpdates: true,
                desiredAccuracy: kCLLocationAccuracyBestForNavigation,
                distanceFilter: 7,
                pausesLocationUpdatesAutomatically: false
            )
            .fireAndForget()

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
            return .merge(
                startTimer(),
                Effect(value: .locationTracker(.startTracking))
            )

        case .pause:
            state.status = .paused
            return .merge(
                .cancel(id: TimerID()),
                Effect(value: .locationTracker(.stopTracking))
            )

        case .stop:
            state.status = .paused
            return .merge(
                .cancel(id: TimerID()),
                Effect(value: .locationTracker(.stopTracking))
            )

        case .stepFinished:
            state.currentIntervalStep.isFinished = true
            let nextIdx = state.currentIntervalIdx + 1
            if nextIdx == state.intervalSteps.count {
                return Effect(value: .stop)
            }
            state.currentIntervalIdx = nextIdx

            // Restart timer, because next tick can be somewhere between switching stages
            return .merge([
                .cancel(id: TimerID()),
                startTimer()
            ])

        case .locationAccess(.onClose):
            return Effect(value: .stop)

        case let .locationTracker(.didPassedDistance(meters: meters)):
            state.fullDistance += meters
            state.currentIntervalStep.fullDistance += meters
            return .none

        case .locationAccess, .locationTracker:
            return .none
        }
    }
)


public let activeWorkoutProgressReducer = Reducer<ActiveWorkout, ActiveWorkoutAction, ActiveWorkoutEnvironment>.combine(
    activeWorkoutReducer,
    locationTrackerReducer.pullback(
        state: \.locationTracker,
        action: /ActiveWorkoutAction.locationTracker,
        environment: { LocationTrackerEnvironment(locationManager: $0.locationManager) }
    ),
    locationRequestReducer.pullback(
        state: \.preparationStatus.locationStatus,
        action: /ActiveWorkoutAction.locationAccess,
        environment: { LocationAccessEnvironment(locationManager: $0.locationManager) }
    )
)
    .debugActions()
