//
//  ScanVC.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/22/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanVC: UIViewController {
    
    // MARK: - Properties:
    var listDevices: [CBPeripheral]  = []
    var isScanning = false
    // MARK: - IBOutlet:
    @IBOutlet weak var scanButtonOutlet: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicatorOutlet: UIActivityIndicatorView!
    
    // MARK: - ViewLifeCycle:
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
//        indicatorOutlet.stopAnimating()
        
        BLEManager.shared.delegate = self
    }
    // MARK: - IBAction:
    @IBAction func scanButtonPressed(_ sender: UIButton) {
        
        // ensure bluetooth is on
        if BLEManager.shared.isCentralManagerReady() {
            if isScanning {
                self.stopScan()
            } else {
                self.startScan()
            }
            isScanning = !isScanning
        } else {
            self.showTurnOnBluetoothWarning()
        }
       
    }
    
    // MARK: - Bluetooth functions :
    func startScan() {
        LogUtils.LogTrace(type: .startFunc)
        self.scanButtonOutlet.setTitle("STOP SCAN", for: .normal)
        self.listDevices.removeAll()
        self.tableView.reloadData()
        
        _ = BLEManager.shared.scanner.startScan(services: nil)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func stopScan() {
        LogUtils.LogTrace(type: .startFunc)
        self.scanButtonOutlet.setTitle("START SCAN", for: .normal)
        _ = BLEManager.shared.scanner.stopScan()
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func startConnect(peripherial: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        // start connect to new device
//        self.indicatorOutlet.startAnimating()
        _ = BLEManager.shared.connector.startConnect(to: peripherial, options: nil)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // MARK: - Warning to turn on bluetooth :
    
    func didBluetoothOn() { // if bluetooth is on, dismiss the popup
        LogUtils.LogTrace(type: .startFunc)
        LogUtils.LogDebug(type: .info, message: "Bluetooth is ON")
        self.dismissWarningAlertControllerIfPresent()
        LogUtils.LogTrace(type: .endFunc)
        
    }
    func didBluetoothOff() { // if bluetooth is off, show popup to turn it on
        LogUtils.LogTrace(type: .startFunc)
        LogUtils.LogDebug(type: .info, message: "Bluetooth is OFF")
        self.showTurnOnBluetoothWarning()
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func dismissWarningAlertControllerIfPresent() {
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
        let ac = UIAlertController(title: "Turn On Bluetooth", message: "Please turn on bluetooth before scan", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            return
        }
        ac.addAction(okAction)
        self.present(ac, animated: true)
    }
    


}

// MARK: - BLEManager Delegate :
extension ScanVC: BLEManagerDelegate {
    func handleServicesAndCharacteristicsReceved(serviesDict: [String : CBService], charDict: [String : CBCharacteristic]) {
        LogUtils.LogTrace(type: .startFunc)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    
    func centralManagerDidUpdateState() {
        LogUtils.LogTrace(type: .startFunc)
        if BLEManager.shared.isCentralManagerReady() {
            // ok
            didBluetoothOn()
        } else {
            // bluetooth is off
            didBluetoothOff()
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func didDiscover(peripheral: CBPeripheral) {
        if listDevices.count > 0 {
            var isNewPeripherial = true
            for (index, existedPeripherial) in listDevices.enumerated() {
                if existedPeripherial == peripheral { // this peripherial is already in the list
                    listDevices[index] = existedPeripherial
                    isNewPeripherial = false
                }
            }
            if isNewPeripherial {
                listDevices.append(peripheral)
            }
        } else { // list is empty
            listDevices.append(peripheral)
        }
        tableView.reloadData()
    }
    
    func didConnectStatusChange(status: CBPeripheralState) {
        if status == .connected {
//            self.indicatorOutlet.stopAnimating()
        }
    }
    
}

extension ScanVC: UITableViewDelegate, UITableViewDataSource {
    // MARK: - TableView Datasource:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foundDeviceCell", for: indexPath)
        let peripherial = self.listDevices[indexPath.row]
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
        
        let peripherial = self.listDevices[indexPath.row]
        self.startConnect(peripherial: peripherial)
        
    }
    
}
