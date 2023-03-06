//
//  Hex.swift
//  SabyEncode
//
//  Created by WOF on 2023/02/27.
//

import Foundation

public enum Hex: Encode {
    public static func encode(data: Data) -> String {
        data.reduce("") { $0 + String(format: "%02x", $1) }
    }
}
