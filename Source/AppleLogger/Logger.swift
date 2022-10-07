//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

@available(iOS 10.0, *)
public final class Logger {
    /// The shared singleton logger object
    ///
    /// - Warning: `shared` logger has empty subsystem or category value.
    public static let shared = Logger()
    
    var loggerSetting: Logger.Setting
    var logService: LogService = OSLogService()
    
    public init() {
        self.loggerSetting = Setting.default
    }
    
    public init(_ subsystem: String, category: String) {
        self.loggerSetting = Setting(subsystem: subsystem, category: category)
    }
    
    public init(configuration: Setting) {
        self.loggerSetting = configuration
    }
}


