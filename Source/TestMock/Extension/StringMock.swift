//
//  StringMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension String: Mockable {
    public static func mock() -> String {
        ""
    }
}
