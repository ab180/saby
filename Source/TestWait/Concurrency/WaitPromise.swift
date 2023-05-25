//
//  WaitPromise.swift
//  SabyTestExtension
//
//  Created by WOF on 2023/05/22.
//

import Foundation
import SabyConcurrency

public struct WaitPromise {
    let timeout: DispatchTimeInterval
    
    public init(timeout: DispatchTimeInterval) {
        self.timeout = timeout
    }

    public func callAsFunction<Value, Failure>(
        _ promise: Promise<Value, Failure>
    ) throws -> Value {
        var result: Value?
        var failure: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        promise.then { value in
            result = value
            semaphore.signal()
        }.catch { error in
            failure = error
            semaphore.signal()
        }

        if case .timedOut = semaphore.wait(timeout: .now() + timeout) {
            throw WaitPromiseError.timeout
        }
        
        if let failure {
            throw failure
        }
        
        return result!
    }
}

public enum WaitPromiseError: Error {
    case timeout
}
