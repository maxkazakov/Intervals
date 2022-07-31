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

                    Section(content: {
                        Picker.init("Finish type",
                                    selection: viewStore.binding(get: \.finishType, send: IntervalAction.finishTypeChanged),
                                    content: {
                            ForEach(Array(IntervalFinishType.allCases.enumerated()), id: \.self.offset) { offset, element in
                                Text(element.description)
                                    .tag(element)
                            }
                        })

                        SwitchStore(self.store.scope(state: \.finishType)) {
                            CaseLet(state: /IntervalFinishType.byDistance,
                                then: { (store: Store<Double, IntervalAction>) in
                                    WithViewStore(store) { viewStore in
                                        Text("\(viewStore.state)")
                                    }
                                })

                            CaseLet(state: /IntervalFinishType.byDuration,
                                    then: { (store: Store<Int, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    Text("\(viewStore.state)")
                                }
                            })

                            CaseLet(state: /IntervalFinishType.byTappingButton,
                                    then: { (store: Store<Void, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    EmptyView()
                                }
                            })
                        }
                    }, header: {
                        Text("Duration")
                    })
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
