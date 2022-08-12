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
    @State var openedInterval: Interval.Id?

    public init(store: Store<WorkoutPlan, WorkoutPlanAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEachStore(
                        self.store.scope(state: \.intervals, action: WorkoutPlanAction.interval(id:action:))
                    ) { intervalStore in
                        WithViewStore(intervalStore) { viewStore in
                            NavigationLink(tag: viewStore.state.id, selection: $openedInterval, destination: {
                                IntervalFormView(store: intervalStore)
                            }, label: {
                                Text(viewStore.state.name)
                            })
                        }
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
        }
    }
}
//
//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        SwiftUIView()
//    }
//}
