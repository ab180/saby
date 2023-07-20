//
//  UUIDMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/20.
//

import Foundation

extension UUID: Mockable {
    public static func mock() -> UUID {
        UUID()
    }
}
