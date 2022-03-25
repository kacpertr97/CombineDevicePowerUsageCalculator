//
//  DeviceModel.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 23/03/2022.
//

import Foundation

struct DeviceModel: Codable, Hashable {
    var deviceId = UUID()
    let name: String
    let timeOfUsage: Int
    let power: Int
    var price: Double = 0
}
