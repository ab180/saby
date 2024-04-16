//
//  OSLogger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/23.
//

import Foundation
import os

public final class OSLogger: LoggerType {
    var loggerSetting: LoggerSetting
    var logService: OSLogService
    
    public init(_ subsystem: String, category: String) {
        let setting = LoggerSetting(subsystem: subsystem, category: category)
        self.loggerSetting = setting
        self.logService = OSLogService(setting: setting)
    }
    
    public init(setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = OSLogService(setting: setting)
    }
}

extension OSLogger {
    public var setting: LoggerSetting {
        return self.loggerSetting
    }
}

extension OSLogger: Logger {    
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
