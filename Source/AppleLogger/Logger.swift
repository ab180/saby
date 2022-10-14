//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

public final class Logger {
    var loggerSetting: Logger.Setting
    var logService: LogService = OSLogService()
    
    public init(_ subsystem: String, category: String) {
        self.loggerSetting = Setting(subsystem: subsystem, category: category)
    }
    
    public init(setting: Setting) {
        self.loggerSetting = setting
    }
    
    /// Displays a log for specified level
    func log(level: LogLevel, _ message: String) {
        guard let loggerLevel = setting.logLevel else {
            return
        }
        
        if level.isHigherOrEqual(to: loggerLevel) {
            if setting.usePrint {
                logService.printLog(type: level, message)
            } else {
                logService.log("%s", log: setting.osLog, type: level.osLogType, message)
            }
        }
    }
}


