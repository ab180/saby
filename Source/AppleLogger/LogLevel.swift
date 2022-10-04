//
//  File.swift
//  
//
//  Created by 이영빈 on 2022/10/04.
//

import OSLog

/// The various log levels that the `SabyApplerLogger` provides
///
/// It basically follows Apple's unified logging system.
/// `default` is the lowest level while `fault` is the highest.
public enum LogLevel: Comparable, CaseIterable {
    /// debug
    case debug
    case info
    case error
    case fault
    
    var name: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .error:
            return "ERROR"
        case .fault:
            return "FAULT"
        }
    }
    
    func isHigherOrEqual(to level: LogLevel) -> Bool {
        return self >= level
    }
}

