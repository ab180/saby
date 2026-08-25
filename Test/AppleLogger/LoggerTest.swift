//
//  LoggerTest.swift
//  SabyAppleLoggerTest
//
//  Created by WOF on 2022/08/24.
//

import Testing
import os
@testable import SabyAppleLogger

@Suite struct LoggerTest {
    @Test func setLogLevel() {
        let logger = mockLogger()
        #expect(logger.setting.logLevel != LogLevel.fault)
        
        logger.setLogLevel(to: .fault)
        #expect(logger.setting.logLevel == LogLevel.fault)
    }
    
    @Test func instantiateSetting() {
        let logger = mockLogger()
        let configBeforeChange = logger.setting

        var configAfterChange = defaultSetting
        configAfterChange.logLevel = .none

        #expect(configBeforeChange.logLevel != configAfterChange.logLevel)
    }

    @Test func shouldNotShowLowerLevelLogs() {
        let allLogLevels: [LogLevel] = [.debug, .info, .warning, .error, .fault]
        let numberOfLogLevels = allLogLevels.count

        for levelIndex in allLogLevels.indices {
            let level = allLogLevels[levelIndex]

            var setting = defaultSetting
            setting.logLevel = level

            let counter = LogCounter()
            let testLogger = mockLogger(counter: counter, setting: setting)
            // Only the logs higher than set level have to be executed.
            // In other words, output will be the logs excluding the logs below the given level.
            // Thus, the expected count of fulfilled log is set as below;
            // Total number of all log levels(numberOfLogLevels) - Current log level(levelIndex)
            // which can be said as the number of remaining log levels.
            testLogger.printAllLogs()
            
            #expect(counter.count == numberOfLogLevels - levelIndex)
        }
    }

    @Test func shouldNotShowAnyLogsWhenLevelIsNone() {
        var setting = defaultSetting
        setting.logLevel = .none

        let counter = LogCounter()
        let testLogger = mockLogger(counter: counter, setting: setting)
        testLogger.printAllLogs()
        #expect(counter.count == 0)
    }
}


// MARK: - Mock factories
fileprivate func mockLogger(counter: LogCounter? = nil,
                            setting: LoggerSetting = defaultSetting) -> MockLogger {
    return MockLogger(counter: counter, setting: setting)
}

fileprivate var defaultSetting: LoggerSetting {
    return LoggerSetting(subsystem: "", category: "")
}

// MARK: - Mocks for test
fileprivate class MockLogService: LogService {
    let setting = defaultSetting
    
    let counter: LogCounter?
    
    func log(level: SabyAppleLogger.LogLevel, _ message: String) {
        counter?.count += 1
    }
    
    init(counter: LogCounter?) {
        self.counter = counter
    }
}

fileprivate class MockLogger: SabyAppleLogger.LoggerType {
    var loggerSetting: SabyAppleLogger.LoggerSetting
    var logService: MockLogService
        
    init(counter: LogCounter?, setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = MockLogService(counter: counter)
    }
}

fileprivate final class LogCounter: @unchecked Sendable {
    var count = 0
}

extension MockLogger: SabyAppleLogger.Logger {
    public func setLogLevel(to level: LogLevel) {
        loggerSetting.logLevel = level
    }
    
    public func debug(_ message: String) {
        self.log(level: .debug, message)
    }
    
    public func info(_ message: String) {
        self.log(level: .info, message)
    }
    
    public func warning(_ message: String) {
        self.log(level: .warning, message)
    }
    
    public func error(_ message: String) {
        self.log(level: .error, message)
    }
    
    public func fault(_ message: String) {
        self.log(level: .fault, message)
    }
}

extension MockLogger {
    var setting: SabyAppleLogger.LoggerSetting {
        return self.loggerSetting
    }
        
    func printAllLogs() {
        self.fault("TEST: FAULT LOG")
        self.error("TEST: ERROR LOG")
        self.warning("TEST: WARNING LOG")
        self.info("TEST: INFO LOG")
        self.debug("TEST: DEFAULT LOG")
    }
}
