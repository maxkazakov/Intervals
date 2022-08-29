//
//  WorkoutPlanCoreTests.swift
//  
//
//  Created by Максим Казаков on 29.08.2022.
//

import XCTest
import ComposableArchitecture
@testable import WorkoutPlanCore
import IntervalCore
import TestHelpers

final class WorkoutPlanCoreTests: XCTestCase {

    var env: WorkoutPlanEnvironment!
    var uuid: (() -> UUID)!

    override func setUp() {
        uuid = UUID.incrementing
        env = WorkoutPlanEnvironment(uuid: uuid)
    }

    func testCopyWorkoutPlan() throws {
        let interval_1 = Interval(id: Interval.Id(uuid()), name: "Running", finishType: .byTappingButton)
        let interval_2 = Interval(id: Interval.Id(uuid()), name: "Walking", finishType: .byTappingButton)

        let store = TestStore(
            initialState: WorkoutPlan(id: UUID(), name: "Workout plan 1", intervals: [interval_1, interval_2]),
            reducer: workoutPlanReducer,
            environment: env
        )

        store.send(.copyInterval(interval_1)) { state in
            let copyId = Interval.Id(UUID(uuidString: "00000000-0000-0000-0000-000000000002")!)
            state.intervals.insert(Interval(id: copyId, name: "Running copy", finishType: .byTappingButton), at: 1)
        }

        XCTAssertEqual(store.state.intervals.count, 3)
    }
}
