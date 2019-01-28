//
//  BaseVC.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/24/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func checkCentralState() {
        LogUtils.LogTrace(type: .startFunc)
        if CentralManager.shared.isCentralManagerReady() {
            self.dismissTurnOnBluetoothWarning()
        } else {
            self.showTurnOnBluetoothWarning()
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // MARK: - Turn On Bluetooth Warning :
    func dismissTurnOnBluetoothWarning() {
        guard let window: UIWindow = UIApplication.shared.keyWindow, var topVC = window.rootViewController?.presentedViewController else {
            return
        }
        while topVC.presentedViewController != nil {
            topVC = topVC.presentedViewController!
        }
        if topVC.isKind(of: UIAlertController.self) {
            topVC.dismiss(animated: true, completion: nil)
        }
    }
    
    func showTurnOnBluetoothWarning() {
        let ac = UIAlertController(title: "Turn On Bluetooth", message: "Please turn bluetooth on", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            return
        }
        ac.addAction(okAction)
        self.present(ac, animated: true)
    }
    
}
// MARK: - BLEManager Delegate :
extension BaseVC: CentralManagerDelegate {
    
    func centralManagerDidUpdateState() {
        LogUtils.LogTrace(type: .startFunc)
        if CentralManager.shared.isCentralManagerReady() {
            self.dismissTurnOnBluetoothWarning()
        } else {
            self.showTurnOnBluetoothWarning()
        }
        LogUtils.LogTrace(type: .endFunc)
    }

}
