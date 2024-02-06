//
//  WaitMockFunction.swift
//  SabyTestWait
//
//  Created by WOF on 2023/06/20.
//

import Foundation
import SabyConcurrency
import SabyTestMock

public struct WaitMockFunction {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Argument, Result>(
        _ mock: MockFunction<Argument, Result>,
        until: @escaping (Argument, Result) -> Bool = { _, _ in true },
        _ block: () throws -> Void
    ) throws -> (argument: Argument, result: Result) {
        var callArgument: Argument?
        var callResult: Result?
        
        let lock = Lock()
        let semaphore = DispatchSemaphore(value: 0)
        let callback = mock.callback
        mock.callback = { argument, result in
            lock.lock()
            defer { lock.unlock() }
            
            if until(argument, result), callArgument == nil, callResult == nil {
                callArgument = argument
                callResult = result
                semaphore.signal()
                mock.callback = callback
            }
            callback(argument, result)
        }
        try block()

        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitMockFunctionError.timeout
        }
        
        return (argument: callArgument!, result: callResult!)
    }
}

public enum WaitMockFunctionError: Error {
    case timeout
}
