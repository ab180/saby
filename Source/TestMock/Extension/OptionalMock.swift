//
//  OptionalMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

extension Optional: Mockable {
    public static func mock() -> Self {
        nil
    }
}
