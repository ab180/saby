//
//  WaitContract.swift
//  SabyTestWait
//
//  Created by WOF on 2023/05/22.
//

import Foundation
import SabyConcurrency

public struct WaitContract {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Value, Failure>(
        _ contract: Contract<Value, Failure>,
        _ block: () throws -> Void
    ) throws -> Value {
        var result: Value?
        var failure: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        contract.next().then { value in
            result = value
            semaphore.signal()
        }.catch { error in
            failure = error
            semaphore.signal()
        }
        try block()

        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitPromiseError.timeout
        }
        
        if let failure {
            throw failure
        }
        
        return result!
    }
}

public enum WaitContractError: Error {
    case timeout
}
