//
//  Mockable.swift
//  SabyTestMock
//
//  Created by WOF on 2023/07/05.
//

import Foundation

import SabyConcurrency

public protocol Mockable {
    static func mock() -> Self
}

extension Promise: Mockable where Value: Mockable {
    public static func mock() -> Promise<Value, Failure> {
        return Promise<Value, Failure>.resolved(Value.mock())
    }
}
