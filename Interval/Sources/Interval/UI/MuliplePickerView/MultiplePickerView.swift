//
//  SwiftUIView.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import SwiftUI

struct MultiplePickerView: UIViewRepresentable {

    @Binding var selectionIndices: [Int]
    var data: [[String]]
    var dataFormatter: ([Int]) -> String

    // MARK: - Initializers
    init<S>(_ title: S, data: [[String]], selectionIndices: Binding<[Int]>, dataFormatter: @escaping ([Int]) -> String) where S: StringProtocol {
        self.placeholder = String(title)
        self.data = data
        self.dataFormatter = dataFormatter
        self._selectionIndices = selectionIndices

        assert(data.count == self.selectionIndices.count)
        textField = MultiplePickerTextField(data: zip(data, self.selectionIndices).map {
            MultiplePickerTextField.Item(values: $0, selectedIdx: $1)
        })
    }

    // MARK: - Private properties
    private var placeholder: String
    private var textField: MultiplePickerTextField!

    // MARK: - Public methods
    func makeUIView(context: UIViewRepresentableContext<MultiplePickerView>) -> MultiplePickerTextField {
        textField.placeholder = placeholder
        textField.textAlignment = .right
        textField.multiplePickerDelegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: MultiplePickerTextField, context: UIViewRepresentableContext<MultiplePickerView>) {
        uiView.text = self.dataFormatter(self.selectionIndices)
    }

    final class Coorinator: NSObject, MultiplePickerTextFieldDelegate {
        private let control: MultiplePickerView

        init(_ control: MultiplePickerView) {
            self.control = control
        }

        func multiplePickerSelected(component: Int, row: Int) {
            control.selectionIndices[component] = row
        }
    }

    func makeCoordinator() -> Coorinator {
        Coorinator(self)
    }
}
