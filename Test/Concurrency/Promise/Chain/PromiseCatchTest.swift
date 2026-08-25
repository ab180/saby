//
//  CatchTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseCatchTest {
    @Test
    func test__catch_from_reject() async {
        let end = AsyncLatch()
        
        let promise =
        PromiseTest.make { () -> Int in
            throw PromiseTest.SampleError.one
        }
        .catch { error in
            #expect(error as? PromiseTest.SampleError == PromiseTest.SampleError.one)
            end.signal()
        }
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__catch_cancel() async {
        let end = AsyncLatch()
        let pending = Promise<Int, Error>.pending()

        let promise0 = pending.promise
        let promise1 = promise0.catch { error in
            pending.cancel()
            end.signal()
        }

        pending.reject(PromiseTest.SampleError.one)
        
        #expect(await end.wait(timeout: .seconds(1)))
        await PromiseTest.expect(promise: promise1, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
