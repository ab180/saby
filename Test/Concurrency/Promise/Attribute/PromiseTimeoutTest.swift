//
//  TimeoutTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseTimeoutTest {
    @Test
    func test__timeout() async {
        let promise =
        Promise { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                resolve(10)
            }
        }.timeout(.milliseconds(200))
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__timeout_reject() async {
        let promise =
        Promise<Int, Error> { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
                resolve(10)
            }
        }.timeout(.milliseconds(10))
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseError.timeout), timeout: .seconds(1))
    }
    
    @Test
    func test__never_timeout() async {
        let promise =
        Promise<Int, Never> { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(10)) {
                resolve(10)
            }
        }
        .timeout(.milliseconds(200))
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__never_timeout_reject() async {
        let promise =
        Promise<Int, Never> { resolve, reject in
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(200)) {
                resolve(10)
            }
        }
        .timeout(.milliseconds(10))
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseError.timeout), timeout: .seconds(1))
    }
}
