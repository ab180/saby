//
//  ThenTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/02.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseThenTest {
    @Test
    func test__then_return_void() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value in
            #expect(value == 10)
            end.signal()
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .resolved({ $0 == () }), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_void_throw_error() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value in
            #expect(value == 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_void_from_reject() async {
        let promise =
        PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value in
            Issue.record()
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_value() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Int in
            #expect(value == 10)
            end.signal()
            
            return 20
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_value_throw_error() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Int in
            #expect(value == 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_value_from_reject() async {
        let promise =
        PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value -> Int in
            Issue.record()
            
            return 20
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_promise() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Promise<Int, Error> in
            #expect(value == 10)
            end.signal()
            
            return PromiseTest.make {
                20
            }
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_promise_throw_error() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Promise<Int, Error> in
            #expect(value == 10)
            end.signal()
            
            throw PromiseTest.SampleError.one
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_rejected_promise() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Promise<Int, Error> in
            #expect(value == 10)
            end.signal()
            
            return Promise<Int, Error>.rejected(
                PromiseTest.SampleError.one
            )
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_promise_cancel() async {
        let end = AsyncLatch()
        let pending = Promise<Int, Error>.pending()
        let thenPromise = Promise<Void, Error>.pending().promise

        let promise0 = pending.promise
        let promise1 = promise0.then { _ in
            pending.cancel()
            end.signal()
            return thenPromise
        }

        pending.resolve(10)
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise1, state: .pending, timeout: .seconds(1))
        await PromiseTest.expect(promise: thenPromise, state: .pending, timeout: .seconds(1))
    }
    
    @Test
    func test__then_return_promise_from_reject() async {
        let promise =
        PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }.then { value -> Promise<Int, Error> in
            Issue.record()
            
            return PromiseTest.make {
                20
            }
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_value() async {
        let promise =
        PromiseTest.make {
            10
        }.then {
            $0 + 10
        }
        
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_throw_error() async {
        let promise =
        PromiseTest.make {
            10
        }.then { value -> Promise<Int, Error> in
            throw PromiseTest.SampleError.one
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_resolved_promise() async {
        let promise =
        PromiseTest.make {
            10
        }.then {
            Promise<Int, Error>.resolved($0 + 10)
        }
        
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_rejected_promise() async {
        let promise =
        PromiseTest.make {
            10
        }.then { _ in
            Promise<Int, Error>.rejected(PromiseTest.SampleError.one)
        }
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_canceled_promise() async {
        let promise =
        PromiseTest.make {
            10
        }.then { _ in
            PromiseTest.canceled() as Promise<Int, Never>
        }
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_resolved_never_promise() async {
        let promise =
        PromiseTest.make {
            10
        }.then {
            Promise<Int, Never>.resolved($0 + 10)
        }
        
        await PromiseTest.expect(promise: promise, state: .resolved(20), timeout: .seconds(1))
    }
    
    @Test
    func test__never_then_return_canceled_never_promise() async {
        let promise =
        PromiseTest.make {
            10
        }.then { _ in
            PromiseTest.canceled() as Promise<Int, Never>
        }
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
