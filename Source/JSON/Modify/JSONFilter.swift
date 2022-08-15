//
//  JSONFilter.swift
//  SabyJSON
//
//  Created by WOF on 2022/08/12.
//

import Foundation

extension JSON {
    public func filter(_ condition: (JSON) -> Bool) -> JSON? {
        if case .object(let value) = self {
            let filteredValue = JSON.object(value.compactMapValues { $0.filter(condition) })
            let result = condition(filteredValue) ? filteredValue : (nil as JSON?)
            return result
        }
        else if case .array(let value) = self {
            let filteredValue = JSON.array(value.compactMap { $0.filter(condition) })
            let result = condition(filteredValue) ? filteredValue : (nil as JSON?)
            return result
        }
        else {
            let result = condition(self) ? self : (nil as JSON?)
            return result
        }
    }
}
