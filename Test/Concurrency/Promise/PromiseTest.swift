//
//  PromiseTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/02.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseTest {
    @Test
    func test__init() async {
        let promise = Promise<Int, Error>()

        await PromiseTest.expect(promise: promise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__init_with_resolver_resolve() async {
        let promise = Promise<Int, Error> { resolve, reject in
            resolve(10)
        }
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__init_with_resolver_reject() async {
        let promise = Promise<Int, Error> { resolve, reject in
            reject(PromiseTest.SampleError.one)
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__init_with_resolver_throw_error() async {
        let promise = Promise<Int, Error> { resolve, reject in
            throw PromiseTest.SampleError.one
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__init_with_resolver_cancel() async {
        let canceled = AsyncLatch()
        
        let promise = Promise<Int, Error> { resolve, reject, cancel, onCancel in
            onCancel {
                canceled.signal()
            }
        }
        promise.cancel()
        
        #expect(await canceled.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__resolve() async {
        let promise = Promise<Int, Error>()
        promise.resolve(10)
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__reject() async {
        let promise = Promise<Int, Error>()
        promise.reject(PromiseTest.SampleError.one)
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__pending() async {
        let pending = Promise<Int, Error>.pending()
        
        await PromiseTest.expect(promise: pending.promise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__pending_resolve() async {
        let pending = Promise<Int, Error>.pending()
        pending.resolve(10)
        
        await PromiseTest.expect(promise: pending.promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__pending_reject() async {
        let pending = Promise<Int, Error>.pending()
        pending.reject(PromiseTest.SampleError.one)
        
        await PromiseTest.expect(promise: pending.promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__pending_cancel() async {
        let canceled = AsyncLatch()
        
        let pending = Promise<Int, Error>.pending()
        pending.onCancel {
            canceled.signal()
        }
        pending.promise.cancel()
        
        #expect(await canceled.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: pending.promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__resolved() async {
        let promise = Promise<Int, Error>.resolved(10)
        
        await PromiseTest.expect(promise: promise, state: .resolved(10), timeout: .seconds(1))
    }
    
    @Test
    func test__rejected() async {
        let promise = Promise<Int, Error>.rejected(PromiseTest.SampleError.one)
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__canceled() async {
        let promise: Promise<Int, Error> = PromiseTest.canceled()
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }

    @Test
    func test__async_with_async_function() async {
        let promise: Promise<Int, Never> = Promise.async(Self.asyncValue)

        await PromiseTest.expect(
            promise: promise,
            state: .resolved(10),
            timeout: .seconds(1)
        )
    }

    @Test
    func test__async_with_throwing_async_function() async {
        let promise: Promise<Int, Error> = Promise.async(Self.throwingAsyncValue)

        await PromiseTest.expect(
            promise: promise,
            state: .rejected(SampleError.one),
            timeout: .seconds(1)
        )
    }

    @Test
    func test__state_properties() async {
        let promise = Promise<Int, Error>()

        #expect(promise.capture().isPending)

        promise.resolve(10)

        let isResolved = await promise.isResolved
        #expect(isResolved)
        #expect(!promise.capture().isRejected)
        #expect(!promise.capture().isCanceled)
    }

    @Test
    func test__first_completion_wins() async {
        for _ in 0..<500 {
            let promise = Promise<Int, Error>()

            promise.resolve(10)
            promise.reject(SampleError.one)
            promise.cancel()
            promise.resolve(20)

            guard case .resolved(let value) = promise.capture() else {
                Issue.record("Promise did not preserve its first completion")
                return
            }

            #expect(value == 10)
        }
    }

    @Test
    func test__concurrent_completion_notifies_once() async {
        let callbackQueue = DispatchQueue(label: #function)
        let pending = Promise<Int, Error>.pending(on: callbackQueue)
        let completionCount = LockedBox(0)

        pending.promise.subscribe(
            on: callbackQueue,
            onResolved: { _ in completionCount.withValue { $0 += 1 } },
            onRejected: { _ in completionCount.withValue { $0 += 1 } },
            onCanceled: { completionCount.withValue { $0 += 1 } }
        )

        DispatchQueue.concurrentPerform(iterations: 1_000) { index in
            switch index % 3 {
            case 0: pending.resolve(index)
            case 1: pending.reject(SampleError.one)
            default: pending.cancel()
            }
        }
        callbackQueue.sync {}

        #expect(completionCount.value == 1)
        #expect(!pending.promise.capture().isPending)
    }
    
    @Test
    func test__cancel_deinit() async throws {
        let promises = WeakPromisePair()
        let didComplete = LockedBox(false)
        
        try await Promise<Void, Never> { resolve, reject in
            let promise00 = Promise<Void, Never>.resolved(())
            let promise11 = promise00.delay(.milliseconds(10)).then {
                didComplete.withValue { $0 = true }
                return ()
            }

            Task {
                await promises.store(promise00, promise11)
                resolve(())
            }
        }.value()

        let (promise0, promise1) = await promises.values()
        #expect(promise0 == nil)
        #expect(promise1 != nil)
        
        try await promise1!.value()
        #expect(didComplete.value)
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
