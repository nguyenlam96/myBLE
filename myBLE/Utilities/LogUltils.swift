//
//  LogUltils.swift
//  myBLE
//
//  Created by Nguyen Lam on 1/23/19.
//  Copyright © 2019 Nguyen Lam. All rights reserved.
//

import Foundation

let debug = true

enum LogTraceType: Int {
    case startFunc = 0
    case endFunc = 1
}

enum LogDebugType: Int {
    case info = 0
    case warning = 1
    case error = 2
}

class LogUtils: NSObject {
    
    static func LogTrace(type: LogTraceType, file: String = #file, function: String = #function, line: Int = #line) {
        var message = ""
        switch type {
        case .startFunc:
            message = "Start Func"
        case .endFunc:
            message = "End Func"
        }
        if debug {
            let className = file.components(separatedBy: "/").last
            print("\(className ?? ""), \(function), \(line) - \(message)")
        }
    }
    
    static func LogDebug(type: LogDebugType, message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        
        var privateMessage = message
        
        switch type {
        case .info:
            privateMessage = "Info: \(message)"
        case .warning:
            privateMessage = "Warning: \(message)"
        case .error:
            privateMessage = "Error: \(message)"
        }
        
        if debug {
            let className = file.components(separatedBy: "/").last
            print("\(className ?? ""), \(function), \(line), - \(privateMessage)")
        }
    }
}
