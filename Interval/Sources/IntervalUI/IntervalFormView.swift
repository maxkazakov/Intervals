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
            Form {

                Section(content: {
                    TextField("Name", text: viewStore.binding(get: \.name, send: IntervalAction.nameChanged))

                    Picker(
                        "Duration",
                        selection: viewStore.binding(
                            get: { ViewFinishType(finishType: $0.finishType) },
                            send: { IntervalAction.finishTypeChanged($0.finishType) }
                        ),
                        content: {
                            ForEach(FinishType.allCases.map(ViewFinishType.init(finishType:))) { type in
                                Text(type.description)
                                    .tag(type)
                            }
                        })

                    SwitchStore(self.store.scope(state: \.finishType)) {
                        CaseLet(state: /FinishType.byDistance,
                                then: { (store: Store<Double, IntervalAction>) in
                            WithViewStore(store) { viewStore in
                                DistancePickerView(viewStore: viewStore) { IntervalAction.distanceChanged(meters: $0) }
                            }
                        })

                        CaseLet(state: /FinishType.byDuration,
                                then: { (store: Store<Int, IntervalAction>) in
                            WithViewStore(store) { viewStore in
                                TimePickerView(title: "Time", viewStore: viewStore) { IntervalAction.durationChanged(seconds: $0) }
                            }
                        })

                        CaseLet(state: /FinishType.byTappingButton,
                                then: { (store: Store<Void, IntervalAction>) in
                            WithViewStore(store) { viewStore in
                                EmptyView()
                            }
                        })
                    }

                    Stepper(value: viewStore.binding(get: \.repeatCount, send: IntervalAction.repeatCountChanged),
                                 in: 1...100,
                                 label: { HStack { Text("Repeat "); Spacer(); Text("\(viewStore.repeatCount)") } })
                }, header: {
                    Text("Interval settings")
                })

                Section(content: {
                    Toggle("Set up recovery",
                           isOn: viewStore.binding(get: { $0.recoveryInfo.isEnabled }, send: { IntervalAction.recoveryEnabledChanged($0)}))

                    if viewStore.recoveryInfo.isEnabled {
                        Picker(
                            "Duration",
                            selection: viewStore.binding(
                                get: { ViewFinishType(finishType: $0.recoveryInfo.finishType) },
                                send: { IntervalAction.recoveryFinishTypeChanged($0.finishType) }
                            ),
                            content: {
                                ForEach(FinishType.allCases.map(ViewFinishType.init(finishType:))) { type in
                                    Text(type.description).tag(type)
                                }
                            })

                        SwitchStore(self.store.scope(state: \.recoveryInfo.finishType)) {
                            CaseLet(state: /FinishType.byDistance,
                                    then: { (store: Store<Double, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    DistancePickerView(viewStore: viewStore) { IntervalAction.recoveryFinishTypeChanged(.byDistance(meters: $0)) }
                                }
                            })

                            CaseLet(state: /FinishType.byDuration,
                                    then: { (store: Store<Int, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    TimePickerView(title: "Time", viewStore: viewStore) { IntervalAction.recoveryFinishTypeChanged(.byDuration(seconds: $0)) }
                                }
                            })

                            CaseLet(state: /FinishType.byTappingButton,
                                    then: { (store: Store<Void, IntervalAction>) in
                                WithViewStore(store) { viewStore in
                                    EmptyView()
                                }
                            })
                        }
                    }
                }, header: {
                    Text("Recovery settings")
                })

                Section(content: {
                    Toggle("Set pace target",
                           isOn: viewStore.binding(get: { $0.paceRange != nil }, send: { IntervalAction.paceRange(enabled: $0 == true)
                    }))

                    IfLetStore(self.store.scope(state: \.paceRange), then: { store in
                        WithViewStore(store.scope(state: \.lowerBound)) { viewStore in
                            TimePickerView(title: "From", viewStore: viewStore) { IntervalAction.paceRangeFromChanged($0) }
                        }
                        WithViewStore(store.scope(state: \.upperBound)) { viewStore in
                            TimePickerView(title: "To", viewStore: viewStore) { IntervalAction.paceRangeToChanged($0) }
                        }
                    })
                }, header: {
                    Text("Pace target")
                })

                Section(content: {
                    Toggle("Set pulse target",
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
                    Text("Pulse target")
                })
            }
            .navigationTitle("Editing")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ViewFinishType: Identifiable, Hashable {
    let finishType: FinishType

    var id: Int {
        switch finishType {
        case .byDuration: return 0
        case .byDistance: return 1
        case .byTappingButton: return 2
        }
    }

    var description: String {
        switch finishType {
        case .byDuration: return "Timer"
        case .byDistance: return "Distance"
        case .byTappingButton: return "No limit"
        }
    }

    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
