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

public enum IntervalFinishType: Equatable, CaseIterable, Hashable {
    public static let defaultIntervalDuration = 60 * 5
    public static let defaultIntervalDistance = 1000.0
    public static var allCases: [IntervalFinishType] = [.byTappingButton,
                                                        .byDuration(seconds: defaultIntervalDuration),
                                                        .byDistance(defaultIntervalDistance)
    ]

    /// time in seconds
    case byDuration(seconds: Int)
    /// meters
    case byDistance(Double)
    ///
    case byTappingButton

    // This is needed for ForEach
    public var id: Int {
        switch self {
        case .byDuration: return 0
        case .byDistance: return 1
        case .byTappingButton: return 2
        }
    }

    public var description: String {
        switch self {
        case .byDuration: return "By duration"
        case .byDistance: return "By distance"
        case .byTappingButton: return "By tapping button"
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}


public typealias PulseRange = ClosedRange<Int>

/// meters per sec
public struct PaceRange: Codable, Hashable {
    public init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }

    public let from: Int
    public let to: Int
}
