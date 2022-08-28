//
//  IntervalCore.swift
//  
//
//  Created by Максим Казаков on 31.07.2022.
//

import Foundation
import ComposableArchitecture

public enum IntervalAction: Equatable {
    case nameChanged(String)
    case finishTypeChanged(FinishType)
    case durationChanged(seconds: Int)
    case distanceChanged(meters: Double)

    case recoveryEnabledChanged(Bool)
    case recoveryFinishTypeChanged(FinishType)

    case paceRange(enabled: Bool)
    case paceRangeFromChanged(Int)
    case paceRangeToChanged(Int)

    case pulseRange(enabled: Bool)
    case pulseRangeFromChanged(Int)
    case pulseRangeToChanged(Int)

    case repeatCountChanged(Int)
}

public struct IntervalEnvironment {
    public init() {}
}

public let intervalReducer = Reducer<Interval, IntervalAction, IntervalEnvironment> { state, action, _ in
    switch action {
    case let .nameChanged(newName):
        state.name = newName
        return .none
    case let .finishTypeChanged(newFinishType):
        state.finishType = newFinishType
        return .none
    case let .durationChanged(seconds):
        state.finishType = .byDuration(seconds: seconds)
        return .none
    case let .distanceChanged(meters):
        state.finishType = .byDistance(meters: meters)
        return .none
    case let .paceRange(enabled):
        if enabled {
            state.paceRange = PaceRange.default
        } else {
            state.paceRange = nil
        }
        return .none
    case let .paceRangeFromChanged(seconds):
        guard var paceRange = state.paceRange else {
            return .none
        }
        paceRange.from = seconds
        paceRange.to = max(seconds, paceRange.to)
        state.paceRange = paceRange
        return .none
    case let .paceRangeToChanged(seconds):
        guard var paceRange = state.paceRange else {
            return .none
        }
        paceRange.to = seconds
        paceRange.from = min(seconds, paceRange.from)
        state.paceRange = paceRange
        return .none

    case let .pulseRange(enabled):
        if enabled {
            state.pulseRange = PulseRange.default
        } else {
            state.pulseRange = nil
        }
        return .none

    case let .pulseRangeFromChanged(pulse):
        state.pulseRange = pulse...max(pulse, state.pulseRange!.upperBound)
        return .none

    case let .pulseRangeToChanged(pulse):
        state.pulseRange = min(pulse, state.pulseRange!.lowerBound)...pulse
        return .none

    case let .repeatCountChanged(repeatCount):
        state.repeatCount = repeatCount
        return .none

    case let .recoveryEnabledChanged(recoveryEnabled):
        state.recoveryInfo.isEnabled = recoveryEnabled
        return .none

    case let .recoveryFinishTypeChanged(finishType):
        state.recoveryInfo.finishType = finishType
        return .none
    }
}
