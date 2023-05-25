//
//  CoreDataArrayStorageManualTest.swift
//  SabyAppleStorageTest
//
//  Created by MinJae on 12/2/22.
//
//

import XCTest
import CoreData
import SabyConcurrency
@testable import SabyAppleStorage

struct Value: Codable {}

class CoreDataArrayStorageManualTest: XCTestCase {
    func testManagingProgramically() {
        let storage = CoreDataArrayStorage<Value>(name: "name")

        let expectation = self.expectation(description: "testManagingProgramically")
        expectation.expectedFulfillmentCount = 1

        let value = Value()

        var count = 0
        Promise.async {
            storage.get(limit: .unlimited)
        }.then {
            count = $0.count
            return storage.add(value)
        }.then { _ in
            storage.save()
        }.then {
            storage.get(limit: .unlimited)
        }.then {
            XCTAssertEqual($0.count, count + 1)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5)
    }
}
