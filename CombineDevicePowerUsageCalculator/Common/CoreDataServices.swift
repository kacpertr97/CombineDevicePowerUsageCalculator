//
//  CoreDataServices.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 27/03/2022.
//

import Foundation
import CoreData
import Combine
import UIKit

enum CoreDataServices {
    // MARK: - Saving and loading devices
    static func saveDeviceToCoreData(device: DeviceModel) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "DevicesCoreData", in: managedContext)
        else { return }
        let deviceToAdd = NSManagedObject(entity: entity, insertInto: managedContext)
        deviceToAdd.setValue(device.deviceId.uuidString, forKey: "deviceId")
        deviceToAdd.setValue(device.power, forKey: "power")
        deviceToAdd.setValue(device.name, forKey: "name")
        deviceToAdd.setValue(device.timeOfUsage, forKey: "timeOfUsage")
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    static func readDevicesFromCoreData() -> Just<[DeviceModel]?> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return Just(nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DevicesCoreData")
        var devicesToReturn = [DeviceModel]()
        do {
            let devices = try managedContext.fetch(fetchRequest)
            devicesToReturn = devices.map { object in
                let name = object.value(forKey: "name") as? String ?? ""
                let power = object.value(forKey: "power") as? Int ?? 0
                let timeOfUsage = object.value(forKey: "timeOfUsage") as? Int ?? 0
                let deviceId = object.value(forKey: "deviceId") as? String ?? ""
                let device = DeviceModel(deviceId: UUID(uuidString: deviceId)!,
                                         name: name,
                                         timeOfUsage: timeOfUsage,
                                         power: power)
                return device
            }
        } catch {
            print(error.localizedDescription)
        }
        return Just(devicesToReturn)
    }

    static func clearAllDevicesFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DevicesCoreData")
        do {
            let devices = try managedContext.fetch(fetchRequest)
            devices.forEach { device in
                managedContext.delete(device)
            }
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    static func removeOneDeviceFromCoreData(deviceId: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DevicesCoreData")
        do {
            let devices = try managedContext.fetch(fetchRequest)
            devices.forEach { device in
                if device.value(forKey: "deviceId") as? String == deviceId {
                    managedContext.delete(device)
                }
            }
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    // MARK: - Saving and loading settings
    static func saveSettingToCoreData(priceForKwh: Double, days: Int) {
        clearSettings()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Settings", in: managedContext)
        else { return }
        let settings = NSManagedObject(entity: entity, insertInto: managedContext)
        settings.setValue(priceForKwh, forKey: "priceForKwh")
        settings.setValue(days, forKey: "days")
        do {
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }

    }

    static func clearSettings() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do {
            let settings = try managedContext.fetch(fetchRequest)
            settings.forEach { setting in
                managedContext.delete(setting)
            }
            try managedContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    static func loadSettings() -> Just<SettingsModel?> {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return Just(nil) }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Settings")
        do {
            let settings = try managedContext.fetch(fetchRequest)
            let price = settings.first?.value(forKey: "priceForKwh") as? Double ?? 0.0
            let days = settings.first?.value(forKey: "days") as? Int ?? 1
            let settingsToReturn = SettingsModel(priceForKwh: price, days: days)
            return Just(settingsToReturn)
        } catch {
            print(error.localizedDescription)
            return(Just(nil))
        }

    }
}
