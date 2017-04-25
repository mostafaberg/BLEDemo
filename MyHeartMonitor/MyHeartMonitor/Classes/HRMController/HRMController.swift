//
//  HRMController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

//MARK - Services
let battery_service_uuid                = "180F"
let hrm_service_uuid                    = "180D"

//MARK - Characteristis
let battery_level_characteristic_uuid   = "2A19"
let hrm_location_characteristic_uuid    = "2A38"
let hrm_reading_characteristic_uuid     = "2A37"

enum heartSensorLocation: UInt8 {
    case other      = 0x00
    case chest      = 0x01
    case wrist      = 0x02
    case finger     = 0x03
    case hand       = 0x04
    case earLobe    = 0x05
    case foot       = 0x06
}

class HRMController: NSObject, CBPeripheralDelegate {
    
    //MARK: - Properties
    var delegate:                           HRMControllerDelegate?
    var targetPeripheral:                   CBPeripheral
    var batteryLevelCharacteristic:         CBCharacteristic!
    var heartMonitorLocationCharacteristic: CBCharacteristic!
    var heartMonitorReadingCharacteristic:  CBCharacteristic!
    
    //MARK: - Implementation
    required init(withPeripheral aPeripheral: CBPeripheral) {
        targetPeripheral = aPeripheral
        super.init()
        targetPeripheral.delegate = self
        
        let batteryServiceIdentifier = CBUUID(string: battery_service_uuid)
        let hrmServiceIdentifier = CBUUID(string: hrm_service_uuid)
        
        targetPeripheral.discoverServices([batteryServiceIdentifier,
                                           hrmServiceIdentifier])
    }

    func beginHRMNotifications() {
        guard heartMonitorReadingCharacteristic != nil else{
            print("HRM reading characteristic not present")
            return
        }
        setNotificationState(aState: true, forCharacteristic: heartMonitorReadingCharacteristic)
    }
    
    func stopHRMNotifications() {
        guard heartMonitorReadingCharacteristic != nil else{
            print("HRM reading characteristic not present")
            return
        }
        setNotificationState(aState: false, forCharacteristic: heartMonitorReadingCharacteristic)
    }

    func beginBatteryNotificaitons() {
        guard batteryLevelCharacteristic != nil else{
            print("Battery level characteristic not present")
            return
        }
        setNotificationState(aState: true, forCharacteristic: batteryLevelCharacteristic)
    }
    
    func stopBatteryNotifications() {
        guard batteryLevelCharacteristic != nil else{
            print("Battery level characteristic not present")
            return
        }
        setNotificationState(aState: false, forCharacteristic: batteryLevelCharacteristic)
    }
    
    private func setNotificationState(aState: Bool, forCharacteristic aCharacteristic: CBCharacteristic) {
        targetPeripheral.setNotifyValue(aState, for: aCharacteristic)
    }
    
    func readSensorLocation() {
        guard heartMonitorLocationCharacteristic != nil else {
            print("Sensor location characteristic not present")
            return
        }
        targetPeripheral.readValue(for: heartMonitorLocationCharacteristic)
    }
    
    //MARK: - CBperipheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard peripheral.services != nil && peripheral.services!.count > 0 else {
            print("peripheral has no services")
            return
        }
        
        for aService in peripheral.services! {
            if aService.uuid.uuidString == battery_service_uuid {
                let batteryLevelCharcateristicUUID = CBUUID(string: battery_level_characteristic_uuid)
                peripheral.discoverCharacteristics([batteryLevelCharcateristicUUID], for: aService)
            }
            if aService.uuid.uuidString == hrm_service_uuid {
                let hrmSensorLocationUUID = CBUUID(string: hrm_location_characteristic_uuid)
                let hrmSensorReadingUUID  = CBUUID(string: hrm_reading_characteristic_uuid)
                peripheral.discoverCharacteristics([hrmSensorLocationUUID,
                                                    hrmSensorReadingUUID], for: aService)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("an error has occured: \(error!)")
            return
        }
        
        for aService in peripheral.services! {
            if aService.uuid.uuidString == battery_service_uuid {
                if let discoveredCharcateristics = aService.characteristics {
                    for aCharacteristic in discoveredCharcateristics {
                        if aCharacteristic.uuid.uuidString == battery_level_characteristic_uuid {
                            print("Battery level chtx found")
                            batteryLevelCharacteristic = aCharacteristic
                        }
                    }
                }
            }
            if aService.uuid.uuidString == hrm_service_uuid {
                if let discoveredCharcateristics = aService.characteristics {
                    for aCharacteristic in discoveredCharcateristics {
                        if aCharacteristic.uuid.uuidString == hrm_reading_characteristic_uuid {
                            print("HRM reading chtx found")
                            heartMonitorReadingCharacteristic = aCharacteristic
                        }
                        if aCharacteristic.uuid.uuidString == hrm_location_characteristic_uuid {
                            print("HRM location chtx found")
                            heartMonitorLocationCharacteristic = aCharacteristic
                        }
                    }
                }
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == battery_level_characteristic_uuid {
            //handle battery level change
            let data = characteristic.value!
            let bytes = [UInt8](data)
            delegate?.didReceiveBatteryLevel(percentage: bytes[0])
        }
        
        if characteristic.uuid.uuidString == hrm_reading_characteristic_uuid {
            //handle hrm readings
            let data = characteristic.value!
            let bytes = [UInt8](data)
            //Check if value is UInt8 or UInt16 (as per spec)
            if bytes[0] & 0x01 == 0 {
                //UInt8 value
                delegate?.didReceiveReading(bpm: UInt16(bytes[1]))
            } else {
                //UInt16 value
                //Convert Endianess from Little to Big
                let convertedBytes = UInt16(bytes[2] * 0xFF) + UInt16(bytes[1])
                delegate?.didReceiveReading(bpm: convertedBytes)
            }
        }
        
        if characteristic.uuid.uuidString == hrm_location_characteristic_uuid {
            //handle location reading
            let data = characteristic.value!
            let bytes = [UInt8](data)
            if let location = heartSensorLocation(rawValue: bytes[0]) {
                delegate?.didUpdateSensorLocation(location: location)
            } else {
                delegate?.didUpdateSensorLocation(location: .other)
            }
        }
    }
}
