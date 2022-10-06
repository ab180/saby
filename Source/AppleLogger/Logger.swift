//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

@available(iOS 10.0, *)
public final class Logger {
    /// The shared singleton logger object
    public static let shared = Logger(configuration: LoggerConfiguration.default)
    
    var loggerConfiguration: LoggerConfiguration
    var logService: LogService = OSLogService()
    
    /// A copy of configuration object of this logger
    public var configuration: LoggerConfiguration {
        return loggerConfiguration
    }
    
    /// Configures the instance with given configuration
    public func configure(with configuration: LoggerConfiguration) {
        loggerConfiguration = configuration
    }
    
    /// Sets the instance's logging level to the given value
    public func setLogLevel(to level: LogLevel) {
        loggerConfiguration.logLevel = level
    }
    
    /// Displays a log for specified level
    func log(level: LogLevel, _ message: String) {
        guard let loggerLevel = configuration.logLevel else {
            return
        }
        
        if level.isHigherOrEqual(to: loggerLevel) {
            if configuration.usePrint {
                logService.printLog(type: level, message)
            } else {
                logService.log("%s", log: level.osLog, type: level.osLogType, message)
            }
        }
    }
    
    public init(configuration: LoggerConfiguration = LoggerConfiguration.default) {
        self.loggerConfiguration = configuration
    }
}
