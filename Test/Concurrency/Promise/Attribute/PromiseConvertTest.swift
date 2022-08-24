//
//  PromiseConvertTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/25.
//

import XCTest
@testable import SabyConcurrency

final class PromiseConvertTest: XCTestCase {
    func test__to_promise_void() {
        let promise = Promise { 10 }.toPromiseVoid()
        
        PromiseTest.expect(promise: promise, state: .resolved(()), timeout: .seconds(1))
    }
    
    func test__to_promise_any() {
        let promise = Promise { 10 }.toPromiseAny()
        
        PromiseTest.expect(promise: promise, state: .resolved({ $0 as? Int == 10 }), timeout: .seconds(1))
    }
}
