//
//  LocationAccessCore.swift
//  
//
//  Created by Максим Казаков on 24.09.2022.
//

import Foundation
import ComposableArchitecture
import ComposableCoreLocation

public enum LocationAccess {
    case initial
    case unknownUserDecision
    case userRejectedAccess
    case authorized
}

public enum LocationAccessAction: Equatable {
    case locationManager(LocationManager.Action)

    case onTapAuthorize
    case onAppear
    case onClose    

    // for external
    case onAuthGranted
}

public struct LocationAccessEnvironment {
    public init(locationManager: LocationManager) {
        self.locationManager = locationManager
    }

    var locationManager: LocationManager
}

public let locationRequestReducer = Reducer<LocationAccess, LocationAccessAction, LocationAccessEnvironment> { state, action, env in
    enum LocationEventsSubscribtion {}

    switch action {
    case .onAppear:
        switch env.locationManager.authorizationStatus() {
        case .notDetermined:
            state = .unknownUserDecision
            return env.locationManager
                .delegate()
                .map(LocationAccessAction.locationManager)
                .cancellable(id: LocationEventsSubscribtion.self)

        case .restricted, .denied:
            state = .userRejectedAccess
            return .none

        case .authorizedAlways, .authorizedWhenInUse:
            return Effect(value: .onAuthGranted)

        @unknown default:
            state = .userRejectedAccess
            return .none
        }

    case .onTapAuthorize:
        return env.locationManager
            .requestWhenInUseAuthorization()
            .fireAndForget()

    case .onAuthGranted:
        state = .authorized
        return .cancel(id: LocationEventsSubscribtion.self)

    case .onClose:
        return .cancel(id: LocationEventsSubscribtion.self)

    case let .locationManager(.didChangeAuthorization(status)):
        switch status {
        case .notDetermined:
            state = .unknownUserDecision
            return .none

        case .restricted, .denied:
            state = .userRejectedAccess
            return .none

        case .authorizedAlways, .authorizedWhenInUse:
            return Effect(value: .onAuthGranted)

        @unknown default:
            state = .userRejectedAccess
            return .none
        }

    case .locationManager:
        return .none
    }
}
