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
    public static let shared = Logger(configuration: LoggerConfiguration.default)
    
    var loggerConfiguration: LoggerConfiguration
    var logService: LogService = OSLogService()
    
    public init(configuration: LoggerConfiguration = LoggerConfiguration.default) {
        self.loggerConfiguration = configuration
    }
}


