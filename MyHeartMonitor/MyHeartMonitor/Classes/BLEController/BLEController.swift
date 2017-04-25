//
//  BLEController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLEController: NSObject, CBCentralManagerDelegate {

    var delegate: BLEControllerDelegate?
    private var centralManager: CBCentralManager
    private var connectedPeriphreals = [CBPeripheral]()
    private var targetPeripheral: CBPeripheral?
    
    override init() {
        centralManager = CBCentralManager()
        super.init()
        centralManager.delegate = self
    }
    
    //MARK: - Scanning and discovery
    public func discoverPeripherals(withServiceIdentifiers serviceIdentifiers: [CBUUID]) {
        guard centralManager.state == .poweredOn else {
            print("Central Manager is not ready, or bluetooth is powered off!")
            return
        }
        centralManager.scanForPeripherals(withServices: serviceIdentifiers, options: nil)
    }

    public func stopDiscovery() {
        centralManager.stopScan()
    }
    
    //MARK: - Connection handling
    public func connect(peripheral aPeripheral: CBPeripheral) {
        targetPeripheral = aPeripheral
        centralManager.connect(targetPeripheral!, options: nil)
    }
    
    public func disconnect(peripheral aPeripheral: CBPeripheral) {
        centralManager.cancelPeripheralConnection(targetPeripheral!)
    }

    //MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOff:
                print("Bluetooth is turned off!")
            case .poweredOn:
                print("Bluetooth is ready!")
            case.resetting:
                print("Bluetooth is resetting")
            case .unknown:
                print("Unknown state")
            case .unsupported:
                print("Unsupported mode")
            case .unauthorized:
                print("Unauthorized")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.didDiscover(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard self.targetPeripheral != nil && peripheral == self.targetPeripheral! else {
            print("Connected to an unknown peripheral")
            return
        }
        delegate?.didConnect(peripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        guard self.targetPeripheral != nil && peripheral == self.targetPeripheral! else {
            print("Disconnected from an unknown peripheral")
            return
        }
        delegate?.didDisconnect(peripheral: peripheral)
        self.targetPeripheral = nil
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        delegate?.didDisconnect(peripheral: peripheral)
    }
}
