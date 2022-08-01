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
                        Picker(
                            "Finish type",
                            selection: viewStore.binding(
                                get: { ViewFinishType(finishType: $0.finishType) },
                                send: { IntervalAction.finishTypeChanged($0.finishType) }
                            ),
                            content: {
                                ForEach(IntervalFinishType.allCases.map(ViewFinishType.init(finishType:))) { type in
                                    Text(type.description)
                                        .tag(type)
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
                                    SecondsPickerView(viewStore: viewStore)
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

struct ViewFinishType: Identifiable, Hashable {
    let finishType: IntervalFinishType

    var id: Int {
        switch finishType {
        case .byDuration: return 0
        case .byDistance: return 1
        case .byTappingButton: return 2
        }
    }

    var description: String {
        switch finishType {
        case .byDuration: return "By duration"
        case .byDistance: return "By distance"
        case .byTappingButton: return "By tapping button"
        }
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
