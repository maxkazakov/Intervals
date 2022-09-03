//
//  ActiveWorkoutView.swift
//  
//
//  Created by Максим Казаков on 03.09.2022.
//

import SwiftUI
import ActiveWorkoutCore
import ComposableArchitecture

public struct ActiveWorkoutView: View {
    public init(store: Store<ActiveWorkout, ActiveWorkoutAction>) {
        self.store = store
    }

    let store: Store<ActiveWorkout, ActiveWorkoutAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text("\(formatMmSs(viewStore.time))")
                .font(.system(.largeTitle))
        }
    }

    static let timerFormat: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with
        return formatter
    }()

    func formatMmSs(_ counter: Double) -> String {
        let hours = Int(counter) / 60 / 60
        let minutes = Int(counter) / 60 % 60
        let seconds = Int(counter) % 60
        let milliseconds = Int(counter * 1000) % 1000
        if hours > 0 {
            return String(format: "%02d:%02d:%02d:%03d", hours, minutes, seconds, milliseconds)
        } else {
            return String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        }
    }
}
