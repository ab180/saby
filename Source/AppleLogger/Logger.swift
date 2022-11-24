//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

public protocol Logger: AnyObject {
    associatedtype T: LogService
    
    /// Implement the way you'd like to show logs according to the protocol `LogService`
    ///
    /// For example, you can use `print` or `osLog`
    var logService: T { get }
    var loggerSetting: LoggerSetting { get set }
    
//    func log(level: LogLevel, _ message: String)
    func setLogLevel(to level: LogLevel)
    
    /// You can use each method to show logs
    func info(_ message: String)
    func debug(_ message: String)
    func error(_ message: String)
    func fault(_ message: String)
}

extension Logger {
    private func log(level: LogLevel, _ message: String) {
        guard let loggerLevel = setting.logLevel else {
            return
        }
        
        if level.isLoggable(with: loggerLevel) {
            logService.log(level: level, message)
        }
    }
}

extension Logger {
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
