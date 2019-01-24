//
//  BLEManager.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol BLEManagerDelegate : NSObjectProtocol {
    
    @objc optional func centralManagerDidUpdateState()
    @objc optional func didDiscover(peripheral: CBPeripheral)
    @objc optional func didDisconnect(peripherial: CBPeripheral, error: Error?)
    @objc optional func didFailToConnect(peripherial: CBPeripheral, error: Error?)
    
    func handleServicesAndCharacteristicsReceved(serviesDict: [String : CBService], charDict: [String : CBCharacteristic])
    
}

class BLEManager: NSObject {
    
    static let shared = BLEManager()
    weak var delegate: BLEManagerDelegate?


    let scanner = Scanner()
    let connector = Connector()
    let adapter = Adapter()
    var centralManager: CBCentralManager?
    var connectedPeripherial: CBPeripheral?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: adapter, queue: nil) // after initialize centerManager, it will automatically call centralManagerDidUpdateState from its delegate (here is adapter)
        adapter.delegate = self
        connector.delegate = self
    }

}
// MARK: - BLEManager funcs :
extension BLEManager {
    
    // Check state of central:
    func isCentralManagerReady() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        // ensure that bluetooth power is on:
        guard self.centralManager?.state == .poweredOn else {
            LogUtils.LogDebug(type: .error, message: "Bluetooth power isn't ON")
            LogUtils.LogTrace(type: .endFunc)
            return false
        }
        // everything is ok:
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
    func startScan() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        let result = scanner.startScan(services: nil)
        LogUtils.LogTrace(type: .endFunc)
        return result
    }
    
    func stopScan() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        let result = scanner.stopScan()
        LogUtils.LogTrace(type: .endFunc)
        return result
    }
    
    func startConnect(to peripherial: CBPeripheral, options: [String:Any]? ) -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        let result = connector.startConnect(to: peripherial, options: options)
        LogUtils.LogTrace(type: .endFunc)
        return result
    }
    
}

// MARK: - AdapterDelegate :
extension BLEManager: AdapterDelegate {
    
    func centralManagerDidUpdateState() {
        
        LogUtils.LogTrace(type: .startFunc)
        if (delegate != nil) && ( delegate?.responds(to: #selector(BLEManagerDelegate.centralManagerDidUpdateState)) )! {
            delegate?.centralManagerDidUpdateState!()
            LogUtils.LogTrace(type: .endFunc)
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func didDiscover(peripherial: CBPeripheral) {
        if (delegate != nil) && ((delegate?.responds(to: #selector(BLEManagerDelegate.didDiscover(peripheral:))))!) {
            delegate?.didDiscover!(peripheral: peripherial)
        }
    }
    
    func didConnect(peripherial: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        self.connectedPeripherial = peripherial
        self.connectedPeripherial?.delegate = adapter
        self.connectedPeripherial?.discoverServices(nil)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func didFailToConnect(peripherial: CBPeripheral) {
        
    }
    
    func didDisconnect(peripherial: CBPeripheral, error: Error?) {
        
    }

}

// MARK: - ConnectorDelegate :
extension BLEManager: ConnectorDelegate {
    @objc func handleServicesAndCharacteristicsReceved(serviesDict: [String : CBService], charDict: [String : CBCharacteristic]) {
        LogUtils.LogTrace(type: .startFunc)

        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
        } else if !((delegate?.responds(to: #selector(BLEManagerDelegate.handleServicesAndCharacteristicsReceved(serviesDict:charDict:))))!) {
            LogUtils.LogDebug(type: .error, message: "Delegate not response to method")
            
        } else {
            delegate?.handleServicesAndCharacteristicsReceved(serviesDict: serviesDict, charDict: charDict)
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    
}
