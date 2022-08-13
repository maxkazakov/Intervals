//
//  FormatDisplay.swift
//  
//
//  Created by Максим Казаков on 13.08.2022.
//

import Foundation

struct FormatDisplay {

    static func decimal(value: Decimal, outputUnit: UnitLength) -> String {
        let formatter = MeasurementFormatter()
        //        formatter.unitStyle = .short
        formatter.unitOptions = [.providedUnit]
        let measurement = Measurement(value: (value as NSNumber).doubleValue, unit: outputUnit)
        let result = formatter.string(from: measurement)
        return result
    }

    ///
    /// - Parameter distance: метры
    /// - Returns: в метрах
    static func distance(meters: Double, outputUnit: UnitLength = .meters) -> String {
        let distanceMeasurement = Measurement(value: meters, unit: UnitLength.meters)
        return FormatDisplay.distance(distanceMeasurement, outputUnit: outputUnit)
    }

    static func distanceWithoutUnits(meters: Double, outputUnit: UnitLength) -> String {
        let metersMeasurement = Measurement(value: meters, unit: UnitLength.meters)
        let converted = metersMeasurement.converted(to: outputUnit)
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: converted.value)) ?? ""
    }

    static func distance(_ distance: Measurement<UnitLength>, outputUnit: UnitLength) -> String {
        let outputDistance = distance.converted(to: outputUnit)
        let formatter = MeasurementFormatter()
        formatter.unitOptions = [.providedUnit]
        formatter.numberFormatter.minimumFractionDigits = 0
        formatter.numberFormatter.maximumFractionDigits = 2
        return formatter.string(from: outputDistance)
    }

    static func time(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        if seconds > 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: TimeInterval(seconds))!
    }

    /// Возвращает темп в мин/км или мин/миль в формате 07:15
    static func pace(metersPerSecond: Double, unit: UnitLength) -> String {
        let distancePerSecond = Measurement(value: metersPerSecond, unit: UnitLength.meters)
            .converted(to: unit)
            .value
        let secondsPerDistance = 1 / distancePerSecond
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        //        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: secondsPerDistance)!
    }

    static func heartRate(value: Int?) -> String {
        value.map { "\($0)" } ?? FormatDisplay.noValue
    }

    static func date(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    static func dateRelative(_ timestamp: Date?) -> String {
        guard let timestamp = timestamp as Date? else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.formattingContext = .listItem
        formatter.unitsStyle = .full
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }

    static let noValue = "—"
}
