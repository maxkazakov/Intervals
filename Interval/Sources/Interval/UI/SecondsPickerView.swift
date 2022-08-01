//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture

struct SecondsPickerView: View {

    let title: String
    let viewStore: ViewStore<Int, IntervalAction>
    let actionFactory: (Int) -> IntervalAction
    private let possibleMinutesOrSeconds = 0..<60

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
                data: minutesOrSecondsData(),
                selectionIndices: viewStore.binding(get: {
                    let minutes = $0 / 60
                    let seconds = $0 % 60
                    let minuteIdx = possibleMinutesOrSeconds.firstIndex { minutes == $0  } ?? 0
                    let secondIdx = possibleMinutesOrSeconds.firstIndex { seconds == $0  } ?? 0
                    return [minuteIdx, secondIdx]
                }, send: {
                    let min = possibleMinutesOrSeconds[$0[0]]
                    let sec = possibleMinutesOrSeconds[$0[1]]
                    let newSeconds = min * 60 + sec
                    return actionFactory(newSeconds)
                }),
                dataFormatter: { formatTime($0) }
            )
        }
    }


    private func minutesOrSecondsData() -> [[String]] {
        [
            possibleMinutesOrSeconds.map { "\($0)" },
            possibleMinutesOrSeconds.map { "\($0)" }
        ]
    }

    private func formatTime(_ indices: [Int]) -> String {
        let minutes = possibleMinutesOrSeconds[indices[0]]
        let seconds = possibleMinutesOrSeconds[indices[1]]
        return "\(minutes):\(String(format: "%02d", seconds))"
    }
}
