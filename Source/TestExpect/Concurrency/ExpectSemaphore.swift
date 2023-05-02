//
//  ExpectSemaphore.swift
//  SabyTestExpect
//
//  Created by WOF on 2022/08/17.
//

import XCTest

extension Expect {
    public static func semaphore(
        _ actual: DispatchSemaphore,
        count: Int = 1,
        timeout: DispatchTimeInterval,
        message: String = "test is timeout",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for _ in 0..<count {
            if case .timedOut = actual.wait(timeout: .now() + timeout) {
                XCTFail(message, file: file, line: line)
            }
        }
    }
}
