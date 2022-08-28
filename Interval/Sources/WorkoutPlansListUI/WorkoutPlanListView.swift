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
                    .onDelete(perform: { listViewStore.send(.tapRemoveWorkoutPlan(indices: $0)) })
                }
                .navigationBarItems(trailing: Button("Add", action: {
                    listViewStore.send(.createNewWorkoutPlan)
                }))
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Workout plans")
            }
            .alert(
                self.store.scope(state: \.removingConfirmationDialog),
                dismiss: .cancelRemoving
            )
            .navigationViewStyle(.stack)
        }
    }
}

public struct WorkoutPlanRow: View {
    let store: Store<WorkoutPlan, WorkoutPlanAction>

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 8) {
                Text(viewStore.name)
                Text(viewStore.intervals.map { $0.durationDescription }.joined(separator: "\n"))
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
            .padding(.vertical, 8)
        }
    }
}
