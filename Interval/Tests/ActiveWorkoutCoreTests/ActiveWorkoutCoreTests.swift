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
            $0.previousTickTime = Date(timeIntervalSince1970: 0)
            $0.status = .inProgress
        }

        (1...2).forEach { _ in
            now.addTimeInterval(1.0)
            scheduler.advance(by: .seconds(1.0))
        }

        store.receive(.timerTicked) {
            $0.time = 1.0
            $0.currentIntervalStep.time = 1.0
            $0.previousTickTime = Date(timeIntervalSince1970: 1.0)
        }
        store.receive(.timerTicked) {
            $0.time = 2.0
            $0.currentIntervalStep.time = 2.0
            $0.previousTickTime = Date(timeIntervalSince1970: 2.0)
        }

        store.send(.pause) {
            $0.status = .paused
        }

        (1...5).forEach { _ in
            now.addTimeInterval(1.0)
            scheduler.advance(by: .seconds(1.0))
        }

        store.send(.start) {
            $0.previousTickTime = Date(timeIntervalSince1970: 7.0)
            $0.status = .inProgress
        }

        (1...2).forEach { _ in
            now.addTimeInterval(1.0)
            scheduler.advance(by: .seconds(1.0))
        }

        store.receive(.timerTicked) {
            $0.time = 3.0
            $0.currentIntervalStep.time = 3.0
            $0.previousTickTime = Date(timeIntervalSince1970: 8.0)
        }
        store.receive(.timerTicked) {
            $0.time = 4.0
            $0.currentIntervalStep.time = 4.0
            $0.previousTickTime = Date(timeIntervalSince1970: 9.0)
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
                finishType: .byDuration(seconds: 2),
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
            $0.previousTickTime = Date(timeIntervalSince1970: 0)
            $0.status = .inProgress
        }

        (1...2).forEach { _ in
            now.addTimeInterval(1.0)
            scheduler.advance(by: .seconds(1.0))
        }

        store.receive(.timerTicked) {
            $0.time = 1.0
            $0.currentIntervalStep.time = 1.0
            $0.previousTickTime = Date(timeIntervalSince1970: 1.0)
        }
        store.receive(.timerTicked) {
            $0.time = 2.0
            $0.currentIntervalStep.time = 2.0
            $0.previousTickTime = Date(timeIntervalSince1970: 2.0)
        }
        store.receive(.stepFinished) {
            $0.currentIntervalIdx = 1
            $0.intervalSteps[0].isFinished = true
        }

        (1...1).forEach { _ in
            now.addTimeInterval(1.0)
            scheduler.advance(by: .seconds(1.0))
        }

        store.receive(.timerTicked) {
            $0.time = 3.0
            $0.currentIntervalStep.time = 1.0
            $0.previousTickTime = Date(timeIntervalSince1970: 3.0)
        }

        store.send(.stop) {
            $0.status = .paused
        }
    }
}
