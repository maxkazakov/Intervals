//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 12.08.2022.
//

import SwiftUI
import IntervalCore
import IntervalUI
import WorkoutPlanCore
import ComposableArchitecture

public struct WorkoutPlanView: View {

    public let store: Store<WorkoutPlan, WorkoutPlanAction>
    @State var openedInterval: Interval?

    public init(store: Store<WorkoutPlan, WorkoutPlanAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            List {
                Section(content: {
                    TextField("Workout name", text: viewStore.binding(get: \.name, send: WorkoutPlanAction.nameChanged))
                }, header: { Text("Name") })

                Section(content: {
                    ForEachStore(self.store.scope(state: \.intervals, action: WorkoutPlanAction.interval(id:action:))) { intervalStore in
                        IntervalRowView(intervalStore: intervalStore,
                                        onTap: { viewStore.send(.startEditInterval(id: $0.id)) },
                                        onCopy: { viewStore.send(.copyInterval($0)) })
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: { viewStore.send(.removeIntervals(indices: $0)) })
                    .onMove(perform: { viewStore.send(.moveIntervals(fromOffsets: $0, toOffset: $1)) })
                },
                        header: {
                    Text("Intervals")
                })
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(
                trailing:
                    HStack {
                        EditButton()
                        Button("Add") {
                            viewStore.send(.addNewInterval)
                        }
                    }
            )
            .navigationTitle(viewStore.name)
            .sheet(
                isPresented: viewStore.binding(get: { $0.editingIntervalId != nil }, send: WorkoutPlanAction.finishEditInterval),
                content: {
                    IfLetStore(self.store.scope(state: \.editingIntervalId), then: { editingIdStore in
                        WithViewStore(editingIdStore) { editingIdViewStore in
                            let editingId = editingIdViewStore.state
                            NavigationView {
                                IntervalFormView(
                                    store: self.store.scope(
                                        state: { $0.intervals[id: editingId]! },
                                        action: { WorkoutPlanAction.interval(id: editingId, action: $0) })
                                )
                            }
                            .navigationViewStyle(.stack)
                        }
                    })
                })
        }
    }
}

struct IntervalRowView: View {

    let intervalStore: Store<Interval, IntervalAction>
    let onTap: (Interval) -> Void
    let onCopy: (Interval) -> Void

    var body: some View {
        WithViewStore(intervalStore) { viewStore in
            Button(action: {
                onTap(viewStore.state)
            }, label: {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(viewStore.state.name)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Copy") {
                            onCopy(viewStore.state)
                        }
                    }
                    HStack {
                        Text(viewStore.state.durationDescription)
                            .foregroundColor(.secondary)
                            .font(.callout)
                        Spacer()
                    }
                }
            })
        }
    }
}
