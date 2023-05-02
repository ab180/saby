//
//  ExpectPromise.swift
//  SabyTestExpect
//
//  Created by WOF on 2022/08/16.
//

import SabyConcurrency

import XCTest

extension Expect {
    public enum PromiseState<Value, Failure> {
        case resolved(_ value: Value)
        case rejected(_ error: Failure)
    }
}

extension Expect {
    public static func promise<Value, Failure>(
        _ actual: Promise<Value, Failure>,
        state: PromiseState<(Value) -> Bool, Failure>,
        timeout: DispatchTimeInterval,
        message: String = "Promise is not expected state",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            actual.then { value in
                XCTAssert(expect(value), message, file: file, line: line)
                end.signal()
            }
            .catch { error in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
        case .rejected(let expect):
            actual.then { value in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
            .catch { error in
                XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                end.signal()
            }
        }
            
        Expect.semaphore(end, timeout: timeout, file: file, line: line)
    }
    
    public static func promise<Value: Equatable, Failure>(
        _ actual: Promise<Value, Failure>,
        state: PromiseState<Value, Failure>,
        timeout: DispatchTimeInterval,
        message: String = "Promise is not expected state",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            actual.then { value in
                XCTAssertEqual(value, expect, message, file: file, line: line)
                end.signal()
            }
            .catch { error in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
        case .rejected(let expect):
            actual.then { value in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
            .catch { error in
                XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                end.signal()
            }
        }
        
        Expect.semaphore(end, timeout: timeout, file: file, line: line)
    }
    
    public static func promise<Failure>(
        _ actual: Promise<Void, Failure>,
        state: PromiseState<Void, Failure>,
        timeout: DispatchTimeInterval,
        message: String = "Promise is not expected state",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(_):
            actual.then { value in
                end.signal()
            }
            .catch { error in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
        case .rejected(let expect):
            actual.then { value in
                XCTFail(message, file: file, line: line)
                end.signal()
            }
            .catch { error in
                XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                end.signal()
            }
        }
        
        Expect.semaphore(end, timeout: timeout, file: file, line: line)
    }
}
