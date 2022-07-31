//
//  IntervalsApp.swift
//  Intervals
//
//  Created by Максим Казаков on 30.07.2022.
//

import SwiftUI
import Interval
import ComposableArchitecture

public struct AppState: Equatable {
    var interval: Interval

    public init() {
        self.interval = Interval(id: Interval.Id(), name: "", dateCreated: Date(), finishType: .byTappingButton)
    }
}

public struct AppEnvironment {}

public enum AppAction {
    case interval(IntervalAction)
}

public let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    intervalReducer.pullback(state: \.interval,
                             action: /AppAction.interval,
                             environment: { _ in
                                 IntervalEnvironment()
                             })
)

@main
struct IntervalsApp: App {
    let store = Store(
        initialState: AppState(),
        reducer: appReducer,
        environment: AppEnvironment()
    )

    var body: some Scene {
        WindowGroup {
            IntervalFormView(store: self.store.scope(state: \.interval, action: AppAction.interval))
        }
    }
}
