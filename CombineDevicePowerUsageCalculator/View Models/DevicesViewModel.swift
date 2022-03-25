//
//  DevicesViewModel.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import Foundation
import Combine

class DevicesViewModel {
    var subscribers = Set<AnyCancellable>()
    @Published var devices = [DeviceModel]()

    let deviceToAdd = PassthroughSubject<DeviceModel, Never>()

    func performBindings() {
        deviceToAdd.sink { [weak self] device in
            self?.devices.append(device)
        }.store(in: &subscribers)
    }
}
