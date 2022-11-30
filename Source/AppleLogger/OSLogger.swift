//
//  OSLogger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/23.
//

import Foundation
import OSLog

public final class OSLogger: LoggerType {
    var loggerSetting: LoggerSetting
    var logService: OSLogService
    
    public init(_ subsystem: String, category: String) {
        let setting = LoggerSetting(subsystem: subsystem, category: category)
        self.loggerSetting = setting
        self.logService = OSLogService(setting.osLog)
    }
    
    public init(setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = OSLogService(setting.osLog)
    }
}

extension OSLogger: Logger {
    public var setting: LoggerSetting {
        return loggerSetting
    }
    
    public func setLogLevel(to level: LogLevel) {
        loggerSetting.logLevel = level
    }
    
    public func info(_ message: String) {
        self.log(level: .info, message)
    }
    
    public func debug(_ message: String) {
        self.log(level: .debug, message)
    }
    
    public func error(_ message: String) {
        self.log(level: .error, message)
    }
    
    public func fault(_ message: String) {
        self.log(level: .fault, message)
    }
}
