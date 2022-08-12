//
//  MultiplePickerTextField.swift
//  
//
//  Created by Максим Казаков on 01.08.2022.
//

import UIKit

protocol MultiplePickerTextFieldDelegate: AnyObject {
    func multiplePickerSelected(component: Int, row: Int)
}

class MultiplePickerTextField: UITextField {
    struct Item {
        let values: [String]
        var selectedIdx: Int
    }

    // MARK: - Public properties
    var data: [Item]
    {
        didSet {
            updateSelection()
        }
    }
    weak var multiplePickerDelegate: MultiplePickerTextFieldDelegate?

    // MARK: - Initializers
    init(data: [Item]) {
        self.data = data
        super.init(frame: .zero)
        self.inputView = pickerView
        updateSelection()

        let bar = UIToolbar()
        bar.barStyle = UIBarStyle.default
        bar.isTranslucent = true
        bar.sizeToFit()

        let reset = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(resetTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        bar.items = [spaceButton, reset]
        self.inputAccessoryView = bar

        self.tintColor = .clear
    }

    @objc func resetTapped() {
        self.resignFirstResponder()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()

    private func updateSelection() {
        data.enumerated().forEach { idx, item in
            pickerView.selectRow(item.selectedIdx, inComponent: idx, animated: false)
        }
    }
}

// MARK: - UIPickerViewDataSource & UIPickerViewDelegate extension
extension MultiplePickerTextField: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data[component].values.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[component].values[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        multiplePickerDelegate?.multiplePickerSelected(component: component, row: row)
    }
}
