//
//  DataMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/20.
//

import Foundation

extension Data: Mockable {
    public static func mock() -> Data {
        Data()
    }
}
