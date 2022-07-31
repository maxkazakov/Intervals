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
}

public enum IntervalFinishType: Equatable {
    /// time in seconds
    case byDuration(seconds: Int)
    /// meters
    case byDistance(Double)
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

    public let from: Int
    public let to: Int
}
