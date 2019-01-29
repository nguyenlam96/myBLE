//
//  BLEPeripheralManager.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/26/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth
import NotificationCenter

let messagerServiceUUID = CBUUID(string: "4F84FA41-4170-4CA4-9F86-57A0F0936879")
let messageContentCharacteristicUUID = CBUUID(string: "83930ED9-F3EF-4863-B105-CEC5927990C3")

class PeriperalManager: NSObject {
    
    // MARK: - Properties:
    static let shared = PeriperalManager()
    var peripheralManager: CBPeripheralManager?
//    let myService = genService()
    var messageContentCharacteristic: CBMutableCharacteristic?
    var messagerService: CBMutableService?
    
    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        messagerService = CBMutableService(type: CBUUID(string: messengerService.serviceUUID.rawValue), primary: true)
        messageContentCharacteristic = CBMutableCharacteristic(type: CBUUID(string: messengerService.contentCharacteristicUUID.rawValue), properties: .read, value: nil, permissions: CBAttributePermissions.writeable)
        messagerService?.characteristics = [messageContentCharacteristic] as! [CBCharacteristic]
        
        peripheralManager?.add(messagerService!)
        
    }
    
    
    // MARK: - PeripheralManager funcs:
    func isPeripheralManagerReady() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        // ensure that bluetooth power is on:
        guard peripheralManager?.state == .poweredOn else {
            LogUtils.LogDebug(type: .error, message: "Bluetooth isn't poweredOn")
            LogUtils.LogTrace(type: .endFunc)
            return false
        }
        
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
    func publishService(service: CBMutableService) {
        LogUtils.LogTrace(type: .startFunc)
        self.peripheralManager?.add(service) // When you add a service to the database, the peripheral manager calls the peripheralManager(_:didAdd:error:) method of its delegate object
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func startAdvertise() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        guard self.peripheralManager?.isAdvertising == false else {
            LogUtils.LogDebug(type: .error, message: "already advertising")
            LogUtils.LogTrace(type: .endFunc)
            return false
        }
        
        self.peripheralManager?.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [messagerService!.uuid] ])
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
    func stopAdvertise() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        self.peripheralManager?.stopAdvertising()
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
    // MARK: - Helper Functions:
    
    
}

// MARK: - PeripheralManager Delegate :
extension PeriperalManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        LogUtils.LogTrace(type: .startFunc)
        
        if peripheral.state != .poweredOn {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.bluetoothIsOff.rawValue), object: nil)
        }
        
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        // ensure there's no error
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        // add success
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        LogUtils.LogTrace(type: .startFunc)
        guard error == nil else {
            LogUtils.LogDebug(type: .error, message: error!.localizedDescription)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        // did start advertising
        LogUtils.LogTrace(type: .startFunc)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        LogUtils.LogTrace(type: .startFunc)
        // ensure characteristic is matched
        guard (request.characteristic.uuid == messageContentCharacteristicUUID) else {
            LogUtils.LogDebug(type: .error, message: "Characteristic UUID doesn't match")
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        // ensure index is validate
        if request.offset > messageContentCharacteristic!.value!.count { // invalid
            LogUtils.LogDebug(type: .error, message: "invalid offset for messageContentCharacteristic")
            peripheralManager?.respond(to: request, withResult: CBATTError.Code.invalidOffset)
            LogUtils.LogTrace(type: .endFunc)
            return
        }

        // if everything's ok, assign value of characteristic for value of request
        let range = Range( NSRange(location: request.offset, length: messageContentCharacteristic!.value!.count - request.offset) )
        request.value = messageContentCharacteristic!.value!.subdata(in: range!)
        // respond to central:
        peripheralManager?.respond(to: request, withResult: CBATTError.Code.success)
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        LogUtils.LogTrace(type: .startFunc)
        // ensure characteristic is matched
        var writeMessageRequest: CBATTRequest?
        for request in requests {
            if request.characteristic.uuid == messageContentCharacteristicUUID {
                writeMessageRequest = request
                break
            }
        }
        
        guard writeMessageRequest != nil else {
            LogUtils.LogDebug(type: .error, message: "Can't find request match characteristicUUID")
            return
        }
        // ensure index is validate
        if writeMessageRequest!.offset > messageContentCharacteristic!.value!.count { // invalid
            LogUtils.LogDebug(type: .error, message: "invalid offset for messageContentCharacteristic")
            peripheralManager?.respond(to: writeMessageRequest!, withResult: CBATTError.Code.invalidOffset)
            LogUtils.LogTrace(type: .endFunc)
            return
        }
        // write:
        messageContentCharacteristic!.value = writeMessageRequest!.value
        // respond to central:
        peripheralManager?.respond(to: writeMessageRequest!, withResult: CBATTError.Code.success)
        let message = String(data: writeMessageRequest!.value!, encoding: String.Encoding.utf8)
        if message == nil {
            LogUtils.LogDebug(type: .warning, message: "message is nil")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.receiveMessage.rawValue), object: nil, userInfo: ["message": message ?? "hello"])
//        peripheralManager?.respond(to: requests.first!, withResult: CBATTError.Code.success)
        LogUtils.LogTrace(type: .endFunc)
        
    }
//
//    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
//        LogUtils.LogTrace(type: .startFunc)
//        LogUtils.LogDebug(type: .info, message: "Central subscribed to \(characteristic)")
//
//        let updatedValue = messageContentCharacteristic.value!
//        let didSentValue = peripheralManager?.updateValue(updatedValue, for: messageContentCharacteristic, onSubscribedCentrals: nil)
//        LogUtils.LogTrace(type: .endFunc)
//    }
//
//    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
//        LogUtils.LogTrace(type: .startFunc)
//        // re-sent characteristic value
//        let updatedValue = messageContentCharacteristic.value!
//        _ = peripheralManager?.updateValue(updatedValue, for: messageContentCharacteristic, onSubscribedCentrals: nil)
//        LogUtils.LogTrace(type: .endFunc)
//    }
//
    
}


