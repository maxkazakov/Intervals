//
//  LocationTracker.swift
//  
//
//  Created by Максим Казаков on 02.10.2022.
//

import ComposableArchitecture
import ComposableCoreLocation

public struct LocationTracker: Equatable {
    public init(lastLocation: Location? = nil, currentPace: Double) {
        self.lastLocation = lastLocation
        self.currentPace = currentPace
    }

    public var lastLocation: Location?
    public var currentPace: Double // secs / km
    var lastPaceIntervals: [Double] = []
}

public enum LocationTrackerAction: Equatable {
    case startTracking
    case stopTracking
    case didPassedDistance(meters: Double, timeInterval: Double)
    case locationTracked(Location)

    case locationManager(LocationManager.Action)
}

public struct LocationTrackerEnvironment {
    var locationManager: LocationManager

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
        state.lastPaceIntervals = []
        return .merge(
            .cancel(id: LocationEventsSubscribtion.self),
            env.locationManager.stopUpdatingLocation().fireAndForget()
        )

    case let .didPassedDistance(meters, timeInterval):
        let pace = meters / timeInterval
        state.lastPaceIntervals.append(pace)

        let last5 = state.lastPaceIntervals.suffix(5)
        if last5.count == 5 {
            let meterPerSec = last5.reduce(0.0, +) / Double(last5.count)
            let secPerKm = 1 / meterPerSec * 1000
            state.currentPace = secPerKm
            state.lastPaceIntervals = Array(last5)
        } else {
            state.currentPace = 0.0
        }
        return .none

    case let .locationManager(.didUpdateLocations(locations)):
        let filteredLocations = filter(locations: locations)
        guard let newLocation = locations.last else {
            return .none
        }
        let locationTrackedEffect = Effect<LocationTrackerAction, Never>(value: LocationTrackerAction.locationTracked(newLocation))
        defer { state.lastLocation = locations.last }
        if let lastLocation = state.lastLocation {
            let timeInterval = newLocation.rawValue.timestamp.timeIntervalSince1970 - lastLocation.rawValue.timestamp.timeIntervalSince1970
            let distance = newLocation.rawValue.distance(from: lastLocation.rawValue)
            return .merge(
                locationTrackedEffect,
                Effect(value: .didPassedDistance(meters: distance, timeInterval: timeInterval))
            )
        }
        return locationTrackedEffect

    case .locationManager, .locationTracked:
        return .none
    }
})

private func filter(locations: [Location]) -> [Location] {
    locations.filter { newLocation in
        let howRecent = abs(newLocation.timestamp.timeIntervalSinceNow)
        guard newLocation.horizontalAccuracy > 0,
              newLocation.horizontalAccuracy < 50,
              abs(howRecent) < 10 else {
            return false
        }
        return true
    }
}
