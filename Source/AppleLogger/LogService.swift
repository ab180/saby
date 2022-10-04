//
//  File.swift
//  
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

protocol LogService {
    func log(_ message: StaticString, log: OSLog, type: OSLogType, _ args: CVarArg)
    func printLog(type: LogLevel, _ message: String)
}

struct OSLogService: LogService {
    public func log(_ message: StaticString, log: OSLog, type: OSLogType, _ args: CVarArg) {
        os_log(message, log: log, type: type, args)
    }
    
    public func printLog(type: LogLevel, _ message: String) {
        print("[AirBridge : \(type.name)] \(message)")
    }
}
