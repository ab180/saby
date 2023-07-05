//
//  DictionaryMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Dictionary: Mockable {
    public static func mock() -> Dictionary {
        [:]
    }
}
