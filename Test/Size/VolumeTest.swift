//
//  VolumeTest.swift
//  SabySizeTest
//
//  Created by WOF on 2023/06/12.
//

import XCTest
@testable import SabySize

final class VolumeTest: XCTestCase {
    func test__byte_create() {
        XCTAssertEqual(Volume.byte(1), Volume(byte: 1))
    }
    
    func test__kibibyte_create() {
        XCTAssertEqual(Volume.kibibyte(1), Volume(byte: 1024))
    }
    
    func test__mebibyte_create() {
        XCTAssertEqual(Volume.mebibyte(1), Volume(byte: 1048576))
    }
    
    func test__gibibyte_create() {
        XCTAssertEqual(Volume.gibibyte(1), Volume(byte: 1073741824))
    }
    
    func test__tebibyte_create() {
        XCTAssertEqual(Volume.tebibyte(1), Volume(byte: 1099511627776))
    }
    
    func test__byte() {
        XCTAssertEqual(Volume(byte: 1099511627776).byte, 1099511627776)
    }
    
    func test__kibibyte() {
        XCTAssertEqual(Volume(byte: 1099511627776).kibibyte, 1073741824)
    }
    
    func test__mebibyte() {
        XCTAssertEqual(Volume(byte: 1099511627776).mebibyte, 1048576)
    }
    
    func test__gibibyte() {
        XCTAssertEqual(Volume(byte: 1099511627776).gibibyte, 1024)
    }
    
    func test__tebibyte() {
        XCTAssertEqual(Volume(byte: 1099511627776).tebibyte, 1)
    }
}
