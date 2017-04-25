//
//  TabbedViewController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

class TabbedViewController: UIViewController, BLEControllerDelegate, HRMControllerDelegate {
    
    public var bleController: BLEController?
    public var targetHeartRateController: HRMController?
    
    //MARK: - Implementation
    func becameActiveTab() {
        bleController?.delegate = self
        targetHeartRateController?.delegate = self
    }
    
    //MARK: - BLEcontrollerDelegate
    func didDiscover(peripheral: CBPeripheral) {
        
    }
    
    func didConnect(peripheral: CBPeripheral) {
        
    }
    
    func didDisconnect(peripheral: CBPeripheral) {
        
    }
    
    //MARK: - HRMControllerDelegate
    func didReceiveReading(bpm: UInt16) {
        print("Heart rate updated")
    }
    
    func didReceiveBatteryLevel(percentage: UInt8) {
        print("Battery percentage updated")
    }
    
    func didUpdateSensorLocation(location: heartSensorLocation) {
        print("Sensor location updated")
    }
    
    func didUpdateRSSI(rssi: UInt16) {
        print("RSSI Updated")
    }
}
