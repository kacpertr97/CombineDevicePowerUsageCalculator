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
    let deviceToAddFromCoreData = PassthroughSubject<DeviceModel, Never>()

    @Published var devices = [DeviceModel]()
    @Published var totalPrice = 0.0

    let action = PerformAction()

    func performBindings() {
        deviceToAdd
            .sink { [weak self] object in
                guard let self = self else { return }
                var device = object
                device.price = self.countPrice(device: device)
                self.totalPrice += device.price
                self.devices.append(device)
            }.store(in: &subscribers)

        priceForKwh
            .combineLatest(days)
            .sink { [weak self] _, _ in
                guard let self = self else { return }
                self.totalPrice = 0.0
                let newDevices = self.devices
                self.devices.removeAll()
                for device in newDevices {
                    self.deviceToAdd.send(device)
                }
            }.store(in: &subscribers)

        moreBindings()
    }

    func moreBindings() {

        action.clearDevices
            .sink { [weak self] _ in
                self?.devices.removeAll()
                CoreDataServices.clearAllDevicesFromCoreData()
            }.store(in: &subscribers)

        action.removeOneDevice
            .sink { [weak self] index in
                guard let self = self else { return }
                CoreDataServices.removeOneDeviceFromCoreData(deviceId: self.devices[index].deviceId.uuidString)
                self.devices.remove(at: index)
            }.store(in: &subscribers)

        action.loadDevices
            .sink { _ in
                CoreDataServices.readDevicesFromCoreData().sink { [weak self] devicesToAdd in
                    guard let self = self else { return }
                    guard let devicesToAdd = devicesToAdd else { return }
                    devicesToAdd.forEach { device in
                        self.deviceToAdd.send(device)
                    }
                }.store(in: &self.subscribers)
            }.store(in: &subscribers)

        action.loadSettings
            .sink { [weak self] _ in
            guard let self = self else { return }
                CoreDataServices.loadSettings().sink { [weak self] settings in
                    guard let settings = settings else { return }
                    self?.priceForKwh.send(settings.priceForKwh)
                    self?.setDays(dayCount: settings.days)
                }.store(in: &self.subscribers)
        }.store(in: &subscribers)

        action.saveSettings
            .sink { [weak self] _ in
                guard let self = self else { return }
                CoreDataServices.saveSettingToCoreData(priceForKwh: self.priceForKwh.value, days: self.returnDays())
            }.store(in: &subscribers)
    }
}

extension DevicesViewModel {
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

    func setDays(dayCount: Int) {
        switch dayCount {
        case 1:
            days.send(.day)
        case 30:
            days.send(.month)
        case 365:
            days.send(.year)
        default:
            days.send(.day)
        }
    }
}

struct PerformAction {
    var clearDevices = PassthroughSubject<Void, Never>()
    var removeOneDevice = PassthroughSubject<Int, Never>()
    var loadDevices = PassthroughSubject<Void, Never>()
    var loadSettings = PassthroughSubject<Void, Never>()
    var saveSettings = PassthroughSubject<Void, Never>()

    enum ActionType {
        case clearDevices
        case removeOneDevice(Int)
        case loadDevices
        case loadSettings
        case saveSettings
    }

    func performAction(with action: ActionType) {
        switch action {
        case .clearDevices:
            clearDevices.send(())
        case .removeOneDevice(let index):
            removeOneDevice.send(index)
        case .loadDevices:
            loadDevices.send(())
        case .loadSettings:
            loadSettings.send(())
        case .saveSettings:
            saveSettings.send(())
        }
    }
}
