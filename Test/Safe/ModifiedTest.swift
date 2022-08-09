//
//  ModifiedTest.swift
//  SabySafeTest
//
//  Created by WOF on 2022/08/09.
//

import XCTest
@testable import SabySafe

final class ModifiedTest: XCTestCase {
    func test__dictionary() {
        XCTAssertEqual(modified([:]) { $0["key"] = "value" }, [ "key": "value" ])
    }
}
