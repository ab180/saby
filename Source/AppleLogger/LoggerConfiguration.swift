//
//  File.swift
//  
//
//  Created by 이영빈 on 2022/09/30.
//

import Foundation

public struct LoggerConfiguration {
    /// A default logger configuration object
    public static var `default`: LoggerConfiguration {
        LoggerConfiguration(logLevel: .debug, usePrint: false)
    }
    
    /// A variable indicating logger's logging level. Set  to `.none` to not show logs.
    public var logLevel: LogLevel?
    
    /// Use `print` to show logs  instead of `OS_log` when set to `true`
    public var usePrint: Bool
    
    init(logLevel: LogLevel?, usePrint: Bool) {
        self.logLevel = logLevel
        self.usePrint = usePrint
    }
}
