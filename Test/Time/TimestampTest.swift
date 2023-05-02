//
//  TimestampTest.swift
//  SabyTimeTest
//
//  Created by WOF on 2023/04/27.
//

import XCTest
@testable import SabyTime

final class TimestampTest: XCTestCase {
    func test__now_create() {
        XCTAssertEqual(
            Int(Timestamp.now().secondFrom1970),
            Int(Date().timeIntervalSince1970)
        )
    }
    
    func test__second_from_1970_create() {
        XCTAssertEqual(
            Timestamp(secondFrom1970: 100).secondFrom1970,
            Date(timeIntervalSince1970: 100).timeIntervalSince1970
        )
    }
    
    func test__second_from_1970() {
        XCTAssertEqual(Timestamp(secondFrom1970: 8640000).secondFrom1970, 8640000)
    }
    
    func test__minute_from_1970() {
        XCTAssertEqual(Timestamp(secondFrom1970: 8640000).minuteFrom1970, 144000)
    }
    
    func test__hour_from_1970() {
        XCTAssertEqual(Timestamp(secondFrom1970: 8640000).hourFrom1970, 2400)
    }
    
    func test__day_from_1970() {
        XCTAssertEqual(Timestamp(secondFrom1970: 8640000).dayFrom1970, 100)
    }
    
    func test__time_from_1970() {
        XCTAssertEqual(Timestamp(secondFrom1970: 100).timeFrom1970, 100)
    }
}
