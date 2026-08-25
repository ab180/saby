//
//  AllTest.swift
//  SabyConcurrencyTest
//
//  Created by WOF on 2020/04/09.
//

import Foundation
import Testing
@testable import SabyConcurrency

@Suite(.serialized) struct PromiseAllTest {
    @Test
    func test__all_same_2() async {
        let promise =
        Promise.all([
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                20
            }
        ])
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == [10, 20]}), timeout: .seconds(1))
    }

    @Test
    func test__all_same_optional_nil() async {
        let promise = Promise.all([
            Promise<Int?, Never>.resolved(nil),
            Promise<Int?, Never>.resolved(10)
        ])

        await PromiseTest.expect(
            promise: promise,
            state: .resolved({ $0.count == 2 && $0[0] == nil && $0[1] == 10 }),
            timeout: .seconds(1)
        )
    }
    
    @Test
    func test__all_2() async {
        let promise =
        Promise.all(
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true)}), timeout: .seconds(1))
    }
    
    @Test
    func test__all_2_reject_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_2_cancel_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.canceled() as Promise<Int, Error>,
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__all_3() async {
        let promise =
        Promise.all(
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10")}), timeout: .seconds(1))
    }
    
    @Test
    func test__all_3_reject_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_3_cancel_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.canceled() as Promise<Int, Error>,
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__all_4() async {
        let promise =
        Promise.all(
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10", 10)}), timeout: .seconds(1))
    }
    
    @Test
    func test__all_4_reject_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_4_cancel_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.canceled() as Promise<Int, Error>,
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__all_5() async {
        let promise =
        Promise.all(
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10", 10, true)}), timeout: .seconds(1))
    }
    
    @Test
    func test__all_5_reject_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_5_cancel_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.canceled() as Promise<Int, Error>,
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__all_same_5_reject_1() async {
        let promise =
        Promise.all([
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                20
            },
            PromiseTest.make {
                30
            },
            PromiseTest.make {
                40
            },
            PromiseTest.make {
                50
            }
        ])
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_6() async {
        let promise =
        Promise.all(
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .resolved({$0 == (10, true, "10", 10, true, "10")}), timeout: .seconds(1))
    }
    
    @Test
    func test__all_6_reject_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
    
    @Test
    func test__all_6_cancel_1() async {
        let promise =
        Promise.tryAll(
            PromiseTest.canceled() as Promise<Int, Error>,
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            },
            PromiseTest.make {
                10
            },
            PromiseTest.make {
                true
            },
            PromiseTest.make {
                "10"
            }
        )
        
        await PromiseTest.expect(promise: promise, state: .canceled, timeout: .seconds(1))
    }
    
    @Test
    func test__all_same_6_reject_1() async {
        let promise =
        Promise.all([
            PromiseTest.make { () -> Int in
                throw PromiseTest.SampleError.one
            },
            PromiseTest.make {
                20
            },
            PromiseTest.make {
                30
            },
            PromiseTest.make {
                40
            },
            PromiseTest.make {
                50
            },
            PromiseTest.make {
                60
            }
        ])
        
        await PromiseTest.expect(promise: promise, state: .rejected(PromiseTest.SampleError.one), timeout: .seconds(1))
    }
}
