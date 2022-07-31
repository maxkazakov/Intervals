//
//  File.swift
//  
//
//  Created by Максим Казаков on 31.07.2022.
//

import Foundation
import ComposableArchitecture

public enum IntervalAction: Equatable {
    case nameChanged(String)
}

public struct IntervalEnvironment {
    public init() {}
}

public let intervalReducer = Reducer<Interval, IntervalAction, IntervalEnvironment> { state, action, _ in
    switch action {
    case let .nameChanged(newName):
        state.name = newName
        return .none
    }
}
    .debug()
