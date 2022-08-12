//
//  IntPickerView.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture
import Foundation
import IntervalCore

struct IntPickerView: View {

    let title: String
    let viewStore: ViewStore<Int, IntervalAction>
    let actionFactory: (Int) -> IntervalAction
    private let possibleValues = Array(100..<200)

    init(title: String, viewStore: ViewStore<Int, IntervalAction>, actionFactory: @escaping (Int) -> IntervalAction) {
        self.title = title
        self.viewStore = viewStore
        self.actionFactory = actionFactory
    }

    var body: some View {
        HStack {
            Text(title)
            MultiplePickerView(
                "",
                data: [possibleValues.map { String($0) }],
                selectionIndices: viewStore.binding(get: { value in
                    let idx = possibleValues.firstIndex { value == $0  } ?? 0
                    return [idx]
                }, send: {
                    let value = possibleValues[$0.first!]
                    return actionFactory(value)
                }),
                dataFormatter: { String(possibleValues[$0.first!]) }
            )
        }
    }
}
