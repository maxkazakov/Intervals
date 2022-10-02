//
//  LocationAccessView.swift
//  
//
//  Created by Максим Казаков on 24.09.2022.
//

import SwiftUI
import LocationAccessCore
import ComposableArchitecture

public struct LocationAccessView: View {
    public init(store: Store<LocationAccess, LocationAccessAction>) {
        self.store = store
    }

    let store: Store<LocationAccess, LocationAccessAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                switch viewStore.state {
                case .initial, .authorized:
                    EmptyView()
                case .unknownUserDecision:
                    UnknownUserDecisionView(viewStore: viewStore)
                case .userRejectedAccess:
                    UserRejectedAccessView(viewStore: viewStore)
                }
            }
            .onAppear(perform: {
                print("LocationAccessView onAppear!")
                viewStore.send(.onAppear)
            })
        }
    }
}

struct UnknownUserDecisionView: View {
    let viewStore: ViewStore<LocationAccess, LocationAccessAction>

    var body: some View {
        ZStack {
            Text("Allow access to your location")
            VStack {
                Spacer()
                Button("Allow Access") {
                    viewStore.send(.onTapAuthorize)
                }
            }
        }
    }
}

struct UserRejectedAccessView: View {
    let viewStore: ViewStore<LocationAccess, LocationAccessAction>

    var body: some View {
        ZStack {
            Text("Allow access to your location")
            VStack {
                Spacer()
                Button("Open Settings") {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
}

//struct LocationAccessView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationAccessView()
//    }
//}
