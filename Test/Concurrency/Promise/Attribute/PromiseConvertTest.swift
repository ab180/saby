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
        let promise = Promise.from(Promise { 10 } as Promise<Int, Error>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__from_optional_promise_nil() {
        let promise = Promise.from(nil as Promise<Int, Error>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(nil), timeout: .seconds(1))
    }
    
    func test__to_promise_optional() {
        let promise = Promise { 10 }.toPromiseOptional()
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__to_promise_void() {
        let promise = Promise { 10 }.toPromiseVoid()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__to_promise_any() {
        let promise = Promise { 10 }.toPromiseAny()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 as? Int == 10 }), timeout: .seconds(1))
    }
    
    func test__never_from_optional_never_promise() {
        let promise = Promise.from(Promise { 10 } as Promise<Int, Never>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__never_from_optional_never_promise_nil() {
        let promise = Promise.from(nil as Promise<Int, Never>?)
        
        PromiseTest.expect(promise: promise, state: .resolved(nil), timeout: .seconds(1))
    }
    
    func test__never_to_promise() {
        let promise = Promise { 10 }.toPromiseError()
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__never_to_promise_optional() {
        let promise = Promise { 10 }.toPromiseOptionalError()
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__never_to_promise_void() {
        let promise = Promise { 10 }.toPromiseVoidError()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__never_to_promise_any() {
        let promise = Promise { 10 }.toPromiseAnyError()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 as? Int == 10 }), timeout: .seconds(1))
    }
    
    func test__never_to_never_promise_optional() {
        let promise = Promise { 10 }.toPromiseOptional()
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__never_to_never_promise_void() {
        let promise = Promise { 10 }.toPromiseVoid()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    func test__never_to_never_promise_any() {
        let promise = Promise { 10 }.toPromiseAny()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 as? Int == 10 }), timeout: .seconds(1))
    }
}
