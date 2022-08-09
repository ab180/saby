//
//  OptTry.swift
//  SabySafe
//
//  Created by WOF on 2022/08/08.
//

import Foundation

public func optTry<Result>(block: () throws -> Result) -> Result? {
    try? block()
}
