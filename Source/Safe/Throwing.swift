//
//  Throwing.swift
//  SabySafe
//
//  Created by 0xwof on 2022/08/08.
//

import Foundation

public func throwing<Result>(_ error: Error = ThrowingError()) throws -> Result {
    throw error
}

public struct ThrowingError: Error {
    public init() {}
}
