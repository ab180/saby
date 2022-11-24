//
//  PrintLogger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/23.
//

import Foundation

public final class PrintLogger: Logger {
    public let logService: PrintLogService
    public var loggerSetting: LoggerSetting
    
    public init(_ subsystem: String, category: String) {
        self.loggerSetting = LoggerSetting(subsystem: subsystem, category: category)
        self.logService = PrintLogService()
    }
    
    public init(setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = PrintLogService()
    }
}
