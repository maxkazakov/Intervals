//
//  IntervalListCore.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import Foundation
import ComposableArchitecture

public enum IntervalListAction: Equatable {
    case saveDraft
    case add
}

public struct IntervalListEnvironment {
    public init() {}
}

public let intervalListReducer = Reducer<IntervalList, IntervalListAction, IntervalListEnvironment> { state, action, _ in
    return .none
}
    .debug()
