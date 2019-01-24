//
//  Adapter.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol AdapterDelegate: NSObjectProtocol {
    func centralManagerDidUpdateState()
    func didDiscover(peripherial: CBPeripheral)
    func didConnect(peripherial: CBPeripheral)
    func didFailToConnect(peripherial: CBPeripheral)
    func didDisconnect(peripherial: CBPeripheral, error: Error?)
}

class Adapter: NSObject {
    weak var delegate: AdapterDelegate?
}

// MARK: - CentralManager Delegate :
extension Adapter: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        LogUtils.LogTrace(type: .startFunc)
        if (delegate != nil) {
            delegate?.centralManagerDidUpdateState()
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // didDiscover peripherial:
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == nil  {
            return
        } else {
            LogUtils.LogTrace(type: .startFunc)
            if delegate != nil {
                delegate?.didDiscover(peripherial: peripheral)
            }
            LogUtils.LogTrace(type: .endFunc)
        }
        
    }
    
    // didConnect to peripherial:
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        if delegate != nil {
            delegate?.didConnect(peripherial: peripheral)
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // didFailToConnect:
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        if delegate != nil {
            delegate?.didFailToConnect(peripherial: peripheral)
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // didDisconnect:
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        if delegate != nil {
            delegate?.didDisconnect(peripherial: peripheral, error: error)
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
}
// MARK: - Peripherial Delegate :
extension Adapter: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        BLEManager.shared.connector.didDiscoverServices(with: peripheral)
        LogUtils.LogTrace(type: .endFunc)
    }
    

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        BLEManager.shared.connector.didDiscoverCharacteristics(peripheral: peripheral, service: service)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    // update NotificationState for specific Characteristic (start or stop)
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    // Invoked when you retrieve a specified characteristic’s value, or when the peripheral device notifies your app that the characteristic’s value has changed.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
}
