//
//  LoggerConfiguration.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import Foundation

public struct LoggerConfiguration {
    /// A default logger configuration object
    public static var `default`: LoggerConfiguration {
        LoggerConfiguration()
    }
    
    /// A variable indicating logger's logging level. Set  to `.none` to not show logs.
    public var logLevel: LogLevel? = .debug
    
    /// Use `print` to show logs  instead of `OS_log` when set to `true`
    public var usePrint: Bool = false
    
    public var subSystem: String = Bundle.main.bundleIdentifier ?? "SabyAppleLogger"
    
    public init() {}
    
    public init(subSystem: String) {
        self.subSystem = subSystem
    }
}
