//
//  TimeoutTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation

import XCTest
@testable import SabyConcurrency

final class PromiseTimeoutTest: XCTestCase {
    func test__timeout() {
        let promise =
        Promise { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                resolve(10)
            }
        }.timeout(.milliseconds(200))
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__timeout_reject() {
        let promise =
        Promise<Int> { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(100)) {
                resolve(10)
            }
        }.timeout(.milliseconds(50))
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseError.timeout), timeout: .seconds(1))
    }
}
