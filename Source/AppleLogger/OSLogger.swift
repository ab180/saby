//
//  OSLogger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/23.
//

import Foundation
import OSLog

public final class OSLogger: Logger {
    public var loggerSetting: LoggerSetting
    public var logService: OSLogService
    
    public init(_ subsystem: String, category: String) {
        let setting = LoggerSetting(subsystem: subsystem, category: category)
        self.loggerSetting = setting
        self.logService = OSLogService(setting.osLog)
    }
    
    public init(setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = OSLogService(setting.osLog)
    }
}



