//
//  NumericApplyTest.swift
//  SabyNumericTest
//
//  Created by WOF on 2022/08/19.
//

import Testing
@testable import SabyNumeric

@Suite
struct NumericApplyTest {
    @Test func appliedLimitClosedRange() {
        #expect((100).applied(limit: 0...200) == 100)
        #expect((-100).applied(limit: 0...200) == 0)
        #expect((300).applied(limit: 0...200) == 200)
    }
    
    @Test func appliedLimitMinimumMaximum() {
        #expect((100).applied(minimum: 0, maximum: 200) == 100)
        #expect((-100).applied(minimum: 0, maximum: 200) == 0)
        #expect((300).applied(minimum: 0, maximum: 200) == 200)
    }
    
    @Test func appliedLimitPartialRangeThrough() {
        #expect((100).applied(limit: ...200) == 100)
        #expect((300).applied(limit: ...200) == 200)
    }
    
    @Test func appliedLimitMaximum() {
        #expect((100).applied(maximum: 200) == 100)
        #expect((300).applied(maximum: 200) == 200)
    }
    
    @Test func appliedLimitPartialRangeFrom() {
        #expect((100).applied(limit: 0...) == 100)
        #expect((-100).applied(limit: 0...) == 0)
    }
    
    @Test func appliedLimitMinimum() {
        #expect((100).applied(minimum: 0) == 100)
        #expect((-100).applied(minimum: 0) == 0)
    }
}
