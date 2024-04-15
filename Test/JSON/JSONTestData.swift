//
//  JSONTestData.swift
//  SabyJSONTest
//
//  Created by WOF on 2022/08/15.
//

import Foundation

struct Codable0: Codable, Equatable {
    let a: String
    let b: Double
    let c: Null
}

struct Null: Codable, Equatable, ExpressibleByNilLiteral {
    init(nilLiteral: ()) {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let _ = container.decodeNil()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
