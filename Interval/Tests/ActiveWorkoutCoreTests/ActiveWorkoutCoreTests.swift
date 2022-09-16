import XCTest
import ComposableArchitecture
import TestHelpers

@testable import ActiveWorkoutCore
import WorkoutPlanCore
import IntervalCore

final class ActiveWorkoutCoreTests: XCTestCase {

    var now: Date!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() async throws {
        now = Date(timeIntervalSince1970: 0)
        scheduler = DispatchQueue.test
    }

    func testStartAndPauseFlow() throws {
        let scheduler = DispatchQueue.test

        let env = ActiveWorkoutEnvironment(
            uuid: UUID.incrementing,
            mainQueue: scheduler.eraseToAnyScheduler(),
            now: { self.now }
        )

        let workoutPlan = WorkoutPlan(id: UUID(), name: "Running", intervals: [])
        let intervalSteps: [WorkoutIntervalStep] = [
            WorkoutIntervalStep(
                id: UUID(),
                name: "Interval 1",
                finishType: .byTappingButton,
                intervalId: Interval.Id()
            )
        ]

        let store = TestStore(
            initialState: ActiveWorkout(
                id: UUID(),
                workoutPlan: workoutPlan,
                intervalSteps: intervalSteps
            ),
            reducer: activeWorkoutReducer,
            environment: env
        )

        store.send(.start) {
            $0.status = .inProgress
        }

        scheduler.advance(by: .seconds(0.2))

        store.receive(.timerTicked) {
            $0.time = 100
            $0.currentIntervalStep.time = 100
        }
        store.receive(.timerTicked) {
            $0.time = 200
            $0.currentIntervalStep.time = 200
        }

        store.send(.pause) {
            $0.status = .paused
        }

        scheduler.advance(by: .seconds(0.5))

        store.send(.start) {
            $0.status = .inProgress
        }

        scheduler.advance(by: .seconds(0.2))

        store.receive(.timerTicked) {
            $0.time = 300
            $0.currentIntervalStep.time = 300
        }
        store.receive(.timerTicked) {
            $0.time = 400
            $0.currentIntervalStep.time = 400
        }

        store.send(.stop) {
            $0.status = .paused
        }
    }

    func testFewCountdownIntervalsFlow() throws {
        let scheduler = DispatchQueue.test

        let env = ActiveWorkoutEnvironment(
            uuid: UUID.incrementing,
            mainQueue: scheduler.eraseToAnyScheduler(),
            now: { self.now }
        )

        let workoutPlan = WorkoutPlan(id: UUID(), name: "Running", intervals: [])
        let intervalSteps: [WorkoutIntervalStep] = [
            WorkoutIntervalStep(
                id: UUID(),
                name: "Interval 1",
                finishType: .byDuration(seconds: 1),
                intervalId: Interval.Id()
            ),
            WorkoutIntervalStep(
                id: UUID(),
                name: "Interval 2",
                finishType: .byDuration(seconds: 2),
                intervalId: Interval.Id()
            )
        ]

        let store = TestStore(
            initialState: ActiveWorkout(
                id: UUID(),
                workoutPlan: workoutPlan,
                intervalSteps: intervalSteps
            ),
            reducer: activeWorkoutReducer,
            environment: env
        )

        store.send(.start) {
            $0.status = .inProgress
        }

        scheduler.advance(by: .seconds(1))

        (1...10).forEach { tickIdx in
            store.receive(.timerTicked) {
                $0.time = 100 * tickIdx
                $0.currentIntervalStep.time = 100 * tickIdx
            }
        }

        store.receive(.stepFinished) {
            $0.currentIntervalIdx = 1
            $0.intervalSteps[0].isFinished = true
        }

        scheduler.advance(by: .seconds(1))

        (1...10).forEach { tickIdx in
            store.receive(.timerTicked) {
                $0.time = 100 * tickIdx + 1000
                $0.currentIntervalStep.time = 100 * tickIdx
            }
        }

        store.send(.stop) {
            $0.status = .paused
        }
    }
}
