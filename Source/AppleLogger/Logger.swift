//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

public protocol Logger {
    var setting: LoggerSetting { get }
    func setLogLevel(to level: LogLevel)
    
    /// You can use each method to show logs
    func info(_ message: String)
    func debug(_ message: String)
    func error(_ message: String)
    func fault(_ message: String)
}
