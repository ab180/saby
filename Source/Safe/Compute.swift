//
//  Compute.swift
//  SabySafe
//
//  Created by WOF on 2022/08/08.
//

import Foundation

public func compute<Result>(
    _ block: () -> Result
) -> Result {
    return block()
}

