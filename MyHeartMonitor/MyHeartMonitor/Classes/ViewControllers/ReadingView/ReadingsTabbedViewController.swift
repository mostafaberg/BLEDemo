//
//  ReadingsTabbedViewController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit

class ReadingsTabbedViewController: TabbedViewController, CAAnimationDelegate {

    @IBOutlet weak var heartVisualizer: UIImageView!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var batteryLevelDataLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var sensorLocationLabel: UILabel!
    @IBOutlet weak var sensorLocaitonDataLabel: UILabel!
    @IBOutlet weak var noDevicesLabel: UILabel!

    var currentBPM: Double = 0
    
    override func becameActiveTab() {
        guard self.targetHeartRateController != nil else {
            UIView.animate(withDuration: 0.25) {
                self.noDevicesLabel.alpha           = 1
                self.sensorLocationLabel.alpha      = 0
                self.sensorLocaitonDataLabel.alpha  = 0
                self.batteryLevelLabel.alpha        = 0
                self.batteryLevelDataLabel.alpha    = 0
                self.heartRateLabel.alpha           = 0
                self.heartVisualizer.alpha          = 0
            }
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.noDevicesLabel.alpha           = 0
            self.sensorLocationLabel.alpha      = 1
            self.sensorLocaitonDataLabel.alpha  = 1
            self.batteryLevelLabel.alpha        = 1
            self.batteryLevelDataLabel.alpha    = 1
            self.heartRateLabel.alpha           = 1
            self.heartVisualizer.alpha          = 1
        }

        targetHeartRateController?.delegate = self
        bleController?.delegate = self
        targetHeartRateController?.readSensorLocation()
        targetHeartRateController?.beginHRMNotifications()
        targetHeartRateController?.beginBatteryNotificaitons()
        self.pulsateHeart(bpm: 100)
    }
    
    //MARK: - Visuals
    func pulsateHeart(bpm: Double){
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 60.0/bpm
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = 1
        animation.toValue = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.delegate = self
        self.heartVisualizer.layer.add(animation, forKey: "animateOpacity")
    }
    
    //MARK: - CAAnimationdelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.pulsateHeart(bpm: currentBPM)
    }
    //MARK: - HRMControllerDelegate
    override func didUpdateSensorLocation(location: heartSensorLocation) {
        super.didUpdateSensorLocation(location: location)
        switch location {
        case .chest:
            self.sensorLocaitonDataLabel.text = "Chest"
        case .earLobe:
            self.sensorLocaitonDataLabel.text = "Ear lobe"
        case .finger:
            self.sensorLocaitonDataLabel.text = "Finger"
        case .foot:
            self.sensorLocaitonDataLabel.text = "Foot"
        case .hand:
            self.sensorLocaitonDataLabel.text = "Hand"
        case .other:
            self.sensorLocaitonDataLabel.text = "Other"
        case .wrist:
            self.sensorLocaitonDataLabel.text = "Wrist"
        }
    }
    
    override func didReceiveReading(bpm: UInt16) {
        super.didReceiveReading(bpm: bpm)
        self.heartRateLabel.text = "\(bpm) bpm"
        self.currentBPM = Double(bpm)
    }
    
    override func didReceiveBatteryLevel(percentage: UInt8) {
        super.didReceiveBatteryLevel(percentage: percentage)
        self.batteryLevelDataLabel.text = "\(percentage) %"
    }
    
    override func didUpdateRSSI(rssi: UInt16) {
        super.didUpdateRSSI(rssi: rssi)
    }
}
