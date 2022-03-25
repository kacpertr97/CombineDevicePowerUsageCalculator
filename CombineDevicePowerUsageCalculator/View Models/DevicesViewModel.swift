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

    var days = CurrentValueSubject<DaysToCount, Never>(.day)
    var priceForKwh = CurrentValueSubject<Double, Never>(0.0)
    let deviceToAdd = PassthroughSubject<DeviceModel, Never>()
    let refreshTableView = PassthroughSubject<Void, Never>()

    @Published var devices = [DeviceModel]()
    @Published var totalPrice = 0.0

    func performBindings() {
        deviceToAdd
        .sink { [weak self] object in
            guard let self = self else { return }
            var device = object
            device.price = self.countPrice(device: device)
            self.totalPrice += device.price
            self.devices.append(device)
        }.store(in: &subscribers)

        priceForKwh.combineLatest(days)
            .sink { [weak self] _, _ in
            guard let self = self else { return }
            print(self.priceForKwh)
            let newDevices = self.devices
            self.devices.removeAll()
            for device in newDevices {
                self.deviceToAdd.send(device)
            }
        }.store(in: &subscribers)
    }

    func countPrice(device: DeviceModel) -> Double {
        let powerInKW = Double(device.power)/1000
        let kwh = powerInKW * Double(device.timeOfUsage)
        let price = kwh * priceForKwh.value * Double(returnDays())
        return round(price * 100) / 100
    }

}

extension DevicesViewModel {

    enum DaysToCount {
        case day
        case month
        case year
    }

    func returnDays() -> Int {
        switch days.value {
        case .day:
            return 1
        case .month:
            return 30
        case .year:
            return 365
        }
    }
}
