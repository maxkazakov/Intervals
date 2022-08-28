//
//  WorkoutPlanListCore.swift
//  
//
//  Created by Максим Казаков on 22.08.2022.
//

import Foundation
import Combine
import ComposableArchitecture
import IdentifiedCollections

import SwiftUI
import IntervalList
import IntervalCore
import WorkoutPlanCore
import WorkoutPlansStorage


public struct WorkoutPlansList: Equatable {

    public var workoutPlans: IdentifiedArrayOf<WorkoutPlan>
    public var isLoadingFromFile = false
    public var openedWorkoutPlanId: UUID?
    public var removingConfirmationDialog: AlertState<WorkoutPlansListAction>?

    public init(workoutPlans: IdentifiedArrayOf<WorkoutPlan>) {
        self.workoutPlans = workoutPlans
    }

    public static let `default` = WorkoutPlansList(workoutPlans: [.default])
}

public struct WorkoutPlansListEnvironment {
    var workoutPlansStorage: WorkoutPlansStorage
    var mainQueue: AnySchedulerOf<DispatchQueue>

    public init(
        workoutPlansStorage: WorkoutPlansStorage,
        mainQueue: AnySchedulerOf<DispatchQueue>
    ) {
        self.workoutPlansStorage = workoutPlansStorage
        self.mainQueue = mainQueue
    }
}

public extension WorkoutPlansListEnvironment {
    static let live = WorkoutPlansListEnvironment(workoutPlansStorage: .live, mainQueue: .main)
}

public enum WorkoutPlansListAction: Equatable {
    case workoutPlan(id: UUID, action: WorkoutPlanAction)

    case setOpenedWorkoutPlan(id: UUID?)
    case createNewWorkoutPlan
    case tapRemoveWorkoutPlan(indices: IndexSet)
    case cancelRemoving
    case confirmRemoving(indices: IndexSet)

    case initialLoading
    case plansLoadedFromDisk([WorkoutPlan])
}

public let workoutPlansListReducer = Reducer<WorkoutPlansList, WorkoutPlansListAction, WorkoutPlansListEnvironment>.combine(
    workoutPlanReducer.forEach(state: \.workoutPlans, action: /WorkoutPlansListAction.workoutPlan, environment: { _ in WorkoutPlanEnvironment() }),
    Reducer { state, action, env in
        switch action {
        case let .setOpenedWorkoutPlan(id):
            state.openedWorkoutPlanId = id
            return .none

        case .createNewWorkoutPlan:
            let idx = state.workoutPlans.count + 1
            let newPlanId = UUID()
            var newPlan = WorkoutPlan.default
            newPlan.id = newPlanId
            newPlan.name = "Workout plan \(idx)"
            state.workoutPlans.append(newPlan)

            return Effect(value: WorkoutPlansListAction.setOpenedWorkoutPlan(id: newPlanId))
                .delay(for: 0.2, scheduler: RunLoop.main)
                .eraseToEffect()

        case let .tapRemoveWorkoutPlan(indices):
            state.removingConfirmationDialog = AlertState(
                title: TextState("Delete"),
                message: TextState("Are you sure you want to delete this? It cannot be undone."),
                primaryButton: .destructive(TextState("Confirm"), action: .send(.confirmRemoving(indices: indices))),
                secondaryButton: .cancel(TextState("Cancel"))
            )
            return .none

        case .workoutPlan:
            return .none

        case .cancelRemoving:
            state.removingConfirmationDialog = nil
            return .none

        case let .confirmRemoving(indices):
            state.removingConfirmationDialog = nil
            indices.forEach { state.workoutPlans.remove(at: $0) }
            return .none

        case .initialLoading:
            state.isLoadingFromFile = true
            return env.workoutPlansStorage.fetch()
                .map { .plansLoadedFromDisk($0) }
                .catch { _ in Just(.plansLoadedFromDisk([])) }
                .eraseToEffect()

        case let .plansLoadedFromDisk(workoutPlans):
            state.isLoadingFromFile = false
            state.workoutPlans = IdentifiedArrayOf<WorkoutPlan>(uniqueElements: workoutPlans)
            return .none
        }
    },
    workoutPlansListSaveReducer
)

let workoutPlansListSaveReducer = Reducer<WorkoutPlansList, WorkoutPlansListAction, WorkoutPlansListEnvironment> {  state, action, env in
    return env.workoutPlansStorage.store(state.workoutPlans.elements)
        .throttle(for: 1, scheduler: env.mainQueue, latest: true)
        .fireAndForget()
}
