//
//  MainCoordinator.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import Foundation
import UIKit

class MainCoordinator: Coordinator {

    var navigationController: UINavigationController?

    func eventOccured(with type: Event) {
        switch type {
        case .goToAddDevices:
            goToAddDevices()
        case .goBackWithNewDevice(let device):
            goBackToDevicesWithNewDevice(device: device)

        }
    }

    func start() {
        var viewController: UIViewController & Coordinating = DevicesViewController()
        viewController.coordinator = self
        navigationController?.setViewControllers([viewController], animated: false)
    }

    func goToAddDevices() {
        var viewController: UIViewController & Coordinating = AddDeviceViewController()
        viewController.coordinator = self
        navigationController?.pushViewController(viewController, animated: true)
    }

    func goBackToDevicesWithNewDevice(device: DeviceModel) {
        let viewController = navigationController?.viewControllers.first as? DevicesViewController
        navigationController?.popViewController(animated: true)
        viewController?.devicesVM.deviceToAdd.send(device)
        CoreDataServices.saveDeviceToCoreData(device: device)
    }
}
