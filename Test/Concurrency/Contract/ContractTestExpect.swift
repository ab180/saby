//
//  ContractTestExpect.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import XCTest
@testable import SabyConcurrency

extension ContractTest {
    enum SampleError: Error {
        case one
        case two
        case three
    }
    
    enum State<Value> {
        case resolved(_ value: Value)
        case rejected(_ error: Error)
        case canceled
    }
    
    enum Message<Value> {
        static func unexpected(value: Value) -> String {
            "Contract provide unexpected: \(value)"
        }
    }
    
    static func expect<Value: Equatable, Failure>(
        contract: Contract<Value, Failure>,
        state: State<Value>,
        timeout: DispatchTimeInterval,
        block: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = DispatchSemaphore(value: 0)
        let message = Message.unexpected(value: state)
        
        switch state {
        case .resolved(let expect):
            let token = OnceToken()
            contract.subscribe(
                queue: contract.queue,
                onResolved: once(token: token) { value -> Void in
                    XCTAssertEqual(value, expect, message, file: file, line: line)
                    end.signal()
                },
                onRejected: once(token: token) { error -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onCanceled: once(token: token) {
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            let token = OnceToken()
            contract.subscribe(
                queue: contract.queue,
                onResolved: once(token: token) { value -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                },
                onRejected: once(token: token) { error -> Void in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                },
                onCanceled: once(token: token) {
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .canceled:
            let token = OnceToken()
            contract.subscribe(
                queue: contract.queue,
                onCanceled: once(token: token) {
                    end.signal()
                }
            )
        }
        
        block()
        expect(semaphore: end, timeout: timeout, file: file, line: line)
    }
    
    private static func expect(
        semaphore: DispatchSemaphore,
        timeout: DispatchTimeInterval,
        file: StaticString,
        line: UInt
    ) {
        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            XCTFail("test is failed with timeout: \(timeout)", file: file, line: line)
        }
    }
    
    private class OnceToken {
        var state: State = .pending
        
        enum State {
            case pending
            case called
        }
    }
    
    private static func once(
        token: OnceToken = OnceToken(),
        block: @escaping () -> Void
    ) -> () -> Void {
        return {
            if case .pending = token.state {
                token.state = .called
                block()
            }
        }
    }
    
    private static func once<Value>(
        token: OnceToken = OnceToken(),
        block: @escaping (Value) -> Void
    ) -> (Value) -> Void {
        return {
            if case .pending = token.state {
                token.state = .called
                block($0)
            }
        }
    }
}
