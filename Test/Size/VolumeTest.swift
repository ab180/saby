//
//  VolumeTest.swift
//  SabySizeTest
//
//  Created by WOF on 2023/06/12.
//

import Testing
@testable import SabySize

@Suite
struct VolumeTest {
    @Test func byteCreate() {
        #expect(Volume.byte(1) == Volume(byte: 1))
    }
    
    @Test func mebibyteCreate() {
        #expect(Volume.mebibyte(1) == Volume(byte: 1048576))
    }
    
    @Test func gibibyteCreate() {
        #expect(Volume.gibibyte(1) == Volume(byte: 1073741824))
    }
    
    @Test func tebibyteCreate() {
        #expect(Volume.tebibyte(1) == Volume(byte: 1099511627776))
    }
    
    @Test func byte() {
        #expect(Volume(byte: 1099511627776).byte == 1099511627776)
    }
    
    @Test func gibibyte() {
        #expect(Volume(byte: 1099511627776).gibibyte == 1024)
    }
    
}
