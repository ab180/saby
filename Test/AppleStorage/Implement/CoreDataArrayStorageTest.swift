//
//  CoreDataArrayStorageTest.swift
//  SabyAppleStorageTest
//
//  Created by MinJae on 12/2/22.
//
//

import XCTest
import CoreData
import SabyConcurrency
@testable import SabyAppleStorage

struct Value: Codable, KeyIdentifiable {
    let key: UUID
}

class CoreDataArrayStorageTest: XCTestCase {
    var storage: CoreDataArrayStorage<Value>!
    var encoder: JSONEncoder!
    
    override func setUpWithError() throws {
        storage = CoreDataArrayStorage(directoryURL: FileManager.default.temporaryDirectory, fileName: "\(UUID())")
        encoder = JSONEncoder()
    }
    
    override func tearDownWithError() throws {
        try storage.clear().wait()
    }
    
    func test__managing_programically() {
        let expectation = self.expectation(description: "testManagingProgramically")
        expectation.expectedFulfillmentCount = 1

        let value = Value(key: UUID())

        var count = 0
        Promise.async {
            self.storage.get(limit: .unlimited)
        }.then {
            count = $0.count
            return self.storage.add(value)
        }.then { _ in
            self.storage.save()
        }.then {
            self.storage.get(limit: .unlimited)
        }.then {
            XCTAssertEqual($0.count, count + 1)
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 5)
    }
    
    func test__length() throws {
        let given = [
            Value(key: UUID()),
            Value(key: UUID()),
            Value(key: UUID())
        ]
        let expect = given.count
        
        for value in given {
            _ = try self.storage.add(value).wait()
        }
        let count = try self.storage.count().wait()
        
        XCTAssertEqual(count, expect)
    }
    
    func test__size() throws {
        let given = [
            Value(key: UUID()),
            Value(key: UUID()),
            Value(key: UUID())
        ]
        let expect = Double(given.reduce(0) { $0 + (try! encoder.encode($1).count) })
        
        for value in given {
            _ = try self.storage.add(value).wait()
        }
        let size = try self.storage.size().wait()
        
        XCTAssertEqual(size.byte, expect)
    }
    
    func test__get_order_oldest() throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            Value(key: UUID())
        }
        let expects = givens
        
        for value in givens {
            _ = try storage.add(value).wait()
        }
        let values = try storage.get(limit: .unlimited, order: .oldest).wait()
        
        for (value, expect) in zip(values, expects) {
            XCTAssertEqual(value.key, expect.key)
        }
    }
    
    func test__get_order_newest() throws {
        let givens = Array(repeating: 0, count: 100).map { _ in
            Value(key: UUID())
        }
        let expects = givens.reversed()
        
        for value in givens {
            _ = try storage.add(value).wait()
        }
        let values = try storage.get(limit: .unlimited, order: .newest).wait()
        
        for (value, expect) in zip(values, expects) {
            XCTAssertEqual(value.key, expect.key)
        }
    }
}
