//
//  LoggerExtension.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

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
    public var setting: Setting {
        return loggerSetting
    }
}

extension Logger {
    /// Sets the instance's logging level to the given value
    public func setLogLevel(to level: LogLevel) {
        loggerSetting.logLevel = level
    }
}
