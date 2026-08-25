//
//  IntervalTest.swift
//  SabyTimeTest
//
//  Created by WOF on 2022/08/19.
//

import Dispatch
import Testing
@testable import SabyTime

@Suite
struct IntervalTest {
    @Test func millisecondCreate() {
        #expect(Interval.millisecond(100) == Interval(second: 0.1))
    }
    
    @Test func secondCreate() {
        #expect(Interval.second(100) == Interval(second: 100))
    }
    
    @Test func minuteCreate() {
        #expect(Interval.minute(100) == Interval(second: 6000))
    }
    
    @Test func hourCreate() {
        #expect(Interval.hour(100) == Interval(second: 360000))
    }
    
    @Test func dayCreate() {
        #expect(Interval.day(100) == Interval(second: 8640000))
    }
    
    @Test func millisecond() {
        #expect(Interval(second: 8640000).millisecond == 8640000000)
    }
    
    @Test func second() {
        #expect(Interval(second: 8640000).second == 8640000)
    }
    
    @Test func day() {
        #expect(Interval(second: 8640000).day == 100)
    }
    
    @Test func time() {
        #expect(Interval(second: 100).time == 100)
    }
    
    @Test func dispatchTime() {
        #expect(Interval(second: 8640000).dispatchTime == .seconds(8640000))
    }
}
