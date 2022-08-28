//
//  IntervalsApp.swift
//  Intervals
//
//  Created by Максим Казаков on 30.07.2022.
//

import SwiftUI
import AppCore
import AppUI
import ComposableArchitecture

@main
struct IntervalsApp: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
    )

    var body: some Scene {
        WindowGroup {
            AppView(store: store)
        }
    }
}
