//
//  LoggerSetting.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/09/30.
//

import OSLog

public struct LoggerSetting {
    /// A variable indicating logger's logging level. Set  to `.none` to not show logs.
    public var logLevel: LogLevel? = .debug
    
    /// A variable used for displaying `subsystem` value in console
    public let subsystem: String
    
    /// A variable used for displaying `category` value in console
    public let category: String
    
    /// An internal variable used to execute `os_log`
    var osLog: OSLog
    
    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
        
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
}