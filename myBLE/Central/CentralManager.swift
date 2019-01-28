//
//  BLEManager.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc protocol CentralManagerDelegate : NSObjectProtocol {
    
    @objc optional func centralManagerDidUpdateState()
    @objc optional func didDiscover(peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    @objc optional func didConnect(peripheral: CBPeripheral)
    @objc optional func didDisconnect(peripheral: CBPeripheral, error: Error?)
    @objc optional func didFailToConnect(peripheral: CBPeripheral, error: Error?)

    @objc optional func didDiscoverServices(peripheral: CBPeripheral)
    @objc optional func didDiscoverCharacteristicsFor(peripheral: CBPeripheral, service: CBService)
    @objc optional func didWriteValueFor(characteristic: CBCharacteristic, error: Error?)
    
}

class CentralManager: NSObject {
    
    static let shared = CentralManager()
    weak var delegate: CentralManagerDelegate?

    let scanner = Scanner()
    let connector = Connector()
    var centralManager: CBCentralManager?
    var connectedPeripherial: CBPeripheral?
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager?.delegate = self
        connectedPeripherial?.delegate = self

    }

    // MARK: - Manager Funcs :
    func isCentralManagerReady() -> Bool {
        // ensure that bluetooth power is on:
        guard centralManager?.state == .poweredOn else {
            LogUtils.LogDebug(type: .error, message: "Bluetooth isn't poweredOn")
            return false
        }
        return true
    }
    
    func startScan(with services: [CBUUID]?) -> Bool {
        // ensure central is ready:
        guard CentralManager.shared.isCentralManagerReady() else {
            LogUtils.LogDebug(type: .warning, message: "CentralManager is not ready")
            return false
        }
        // everything is ok, do scan:
        let scanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        self.centralManager?.scanForPeripherals(withServices: nil, options: scanOptions) // scan all peripherial
        return true
    }
    
    func stopScan() -> Bool {
        self.centralManager?.stopScan()
        return true
    }

    func startConnect(to peripherial: CBPeripheral, options: [String:Any]? ) -> Bool {
        // ensure current state is disconnect
        guard peripherial.state == .disconnected else {
            LogUtils.LogDebug(type: .info, message: "Device is not on disconnected state")
            return false
        }
        CentralManager.shared.centralManager?.connect(peripherial, options: options)
        return true
    }
    
    func disconnect(to peripheral: CBPeripheral) -> Bool {
        // ensure device is connected or connecting
        let connectStatus = CentralManager.shared.connectedPeripherial?.state
        guard connectStatus == .connected else {
            LogUtils.LogDebug(type: .warning, message: "Device is not connected state")
            return false
        }
        _ = CentralManager.shared.centralManager?.cancelPeripheralConnection(CentralManager.shared.connectedPeripherial!)
        return true
    }
    
    func writeValue(value: String?) -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        
        guard let value = value else {
            LogUtils.LogDebug(type: .error, message: "value is nil")
            LogUtils.LogTrace(type: .endFunc)
            return false
        }

        let data = value.data(using: String.Encoding.utf8)

        if let services = connectedPeripherial?.services {
            for service in services {
                if service.uuid == messagerServiceUUID {
                    for characteristic in service.characteristics! {
                        if characteristic.uuid == messageContentCharacteristicUUID {
                            // write value:
                            self.connectedPeripherial?.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                            return true
                        } else {
                            LogUtils.LogDebug(type: .error, message: "can't find messageContentCharacteristicUUID")
                        }
                    }
                } else {
                    LogUtils.LogDebug(type: .error, message: "can't find messagerServiceUUID")
                }
            }
        } else {
            LogUtils.LogDebug(type: .error, message: "can't find services in connectedPeripheral")
        }
        
        return false
    }

}

// MARK: - CentralManagerDelegate :
extension CentralManager: CBCentralManagerDelegate {
    
    // Invoked when the central manager’s state is updated.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        LogUtils.LogTrace(type: .startFunc)
        if (delegate != nil) && ((delegate?.responds(to: #selector(CentralManagerDelegate.centralManagerDidUpdateState)))!) {
            delegate?.centralManagerDidUpdateState!()
        }
        LogUtils.LogTrace(type: .endFunc)
        
    }
    
    // Invoked when the central manager discovers a peripheral while scanning.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        LogUtils.LogTrace(type: .startFunc)
        // ensure peripherial have name
        if (peripheral.name == nil ) {
            return
        }

        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !((delegate?.responds(to: #selector(CentralManagerDelegate.didDiscover(peripheral:advertisementData:rssi:)) ))! ) {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            delegate?.didDiscover!(peripheral: peripheral, advertisementData: advertisementData, rssi: RSSI)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
    }
    
    
    // Invoked when a connection is successfully created with a peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        LogUtils.LogTrace(type: .startFunc)

        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !( (delegate?.responds(to: #selector(CentralManagerDelegate.didConnect(peripheral:))))! )  {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            delegate?.didConnect!(peripheral: peripheral)
            LogUtils.LogTrace(type: .endFunc)
            return
        }

    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            return
        }
        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !( (delegate?.responds(to: #selector(CentralManagerDelegate.didDisconnect(peripheral:error:)) ))! )  {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            
            delegate?.didDisconnect!(peripheral: peripheral, error: error)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
    }
    
}
    

// MARK: - Peripheral Delegate :
extension CentralManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            return
        }
        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !((delegate?.responds(to: #selector(CentralManagerDelegate.didDiscoverServices(peripheral:))))!)  {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            delegate?.didDiscoverServices!(peripheral: peripheral)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            return
        }
        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !((delegate?.responds(to: #selector(CentralManagerDelegate.didDiscoverCharacteristicsFor(peripheral:service:))))!)  {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            delegate?.didDiscoverCharacteristicsFor!(peripheral: peripheral, service: service)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
//        guard error == nil else {
//            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
//            return
//        }
        if error != nil {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
        }
        if (delegate == nil) {
            LogUtils.LogDebug(type: .error, message: "Delegate is nil")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else if !((delegate?.responds(to: #selector(CentralManagerDelegate.didWriteValueFor(characteristic:error:))))!)  {
            LogUtils.LogDebug(type: .error, message: "Delegate is not response")
            LogUtils.LogTrace(type: .endFunc)
            return
        } else {
            delegate?.didWriteValueFor!(characteristic: characteristic, error: error)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        
    }
    
    
    
}


