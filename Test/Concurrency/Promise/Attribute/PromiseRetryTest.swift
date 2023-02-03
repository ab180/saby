//
//  PromiseRetryTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2023/02/03.
//

import Foundation

import XCTest
@testable import SabyConcurrency

final class PromiseRetryTest: XCTestCase {
    func test__retry() {
        var value = 0
        
        let promise =
        Promise.retry(5) {
            Promise {
                if (value < 3) {
                    value += 1
                    throw PromiseTest.Error.one
                }
                
                return value
            }
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(3), timeout: .seconds(1))
    }
    
    func test__retry_error() {
        var value = 0
        
        let promise =
        Promise.retry(3) {
            Promise {
                if (value < 5) {
                    value += 1
                    throw PromiseTest.Error.one
                }
                
                return value
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.Error.one), timeout: .seconds(1))
    }
}
