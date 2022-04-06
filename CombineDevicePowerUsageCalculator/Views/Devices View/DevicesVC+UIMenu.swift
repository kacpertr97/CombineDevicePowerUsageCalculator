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
        let deleteItem = UIAction(title: "Clear All Devices", attributes: .destructive, handler: { [weak self] _ in
            self?.createDeleteAlert()
        })
        let menu = UIMenu(title: "Settings", options: .displayInline,
                          children: [setPriceItem, createSubmenu(), deleteItem])
        return menu
    }

    func createDeleteAlert() {
        let alert = UIAlertController(title: "Are you sure you want to delete all devices?",
                                      message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { [weak self]_ in
            self?.devicesVM.action.performAction(with: .clearDevices)
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel, handler: nil))
        present(alert, animated: true)

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
                self?.devicesVM.priceForKwh.send(text)
                self?.devicesVM.action.performAction(with: .saveSettings)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }

    func createSubmenu() -> UIMenu {
        let dayAction = UIAction(title: "Day", handler: { [weak self] _ in
            self?.devicesVM.days.send(.day)
            self?.devicesVM.action.performAction(with: .saveSettings)
        })
        let monthAction = UIAction(title: "Month", handler: { [weak self] action in
            self?.devicesVM.days.send(.month)
            self?.devicesVM.action.performAction(with: .saveSettings)
        })
        let yearAction = UIAction(title: "Year", handler: { [weak self] _ in
            self?.devicesVM.days.send(.year)
            self?.devicesVM.action.performAction(with: .saveSettings)
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
