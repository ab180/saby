//
//  LockTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/25.
//

import XCTest
@testable import SabyConcurrency

final class LockTest: XCTestCase {
    func test__lock() {
        let end = DispatchSemaphore(value: 0)
        
        let lock = Lock()
        var value = 0
            
        let queue = DispatchQueue.global()
        let token = DispatchGroup()
        
        for _ in 0..<10000 {
            token.enter()
            queue.async {
                lock.lock()
                value += 1
                lock.unlock()
                token.leave()
            }
        }
        
        token.notify(queue: queue) {
            XCTAssertEqual(value, 10000)
            end.signal()
        }
        
        let _ = end.wait(timeout: .now() + .seconds(1))
    }
}
