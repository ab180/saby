//
//  PromiseConvertTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/25.
//

import XCTest
@testable import SabyConcurrency

final class PromiseConvertTest: XCTestCase {
    func test__from_optional_promise() {
        let promise = Promise.from(Promise { 10 } as Promise<Int>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__from_optional_promise_nil() {
        let promise = Promise.from(nil as Promise<Int>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(nil), timeout: .seconds(1))
    }
    
    func test__to_promise_optional() {
        let promise = Promise { 10 }.toPromiseOptional()
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__to_promise_void() {
        let promise = Promise { 10 }.toPromiseVoid()
        
        PromiseTest.expect(promise: promise, state: .resolved(()), timeout: .seconds(1))
    }
    
    func test__to_promise_any() {
        let promise = Promise { 10 }.toPromiseAny()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 as? Int == 10 }), timeout: .seconds(1))
    }
}
