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
        _ mock: inout MockFunction<Argument, Result>
    ) throws -> MockFunctionCall<Argument, Result> {
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

        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitMockFunctionError.timeout
        }
        
        return MockFunctionCall<Argument, Result>(argument: callArgument!, result: callResult!)
    }
}

public enum WaitMockFunctionError: Error {
    case timeout
}
