//
//  Logger.swift
//  SabyAppleLogger
//
//  Created by WOF on 2022/08/22.
//

import Foundation
import OSLog

public protocol Logger {
    /// You can use each method to show logs
    func debug(_ message: String)
    func info(_ message: String)
    func warning(_ message: String)
    func error(_ message: String)
    func fault(_ message: String)
}
