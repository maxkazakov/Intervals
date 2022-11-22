import SwiftUI
import Combine
import ComposableArchitecture
import ActiveWorkoutCore
import Foundation

struct DistanceTimerView<IntervalNameView: View>: View {
    let viewStore: ViewStore<ActiveWorkout, ActiveWorkoutAction>
    let fullDistanceMeters: Double
    let nameView: IntervalNameView

    var body: some View {
        ZStack {
            CircleTimerView(percent: max(0.0, 1 - viewStore.currentIntervalStep.fullDistance / fullDistanceMeters))

            VStack {
                nameView
                Text(String(format: "%.1f m", fullDistanceMeters - viewStore.currentIntervalStep.fullDistance))
                    .font(.system(.largeTitle, design: .monospaced))
            }
        }
    }
}
