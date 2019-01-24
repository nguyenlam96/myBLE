//
//  Scanner.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation
import CoreBluetooth

class Scanner {
    // MARK: - Properties:

    // MARK: - Scann funcs :
    func startScan(services: [CBUUID]? ) -> Bool {
        LogUtils.LogTrace(type: .startFunc)
        // ensure central is ready:
        guard BLEManager.shared.isCentralManagerReady() else {
            LogUtils.LogDebug(type: .warning, message: "Central is not ready")
            LogUtils.LogTrace(type: .endFunc)
            return false
        }

        // everything is ok, do scan:
        let scanOptions = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        BLEManager.shared.centralManager?.scanForPeripherals(withServices: nil, options: scanOptions) // scan all peripherial
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
    func stopScan() -> Bool {
        LogUtils.LogTrace(type: .startFunc)

        BLEManager.shared.centralManager?.stopScan()
        LogUtils.LogTrace(type: .endFunc)
        return true
    }
    
}
