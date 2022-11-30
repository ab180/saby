//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/11/30.
//

import Foundation

protocol LoggerType: AnyObject {
    associatedtype T: LogService
    
    /// Implement the way you'd like to show logs according to the protocol `LogService`
    ///
    /// For example, you can use `print` or `osLog`
    var logService: T { get set }
    var loggerSetting: LoggerSetting { get set }
    
    
    func log(level: LogLevel, _ message: String)
}

extension LoggerType {
    func log(level: LogLevel, _ message: String) {
        guard let loggerLevel = loggerSetting.logLevel else {
            return
        }
        
        if level.isLoggable(with: loggerLevel) {
            logService.log(level: level, message)
        }
    }
}
