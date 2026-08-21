//
//  PromiseTryTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2023/02/03.
//

import Foundation

import XCTest
@testable import SabyConcurrency

final class PromiseTryTest: XCTestCase {
    func test__try() {
        let counter = PromiseTryCounter()
        
        let promise =
        Promise.try(count: 5) {
            let pending = Promise<Int, Error>.pending()

            Task {
                do {
                    pending.resolve(try await counter.increment(until: 3))
                }
                catch {
                    pending.reject(error)
                }
            }

            return pending.promise
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(3), timeout: .seconds(1))
    }
    
    func test__try_error() {
        let counter = PromiseTryCounter()
        
        let promise =
        Promise.try(count: 3) {
            let pending = Promise<Int, Error>.pending()

            Task {
                do {
                    pending.resolve(try await counter.increment(until: 5))
                }
                catch {
                    pending.reject(error)
                }
            }

            return pending.promise
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}

private actor PromiseTryCounter {
    private var value = 0

    func increment(until limit: Int) throws -> Int {
        if value < limit {
            value += 1
            throw PromiseTest.SampleError.one
        }

        return value
    }
}
