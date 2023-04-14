//
//  PromiseFilterTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/24.
//

import XCTest
@testable import SabyConcurrency

final class PromiseFilterTest: XCTestCase {
    func test__filter_bool() {
        let promise0 = Promise<Int, Error>()

        let promise = promise0.filter { $0 % 2 == 0 }
        
        promise0.resolve(2)
        PromiseTest.expect(
            promise: promise,
            state: .resolved(2),
            timeout: .seconds(1)
        )
    }
    
    func test__filter_non_null() {
        let promise0 = Promise<String, Error>()

        let promise = promise0.filter { URL(string: $0) }
        
        promise0.resolve("https://a.example")
        PromiseTest.expect(
            promise: promise,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        )
    }
    
    func test__filter_promise() {
        let promise0 = Promise<String, Error>()

        let promise = promise0.filter { Promise.resolved(URL(string: $0)) }
        
        promise0.resolve("https://a.example")
        PromiseTest.expect(
            promise: promise,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        )
    }
    
    func test__filter_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let promise0 = Promise<String, Error>()

        let promise = promise0.filter { _ in
            promise0.cancel()
            end.signal()
            return filterPromise
        }
        
        promise0.resolve("10")
        PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: filterPromise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__never_filter_bool() {
        let promise0 = Promise<Int, Never>()

        let promise = promise0.filter { $0 % 2 == 0 }
        
        promise0.resolve(2)
        PromiseTest.expect(
            promise: promise,
            state: .resolved(2),
            timeout: .seconds(1)
        )
    }
    
    func test__never_filter_non_null() {
        let promise0 = Promise<String, Never>()

        let promise = promise0.filter { URL(string: $0) }
        
        promise0.resolve("https://a.example")
        PromiseTest.expect(
            promise: promise,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        )
    }
    
    func test__never_filter_promise() {
        let promise0 = Promise<String, Never>()

        let promise = promise0.filter { Promise<URL?, Never>.resolved(URL(string: $0)) }
        
        promise0.resolve("https://a.example")
        PromiseTest.expect(
            promise: promise,
            state: .resolved(URL(string: "https://a.example")!),
            timeout: .seconds(1)
        )
    }
    
    func test__never_filter_promise_cancel() {
        let end = DispatchSemaphore(value: 0)
        let filterPromise = Promise<Int, Never>.pending().promise
        
        let promise0 = Promise<String, Never>()

        let promise = promise0.filter { _ in
            promise0.cancel()
            end.signal()
            return filterPromise
        }
        
        promise0.resolve("10")
        PromiseTest.expect(
            promise: promise,
            state: .canceled,
            timeout: .seconds(1)
        )
        PromiseTest.expect(semaphore: end, timeout: .seconds(1))
        PromiseTest.expect(promise: filterPromise, state: .canceled, timeout: .seconds(1))
    }
}
