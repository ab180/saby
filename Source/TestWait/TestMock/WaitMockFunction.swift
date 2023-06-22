//
//  WaitMockFunction.swift
//  SabyTestWait
//
//  Created by WOF on 2023/06/20.
//

import Foundation
import SabyTestMock

public struct WaitMockFunction {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Argument, Result>(
        _ mock: MockFunction<Argument, Result>,
        _ block: () throws -> Void
    ) throws -> (argument: Argument, result: Result) {
        var callArgument: Argument?
        var callResult: Result?
        
        let semaphore = DispatchSemaphore(value: 0)
        let implementation = mock.implementation
        mock.implementation = { argument in
            callArgument = argument
            callResult = implementation(argument)
            semaphore.signal()
            
            return callResult!
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
