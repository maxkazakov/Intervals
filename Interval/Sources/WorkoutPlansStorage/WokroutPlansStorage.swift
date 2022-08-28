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
                    WorkoutPlan(id: $0.id, name: $0.name, intervals: [])
                }
                return workoutPlans
            }
            .subscribe(on: backgroundQueue.eraseToAnyScheduler())
            .eraseToEffect()
        },
        store: { workoutPlans in
                .fireAndForget {
                    let dto = workoutPlans.map { WorkoutPlanDTO(id: $0.id, name: $0.name) }
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
        URL(
            fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        ).appendingPathComponent(filename)
    }
}

struct WorkoutPlanDTO: Codable {
    init(version: Int = 1, id: UUID, name: String) {
        self.version = version
        self.id = id
        self.name = name
    }

    var version = 1
    var id: UUID
    var name: String
}

//struct IntervalDTO: Codable {
//    var version = 1
//    var id: UUID
//    var name: String
//    var dateCreated: Date
//}
