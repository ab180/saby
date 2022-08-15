//
//  JSONError.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON {
    public enum InternalError: Error {
        case decodedValueIsNotJSON
        case stringToDataIsNil
        case dataToStringIsNil
        case valueIsNotJSON
    }
}
