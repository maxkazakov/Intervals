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

                VStack {
                    HStack {
                        Button(action: {
                            viewStore.send(.onClose)
                        }, label: {
                            Image(systemName: "xmark")
                                .imageScale(.large)
                                .foregroundColor(.black)
                        })
                        .padding()

                        Spacer()
                    }
                    Spacer()
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
                Button(action: {
                    viewStore.send(.onTapAuthorize)
                }, label: {
                    Text("Allow Access")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .clipShape(Capsule(style: .continuous))
                })
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
                Button(action: {
                    UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
                }, label: {
                    Text("Open Settings")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .clipShape(Capsule(style: .continuous))
                })
            }
        }
    }
}

//struct LocationAccessView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationAccessView()
//    }
//}
