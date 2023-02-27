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
        var value = 0
        
        let promise =
        Promise.try(count: 5) {
            Promise {
                if (value < 3) {
                    value += 1
                    throw PromiseTest.SampleError.one
                }
                
                return value
            }
        }
        
        PromiseTest.expect(promise: promise, state: .resolved(3), timeout: .seconds(1))
    }
    
    func test__try_error() {
        var value = 0
        
        let promise =
        Promise.try(count: 3) {
            Promise {
                if (value < 5) {
                    value += 1
                    throw PromiseTest.SampleError.one
                }
                
                return value
            }
        }
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
