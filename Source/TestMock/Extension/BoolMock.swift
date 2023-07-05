//
//  BooleanMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Bool: Mockable {
    public static func mock() -> Bool {
        false
    }
}
