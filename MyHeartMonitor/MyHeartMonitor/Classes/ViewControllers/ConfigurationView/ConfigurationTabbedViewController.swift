//
//  ConfigurationTabbedViewController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit
import CoreBluetooth

class ConfigurationTabbedViewController: TabbedViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var peripheralsTable: UITableView!
    var discoveredPeripherals =  [CBPeripheral]()

    override func becameActiveTab() {
        super.becameActiveTab()
        
        let batteryServiceIdentifier = CBUUID(string: battery_service_uuid)
        let hrmServiceIdentifier = CBUUID(string: hrm_service_uuid)
        
        bleController?.discoverPeripherals(withServiceIdentifiers: [hrmServiceIdentifier,
                                                                    batteryServiceIdentifier])
    }
    
    override func didDiscover(peripheral: CBPeripheral) {
        super.didDiscover(peripheral: peripheral)
        if discoveredPeripherals.contains(peripheral) == false {
            discoveredPeripherals.append(peripheral)
            peripheralsTable.reloadData()
        }
    }
    
    override func didConnect(peripheral: CBPeripheral) {
        super.didConnect(peripheral: peripheral)
        print("Connected: \(peripheral)")
        peripheralsTable.reloadData()
        targetHeartRateController = HRMController(withPeripheral: peripheral)
    }
    
    override func didDisconnect(peripheral: CBPeripheral) {
        super.didDisconnect(peripheral: peripheral)
        print("disconnected: \(peripheral)")
        peripheralsTable.reloadData()
        targetHeartRateController = nil
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedPeripheral = discoveredPeripherals[indexPath.row]
        print("Stopping discovery")
        self.bleController?.stopDiscovery()
        
        if  selectedPeripheral.state == .connected {
            print("Peripheral is connected, disconnecting")
            self.bleController?.disconnect(peripheral: selectedPeripheral)
        } else {
            print("Connecting to peripheral")
            self.bleController?.connect(peripheral: selectedPeripheral)
        }
    }
    //MARK: - UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: "peripheralCell", for: indexPath)
        let aPeripheral = discoveredPeripherals[indexPath.row]
        let peripheralName = aPeripheral.name ?? "N/A"
        let peripheralConnected = aPeripheral.state == .connected
        aCell.textLabel?.text = peripheralName
        if peripheralConnected {
            aCell.detailTextLabel?.text = "Connected"
        } else {
            aCell.detailTextLabel?.text = "Disconnected"
        }

        return aCell
    }
}
