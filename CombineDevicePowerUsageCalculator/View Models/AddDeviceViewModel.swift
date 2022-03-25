//
//  AddDeviceViewModel.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 24/03/2022.
//

import Foundation
import Combine

class AddDeviceViewModel {
    var subscribers = Set<AnyCancellable>()
    let deviceName = CurrentValueSubject<String, Never>("")
    let devicePower = CurrentValueSubject<String, Never>("")
    let timeOfUsage = CurrentValueSubject<Float, Never>(1)
    let enableAddButton = CurrentValueSubject<Bool, Never>(false)
    }

extension AddDeviceViewModel {
    func performBindings() {
        deviceName.combineLatest(devicePower).sink { [weak self] value1, value2 in
            let name = value1.trimmingCharacters(in: .whitespacesAndNewlines)
            let power = value2.trimmingCharacters(in: .whitespacesAndNewlines)
            if name.isEmpty || power.isEmpty {
                self?.enableAddButton.send(false)
            } else {
                self?.enableAddButton.send(true)
            }
        }.store(in: &subscribers)

    }
}
