//
//  BLEControllerDelegate.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import CoreBluetooth
protocol BLEControllerDelegate {
    func didDiscover(peripheral: CBPeripheral)
    func didConnect(peripheral: CBPeripheral)
    func didDisconnect(peripheral: CBPeripheral)
}
