//
//  AllTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import XCTest
@testable import SabyConcurrency

final class PromiseAllTest: XCTestCase {
    func test__all_same_2() {
        let promise =
        Promise.all([
            Promise.async {
                10
            },
            Promise.async {
                20
            }
        ])
        
        PromiseTest.expect(promise: promise, state: .resolved({$0 == [10, 20]}), timeout: .seconds(1))
    }
    
    func test__all_2() {
        let promise =
        Promise.all(
            Promise.async {
                10
            },
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true)}), timeout: .seconds(1))
    }
    
    func test__all_2_reject_1() {
        let promise =
        Promise.all(
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            },
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__all_2_cancel_1() {
        let promise =
        Promise.all(
            Promise<Int, Error>.canceled(),
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__all_3() {
        let promise =
        Promise.all(
            Promise.async {
                10
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            }
        )
        
        PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10")}), timeout: .seconds(1))
    }
    
    func test__all_3_reject_1() {
        let promise =
        Promise.all(
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            }
        )
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__all_3_cancel_1() {
        let promise =
        Promise.all(
            Promise<Int, Error>.canceled(),
            Promise.async {
                true
            },
            Promise.async {
                "10"
            }
        )
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__all_4() {
        let promise =
        Promise.all(
            Promise.async {
                10
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            }
        )
        
        PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10", 10)}), timeout: .seconds(1))
    }
    
    func test__all_4_reject_1() {
        let promise =
        Promise.all(
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            }
        )
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__all_4_cancel_1() {
        let promise =
        Promise.all(
            Promise<Int, Error>.canceled(),
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            }
        )
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__all_5() {
        let promise =
        Promise.all(
            Promise.async {
                10
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            },
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10", 10, true)}), timeout: .seconds(1))
    }
    
    func test__all_5_reject_1() {
        let promise =
        Promise.all(
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            },
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            },
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    func test__all_5_cancel_1() {
        let promise =
        Promise.all(
            Promise<Int, Error>.canceled(),
            Promise.async {
                true
            },
            Promise.async {
                "10"
            },
            Promise.async {
                10
            },
            Promise.async {
                true
            }
        )
        
        PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    func test__all_same_5_reject_1() {
        let promise =
        Promise.all([
            Promise.async { () -> Int in
                throw PromiseTest.SampleError.one
            },
            Promise.async {
                20
            },
            Promise.async {
                30
            },
            Promise.async {
                40
            },
            Promise.async {
                50
            }
        ])
        
        PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
