//
//  PromiseConvertTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/25.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseConvertTest {
    @Test
    func test__from_optional_promise() async {
        let promise = Promise.from(PromiseTest.make { 10 } as Promise<Int, Error>?)

        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__from_optional_promise_nil() async {
        let promise = Promise.from(nil as Promise<Int, Error>?)

        await PromiseTest.expect(promise: promise, state: .resolved(nil), timeout: .seconds(1))
    }

    @Test
    func test__never_from_optional_never_promise() async {
        let promise = Promise.from(PromiseTest.make { 10 } as Promise<Int, Never>?)

        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }

    @Test
    func test__never_from_optional_never_promise_nil() async {
        let promise = Promise.from(nil as Promise<Int, Never>?)

        await PromiseTest.expect(promise: promise, state: .resolved(nil), timeout: .seconds(1))
    }

    @Test
    func test__to_promise_optional() async {
        let promise = PromiseTest.make { 10 }.toPromiseOptional()
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__to_promise_void() async {
        let promise = PromiseTest.make { 10 }.toPromiseVoid()
        
        await PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    @Test
    func test__never_to_promise() async {
        let promise = PromiseTest.make { 10 }.toPromiseError()
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__never_to_never_promise_optional() async {
        let promise = PromiseTest.make { 10 }.toPromiseOptional()
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__never_to_never_promise_void() async {
        let promise = PromiseTest.make { 10 }.toPromiseVoid()
        
        await PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
}
