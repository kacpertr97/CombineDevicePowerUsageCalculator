//
//  AddDeviceViewController.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 24/03/2022.
//

import UIKit
import Combine

class AddDeviceViewController: UIViewController, Coordinating {
    var coordinator: Coordinator?
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var deviceNameTextField: UITextField!
    @IBOutlet weak var powerUsageTextField: UITextField!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addDeviceButton: UIButton!

    let addDeviceVM = AddDeviceViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
    }

    func basicSetup() {
        title = "Add Devices"
        powerUsageTextField.delegate = self
        addDeviceVM.performBindings()
        performBindings()
    }

    func performBindings() {
        deviceNameTextField.createBinding(with: addDeviceVM.deviceName, storeIn: &subscriptions)
        powerUsageTextField.createBinding(with: addDeviceVM.devicePower, storeIn: &subscriptions)
        timeSlider.createBinding(with: addDeviceVM.timeOfUsage, storeIn: &subscriptions)

        addDeviceVM.timeOfUsage.sink { [weak self] value in
            self?.timeLabel.text = "\(Int(value))h"
        }.store(in: &subscriptions)

        addDeviceVM.enableAddButton.sink { [weak self] value in
            if value { self?.addDeviceButton.isEnabled = true } else {
                self?.addDeviceButton.isEnabled = false }
        }.store(in: &subscriptions)

        addDeviceButton.tapPublisher().sink { [weak self]_ in
            guard let name = self?.addDeviceVM.deviceName.value else { return }
            guard let power = Int(self?.addDeviceVM.devicePower.value ?? "0") else { return }
            let time = Int(self?.addDeviceVM.timeOfUsage.value ?? 1)
            let deviceToAdd = DeviceModel(name: name, timeOfUsage: time, power: power)
            self?.coordinator?.eventOccured(with: .goBackWithNewDevice(deviceToAdd))
        }.store(in: &subscriptions)
    }

}

extension AddDeviceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        let allowedCharacters = CharacterSet(charactersIn: "0123456789")
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
