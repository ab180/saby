//
//  ArrayMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Array: Mockable {
    public static func mock() -> Array {
        []
    }
}
