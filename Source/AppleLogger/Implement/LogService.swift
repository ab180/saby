//
//  LogService.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

public protocol LogService {
    func log(level: LogLevel, _ message: String)
}

public struct OSLogService: LogService {
    let osLog: OSLog
    
    public func log(level: LogLevel, _ message: String) {
        self.sendLog("%s", log: self.osLog, type: level.osLogType, message)
    }
    
    private func sendLog(_ message: StaticString, log: OSLog, type: OSLogType, _ args: CVarArg) {
        os_log(message, log: log, type: type, args)
    }

    init(_ osLog: OSLog) {
        self.osLog = osLog
    }
}

public struct PrintLogService: LogService {
    public func log(level: LogLevel, _ message: String) {
        print("[AirBridge : \(level.name)] \(message)")
    }
}
