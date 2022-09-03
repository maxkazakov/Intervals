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
            Text("Time: \(Self.timerFormat.string(from: viewStore.time)!)")
        }
    }

    static let timerFormat: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional // Use the appropriate positioning for the current locale
        formatter.allowedUnits = [ .hour, .minute, .second ] // Units to display in the formatted string
        formatter.zeroFormattingBehavior = [ .pad ] // Pad with
        return formatter
    }()
}
