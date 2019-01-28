//
//  PeripheralVC.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/26/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit


class PeripheralVC: BaseVC {
    
    // MARK: - Properties:
    
    // MARK: - IBOutlet:
    @IBOutlet weak var advertiseButtonOutlet: UIButton!
    @IBOutlet weak var stopButtonOutlet: UIButton!
    @IBOutlet weak var receivedMessage: UILabel!
    
    // MARK: - ViewLifeCycle:
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // register notification
        NotificationCenter.default.addObserver(self, selector: #selector(alertWhenBluetoothIsOff), name: NSNotification.Name(rawValue: NotificationName.bluetoothIsOff.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceivedMessage(notification:)), name: NSNotification.Name(NotificationName.receiveMessage.rawValue), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stopButtonOutlet.isHidden = true
        self.receivedMessage.text = ""
        self.advertiseButtonOutlet.setTitle("Start Advertise", for: .normal)
        self.dismissKeyboardWhenTappingArround()
    }
    
    // MARK: - Notification action :
    @objc func alertWhenBluetoothIsOff() {
        super.showTurnOnBluetoothWarning()
    }
    
    @objc func didReceivedMessage(notification: Notification) {
        LogUtils.LogTrace(type: .startFunc)
        if let message = notification.userInfo?["message"] as? String {
            receivedMessage.text = message
        } else {
            LogUtils.LogDebug(type: .error, message: "Message is nil")
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // MARK: - IBAction:
    @IBAction func advertiseButtonPressed(_ sender: UIButton) {
        LogUtils.LogTrace(type: .startFunc)
        if PeriperalManager.shared.isPeripheralManagerReady() {
            self.stopButtonOutlet.isHidden = false
            self.advertiseButtonOutlet.setTitle("Advertising...", for: .normal)
            _ = PeriperalManager.shared.startAdvertise()
            LogUtils.LogTrace(type: .endFunc)
        } else {
            super.showTurnOnBluetoothWarning()
            LogUtils.LogTrace(type: .endFunc)
        }
 
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        LogUtils.LogTrace(type: .startFunc)
        if let isAdvertising = PeriperalManager.shared.peripheralManager?.isAdvertising {
            if isAdvertising == true { // do stop:
                _ = PeriperalManager.shared.stopAdvertise()
                self.stopButtonOutlet.isHidden = true
                self.advertiseButtonOutlet.setTitle("Start Advertising", for: .normal)
                LogUtils.LogTrace(type: .endFunc)
            } else {
                LogUtils.LogDebug(type: .warning, message: "Peripheral is advertising")
                LogUtils.LogTrace(type: .endFunc)
            }
        } else {
            LogUtils.LogDebug(type: .error, message: "Advertising state is nil")
            LogUtils.LogTrace(type: .endFunc)
        }
    }
    
    // MARK: - Helper Functions:
    
    func dismissKeyboardWhenTappingArround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    
}
