//
//  PromiseWait.swift
//  SabyTestExtension
//
//  Created by WOF on 2023/05/22.
//

import Foundation
import SabyConcurrency

extension Promise {
    public func wait() throws -> Value {
        var result: Value?
        var failure: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        self.then { value in
            result = value
            semaphore.signal()
        }.catch { error in
            failure = error
            semaphore.signal()
        }
        semaphore.wait()
        
        if let failure {
            throw failure
        }
        
        return result!
    }
}

extension Promise where Failure == Never {
    public func wait() -> Value {
        var result: Value?
        
        let semaphore = DispatchSemaphore(value: 0)
        self.then { value in
            result = value
            semaphore.signal()
        }
        semaphore.wait()
        
        return result!
    }
}

