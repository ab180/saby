//
//  IntervalTest.swift
//  SabyTimeTest
//
//  Created by 0xwof on 2022/08/19.
//

import XCTest
@testable import SabyTime

final class IntervalTest: XCTestCase {
    func test__millisecond_create() {
        XCTAssertEqual(Interval.millisecond(100), Interval(second: 0.1))
    }
    
    func test__second_create() {
        XCTAssertEqual(Interval.second(100), Interval(second: 100))
    }
    
    func test__minute_create() {
        XCTAssertEqual(Interval.minute(100), Interval(second: 6000))
    }
    
    func test__hour_create() {
        XCTAssertEqual(Interval.hour(100), Interval(second: 360000))
    }
    
    func test__day_create() {
        XCTAssertEqual(Interval.day(100), Interval(second: 8640000))
    }
    
    func test__millisecond() {
        XCTAssertEqual(Interval(second: 8640000).millisecond, 8640000000)
    }
    
    func test__second() {
        XCTAssertEqual(Interval(second: 8640000).second, 8640000)
    }
    
    func test__minute() {
        XCTAssertEqual(Interval(second: 8640000).minute, 144000)
    }
    
    func test__hour() {
        XCTAssertEqual(Interval(second: 8640000).hour, 2400)
    }
    
    func test__day() {
        XCTAssertEqual(Interval(second: 8640000).day, 100)
    }
    
    func test__time() {
        XCTAssertEqual(Interval(second: 100).time, 100)
    }
    
    func test__dispatch_time() {
        XCTAssertEqual(Interval(second: 8640000).dispatchTime, .seconds(8640000))
    }
}
