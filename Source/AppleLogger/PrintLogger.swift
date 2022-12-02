//
//  PrintLogger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/23.
//

import Foundation

public final class PrintLogger: LoggerType {
    var logService: PrintLogService
    var loggerSetting: LoggerSetting
    
    public init(_ subsystem: String, category: String) {
        self.loggerSetting = LoggerSetting(subsystem: subsystem, category: category)
        self.logService = PrintLogService()
    }
    
    public init(setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = PrintLogService()
    }
}

extension PrintLogger {
    public var setting: LoggerSetting {
        return self.loggerSetting
    }
}

extension PrintLogger: Logger {
    public func setLogLevel(to level: LogLevel) {
        loggerSetting.logLevel = level
    }
    
    public func debug(_ message: String) {
        self.log(level: .debug, message)
    }
    
    public func info(_ message: String) {
        self.log(level: .info, message)
    }
    
    public func warning(_ message: String) {
        self.log(level: .warning, message)
    }
    
    public func error(_ message: String) {
        self.log(level: .error, message)
    }
    
    public func fault(_ message: String) {
        self.log(level: .fault, message)
    }
}
