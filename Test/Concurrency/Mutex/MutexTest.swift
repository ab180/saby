//
//  MutexTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2022/08/25.
//

import XCTest
@testable import SabyConcurrency

final class MutexTest: XCTestCase {
    func test__lock() {
        let end = DispatchSemaphore(value: 0)
        
        let mutex = Mutex()
        var value = 0
            
        let queue = DispatchQueue.global()
        let token = DispatchGroup()
        
        for _ in 0..<10000 {
            token.enter()
            queue.async {
                mutex.run { value += 1 }
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
