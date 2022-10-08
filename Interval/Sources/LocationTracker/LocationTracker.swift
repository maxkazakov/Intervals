//
//  LocationTracker.swift
//  
//
//  Created by Максим Казаков on 02.10.2022.
//

import ComposableArchitecture
import ComposableCoreLocation

public struct LocationTracker: Equatable {
    public init(lastLocation: Location? = nil, currentSpeed: Double) {
        self.lastLocation = lastLocation
        self.currentSpeed = currentSpeed
    }

    public var lastLocation: Location?
    public var currentSpeed: Double
}

public enum LocationTrackerAction: Equatable {
    case startTracking
    case stopTracking
    case didPassedDistance(meters: Double)

    case locationManager(LocationManager.Action)
}

public struct LocationTrackerEnvironment {
    let locationManager: LocationManager

    public init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }
}

public let locationTrackerReducer = Reducer<LocationTracker, LocationTrackerAction, LocationTrackerEnvironment>.init({ state, action, env in
    enum LocationEventsSubscribtion {}

    switch action {
    case .startTracking:
        return .merge(
            env.locationManager
                .delegate()
                .map(LocationTrackerAction.locationManager)
                .cancellable(id: LocationEventsSubscribtion.self),
            env.locationManager
                .startUpdatingLocation()
                .fireAndForget()
        )

    case .stopTracking:
        state.lastLocation = nil
        return .merge(
            .cancel(id: LocationEventsSubscribtion.self),
            env.locationManager.stopUpdatingLocation().fireAndForget()
        )

    case let .didPassedDistance(meters):
        return .none

    case let .locationManager(.didUpdateLocations(locations)):
        guard let newLocation = locations.last else {
            return .none
        }
        defer { state.lastLocation = locations.last }
        if let lastLocation = state.lastLocation {
            let distance = newLocation.rawValue.distance(from: lastLocation.rawValue)
            return Effect(value: .didPassedDistance(meters: distance))
        }
        return .none

    case .locationManager:
        return .none
    }
})
