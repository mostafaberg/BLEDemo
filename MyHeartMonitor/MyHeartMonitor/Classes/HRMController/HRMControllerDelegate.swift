//
//  HRMControllerDelegate.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

protocol HRMControllerDelegate {
    func didUpdateSensorLocation(location: heartSensorLocation)
    func didReceiveReading(bpm: UInt16)
    func didReceiveBatteryLevel(percentage: UInt8)
    func didUpdateRSSI(rssi: UInt16)
}
