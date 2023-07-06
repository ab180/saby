//
//  DictionaryMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Dictionary: Mockable {
    public static func mock() -> Dictionary {
        if
            let keyType = Key.self as? Mockable.Type,
            let valueType = Value.self as? Mockable.Type
        {
            return [keyType.mock() as! Key: valueType.mock() as! Value]
        }
        else {
            return [:]
        }
    }
}
