//
//  Coordinator.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import Foundation
import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }

    func eventOccured(with type: Event)
    func start()
}

enum Event {
    case goToAddDevices
    case goBackWithNewDevice(DeviceModel)
}

protocol Coordinating {
    var coordinator: Coordinator? { get set }
}
