//
//  TabBarViewController.swift
//  MyHeartMonitor
//
//  Created by Mosdafa on 25/04/2017.
//  Copyright © 2017 Mostafa Berg. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, UITabBarControllerDelegate {

    var blecontroller: BLEController!
    var targetPripheral: HRMController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //Set the unselected color to a transparent white color to follow the app's style
        self.tabBar.unselectedItemTintColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
        
        //Create the BLE controller object
        blecontroller = BLEController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let topView = self.selectedViewController as? TabbedViewController {
            topView.becameActiveTab()
        }
    }

    //MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let topView = self.selectedViewController as? TabbedViewController {
            //Take the selected peripheral back from that view
            targetPripheral = topView.targetHeartRateController
        }
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let targetViewController = viewController as? TabbedViewController {
            targetViewController.bleController = blecontroller
            targetViewController.targetHeartRateController = targetPripheral
            targetViewController.becameActiveTab()
        } else {
            print("Error: Tabbed view did not appear properly")
        }
    }
}
