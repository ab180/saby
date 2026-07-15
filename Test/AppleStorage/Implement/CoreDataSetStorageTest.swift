//
//  CoreDataSetStorageTest.swift
//  SabyAppleStorageTest
//

import XCTest
@testable import SabyAppleStorage

private struct SetValue: Codable, Hashable {
    let id: Int
}

final class CoreDataSetStorageTest: XCTestCase {
    private var storage: CoreDataSetStorage<SetValue>!

    override func setUpWithError() throws {
        storage = CoreDataSetStorage(
            directoryURL: FileManager.default.temporaryDirectory,
            storageName: "\(UUID())"
        )
    }

    override func tearDownWithError() throws {
        try storage.clear().wait()
    }

    func test__set_replaces_existing_values() throws {
        try storage.set([SetValue(id: 0), SetValue(id: 1)]).wait()

        let expected: Set<SetValue> = [SetValue(id: 2), SetValue(id: 3)]
        try storage.set(expected).wait()

        XCTAssertEqual(try storage.get().wait(), expected)
        XCTAssertEqual(try storage.count().wait(), expected.count)
    }

    func test__set_empty_clears_existing_values() throws {
        try storage.set([SetValue(id: 0)]).wait()

        try storage.set([]).wait()

        XCTAssertEqual(try storage.get().wait(), [])
        XCTAssertEqual(try storage.count().wait(), 0)
        XCTAssertEqual(try storage.size().wait().byte, 0)
    }

    func test__set_and_get_100_000_values() throws {
        let expected = Set((0 ..< 100_000).map(SetValue.init(id:)))

        try storage.set(expected).wait()
        let actual = try storage.get().wait()

        XCTAssertEqual(actual, expected)
        XCTAssertEqual(try storage.count().wait(), expected.count)
    }
}
