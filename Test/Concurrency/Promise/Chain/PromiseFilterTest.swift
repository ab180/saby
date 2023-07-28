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
    
    func test__filter_deinit() throws {
        weak var promise0: Promise<Int, Never>?
        weak var promise1: Promise<Int, Never>?
        
        try Promise.async {
            let promise00 = Promise.async { 10 }.filter { $0 == 10 }.then { $0 }
            let promise11 = Promise.async { 10 }.filter { $0 == 20 }.then { $0 }
            
            promise0 = promise00
            promise1 = promise11
            
            return promise00
        }.wait()
    
        XCTAssertNil(promise0)
        XCTAssertNil(promise1)
    }
}
