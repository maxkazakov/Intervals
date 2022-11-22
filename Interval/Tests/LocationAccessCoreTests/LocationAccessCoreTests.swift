//
//  LocationAccessCoreTests.swift
//  
//
//  Created by Максим Казаков on 24.09.2022.
//

import Foundation

import XCTest
import Combine
import ComposableArchitecture
import ComposableCoreLocation
@testable import LocationAccessCore

//@MainActor
final class LocationAccessCoreTests: XCTestCase {

    func test_notDetermined_justOpenAndClose() throws {
        let store = TestStore(
            initialState: LocationAccess.initial,
            reducer: locationRequestReducer,
            environment: LocationAccessEnvironment(
                locationManager: .failing
            )
        )

        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
        store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
        store.environment.locationManager.authorizationStatus = { .notDetermined }
        store.environment.locationManager.requestWhenInUseAuthorization = { .none }

        store.send(.onAppear) {
            $0 = .unknownUserDecision
        }
        store.send(.onClose)
    }

    func test_notDetermined__userRejectedAuthorization() throws {
        let store = TestStore(
            initialState: LocationAccess.initial,
            reducer: locationRequestReducer,
            environment: LocationAccessEnvironment(
                locationManager: .failing
            )
        )

        var didRequestInUseAuthorization = false
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

        store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
        store.environment.locationManager.authorizationStatus = { .notDetermined }
        store.environment.locationManager.requestWhenInUseAuthorization = {
            .fireAndForget { didRequestInUseAuthorization = true }
        }

        store.send(.onAppear) {
            $0 = .unknownUserDecision
        }
        store.send(.onTapAuthorize)

        XCTAssertTrue(didRequestInUseAuthorization)
        locationManagerSubject.send(.didChangeAuthorization(.denied))

        store.receive(.locationManager(.didChangeAuthorization(.denied))) {
            $0 = .userRejectedAccess
        }

        store.send(.onClose)
    }

    func test_notDetermined_userAcceptedAuthorization() throws {
        let store = TestStore(
            initialState: LocationAccess.initial,
            reducer: locationRequestReducer,
            environment: LocationAccessEnvironment(
                locationManager: .failing
            )
        )

        var didRequestInUseAuthorization = false
        let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

        store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
        store.environment.locationManager.authorizationStatus = { .notDetermined }
        store.environment.locationManager.requestWhenInUseAuthorization = {
            .fireAndForget { didRequestInUseAuthorization = true }
        }

        store.send(.onAppear)  {
            $0 = .unknownUserDecision
        }
        store.send(.onTapAuthorize)

        XCTAssertTrue(didRequestInUseAuthorization)
        locationManagerSubject.send(.didChangeAuthorization(.authorizedWhenInUse))

        store.receive(.locationManager(.didChangeAuthorization(.authorizedWhenInUse)))
        store.receive(.onAuthGranted) {
            $0 = .authorized
        }

        store.send(.onClose)
    }
}

