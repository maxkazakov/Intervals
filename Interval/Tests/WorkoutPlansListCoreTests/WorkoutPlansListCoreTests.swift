//
//  WorkoutPlansListCoreTests.swift
//  
//
//  Created by Максим Казаков on 29.08.2022.
//

import Foundation

import XCTest
import Combine
import ComposableArchitecture
import WorkoutPlanCore
import WorkoutPlansListCore
import WorkoutPlansStorage
import TestHelpers
import IntervalCore

final class WorkoutPlansListCoreTests: XCTestCase {

    var mainQueue: TestSchedulerOf<DispatchQueue>!
    var uuid: (() -> UUID)!

    override func setUp() {
        uuid = UUID.incrementing
        mainQueue = DispatchQueue.test
    }

    func testCreateWorkoutPlan() throws {
        let env = WorkoutPlansListEnvironment(
            workoutPlansStorage: WorkoutPlansStorage(
                fetch: { Effect(value: []) },
                store: { _ in .fireAndForget {} }),
            mainQueue: mainQueue.eraseToAnyScheduler(),
            uuid: uuid
        )

        let store = TestStore(
            initialState: WorkoutPlansList(workoutPlans: []),
            reducer: workoutPlansListReducer,
            environment: env
        )

        store.send(.createNewWorkoutPlan) { state in
            let workoutPlan = WorkoutPlan(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
                name: "Workout plan 1",
                intervals: [
                    Interval(id: .init(UUID(uuidString: "00000000-0000-0000-0000-000000000001")!), name: "Warm up", finishType: .byDuration(seconds: 60 * 5)),
                    Interval(id: .init(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!), name: "Workout", finishType: .byDistance(meters: 1000))
                ]
            )
            state.workoutPlans.insert(workoutPlan, at: 0)
        }

        self.mainQueue.advance(by: .milliseconds(150))

        store.receive(.setOpenedWorkoutPlan(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)) { state in
            state.openedWorkoutPlanId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }

        self.mainQueue.advance(by: .milliseconds(500))
    }

    @MainActor
    func testImmediateDebounce() async {
        enum Action { case tap }
        let store = TestStore(
            initialState: 0,
            reducer: Reducer<Int, Action, Void> { state, action, _ in
//                return .fireAndForget {
//                }
//                .debounce(id: 1, for: 1, scheduler: DispatchQueue.immediate)
                return .none
            },
            environment: ()
        )

        await store.send(.tap)
    }
}
