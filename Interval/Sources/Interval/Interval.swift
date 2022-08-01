import Foundation

public struct EntityId<Entity>: Hashable {
    public init(_ value: UUID = UUID()) {
        self.value = value
    }

    private let value: UUID
}

public struct Interval: Identifiable, Equatable {
    public typealias Id = EntityId<Interval>

    public init(id: Id,
                name: String,
                dateCreated: Date,
                finishType: IntervalFinishType,
                heartRange: PulseRange? = nil,
                paceRange: PaceRange? = nil) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
        self.finishType = finishType
        self.heartRange = heartRange
        self.paceRange = paceRange
    }

    public let id: Id
    public var name: String
    public var dateCreated: Date
    public var finishType: IntervalFinishType
    public var heartRange: PulseRange? = nil
    public var paceRange: PaceRange? = nil

    public static let `default` = Interval(id: Interval.Id(), name: "", dateCreated: Date(), finishType: .byTappingButton)
}

public enum IntervalFinishType: CaseIterable, Equatable {
    public static let defaultIntervalDuration = 60 * 5
    public static let defaultIntervalDistance = 1000.0
    public static var allCases: [IntervalFinishType] = [.byTappingButton,
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

/// meters per sec
public struct PaceRange: Codable, Hashable {
    public init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }

    public var from: Int
    public var to: Int

    public static let `default` = PaceRange(from: 60 * 5, to: 60 * 7)
}
