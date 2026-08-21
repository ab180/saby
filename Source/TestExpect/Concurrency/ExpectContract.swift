//
//  ExpectContract.swift
//  SabyTestExpect
//
//  Created by WOF on 2022/08/17.
//

import SabyConcurrency

import XCTest

extension Expect {
    public enum ContractState<Value, Failure> {
        case resolved(_ value: Value)
        case rejected(_ error: Failure)
    }
}

extension Expect {
    public static func contract<Value: Sendable, Failure: Error & Sendable>(
        _ actual: Contract<Value, Failure>,
        state: ContractState<(Value) -> Bool, Failure>,
        timeout: DispatchTimeInterval,
        block: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = DispatchSemaphore(value: 0)
        let message = Message.unexpected(value: state)
        
        switch state {
        case .resolved(let expect):
            nonisolated(unsafe) let expect = expect
            let token = OnceToken()
            actual.then(
                once(token: token) { value -> Void in
                    XCTAssert(expect(value), message, file: file, line: line)
                    end.signal()
                }
            )
            .catch(
                once(token: token) { error -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            let token = OnceToken()
            actual.then(
                once(token: token) { value -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
            .catch(
                once(token: token) { error -> Void in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                }
            )
        }
        
        block()
        Expect.semaphore(end, timeout: timeout, file: file, line: line)
    }
}

extension Expect {
    public static func contract<Value: Equatable & Sendable, Failure: Error & Sendable>(
        _ actual: Contract<Value, Failure>,
        state: ContractState<Value, Failure>,
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
            actual.then(
                once(token: token) { value -> Void in
                    XCTAssertEqual(value, expect, message, file: file, line: line)
                    end.signal()
                }
            )
            .catch(
                once(token: token) { error -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
        case .rejected(let expect):
            let token = OnceToken()
            actual.then(
                once(token: token) { value -> Void in
                    XCTFail(message, file: file, line: line)
                    end.signal()
                }
            )
            .catch(
                once(token: token) { error -> Void in
                    XCTAssertEqual(error.localizedDescription, expect.localizedDescription, file: file, line: line)
                    end.signal()
                }
            )
        }
        
        block()
        Expect.semaphore(end, timeout: timeout, file: file, line: line)
    }
}

extension Expect {
    fileprivate enum Message<Value> {
        static func unexpected(value: Value) -> String {
            "Contract provide unexpected: \(value)"
        }
    }
}

extension Expect {
    fileprivate final class OnceToken: Sendable {
        private let lock = NSLock()
        nonisolated(unsafe) private var state: State = .pending

        func callOnce(_ block: () -> Void) {
            let shouldCall = lock.withLock {
                guard case .pending = state else { return false }
                state = .called
                return true
            }

            if shouldCall { block() }
        }
        
        enum State {
            case pending
            case called
        }
    }
    
    fileprivate static func once<Value: Sendable>(
        token: OnceToken = OnceToken(),
        block: @escaping (Value) -> Void
    ) -> @Sendable (Value) -> Void {
        nonisolated(unsafe) let block = block
        return { value in
            token.callOnce { block(value) }
        }
    }
}
