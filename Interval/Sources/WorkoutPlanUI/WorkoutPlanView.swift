//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 12.08.2022.
//

import SwiftUI
import IntervalUI
import WorkoutPlanCore
import ComposableArchitecture

public struct WorkoutPlanView: View {
    public let store: Store<WorkoutPlan, WorkoutPlanAction>

    public init(store: Store<WorkoutPlan, WorkoutPlanAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                List {
                    ForEach(viewStore.intervals) { interval in
                        Text(interval.name)
                    }
                }
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
