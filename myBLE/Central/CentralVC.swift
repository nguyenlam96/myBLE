//
//  ScanVC.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/22/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralVC: BaseVC {
    
    // MARK: - Properties:
    var listPeripherials: [CBPeripheral]  = []
    var isScanning = false
    // MARK: - IBOutlet:
    @IBOutlet weak var scanButtonOutlet: UIButton!
    @IBOutlet weak var stopScanButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendStatusLabel: UILabel!
    
    
    // MARK: - ViewLifeCycle:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
//        self.dismissKeyboardWhenTappingArround()
        sendStatusLabel.text = ""
        connectingIndicator.stopAnimating()
        stopScanButtonOutlet.isHidden = true
        CentralManager.shared.delegate = self
    }
    // MARK: - IBAction:
    @IBAction func startScanButtonPressed(_ sender: UIButton) {
        
        // ensure bluetooth is on
        if CentralManager.shared.isCentralManagerReady() {
            self.startScan()
        } else {
            super.showTurnOnBluetoothWarning()
        }
       
    }
    
    @IBAction func stopScanButtonPressed(_ sender: UIButton) {
        self.stopScan()
        stopScanButtonOutlet.isHidden = true
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        LogUtils.LogTrace(type: .startFunc)
        self.sendStatusLabel.text = ""
        let text = messageTextField.text
        // ensure state is connected
        guard CentralManager.shared.connectedPeripherial?.state == .connected else {
            LogUtils.LogDebug(type: .error, message: "peripheral is not connected")
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        _ = CentralManager.shared.writeValue(value: text)
        LogUtils.LogTrace(type: .endFunc)
        
    }
    @IBAction func backgroundButtonPressed(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    // MARK: - Bluetooth functions :
    func startScan() {
        LogUtils.LogTrace(type: .startFunc)
        stopScanButtonOutlet.isHidden = false // show stop button
        connectingIndicator.stopAnimating()           // stop animating
        self.scanButtonOutlet.setTitle("Scanning...", for: .normal)
        self.listPeripherials.removeAll()
        self.tableView.reloadData()
        _ = CentralManager.shared.startScan(with: nil) // ServicesUUID is nil
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func stopScan() {
        LogUtils.LogTrace(type: .startFunc)
        self.scanButtonOutlet.setTitle("Start Scan", for: .normal)
        _ = CentralManager.shared.stopScan()
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func startConnect(to peripherial: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        
        let connectState = peripherial.state
        if connectState == .connected {
            LogUtils.LogDebug(type: .info, message: "This peripherial is connected")
        } else if connectState == .connecting {
            LogUtils.LogDebug(type: .info, message: "This peripherial is connecting")
        } else { // do connect:
            self.stopScanButtonOutlet.isHidden = true // hide the stopButton
            self.stopScan() // stop scan first
            self.connectingIndicator.startAnimating() // start indicator
            _ = CentralManager.shared.startConnect(to: peripherial, options: nil) // startConnect
        }

        LogUtils.LogTrace(type: .endFunc)
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

// MARK: - BLEManager Delegate :
extension CentralVC {
    // didDiscover peripheral
    func didDiscover(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if listPeripherials.count > 0 {
            var isNewPeripherial = true
            for (_, existedPeripherial) in listPeripherials.enumerated() {
                if existedPeripherial == peripheral { // this peripherial is already in the list
                    isNewPeripherial = false
                }
            }
            if isNewPeripherial {
                listPeripherials.append(peripheral)
            }
        } else { // list is empty
            listPeripherials.append(peripheral)
        }
        tableView.reloadData()
    }
    // didConnect
    func didConnect(peripheral: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        self.connectingIndicator.stopAnimating()
        CentralManager.shared.connectedPeripherial = peripheral // set connected peripheral
        CentralManager.shared.connectedPeripherial?.discoverServices(nil)
        self.tableView.reloadData()
        LogUtils.LogTrace(type: .endFunc)
    }
    // didDisconnect
    func didDisconnect(peripheral: CBPeripheral, error: Error?) {
        
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            tableView.reloadData()
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        self.connectingIndicator.stopAnimating()
        tableView.reloadData()
        LogUtils.LogTrace(type: .endFunc)
        
    }
    
    func didWriteValueFor(characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            sendStatusLabel.text = "send fail"
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
        } else {
            sendStatusLabel.text = "send success"
        }
    }
    
    
}

extension CentralVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPeripherials.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foundDeviceCell", for: indexPath)
        let peripherial = self.listPeripherials[indexPath.row]
        if peripherial.state == .connected {
             cell.detailTextLabel?.text = "connected"
        } else {
            cell.detailTextLabel?.text = "not connected"
        }
        cell.textLabel?.text = peripherial.name ?? "Unkowned"
        return cell
    }
    
    // MARK: - TableView Delegate:
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let peripherial = self.listPeripherials[indexPath.row]
        let connectState = peripherial.state
        if (connectState == .connected) {
            // stop connect
           _ = CentralManager.shared.disconnect(to: peripherial)
        } else {
             self.startConnect(to: peripherial)
        }

    }
    
}
