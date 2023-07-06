//
//  Mockable.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

public protocol Mockable {
    static func mock() -> Self
}
