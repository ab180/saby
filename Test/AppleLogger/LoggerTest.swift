//
//  LoggerTest.swift
//  SabyAppleLoggerTest
//
//  Created by WOF on 2022/08/24.
//

import XCTest
import OSLog
@testable import SabyAppleLogger

final class LoggerTest: XCTestCase {
    func test__set_log_level() {
        let logger = mockLogger()
        XCTAssertNotEqual(logger.setting.logLevel, LogLevel.fault)
        
        logger.setLogLevel(to: .fault)
        XCTAssertEqual(logger.setting.logLevel, LogLevel.fault)
    }
    
    func test__instantiate_setting() {
        let logger = mockLogger()
        let configBeforeChange = logger.setting

        var configAfterChange = defaultSetting
        configAfterChange.logLevel = .none

        XCTAssertNotNil(configBeforeChange.osLog)
        XCTAssertNotNil(configAfterChange.osLog)
        XCTAssertNotEqual(configBeforeChange.logLevel, configAfterChange.logLevel)
    }

    func test__should_not_show_lower_level_logs() {
        let allLogLevels = LogLevel.allCases
        let numberOfLogLevels = allLogLevels.count

        for levelIndex in allLogLevels.indices {
            let level = allLogLevels[levelIndex]

            var setting = defaultSetting
            setting.logLevel = level

            let expectation = XCTestExpectation(description: "Shouldn't show lower level logs")
            expectation.expectedFulfillmentCount = numberOfLogLevels - levelIndex
            expectation.assertForOverFulfill = true

            let testLogger = mockLogger(expectation: expectation, setting: setting) as! MockLogger
            // Only the logs higher than set level have to be executed.
            // In other words, output will be the logs excluding the logs below the given level.
            // Thus, the expected count of fulfilled log is set as below;
            // Total number of all log levels(numberOfLogLevels) - Current log level(levelIndex)
            // which can be said as the number of remaining log levels.
            testLogger.printAllLogs()
            
            wait(for: [expectation], timeout: 0.5)
        }
    }

    func test__should_not_show_any_logs_when_level_is_none() {
        let expectation = XCTestExpectation(description: "Should not show any logs")
        expectation.isInverted = true // means expectation shouldn't be fulfilled

        var setting = defaultSetting
        setting.logLevel = .none

        let testLogger = mockLogger(expectation: expectation, setting: setting) as! MockLogger
        testLogger.printAllLogs()

        wait(for: [expectation], timeout: 0.5)
    }
}

// MARK: - Internal mocks for test
fileprivate class MockLogService: LogService {
    let expectation: XCTestExpectation?
    
    func log(level: SabyAppleLogger.LogLevel, _ message: String) {
        print(level.name, message)
        expectation?.fulfill()
    }
    
    init(expectation: XCTestExpectation?) {
        self.expectation = expectation
    }
}

fileprivate class MockLogger: SabyAppleLogger.Logger {
    var loggerSetting: SabyAppleLogger.LoggerSetting
    let logService: MockLogService
    
    init(expectation: XCTestExpectation?, setting: LoggerSetting) {
        self.loggerSetting = setting
        self.logService = MockLogService(expectation: expectation)
    }
}

fileprivate func mockLogger(expectation: XCTestExpectation? = nil,
                            setting: LoggerSetting = defaultSetting) -> some SabyAppleLogger.Logger {
    return MockLogger(expectation: expectation, setting: setting)
}

fileprivate var defaultSetting: LoggerSetting {
    return LoggerSetting(subsystem: "", category: "")
}

extension MockLogger {
    func printAllLogs() {
        self.fault("TEST: FAULT LOG")
        self.error("TEST: ERROR LOG")
        self.info("TEST: INFO LOG")
        self.debug("TEST: DEFAULT LOG")
    }
}
