//
//  LogLevel.swift
//  SabyAppleLogger
//
//  Created by 이영빈 on 2022/10/04.
//

import OSLog

/// The various log levels that the `SabyApplerLogger` provides
///
/// It basically follows Apple's unified logging system.
/// `default` is the lowest level while `fault` is the highest.
public enum LogLevel: Comparable, CaseIterable {
    case debug
    case info
    case warning
    case error
    case fault
    
    var name: String {
        switch self {
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .fault:
            return "FAULT"
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .default
        case .info:
            return .info
        case .warning:
            return .info
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
    
    func isLoggable(with loggerLevel: LogLevel?) -> Bool {
        guard let loggerLevel = loggerLevel else {
            return false
        }
        
        if self.isHigherOrEqual(to: loggerLevel) {
            return true
        } else {
            return false
        }
    }
    
    private func isHigherOrEqual(to level: LogLevel) -> Bool {
        return self >= level
    }
}

