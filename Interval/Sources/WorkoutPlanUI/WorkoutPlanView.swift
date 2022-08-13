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
            NavigationView {
                List {
                    ForEachStore(self.store.scope(state: \.intervals, action: WorkoutPlanAction.interval(id:action:))) { intervalStore in
                        IntervalRowView(intervalStore: intervalStore,
                                        onTap: { viewStore.send(.startEditInterval(id: $0)) },
                                        onCopy: { viewStore.send(.copyInterval($0)) })
                    }
                    .onDelete(perform: { viewStore.send(.removeIntervals(indices: $0)) })
                    .onMove(perform: { viewStore.send(.moveIntervals(fromOffsets: $0, toOffset: $1)) })
                }
                .navigationBarItems(
                    leading: EditButton(),
                    trailing: Button("Add") {
                        viewStore.send(.addNewInterval)
                    }
                )
                .navigationTitle(viewStore.name)
            }
            .sheet(item: viewStore.binding(get: \.editingInterval, send: { _ in WorkoutPlanAction.finishEditInterval }), content: { interval in
                NavigationView {
                    IntervalFormView(
                        store: self.store.scope(
                            state: { $0.intervals[id: interval.id]! },
                            action: { WorkoutPlanAction.interval(id: interval.id, action: $0) })
                    )
                        .navigationBarTitle(viewStore.state.name)
                }
                .navigationViewStyle(.stack)
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
                VStack(alignment: .leading) {
                    HStack {
                        Text(viewStore.state.name)
                        Spacer()
                    }

                    HStack {
                        Spacer()
                        Button("Copy") {
                            onCopy(viewStore.state)
                        }
                    }
                    .padding(.horizontal)
                }
            })
        }
    }
}

//
//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
