//
//  AtomicTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import XCTest
@testable import SabyConcurrency

final class AtomicTest: XCTestCase {
    func test__init() {
        let atomic = Atomic<Int>(10)
            
        XCTAssertEqual(atomic.capture, 10)
    }
    
    func test__capture() {
        let atomic = Atomic([1, 2, 3])
            
        XCTAssertEqual(atomic.capture, [1, 2, 3])
    }
    
    func test__use() {
        let atomic = Atomic([1, 2, 3])
            
        atomic.use { array in
            XCTAssertEqual(array, [1, 2, 3])
        }
    }
    
    func test__mutate() {
        let end = DispatchSemaphore(value: 0)
        
        let atomic = Atomic<Int>(0)
            
        let queue = DispatchQueue.global()
        let token = DispatchGroup()
        
        for _ in 0..<10000 {
            token.enter()
            queue.async {
                atomic.mutate { $0 += 1 }
                token.leave()
            }
        }
        
        token.notify(queue: queue) {
            XCTAssertEqual(atomic.capture, 10000)
            end.signal()
        }
        
        AtomicTest.expect(semaphore: end, timeout: .seconds(1))
    }
}
