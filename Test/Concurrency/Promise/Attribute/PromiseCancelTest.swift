//
//  PromiseCancelTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2023/02/06.
//

import XCTest
@testable import SabyConcurrency

final class PromiseCancelTest: XCTestCase {
    func test__cancel() {
        let trigger = Promise<Void>.resolved(())
        
        let promise = Promise.cancel(when: trigger) {
            Promise<Void>()
        }
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
}
