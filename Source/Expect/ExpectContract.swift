//
//  ExpectContract.swift
//  SabyExpect
//
//  Created by 0xwof on 2022/08/17.
//

import SabyConcurrency

import XCTest

extension Expect {
    public enum ContractState<Value> {
        case resolved(_ value: Value)
        case rejected(_ error: Swift.Error)
    }
}

extension Expect {
    public static func contract<Value: Equatable>(
        _ actual: Contract<Value>,
        state: ContractState<Value>,
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
    fileprivate class OnceToken {
        var state: State = .pending
        
        enum State {
            case pending
            case called
        }
    }
    
    fileprivate static func once<Value>(
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
