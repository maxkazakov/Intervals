//
//  LocationTrackerTests.swift
//  
//
//  Created by Максим Казаков on 08.10.2022.
//

import Foundation

import XCTest
import Combine
import ComposableArchitecture
import ComposableCoreLocation
@testable import LocationTracker

//@MainActor
final class LocationTrackerTests: XCTestCase {

    func test_singleLocationTracked() throws {
        let store = TestStore(
            initialState: LocationTracker(lastLocation: nil, currentSpeed: 0.0),
            reducer: locationTrackerReducer,
            environment: LocationTrackerEnvironment(locationManager: .failing)
        )
        let location = Location(coordinate: CLLocationCoordinate2D(latitude: 100, longitude: 100))
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
        store.environment.locationManager.startUpdatingLocation = { .none }
        store.environment.locationManager.stopUpdatingLocation = { .none }

        store.send(.startTracking)
        locationManagerSubject.send(.didUpdateLocations([location]))

        store.receive(LocationTrackerAction.locationManager(.didUpdateLocations([location]))) { $0.lastLocation = location }

        store.send(.stopTracking) {
            $0.lastLocation = nil
        }
    }

    func test_multipleLocationTracked() throws {
        let store = TestStore(
            initialState: LocationTracker(lastLocation: nil, currentSpeed: 0.0),
            reducer: locationTrackerReducer,
            environment: LocationTrackerEnvironment(locationManager: .failing)
        )
        let location_1 = Location(coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10))
        let location_2 = location_1.advance(bearing: 0.0, distanceMeters: 100.0)
        let locations = [location_1, location_2]

        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
        store.environment.locationManager.startUpdatingLocation = { .none }
        store.environment.locationManager.stopUpdatingLocation = { .none }

        store.send(.startTracking)
        locationManagerSubject.send(.didUpdateLocations([locations[0]]))
        store.receive(LocationTrackerAction.locationManager(.didUpdateLocations([locations[0]]))) { $0.lastLocation = location_1 }

        locationManagerSubject.send(.didUpdateLocations([locations[1]]))
        store.receive(LocationTrackerAction.locationManager(.didUpdateLocations([locations[1]]))) { $0.lastLocation = location_2 }

        store.receive(LocationTrackerAction.didPassedDistance(meters: 99.4438971725132))

        store.send(.stopTracking) {
            $0.lastLocation = nil
        }
    }
}

extension CLLocationCoordinate2D {
    func advance(bearing: Double, distanceMeters: Double) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6)

        let rbearing = bearing * Double.pi / 180.0

        let lat1 = self.latitude * Double.pi / 180
        let lon1 = self.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(rbearing))
        let lon2 = lon1 + atan2(sin(rbearing) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
}

extension Location {
    func advance(bearing: Double, distanceMeters: Double) -> Location {
        Location(
            altitude: self.altitude,
            coordinate: self.coordinate.advance(bearing: bearing, distanceMeters: distanceMeters),
            course: self.course,
            horizontalAccuracy: self.horizontalAccuracy,
            speed: self.speed,
            timestamp: self.timestamp,
            verticalAccuracy: self.verticalAccuracy
        )
    }
}

