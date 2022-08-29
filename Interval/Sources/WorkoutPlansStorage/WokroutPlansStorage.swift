//
//  WorkoutPlansStorage.swift
//  
//
//  Created by Максим Казаков on 28.08.2022.
//

import WorkoutPlanCore
import IntervalCore
import ComposableArchitecture
import Combine
import Foundation

public struct WorkoutPlansStorage {
    public init(
        fetch: @escaping () -> Effect<[WorkoutPlan], Error>,
        store: @escaping ([WorkoutPlan]) -> Effect<Never, Never>
    ) {
        self.fetch = fetch
        self.store = store
    }

    public var fetch: () -> Effect<[WorkoutPlan], Error>
    public var store: ([WorkoutPlan]) -> Effect<Never, Never>

    public struct Failure: Error, Equatable {}
}

extension WorkoutPlansStorage {
    public static let live = WorkoutPlansStorage(
        fetch: {
            .catching {
                let data = try Data(contentsOf: fileUrl)
                let dto = try JSONDecoder().decode([WorkoutPlanDTO].self, from: data)
                let workoutPlans = dto.map {
                    WorkoutPlan(id: $0.id, name: $0.name, intervals: .init(uniqueElements: $0.intervals.map {
                        Interval(
                            id: Interval.Id($0.id),
                            name: $0.name,
                            finishType: $0.finishType.wrappedValue,
                            recoveryInfo: RecoveryInfo(finishType: $0.recoveryInfo.finishType.wrappedValue,
                                                       isEnabled: $0.recoveryInfo.isEnabled),
                            repeatCount: $0.repeatCount,
                            pulseRange: $0.pulseRange,
                            paceRange: $0.paceRange
                        )
                    }))
                }
                return workoutPlans
            }
            .subscribe(on: backgroundQueue.eraseToAnyScheduler())
            .eraseToEffect()
        },
        store: { workoutPlans in
                .fireAndForget {
                    let dto = workoutPlans.map {
                        WorkoutPlanDTO(
                            id: $0.id,
                            name: $0.name,
                            intervals: $0.intervals.map { interval in
                                IntervalDTO(
                                    id: interval.id.value,
                                    name: interval.name,
                                    repeatCount: interval.repeatCount,
                                    pulseRange: interval.pulseRange,
                                    paceRange: interval.paceRange,
                                    finishType: FinishTypeDTO(interval.finishType),
                                    recoveryInfo: RecoveryInfoDTO(
                                        finishType: FinishTypeDTO(interval.recoveryInfo.finishType),
                                        isEnabled: interval.recoveryInfo.isEnabled)
                                )
                            }
                        )
                    }
                    let data = try JSONEncoder().encode(dto)
                    try data.write(to: fileUrl)
                }
                .subscribe(on: backgroundQueue.eraseToAnyScheduler())
                .eraseToEffect()
        }
    )

    private static let backgroundQueue = DispatchQueue(label: "WorkoutPlansStorage")
    private static let filename = "workoutPlans.json"
    private static var fileUrl: URL {
        URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(filename)
    }
}

struct WorkoutPlanDTO: Codable {
    var version = 1
    var id: UUID
    var name: String
    var intervals: [IntervalDTO]
}

struct IntervalDTO: Codable {
    var version = 1
    var id: UUID
    var name: String
    var repeatCount: Int
    var pulseRange: PulseRange?
    var paceRange: PaceRange?
    var finishType: FinishTypeDTO
    var recoveryInfo: RecoveryInfoDTO
}

struct FinishTypeDTO: Codable {

    var version = 1
    var wrappedValue: FinishType

    init(version: Int = 1, _ finishType: FinishType) {
        self.version = version
        self.wrappedValue = finishType
    }

    enum CodingKeys: String, CodingKey {
        case version
        case key
        case value
    }

    enum Key: String, CodingKey, Codable {
        case byDuration
        case byDistance
        case byTappingButton
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        version = try container.decode(Int.self, forKey: .version)
        let key = try container.decode(Key.self, forKey: .key)
        switch key {
        case .byDuration:
            wrappedValue = .byDuration(seconds: try container.decode(Int.self, forKey: .value))
        case .byDistance:
            wrappedValue = .byDistance(meters: try container.decode(Double.self, forKey: .value))
        case .byTappingButton:
            wrappedValue = .byTappingButton
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var key: Key
        switch wrappedValue {
        case .byDuration(let seconds):
            key = .byDuration
            try container.encode(seconds, forKey: .value)
        case .byDistance(let meters):
            key = .byDistance
            try container.encode(meters, forKey: .value)
        case .byTappingButton:
            key = .byTappingButton
        }
        try container.encode(version, forKey: .version)
        try container.encode(key, forKey: .key)
    }
}

struct RecoveryInfoDTO: Codable {
    var version = 1
    var finishType: FinishTypeDTO
    var isEnabled: Bool
}
