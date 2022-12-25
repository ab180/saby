//
//  PromiseTestExpect.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/08.
//

import XCTest
@testable import SabyConcurrency

extension PromiseTest {
    enum Error: Swift.Error {
        case one
        case two
        case three
    }
    
    enum State<Value> {
        case pending
        case resolved(_ value: Value)
        case rejected(_ error: Swift.Error)
    }
    
    static func expect<Value>(promise: Promise<Value>,
                              state: PromiseTest.State<(Value) -> Bool>,
                              timeout: DispatchTimeInterval,
                              message: String = "Promise is not expected state",
                              file: StaticString = #file,
                              line: UInt = #line)
    {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    XCTAssert(expect(value), message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                }
            )
        case .pending:
            if case .pending = promise.state {} else {
                XCTFail(message, file: file, line: line)
            }
            
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: timeout, file: file, line: line)
    }
    
    static func expect<Value: Equatable>(promise: Promise<Value>,
                                         state: PromiseTest.State<Value>,
                                         timeout: DispatchTimeInterval,
                                         message: String = "Promise is not expected state",
                                         file: StaticString = #file,
                                         line: UInt = #line)
    {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    XCTAssertEqual(value, expect, message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                }
            )
        case .pending:
            if case .pending = promise.state {} else {
                XCTFail(message, file: file, line: line)
            }
            
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: timeout, file: file, line: line)
    }
    
    static func expect(promise: Promise<Void>,
                       state: PromiseTest.State<Void>,
                       timeout: DispatchTimeInterval,
                       message: String = "Promise is not expected state",
                       file: StaticString = #file,
                       line: UInt = #line)
    {
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(_):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    end.signal()
                },
                onRejected: { error in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            promise.subscribe(
                on: promise.queue,
                onResolved: { value in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                }
            )
        case .pending:
            if case .pending = promise.state {} else {
                XCTFail(message, file: file, line: line)
            }
            
            end.signal()
        }
        
        PromiseTest.expect(semaphore: end, timeout: timeout, file: file, line: line)
    }
    
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
