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
    
    /// A variable indicating logger paginate log or not. Because of `os_log`'s 1024 length limit.
    public var isPaginateLogEnabled: Bool
    
    /// A variable used for displaying `subsystem` value in console
    public let subsystem: String
    
    /// A variable used for displaying `category` value in console
    public let category: String
    
    /// An internal variable used to execute `os_log`
    let osLog: OSLog
    
    public init(
        subsystem: String,
        category: String,
        isPaginateLogEnabled: Bool = false
    ) {
        self.subsystem = subsystem
        self.category = category
        self.isPaginateLogEnabled = isPaginateLogEnabled
        
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
}
