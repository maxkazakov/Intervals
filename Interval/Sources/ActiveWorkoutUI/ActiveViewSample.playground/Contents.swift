
import ComposableArchitecture
import PlaygroundSupport
import SwiftUI
import ActiveWorkoutUI
import ActiveWorkoutCore
import WorkoutPlanCore

var environment = ActiveWorkoutEnvironment(uuid: UUID.init)
let workoutPlan = ActiveWorkout(
    id: UUID(),
    workoutPlan: WorkoutPlan(
        id: UUID(),
        name: "Some",
        intervals: []
    ),
    time: 3600 - 0.001,
    status: .initial
)

PlaygroundPage.current.liveView = UIHostingController(
    rootView:
        NavigationView {
            ActiveWorkoutView(
                store: Store<ActiveWorkout, ActiveWorkoutAction>(
                    initialState: workoutPlan,
                    reducer: activeWorkoutReducer,
                    environment: environment
                )
            )
            .navigationTitle("Workout")
        }
)

