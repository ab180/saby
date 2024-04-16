//
//  LogService.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import os

public protocol LogService {
    var setting: LoggerSetting { get }
    func log(level: LogLevel, _ message: String)
}

extension LogService {
    fileprivate func log(
        level: LogLevel, 
        _ message: String,
        _ printBlock: (String) -> Void
    ) {
        if setting.isPaginateLogEnabled, message.count > LoggerConstant.paginateSize {
            let logs = LoggerConstant.paginatedLog(message)
            let id = arc4random() % 1000000000
            
            logs.enumerated().forEach { (index, log) in
                printBlock(
                    "\(log)"
                    + "\nlog={page=\(index + 1)/\(logs.count), id=\(id)}"
                )
            }
            return
        }
        
        printBlock(message)
    }
}

public struct OSLogService: LogService {
    public let setting: LoggerSetting
    
    public func log(level: LogLevel, _ message: String) {
        log(level: level, message) {
            os_log("%{public}s", log: setting.osLog, type: level.osLogType, $0)
        }
    }
}

public struct PrintLogService: LogService {
    public let setting: LoggerSetting
    
    public func log(level: LogLevel, _ message: String) {
        let message = "[\(setting.subsystem)/\(setting.category)/\(level.name)] \(message)"
        log(level: level, message) {
            print($0)
        }
    }
}
