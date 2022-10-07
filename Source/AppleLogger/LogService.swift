//
//  LogService.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

protocol LogService {
    func log(_ message: StaticString, log: OSLog?, type: OSLogType, _ args: CVarArg)
    func printLog(type: LogLevel, _ message: String)
}

struct OSLogService: LogService {
    public func log(_ message: StaticString, log: OSLog?, type: OSLogType, _ args: CVarArg) {
        if let osLog = log {
            os_log(message, log: osLog, type: type, args)
        } else {
            if #available(iOS 12.0, *) {
                os_log(type, message, args)
            } else {
                // Return empty subsystem and category when OSLog is `nil`
                let emptyOSLog = OSLog(subsystem: "", category: "")
                os_log(message, log: emptyOSLog, type: type, args)
            }
        }
    }
    
    public func printLog(type: LogLevel, _ message: String) {
        print("[AirBridge : \(type.name)] \(message)")
    }
}
