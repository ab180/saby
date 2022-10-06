//
//  LoggerExtension.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

extension Logger {
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
}

extension Logger {
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

extension Logger {
    /// A copy of configuration object of this logger
    public var configuration: LoggerConfiguration {
        return loggerConfiguration
    }
}

extension Logger {
    /// Configures the instance with given configuration
    public func configure(with configuration: LoggerConfiguration) {
        loggerConfiguration = configuration
    }
    
    /// Sets the instance's logging level to the given value
    public func setLogLevel(to level: LogLevel) {
        loggerConfiguration.logLevel = level
    }
}
