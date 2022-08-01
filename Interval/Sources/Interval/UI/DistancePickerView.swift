//
//  DistancePickerView.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI
import ComposableArchitecture
import Foundation

struct DistancePickerView: View {

    let viewStore: ViewStore<Double, IntervalAction>
    init(viewStore: ViewStore<Double, IntervalAction>) {
        self.viewStore = viewStore
    }

    private let possibleDistanceIntegerValues = (0...100).map { $0 }
    private let possibleDistanceFractionalValues = stride(from: 0, to: 1000, by: 100).map { $0 }

    var body: some View {
        HStack {
            Text(NSLocalizedString("Distance", comment: ""))
            MultiplePickerView(
                "",
                data: distanceData(),
                selectionIndices: viewStore.binding(get: { meters in
                    let integerIdx = possibleDistanceIntegerValues.firstIndex { Int(meters) / 1000 == $0  } ?? 0
                    let fractionIdx = possibleDistanceFractionalValues.firstIndex { Int(meters) % 1000 == $0  } ?? 0
                    return [integerIdx, fractionIdx]
                }, send: {
                    IntervalAction.distanceChanged(meters: Double(indicesToMeters(ids: $0)))
                }),
                dataFormatter: { format(ids: $0) }
            )
        }
    }

    private func distanceData() -> [[String]] {
        [
            possibleDistanceIntegerValues.map { "\($0)" },
            possibleDistanceFractionalValues.map { String(format: "%03d", $0) }
        ]
    }

    func indicesToMeters(ids: [Int]) -> Int {
        let kmId = ids[0]
        let mId = ids[1]
        return possibleDistanceIntegerValues[kmId] * 1000 + possibleDistanceFractionalValues[mId]
    }

    func format(ids: [Int]) -> String {
        "\(indicesToMeters(ids: ids))"
    }
}
