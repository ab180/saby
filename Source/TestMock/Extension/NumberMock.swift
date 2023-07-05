//
//  NumberMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Double: Mockable {
    public static func mock() -> Double {
        0.0
    }
}

extension Float: Mockable {
    public static func mock() -> Float {
        0.0
    }
}

extension Int64: Mockable {
    public static func mock() -> Int64 {
        0
    }
}

extension Int32: Mockable {
    public static func mock() -> Int32 {
        0
    }
}

extension Int16: Mockable {
    public static func mock() -> Int16 {
        0
    }
}

extension Int8: Mockable {
    public static func mock() -> Int8 {
        0
    }
}

extension Int: Mockable {
    public static func mock() -> Int {
        0
    }
}

extension UInt64: Mockable {
    public static func mock() -> UInt64 {
        0
    }
}

extension UInt32: Mockable {
    public static func mock() -> UInt32 {
        0
    }
}

extension UInt16: Mockable {
    public static func mock() -> UInt16 {
        0
    }
}

extension UInt8: Mockable {
    public static func mock() -> UInt8 {
        0
    }
}

extension UInt: Mockable {
    public static func mock() -> UInt {
        0
    }
}
