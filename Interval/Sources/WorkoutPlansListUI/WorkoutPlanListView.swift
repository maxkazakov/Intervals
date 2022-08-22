//
//  WorkoutPlanListView.swift
//  
//
//  Created by Максим Казаков on 22.08.2022.
//

import SwiftUI
import WorkoutPlansListCore
import WorkoutPlanCore
import WorkoutPlanUI
import ComposableArchitecture

public struct WorkoutPlanListView: View {
    let store: Store<WorkoutPlansList, WorkoutPlansListAction>

    public init(store: Store<WorkoutPlansList, WorkoutPlansListAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { listViewStore in
            NavigationView {
                List {
                    ForEachStore(store.scope(state: \.workoutPlans, action: WorkoutPlansListAction.workoutPlan(id:action:)), content: { workoutPlanStore in
                        WithViewStore(workoutPlanStore) { viewStore in
                            NavigationLink(
                                tag: viewStore.id,
                                selection: listViewStore.binding(get: \.openedWorkoutPlanId, send: { .setOpenedWorkoutPlan(id: $0) }),
                                destination: {
                                    WorkoutPlanView(store: workoutPlanStore)
                                }, label: {
                                    WorkoutPlanRow(store: workoutPlanStore)
                                })
                        }
                    })
                }
                .navigationBarItems(trailing: Button("Add", action: {
                    
                }))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Workout plans")
            }
            .navigationViewStyle(.stack)
        }
    }
}

public struct WorkoutPlanRow: View {
    let store: Store<WorkoutPlan, WorkoutPlanAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            Text(viewStore.name)
        }
    }
}
