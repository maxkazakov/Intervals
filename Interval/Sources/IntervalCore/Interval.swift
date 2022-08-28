import Foundation

public struct EntityId<Entity>: Hashable {
    public init(_ value: UUID = UUID()) {
        self.value = value
    }

    private let value: UUID
}

public struct RecoveryInfo: Equatable {
    public var finishType: FinishType
    public var isEnabled: Bool

    public init(finishType: FinishType, isEnabled: Bool) {
        self.finishType = finishType
        self.isEnabled = isEnabled
    }

    public static let `default` = RecoveryInfo(finishType: .byDuration(seconds: 60), isEnabled: false)
}

public struct Interval: Identifiable, Equatable {
    public typealias Id = EntityId<Interval>

    public init(id: Id,
                name: String,
                dateCreated: Date = Date(),
                finishType: FinishType,
                pulseRange: PulseRange? = nil,
                paceRange: PaceRange? = nil) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.finishType = finishType
        self.pulseRange = pulseRange
        self.paceRange = paceRange
    }

    public var id: Id
    public var name: String
    public var dateCreated: Date
    public var finishType: FinishType

    public var recoveryInfo: RecoveryInfo = .default
    public var repeatCount: Int = 1

    public var pulseRange: PulseRange? = nil
    public var paceRange: PaceRange? = nil


    public static let `default` = Interval(id: Interval.Id(), name: "", dateCreated: Date(), finishType: .byTappingButton)

    public static func make(with name: String, and finishType: FinishType) -> Interval {
        Interval(id: Interval.Id(), name: name, dateCreated: Date(), finishType: finishType)
    }
}

public enum FinishType: CaseIterable, Equatable {
    public static let defaultIntervalDuration = 60 * 5
    public static let defaultIntervalDistance = 1000.0
    public static var allCases: [FinishType] = [.byTappingButton,
                                                        .byDuration(seconds: defaultIntervalDuration),
                                                        .byDistance(meters: defaultIntervalDistance)
    ]

    /// time in seconds
    case byDuration(seconds: Int)
    /// meters
    case byDistance(meters: Double)
    ///
    case byTappingButton
}


public typealias PulseRange = ClosedRange<Int>
extension PulseRange {
    public static let defaultPulse = 140...160
}

public typealias PaceRange = ClosedRange<Int>

/// meters per sec
extension PaceRange {
    public static let defaultPace = 60 * 5...60 * 7
}
