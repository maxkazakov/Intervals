//
//  AppCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import IntervalList
import IntervalCore
import ComposableArchitecture

public struct AppState: Equatable {
    public var interval: Interval

    public init() {
        self.interval = .default
    }
}

public struct AppEnvironment {
    public init() {}
}

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
