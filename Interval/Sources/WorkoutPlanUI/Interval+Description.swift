//
//  File.swift
//  
//
//  Created by Максим Казаков on 28.08.2022.
//

import Foundation
import IntervalCore

extension Interval {

    public var durationDescription: String {
        func recoveryInfo(_ recovery: RecoveryInfo) -> String {
            guard recovery.isEnabled else {
                return ""
            }
            switch recovery.finishType {
            case .byTappingButton:
                return "No limit"

            case let .byDistance(meters):
                return "\(FormatDisplay.distance(meters: meters, outputUnit: .meters))"

            case let .byDuration(seconds):
                return "\(FormatDisplay.time(seconds))"
            }
        }

        func repeatInfo( _ repeatCount: Int) -> String {
            guard self.repeatCount > 1 else {
                return ""
            }
            return "\(self.repeatCount)"
        }

        let recoveryString = recoveryInfo(self.recoveryInfo)
        let repeatString = repeatInfo(self.repeatCount)

        switch self.finishType {
        case .byTappingButton:
            return "No limit"
                .applyRecovery(recoveryString)
                .applyRepeatCount(repeatString)

        case let .byDistance(meters):
            return "\(FormatDisplay.distance(meters: meters, outputUnit: .meters))"
                .applyRecovery(recoveryString)
                .applyRepeatCount(repeatString)


        case let .byDuration(seconds):
            return "\(FormatDisplay.time(seconds))"
                .applyRecovery(recoveryString)
                .applyRepeatCount(repeatString)
        }
    }
}

private extension String {
    func applyRecovery(_ recovery: String) -> String {
        guard !recovery.isEmpty else { return self }
        return  "\(self) + \(recovery) recovery"
    }

    func applyRepeatCount(_ repeatCount: String) -> String {
        guard !repeatCount.isEmpty else { return self }
        return "\(repeatCount) x (" + self + ")"
    }
}
