//
//  PromiseTestExpect.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/08.
//

import XCTest
@testable import SabyConcurrency

extension PromiseTest {
    enum SampleError: Swift.Error {
        case one
        case two
        case three
    }
    
    enum State<Value> {
        case pending
        case resolved(_ value: Value)
        case rejected(_ error: Swift.Error)
        case canceled
    }
    
    static func expect<Value, Failure>(promise: Promise<Value, Failure>,
                              state: PromiseTest.State<(Value) -> Bool>,
                              timeout: DispatchTimeInterval,
                              file: StaticString = #file,
                              line: UInt = #line)
    {
        let message = "Promise is not expected state \(state)"
        
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            promise.subscribe(
                queue: promise.queue,
                onResolved: { value in
                    XCTAssert(expect(value), message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onCanceled: {
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            promise.subscribe(
                queue: promise.queue,
                onResolved: { value in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                },
                onCanceled: {
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .pending:
            if case .pending = promise.state.capture({ $0 }) {} else {
                XCTFail(message, file: file, line: line)
            }
            
            end.signal()
        case .canceled:
            promise.subscribe(
                queue: promise.queue,
                onCanceled: {
                    end.signal()
                }
            )
        }
        
        PromiseTest.expect(semaphore: end, timeout: timeout, file: file, line: line)
    }
    
    static func expect<Value: Equatable, Failure>(promise: Promise<Value, Failure>,
                                         state: PromiseTest.State<Value>,
                                         timeout: DispatchTimeInterval,
                                         file: StaticString = #file,
                                         line: UInt = #line)
    {
        let message = "Promise is not expected state \(state)"
        
        let end = DispatchSemaphore(value: 0)
        
        switch state {
        case .resolved(let expect):
            promise.subscribe(
                queue: promise.queue,
                onResolved: { value in
                    XCTAssertEqual(value, expect, message, file: file, line: line)
                    end.signal()
                },
                onRejected: { error in
                    XCTFail(
                        "Promise is rejected",
                        file: file,
                        line: line
                    )
                    end.signal()
                },
                onCanceled: {
                    XCTFail(
                        "Promise is canceled",
                        file: file,
                        line: line
                    )
                    end.signal()
                }
            )
        case .rejected(let expect):
            promise.subscribe(
                queue: promise.queue,
                onResolved: { value in
                    XCTFail(
                        "Promise is resolved",
                        file: file,
                        line: line
                    )
                    end.signal()
                },
                onRejected: { error in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                },
                onCanceled: {
                    XCTFail(
                        "Promise is canceled",
                        file: file,
                        line: line
                    )
                    end.signal()
                }
            )
        case .pending:
            if case .pending = promise.state.capture({ $0 }) {} else {
                XCTFail(message, file: file, line: line)
            }
            
            end.signal()
        case .canceled:
            promise.subscribe(
                queue: promise.queue,
                onCanceled: {
                    end.signal()
                }
            )
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
