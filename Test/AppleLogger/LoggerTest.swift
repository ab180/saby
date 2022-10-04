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
    func test_SetLogLevel() {
        let logger = Logger.shared
        XCTAssertNotEqual(logger.configuration.logLevel, LogLevel.fault)
        
        logger.setLogLevel(to: .fault)
        XCTAssertEqual(logger.configuration.logLevel, LogLevel.fault)
    }
    
    func test_Configure() {
        let logger = Logger.shared
        let loggerConfiguration = logger.configuration
        let mockConfiguration = LoggerConfiguration(logLevel: .none, usePrint: true)
        XCTAssertNotEqual(loggerConfiguration.logLevel, mockConfiguration.logLevel)
        
        logger.configure(with: mockConfiguration)
        XCTAssertEqual(logger.configuration.logLevel, mockConfiguration.logLevel)
    }
    
    func test_UsePrintOption() {
        let printerExp = XCTestExpectation(description: "Should show print, not log")
        let loggerExp = XCTestExpectation(description: "Should show log, not print")
        
        var loggerConfiguration = LoggerConfiguration.default
        loggerConfiguration.usePrint = true
        
        let testPrinter = Logger(configuration: loggerConfiguration)
        testPrinter.logService = MockPrintService(expectation: printerExp, showLogs: false)
        
        loggerConfiguration.usePrint = false
        let testLogger = Logger(configuration: loggerConfiguration)
        testLogger.logService = MockLogService(expectation: loggerExp, showLogs: false)
        
        // XCTFail will be triggered if `log` is called in this case.
        printAllLogs(testPrinter)
        
        // XCTFail will be triggered if `print` is called in this case.
        printAllLogs(testLogger)
        wait(for: [printerExp, loggerExp], timeout: 0.5)
    }
    
    func test_ShouldNotShowLowerLevelLogs() {
        let allLogLevels = LogLevel.allCases
        let numberOfLogLevels = allLogLevels.count
                
        for levelIndex in allLogLevels.indices {
            let level = allLogLevels[levelIndex]
            
            var loggerConfiguration = LoggerConfiguration.default
            loggerConfiguration.logLevel = level
            
            let testLogger = Logger(configuration: loggerConfiguration)
            
            let expectation = XCTestExpectation(description: "Shouldn't show lower level logs")

            // Only the logs higher than set level have to be executed.
            // In other words, output will be the logs excluding the logs below the given level.
            // Thus, the expected count of fulfilled log is set as below;
            // Total number of all log levels(numberOfLogLevels) - Current log level(levelIndex)
            // which can be said as the number of remaining log levels.
            expectation.expectedFulfillmentCount = numberOfLogLevels - levelIndex
            
            testLogger.logService = MockLogService(expectation: expectation, showLogs: true)

            printAllLogs(testLogger)
            wait(for: [expectation], timeout: 0.5)
        }
    }
    
    func test_ShouldNotShowAnyLogsWhenLevelIsNone() {
        let expectation = XCTestExpectation(description: "Should not show any logs")
        expectation.isInverted = true
        
        var loggerConfiguration = LoggerConfiguration.default
        loggerConfiguration.logLevel = .none
        
        let testLogger = Logger(configuration: loggerConfiguration)
        testLogger.logService = MockLogService(expectation: expectation, showLogs: true)
        
        printAllLogs(testLogger)
        wait(for: [expectation], timeout: 0.5)
    }
}

fileprivate struct MockLogService: LogService {
    let expectation: XCTestExpectation
    var showLogs: Bool
    
    func log(_ message: StaticString, log: OSLog, type: OSLogType, _ args: CVarArg) {
        if showLogs {
            print(args)
        }
        
        expectation.fulfill()
    }
    
    public func printLog(type: LogLevel, _ message: String) {
        XCTFail("Test aborted because print method called")
        return
    }
}

fileprivate struct MockPrintService: LogService {
    let expectation: XCTestExpectation
    var showLogs: Bool
    
    func log(_ message: StaticString, log: OSLog, type: OSLogType, _ args: CVarArg) {
        XCTFail("Test aborted because log method called")
        return
    }
    
    public func printLog(type: LogLevel, _ message: String) {
        if showLogs {
            print(message)
        }
        
        expectation.fulfill()
    }
}

fileprivate func printAllLogs(_ logger: SabyAppleLogger.Logger) {
    logger.fault("TEST: FAULT LOG")
    logger.error("TEST: ERROR LOG")
    logger.info("TEST: INFO LOG")
    logger.debug("TEST: DEFAULT LOG")
}
