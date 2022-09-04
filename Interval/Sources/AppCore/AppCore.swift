//
//  AppCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture
import WorkoutPlansListCore

import ActiveWorkoutCore

public struct AppState: Equatable {
    public var workoutPlans: WorkoutPlansList
    public var activeWorkout: ActiveWorkout?

    public init() {
        self.workoutPlans = .init(workoutPlans: [])
    }
}

public struct AppEnvironment {
    var uuid: () -> UUID

    public init(uuid: @escaping () -> UUID) {
        self.uuid = uuid
    }
}

public enum AppAction {    
    case workoutPlanList(WorkoutPlansListAction)
    case activeWorkoutAction(ActiveWorkoutAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    workoutPlansListReducer.pullback(
        state: \.workoutPlans,
        action: /AppAction.workoutPlanList,
        environment: {
            WorkoutPlansListEnvironment(
                workoutPlansStorage: .live,
                mainQueue: .main,
                uuid: $0.uuid
            )
        }
    ),
    activeWorkoutReducer.optional().pullback(state: \.activeWorkout, action: /AppAction.activeWorkoutAction, environment: { ActiveWorkoutEnvironment(uuid: $0.uuid) }),
    startWorkoutReducer
)
.debug()

let startWorkoutReducer = Reducer<AppState, AppAction, AppEnvironment>({ state, action, env in
    switch action {
    case let .workoutPlanList(.workoutPlan(_, action: .startWorkout(workoutPlan))):
        let intervalSteps: [WorkoutIntervalStep] = workoutPlan.intervals.flatMap { interval -> [WorkoutIntervalStep] in
            var steps = [WorkoutIntervalStep]()
            let mainStep = WorkoutIntervalStep(id: env.uuid(),
                                name: interval.name,
                                finishType: interval.finishType,
                                intervalId: interval.id)
            steps.append(mainStep)

            if interval.recoveryInfo.isEnabled {
                let recoveryStep = WorkoutIntervalStep(id: env.uuid(),
                                                       name: "Recovery",
                                                       finishType: interval.recoveryInfo.finishType,
                                                       intervalId: interval.id)
                steps.append(recoveryStep)
            }

            if interval.repeatCount > 1 {
                let originSteps = steps
                steps = []
                for i in 0..<interval.repeatCount {
                    let newSteps: [WorkoutIntervalStep] = originSteps.map {
                        var stepCopy = $0
                        stepCopy.name = "\($0.name) \(i + 1)/\(interval.repeatCount)"
                        return stepCopy
                    }
                    steps.append(contentsOf: newSteps)
                }
            }
            return steps
        }
        state.activeWorkout = ActiveWorkout(id: env.uuid(),
                                            workoutPlan: workoutPlan,
                                            intervalSteps: intervalSteps,
                                            currentIntervalStep: intervalSteps.first)

        return .none
    case .activeWorkoutAction(.stop):
        state.activeWorkout = nil
        return .none
    default:
        return .none
    }
})
