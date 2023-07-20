//
//  URLMock.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/20.
//

import Foundation

extension URL: Mockable {
    public static func mock() -> URL {
        URL(string: "scheme://")!
    }
}
