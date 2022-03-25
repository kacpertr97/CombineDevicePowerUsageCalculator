//
//  DevicesVC+UIMenu.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 25/03/2022.
//

import Foundation
import UIKit
import Combine

extension DevicesViewController {
    func createUIMenu() -> UIMenu {
        let setPriceItem = UIAction(title: "Set price for kWh") { [weak self] _ in
            self?.createPriceAlert()
        }
        let cancelItem = UIAction(title: "Cancel", handler: { _ in })
        let menu = UIMenu(title: "Settings", options: .displayInline,
                          children: [setPriceItem, createSubmenu(), cancelItem])
        return menu
    }

    func createPriceAlert() {
        let alert = UIAlertController(title: "Set price for kWh", message: "", preferredStyle: .alert)
        var textField = UITextField()
        alert.addTextField { text in
            text.delegate = self
            text.keyboardType = .decimalPad
            textField = text
        }
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            guard let textFromTextField = textField.text else { return }
            if let text = Double(textFromTextField) {
                self?.devicesVM.priceForKwh.send(text)            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }

    func createSubmenu() -> UIMenu {
        let dayAction = UIAction(title: "Day", handler: { [weak self] _ in
            self?.devicesVM.days.send(.day)
        })
        let monthAction = UIAction(title: "Month", handler: { [weak self] _ in
            self?.devicesVM.days.send(.month)
        })
        let yearAction = UIAction(title: "Year", handler: { [weak self] _ in
            self?.devicesVM.days.send(.year)
        })
        switch devicesVM.days.value {
        case .day:
            dayAction.state = .on
        case .month:
            monthAction.state = .on
        case .year:
            yearAction.state = .on
        }
        let submenu = UIMenu(title: "Select days to count",
                             options: .singleSelection,
                             children: [dayAction, monthAction, yearAction])
        return submenu
    }
}

extension DevicesViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        var allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        if textField.text!.contains(".") || textField.text!.contains(",") {
            allowedCharacters = CharacterSet(charactersIn: "0123456789")
        }
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
