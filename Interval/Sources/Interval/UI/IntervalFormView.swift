//
//  IntervalFormView.swift
//  
//
//  Created by Максим Казаков on 31.07.2022.
//

import SwiftUI
import ComposableArchitecture

public struct IntervalFormView: View {
    let store: Store<Interval, IntervalAction>

    public init(store: Store<Interval, IntervalAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            NavigationView {
                Form {
                    TextField("Name", text: viewStore.binding(get: \.name, send: IntervalAction.nameChanged))
                }
                .navigationTitle("New interval")
            }
            .navigationViewStyle(.stack)
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
