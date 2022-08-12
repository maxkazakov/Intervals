//
//  File.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import AppCore
import WorkoutPlanUI
import ComposableArchitecture


public struct AppView: View {
    let store: Store<AppState, AppAction>

    public init(store: Store<AppState, AppAction>) {
        self.store = store
    }

    public var body: some View {
        WorkoutPlanView(store: self.store.scope(state: \.workoutPlan, action: AppAction.workoutPlan))
    }
}

