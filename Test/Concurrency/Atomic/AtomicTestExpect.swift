//
//  AtomicTestExpect.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation

import XCTest
@testable import SabyConcurrency

extension AtomicTest {
    static func expect(semaphore: DispatchSemaphore,
                       count: Int = 1,
                       timeout: DispatchTimeInterval,
                       message: String = "test is timeout",
                       file: StaticString = #file,
                       line: UInt = #line)
    {
        for _ in 0..<count {
            if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
                XCTFail(message, file: file, line: line)
            }
        }
    }
}
