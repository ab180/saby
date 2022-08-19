//
//  JSONDescription.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/17.
//

import Foundation

extension JSON: CustomDebugStringConvertible {
    public var debugDescription: String {
        "JSON(\((try? self.stringify(format: .prettyPrinted)) ?? "value is not stringifiable"))"
    }
}
