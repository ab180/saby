//
//  JSON.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/11.
//

import Foundation

public enum JSON: Equatable {
    case number(Double)
    case boolean(Bool)
    case string(String)
    case object([String: JSON])
    case array([JSON])
    case null
}
