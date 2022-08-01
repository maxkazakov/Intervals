//
//  IntervalFormView.swift
//  
//
//  Created by Максим Казаков on 31.07.2022.
//

import SwiftUI
import ComposableArchitecture
import IntervalCore

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
                                        DistancePickerView(viewStore: viewStore)
                                    }
                                })

                            CaseLet(state: /IntervalFinishType.byDuration,
                                    then: { (store: Store<Int, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    TimePickerView(title: "Time", viewStore: viewStore) { IntervalAction.durationChanged(seconds: $0) }
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

                    Section(content: {
                        Toggle("Set pace range",
                               isOn: viewStore.binding(get: { $0.paceRange != nil }, send: { IntervalAction.paceRange(enabled: $0 == true)
                        }))

                        IfLetStore(self.store.scope(state: \.paceRange), then: { store in
                            WithViewStore(store.scope(state: \.from)) { viewStore in
                                TimePickerView(title: "From", viewStore: viewStore) { IntervalAction.paceRangeFromChanged($0) }
                            }
                            WithViewStore(store.scope(state: \.to)) { viewStore in
                                TimePickerView(title: "To", viewStore: viewStore) { IntervalAction.paceRangeToChanged($0) }
                            }

                        })
                    }, header: {
                        Text("Pace")
                    })

                    Section(content: {
                        Toggle("Set pulse range",
                               isOn: viewStore.binding(get: { $0.pulseRange != nil }, send: { IntervalAction.pulseRange(enabled: $0 == true)
                        }))

                        IfLetStore(self.store.scope(state: \.pulseRange), then: { store in
                            WithViewStore(store.scope(state: \.lowerBound)) { viewStore in
                                IntPickerView(title: "From", viewStore: viewStore) { IntervalAction.pulseRangeFromChanged($0) }
                            }
                            WithViewStore(store.scope(state: \.upperBound)) { viewStore in
                                IntPickerView(title: "To", viewStore: viewStore) { IntervalAction.pulseRangeToChanged($0) }
                            }
                        })
                    }, header: {
                        Text("Pulse")
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
