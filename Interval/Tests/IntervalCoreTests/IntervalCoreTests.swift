import XCTest
import ComposableArchitecture
@testable import IntervalCore

final class IntervalCoreTests: XCTestCase {

    func testNameChanged() throws {
        let store = TestStore(
            initialState: Interval(id: Interval.Id.init(UUID()), name: "Running", finishType: .byTappingButton),
            reducer: intervalReducer,
            environment: IntervalEnvironment()
        )

        store.send(.nameChanged("Walking"), { state in
            state.name = "Walking"
        })
    }

    func testFinishTypeChanged() throws {
        let store = TestStore(
            initialState: Interval(id: Interval.Id.init(UUID()), name: "Running", finishType: .byTappingButton),
            reducer: intervalReducer,
            environment: IntervalEnvironment()
        )

        store.send(.finishTypeChanged(.byDuration(seconds: 120))) { state in
            state.finishType = .byDuration(seconds: 120)
        }
    }

    func testPaceChangedFromChanged() throws {
        let store = TestStore(
            initialState: Interval(id: Interval.Id.init(UUID()), name: "Running", finishType: .byTappingButton, paceRange: 100...120),
            reducer: intervalReducer,
            environment: IntervalEnvironment()
        )

        store.send(.paceRangeFromChanged(200)) { state in
            state.paceRange = 200...200
        }

        store.send(.paceRangeFromChanged(120)) { state in
            state.paceRange = 120...200
        }
    }

    func testPaceChangedToChanged() throws {
        let store = TestStore(
            initialState: Interval(id: Interval.Id.init(UUID()), name: "Running", finishType: .byTappingButton, paceRange: 100...120),
            reducer: intervalReducer,
            environment: IntervalEnvironment()
        )

        store.send(.paceRangeToChanged(90)) { state in
            state.paceRange = 90...90
        }

        store.send(.paceRangeToChanged(120)) { state in
            state.paceRange = 90...120
        }
    }
}
