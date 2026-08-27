//
//  ContractThenTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/07/21.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct ContractThenTest {
    @Test
    func test__then_return_value() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            value + 1
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_throw_error_return_value() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_throw_error_return_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_throw_error_return_never_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_resolved_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_rejected_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_canceled_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            canceledPromise() as Promise<Int, Error>
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_resolved_never_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_canceled_never_promise() async {
        let contract0 = Contract<Int, Error>()
        
        let contract = contract0.then { value in
            canceledPromise() as Promise<Int, Never>
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_return_promise_cancel() async {
        let end = AsyncLatch()
        let thenPromise = Promise<Int, Error>.pending().promise

        let contract0 = Contract<Int, Error>()

        let contract = contract0.then { _ in
            contract0.cancel()
            end.signal()
            return thenPromise
        }

        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: thenPromise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_value() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            value + 1
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }

    @Test
    func test__never_then_async_return_value() async {
        let contract0 = Contract<Int, Never>()

        let contract = contract0.then { value async -> Int in
            await Task.yield()
            return value + 1
        }

        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
    }

    @Test
    func test__never_then_async_schedule_sync() async {
        let contract0 = Contract<Int, Never>()
        let completed = AsyncLatch()
        let activeCount = LockedBox(0)
        let maxActiveCount = LockedBox(0)
        let actual = LockedBox<[Int]>([])

        let contract = contract0.then(schedule: .sync) { value async -> Int in
            let active = activeCount.withValue {
                $0 += 1
                return $0
            }
            maxActiveCount.withValue { $0 = max($0, active) }

            await Task.yield()

            activeCount.withValue { $0 -= 1 }
            actual.withValue { $0.append(value) }
            return value
        }
        contract.subscribe(
            onResolved: { value in
                if value == 100 { completed.signal() }
            },
            onRejected: { _ in },
            onCanceled: {}
        )

        (0...100).forEach { contract0.resolve($0) }

        #expect(await completed.wait(timeout: .seconds(1)))
        #expect(maxActiveCount.value == 1)
        #expect(actual.value == Array(0...100))
    }
    
    @Test
    func test__never_then_throw_error_return_value() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Int in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_throw_error_return_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Promise<Int, Error> in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_throw_error_return_never_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value -> Promise<Int, Never> in
            throw ContractTest.SampleError.one
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_return_resolved_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.resolved(value + 1)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_return_rejected_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Error>.rejected(ContractTest.SampleError.one)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .rejected(ContractTest.SampleError.one),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_return_canceled_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            canceledPromise() as Promise<Int, Error>
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_return_resolved_never_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            Promise<Int, Never>.resolved(value + 1)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(11),
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .resolved(21),
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__never_then_return_canceled_never_promise() async {
        let contract0 = Contract<Int, Never>()
        
        let contract = contract0.then { value in
            canceledPromise() as Promise<Int, Never>
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(10)
        }
        
        await ContractTest.expect(
            contract: contract,
            state: .canceled,
            timeout: .seconds(1)
        ) {
            contract0.resolve(20)
        }
    }
    
    @Test
    func test__then_schedule_sync() async throws {
        let expect = (0...10000).map { $0 }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        let actual = LockedBox<[Int]>([])
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in value }
            }
            .then { value in
                actual.withValue { $0.append(value) }
                return value
            }
        
        try await contract.testValue(until: { $0 == 10000 }) {
            (0...10000).forEach {
                contract0.resolve($0)
            }
            promise0.resolve(())
        }
        
        #expect(actual.value == expect)
    }
    
    @Test
    func test__then_schedule_sync_throw() async {
        let expect = (0...10000).compactMap { $0 % 2 == 0 ? $0 : nil }
        
        let contract0 = Contract<Int, Never>()
        let promise0 = Promise<Void, Never>()
        
        let completed = AsyncLatch()
        let actual = LockedBox<[Int]>([])
        let contract = contract0
            .then(schedule: .sync) { value in
                promise0.then { _ in
                    if value % 2 == 0 {
                        return value
                    }
                    else {
                        throw ContractTest.SampleError.one
                    }
                }
            }
            .then { value in
                let isComplete = actual.withValue {
                    $0.append(value)
                    return $0.count == expect.count
                }
                if isComplete {
                    completed.signal()
                }
                return value
            }
        
        (0...10000).forEach {
            contract0.resolve($0)
        }
        promise0.resolve(())
        #expect(await completed.wait(timeout: .seconds(1)))
        withExtendedLifetime(contract) {}
        
        #expect(actual.value == expect)
    }

}

private func canceledPromise<Value, Failure>() -> Promise<Value, Failure> {
    let pending = Promise<Value, Failure>.pending()
    pending.cancel()
    return pending.promise
}
