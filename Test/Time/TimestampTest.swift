//
//  TimestampTest.swift
//  SabyTimeTest
//
//  Created by WOF on 2023/04/27.
//

import Foundation
import Testing
@testable import SabyTime

@Suite
struct TimestampTest {
    @Test func nowCreate() {
        #expect(Int(Timestamp.now().secondFrom1970) == Int(Date().timeIntervalSince1970))
    }
    
    @Test func secondFrom1970Create() {
        #expect(
            Timestamp(secondFrom1970: 100).secondFrom1970
                == Date(timeIntervalSince1970: 100).timeIntervalSince1970
        )
    }
    
    @Test func secondFrom1970() {
        #expect(Timestamp(secondFrom1970: 8640000).secondFrom1970 == 8640000)
    }
    
    @Test func timeFrom1970() {
        #expect(Timestamp(secondFrom1970: 100).timeFrom1970 == 100)
    }
}
