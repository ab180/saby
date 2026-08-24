//
//  PromiseTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/02.
//

import XCTest
@testable import SabyConcurrency

final class PromiseTest: XCTestCase {
    func test__init() {
        let promise = Promise<Int, Error>()

        PromiseTest.expect(promise: promise, state: .pending, timeout: .seconds(1))
    }
    
    func test__init_with_resolver_resolve() {
        let promise = Promise<Int, Error> { resolve, reject in
            resolve(10)
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_reject() {
        let promise = Promise<Int, Error> { resolve, reject in
            reject(PromiseTest.SampleError.one)
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_throw_error() {
        let promise = Promise<Int, Error> { resolve, reject in
            throw PromiseTest.SampleError.one
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__init_with_resolver_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let promise = Promise<Int, Error> { resolve, reject, cancel, onCancel in
            onCancel {
                expect.fulfill()
            }
        }
        promise.cancel()
        
        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__resolve() {
        let promise = Promise<Int, Error>()
        promise.resolve(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__reject() {
        let promise = Promise<Int, Error>()
        promise.reject(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__pending() {
        let pending = Promise<Int, Error>.pending()
        
        PromiseTest.expect(promise: pending.promise, state: .pending, timeout: .seconds(1))
    }
    
    func test__pending_resolve() {
        let pending = Promise<Int, Error>.pending()
        pending.resolve(10)
        
        PromiseTest.expect(promise: pending.promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__pending_reject() {
        let pending = Promise<Int, Error>.pending()
        pending.reject(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: pending.promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__pending_cancel() {
        let expect = XCTestExpectation()
        expect.expectedFulfillmentCount = 1
        
        let pending = Promise<Int, Error>.pending()
        pending.onCancel {
            expect.fulfill()
        }
        pending.promise.cancel()
        
        XCTAssertEqual(XCTWaiter().wait(for: [expect], timeout: 1), .completed)
        PromiseTest.expect(promise: pending.promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__resolved() {
        let promise = Promise<Int, Error>.resolved(10)
        
        PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    func test__rejected() {
        let promise = Promise<Int, Error>.rejected(PromiseTest.SampleError.one)
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__canceled() {
        let promise = Promise<Int, Error>.canceled()
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }

    func test__async_with_async_function() {
        let promise: Promise<Int, Never> = Promise.async(Self.asyncValue)

        PromiseTest.expect(
            promise: promise,
            state: .resolved(10),
            timeout: .seconds(1)
        )
    }

    func test__async_with_throwing_async_function() {
        let promise: Promise<Int, Error> = Promise.async(Self.throwingAsyncValue)

        PromiseTest.expect(
            promise: promise,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        )
    }

    func test__state_properties() async {
        let promise = Promise<Int, Error>()

        let isPending = await promise.isPending
        XCTAssertTrue(isPending)

        promise.resolve(10)

        let isResolved = await promise.isResolved
        let isRejected = await promise.isRejected
        let isCanceled = await promise.isCanceled
        XCTAssertTrue(isResolved)
        XCTAssertFalse(isRejected)
        XCTAssertFalse(isCanceled)
    }

    func test__first_completion_wins() async {
        for _ in 0..<500 {
            let promise = Promise<Int, Error>()

            promise.resolve(10)
            promise.reject(SampleError.one)
            promise.cancel()
            promise.resolve(20)

            guard case .resolved(let value) = await promise.capture() else {
                XCTFail("Promise did not preserve its first completion")
                return
            }

            XCTAssertEqual(value, 10)
        }
    }

    func test__concurrent_completion_notifies_once() async {
        let callbackQueue = DispatchQueue(label: #function)
        let pending = Promise<Int, Error>.pending(on: callbackQueue)
        let lock = NSLock()
        nonisolated(unsafe) var completionCount = 0

        pending.promise.subscribe(
            on: callbackQueue,
            onResolved: { _ in lock.withLock { completionCount += 1 } },
            onRejected: { _ in lock.withLock { completionCount += 1 } },
            onCanceled: { lock.withLock { completionCount += 1 } }
        )

        DispatchQueue.concurrentPerform(iterations: 1_000) { index in
            switch index % 3 {
            case 0: pending.resolve(index)
            case 1: pending.reject(SampleError.one)
            default: pending.cancel()
            }
        }
        callbackQueue.sync {}

        XCTAssertEqual(lock.withLock { completionCount }, 1)
        let isPending = await pending.promise.isPending
        XCTAssertFalse(isPending)
    }
    
    func test__cancel_deinit() async throws {
        let promises = WeakPromisePair()
        let result = DispatchSemaphore(value: 0)
        
        try Promise<Void, Never> { resolve, reject in
            let promise00 = Promise<Void, Never>.resolved(())
            let promise11 = promise00.delay(.milliseconds(10)).then {
                result.signal()
                return ()
            }

            Task {
                await promises.store(promise00, promise11)
                resolve(())
            }
        }.wait()

        let (promise0, promise1) = await promises.values()
        XCTAssertNil(promise0)
        XCTAssertNotNil(promise1)
        
        try promise1!.wait()
        XCTAssertEqual(result.wait(timeout: .now() + .seconds(1)), .success)
    }

    private static func asyncValue() async -> Int {
        10
    }

    private static func throwingAsyncValue() async throws -> Int {
        throw SampleError.one
    }
}

private actor WeakPromisePair {
    private weak var first: Promise<Void, Never>?
    private weak var second: Promise<Void, Never>?

    func store(
        _ first: Promise<Void, Never>,
        _ second: Promise<Void, Never>
    ) {
        self.first = first
        self.second = second
    }

    func values() -> (Promise<Void, Never>?, Promise<Void, Never>?) {
        (first, second)
    }
}
