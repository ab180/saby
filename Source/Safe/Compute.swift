//
//  Compute.swift
//  SabySafe
//
//  Created by 0xwof on 2022/08/08.
//

import Foundation

public func compute<Result>(
    _ block: () -> Result
) -> Result {
    return block()
}

