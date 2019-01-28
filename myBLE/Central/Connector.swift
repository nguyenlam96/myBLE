//
//  Connector.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ConnectorDelegate: NSObjectProtocol {
    
}

class Connector: NSObject {
    
    // MARK: - Properties:
    weak var delegate: ConnectorDelegate?
    var arrayOfDiscoveredServices: [CBService] = []
    
    var servicesDictionary: [String:CBService] = [:]
    var characteristicDictionary: [String: CBCharacteristic] = [:]
    
    // MARK: - Connect funcs :
    func startConnect(to peripherial: CBPeripheral, options: [String:Any]? ) -> Bool { // options is nil
        LogUtils.LogTrace(type: .startFunc)
        
        guard peripherial.state == .disconnected else {
            LogUtils.LogDebug(type: .info, message: "Device is not on disconnected state")
            return false
        }
        CentralManager.shared.centralManager?.connect(peripherial, options: options)
        return true
    }
    
    func disconnect() -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        // ensure device is connected or connecting
        let connectStatus = CentralManager.shared.connectedPeripherial?.state
        guard connectStatus == .connected else {
            LogUtils.LogDebug(type: .warning, message: "Device is not connected state")
            return false
        }
        _ = CentralManager.shared.centralManager?.cancelPeripheralConnection(CentralManager.shared.connectedPeripherial!)
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
}
extension Connector {
    // MARK: - Discover Service and Characteristic :
    
    func didDiscoverServices(with peripherial: CBPeripheral) {
        LogUtils.LogTrace(type: .startFunc)
        // ensure that peripherial have services
        if let discoveredServices = peripherial.services, discoveredServices.count > 0 {
            self.arrayOfDiscoveredServices = discoveredServices
            // start discover characteristic:
            CentralManager.shared.connectedPeripherial?.discoverCharacteristics(nil, for: discoveredServices.first!) // characteristicUUID = nil
            
        } else {
            LogUtils.LogDebug(type: .error, message: "Peripherial doens't have services")
        }
        LogUtils.LogTrace(type: .endFunc)
    }
    
    func didDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService) {
        LogUtils.LogTrace(type: .startFunc)
        
        arrayOfDiscoveredServices.removeFirst()
        if arrayOfDiscoveredServices.count > 0 {
            // keep discover next services
            LogUtils.LogDebug(type: .info, message: "Discovering characteristic for the next services")
            CentralManager.shared.connectedPeripherial?.discoverCharacteristics(nil, for: arrayOfDiscoveredServices.first!)
        } else {
            // save service and characteristic to list
            self.handleDiscoverServices(services: peripheral.services)
        }
    }
    
    func handleDiscoverServices(services: [CBService]?) {
        LogUtils.LogTrace(type: .startFunc)
        // ensure services is not empty
        guard let services = services, services.count > 0 else {
            LogUtils.LogDebug(type: .error, message: "No services to handle")
            return
        }
        for service in services {
            // save services:
            self.servicesDictionary[service.uuid.uuidString.lowercased()] = service
            // ensure characteristic is not empty
            guard let characteristics = service.characteristics, characteristics.count > 0 else {
                LogUtils.LogDebug(type: .error, message: "Characteristic is nill or empty")
                LogUtils.LogTrace(type: .endFunc)
                return
            }
            for characteristic in characteristics {
                // save characteristic:
                self.characteristicDictionary[characteristic.uuid.uuidString.lowercased()] = characteristic
            }
            
        }

        LogUtils.LogTrace(type: .endFunc)
    }
    
    
}
