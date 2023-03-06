//
//  Encode.swift
//  SabyEncode
//
//  Created by WOF on 2023/02/27.
//

import Foundation

public protocol Encode {
    static func encode(data: Data) -> String
}
